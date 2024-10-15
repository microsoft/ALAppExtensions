#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using System.Text;
using Microsoft.Inventory.Analysis;
using Microsoft.Inventory.Ledger;
using Microsoft.PowerBIReports;
using Microsoft.Purchases.PowerBIReports;
using System.TestLibraries.Security.AccessControl;

codeunit 139880 "PowerBI Purchases Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibERM: Codeunit "Library - ERM";
        LibPurch: Codeunit "Library - Purchase";
        LibInv: Codeunit "Library - Inventory";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestGetOutstandingPurchOrderLine()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] An outstanding purchase order with multiple lines exists
        LibPurch.CreatePurchaseOrder(PurchHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        Commit();

        // [WHEN] Get request for outstanding purchase order line is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Item Outstd.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('purchOrderNo eq ''%1''', PurchHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the outstanding purchase order information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        if PurchLine.FindSet() then
            repeat
                VerifyPurchOrderLine(Response, PurchHeader, PurchLine);
            until PurchLine.Next() = 0;
    end;

    [Test]
    procedure TestGetOutstandingPurchOrderLineOutsideFilter()
    var
        PurchHeader: Record "Purchase Header";
        PurchHeader2: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase lines exist outside of the query filter
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := LibUtility.GenerateRandomCode20(PurchHeader.FieldNo("No."), Database::"Purchase Header");
        PurchHeader.Insert();
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine."No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("No."), Database::"Purchase Line");
        PurchLine."Outstanding Qty. (Base)" := 1;
        PurchLine.Insert();

        PurchHeader2."Document Type" := PurchHeader2."Document Type"::Order;
        PurchHeader2."No." := LibUtility.GenerateRandomCode20(PurchHeader2.FieldNo("No."), Database::"Purchase Header");
        PurchHeader2.Insert();
        PurchLine."Document Type" := PurchHeader2."Document Type";
        PurchLine."Document No." := PurchHeader2."No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine."No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("No."), Database::"Purchase Line");
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine.Insert();

        Commit();

        // [WHEN] Get request for the purchase lines outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Item Outstd.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('purchOrderNo eq ''%1'' OR purchOrderNo eq ''%2''', PurchHeader."No.", PurchHeader2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the purchase line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    local procedure VerifyPurchOrderLine(Response: Text; PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.lineNo == %1)]', PurchLine."Line No.")), 'Purchase line not found.');
        Assert.AreEqual(Format(PurchHeader."No."), JsonMgt.GetValue('purchOrderNo'), 'Purchase order no does not match.');
        Assert.AreEqual(Format(PurchHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Purchase header document type does not match.');
        Assert.AreEqual(PurchHeader."Buy-from Vendor No.", JsonMgt.GetValue('vendorNo'), 'Purchase header vendor no does not match.');
        Assert.AreEqual(Format(PurchHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Purchase header order date does not match.');
        Assert.AreEqual(PurchHeader."Purchaser Code", JsonMgt.GetValue('purchaserCode'), 'Purchase header purchaser code does not match.');
        Assert.AreEqual(Format(PurchLine."Document Type"), JsonMgt.GetValue('purchaseLineDocumentType'), 'Purchase line document type does not match.');
        Assert.AreEqual(PurchLine."Document No.", JsonMgt.GetValue('documentNo'), 'Purchase line document no does not match.');
        Assert.AreEqual(PurchLine."No.", JsonMgt.GetValue('itemNo'), 'Purchase line item no does not match.');
        Assert.AreEqual(PurchLine."Location Code", JsonMgt.GetValue('locationCode'), 'Purchase line location code does not match.');
        Assert.AreEqual(Format(PurchLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Purchase line outstanding qty base does not match.');
        Assert.AreEqual(Format(PurchLine."Outstanding Amt. Ex. VAT (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingAmountLCY'), 'Purchase line outstanding amount lcy does not match.');
        Assert.AreEqual(Format(PurchLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Purchase line dimension set id does not match.');
    end;

    [Test]
    procedure TestGetPurchItemBudgetEntry()
    var
        ItemBudgetName: Record "Item Budget Name";
        ItemBudgetEntry: Record "Item Budget Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] An item budget entry exists
        LibERM.CreateItemBudgetName(ItemBudgetName, "Analysis Area Type"::Purchase);
        LibInv.CreateItemBudgetEntry(
            ItemBudgetEntry,
            ItemBudgetEntry."Analysis Area"::Purchase,
            ItemBudgetName.Name,
            WorkDate(),
            LibInv.CreateItemNo());
        Commit();

        // [WHEN] Get request for outstanding purchase order line is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Budget Entries - Purch.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('entryNo eq %1', ItemBudgetEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the item budget entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyItemBudgetEntry(Response, ItemBudgetEntry);
    end;

    local procedure VerifyItemBudgetEntry(Response: Text; ItemBudgetEntry: Record "Item Budget Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', ItemBudgetEntry."Entry No.")), 'Item budget entry not found.');
        Assert.AreEqual(ItemBudgetEntry."Budget Name", JsonMgt.GetValue('budgetName'), 'Item budget entry budget name does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry.Date, 0, 9), JsonMgt.GetValue('entryDate'), 'Item budget entry entry date does not match.');
        Assert.AreEqual(ItemBudgetEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item budget entry item no does not match.');
        Assert.AreEqual(ItemBudgetEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Item budget entry location code does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry."Source Type"), JsonMgt.GetValue('sourceType'), 'Item budget entry source type does not match.');
        Assert.AreEqual(ItemBudgetEntry."Source No.", JsonMgt.GetValue('sourceNo'), 'Item budget entry source no does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Item budget entry quantity does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry."Cost Amount" / 1.0, 0, 9), JsonMgt.GetValue('costAmount'), 'Item budget entry cost amount does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Item budget entry dimension set id does not match.');
    end;

    [Test]
    procedure TestGetPurchItemBudgetEntryOutsideFilter()
    var
        ItemBudgetEntry: Record "Item Budget Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Item budget entries exist outside of the query filter
        if ItemBudgetEntry.FindLast() then;
        ItemBudgetEntry."Entry No." += 1;
        ItemBudgetEntry.Init();
        ItemBudgetEntry."Analysis Area" := ItemBudgetEntry."Analysis Area"::Sales;
        ItemBudgetEntry.Insert();

        Commit();

        // [WHEN] Get request for the item budget entries outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Budget Entries - Purch.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('entryNo eq %1', ItemBudgetEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the item budget entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetPurchValueEntry()
    var
        PurchaseHeader: Record "Purchase Header";
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A purchase order is posted with item ledger entry and value entry
        LibPurch.CreatePurchaseOrder(PurchaseHeader);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Purchase Invoice");
        ValueEntry.SetRange("Document No.", LibPurch.PostPurchaseDocument(PurchaseHeader, true, true));
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.FindLast();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        Commit();

        // [WHEN] Get request for purchase value entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Value Entries - Purch.", '');
        LibGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response contains the purchase value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyPurchValueEntry(Response, PurchaseHeader, ValueEntry, ItemLedgerEntry);
    end;

    local procedure VerifyPurchValueEntry(Response: Text; PurchaseHeader: Record "Purchase Header"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemLedgerEntryNo == %1)]', ItemLedgerEntry."Entry No.")), 'Purchase item ledger entry not found.');
        Assert.AreEqual(PurchaseHeader."Buy-from Vendor No.", JsonMgt.GetValue('vendorNo'), 'Vendor no does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Value entry entry no does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Value entry entry type does not match.');
        Assert.AreEqual(ValueEntry."Document No.", JsonMgt.GetValue('documentNo'), 'Value entry document no does not match.');
        Assert.AreEqual(Format(ValueEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Value entry document type does not match.');
        Assert.AreEqual(Format(ValueEntry."Invoiced Quantity" / 1.0, 0, 9), JsonMgt.GetValue('invoicedQuantity'), 'Value entry invoiced quantity does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Value entry cost amount actual does not match.');
        Assert.AreEqual(ValueEntry."Source No.", JsonMgt.GetValue('vendorNo'), 'Value entry vendor no does not match.');
        Assert.AreEqual(Format(ValueEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Value entry posting date does not match.');
        Assert.AreEqual(ValueEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Value entry item no does not match.');
        Assert.AreEqual(ValueEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Value entry location code does not match.');
        Assert.AreEqual(Format(ValueEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Value entry dimension set id does not match.');
    end;

    [Test]
    procedure TestGetPurchValueEntryOutsideFilter()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Value entries exist outside of the query filter
        PermissionsMock.Assign('SUPER');
        if ItemLedgerEntry.FindLast() then;
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Entry No." += 1;
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
        ItemLedgerEntry.Insert();
        PermissionsMock.ClearAssignments();

        if ValueEntry.FindLast() then;
        ValueEntry."Entry No." += 1;
        ValueEntry.Init();
        ValueEntry."Item Ledger Entry Type" := ItemLedgerEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry.Insert();

        Commit();

        // [WHEN] Get request for the value entries outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Value Entries - Purch.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('itemLedgerEntryNo eq %1', ItemLedgerEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the value entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetReceivedNotInvoiced()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A purchase order with multiple lines is received but not invoiced
        LibPurch.CreatePurchaseOrder(PurchaseHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibPurch.PostPurchaseDocument(PurchaseHeader, true, false);
        Commit();

        // [WHEN] Get request for received not invoiced purchase order is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Item Received", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('purchaseOrderNo eq ''%1''', PurchaseHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the received not invoiced purchase order information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindSet() then
            repeat
                VerifyReceivedNotInvoiced(Response, PurchaseHeader, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure VerifyReceivedNotInvoiced(Response: Text; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.lineNo == %1)]', PurchaseLine."Line No.")), 'Purchase item ledger entry not found.');
        Assert.AreEqual(Format(PurchaseHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Purchase header document type does not match.');
        Assert.AreEqual(PurchaseHeader."Pay-to Vendor No.", JsonMgt.GetValue('vendorNo'), 'Purchase header vendor no does not match.');
        Assert.AreEqual(Format(PurchaseHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Purchase header order date does not match.');
        Assert.AreEqual(PurchaseHeader."Purchaser Code", JsonMgt.GetValue('purchaserCode'), 'Purchase header purchaser code does not match.');
        Assert.AreEqual(Format(PurchaseLine."Document Type"), JsonMgt.GetValue('purchaseLineDocumentType'), 'Purchase line document type does not match.');
        Assert.AreEqual(PurchaseLine."Document No.", JsonMgt.GetValue('documentNo'), 'Purchase line document no does not match.');
        Assert.AreEqual(Format(PurchaseLine."Line No."), JsonMgt.GetValue('lineNo'), 'Purchase line line no does not match.');
        Assert.AreEqual(PurchaseLine."No.", JsonMgt.GetValue('itemNo'), 'Purchase line item no does not match.');
        Assert.AreEqual(PurchaseLine."Location Code", JsonMgt.GetValue('locationCode'), 'Purchase line location code does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. Rcd. Not Invoiced (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyRcdNotInvoicedBase'), 'Purchase line qty received not invoiced base does not match.');
        Assert.AreEqual(Format(PurchaseLine."A. Rcd. Not Inv. Ex. VAT (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('amtRcdNotInvoicedLCY'), 'Purchase line amount received not invoiced lcy does not match.');
        Assert.AreEqual(Format(PurchaseLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Purchase line dimension set id does not match.');
    end;

    [Test]
    procedure TestGetReceivedNotInvoicedOutsideFilter()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase lines exist outside of the query filter
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader."No." := LibUtility.GenerateRandomCode20(PurchaseHeader.FieldNo("No."), Database::"Purchase Header");
        PurchaseHeader.Insert();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := LibUtility.GenerateRandomCode20(PurchaseLine.FieldNo("No."), Database::"Purchase Line");
        PurchaseLine."Qty. Rcd. Not Invoiced (Base)" := 1;
        PurchaseLine.Insert();

        PurchaseHeader2."Document Type" := PurchaseHeader2."Document Type"::Order;
        PurchaseHeader2."No." := LibUtility.GenerateRandomCode20(PurchaseHeader2.FieldNo("No."), Database::"Purchase Header");
        PurchaseHeader2.Insert();
        PurchaseLine."Document Type" := PurchaseHeader2."Document Type";
        PurchaseLine."Document No." := PurchaseHeader2."No.";
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := LibUtility.GenerateRandomCode20(PurchaseLine.FieldNo("No."), Database::"Purchase Line");
        PurchaseLine."Qty. Rcd. Not Invoiced (Base)" := 0;
        PurchaseLine.Insert();

        Commit();

        // [WHEN] Get request for the purchase lines outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purch. Lines - Item Received", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('purchaseOrderNo eq ''%1'' OR purchaseOrderNo eq ''%2''', PurchaseHeader."No.", PurchaseHeader2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the purchase line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    local procedure AssertZeroValueResponse(Response: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        Assert.IsTrue(JObject.ReadFrom(Response), 'Invalid response format.');
        Assert.IsTrue(JObject.Get('value', JToken), 'Value token not found.');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'Response contains data outside of the filter.');
    end;

    [Test]
    procedure TestGenerateItemPurchasesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Item Purch. Start Date" := Today();
        PBISetup."Item Purch. End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemPurchasesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Item Purch. Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Item Purch. Date Formula"));

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemPurchasesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Purchases Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemPurchasesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Purch. Load Date Type" := PBISetup."Item Purch. Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemPurchasesReportDateFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    local procedure RecreatePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then
            PBISetup.Delete();
        PBISetup.Init();
        PBISetup.Insert();
    end;
}

#pragma warning restore AA0247
#pragma warning restore AA0137
#pragma warning restore AA0217
#pragma warning restore AA0205
#pragma warning restore AA0210