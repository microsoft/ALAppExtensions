namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using System.Text;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Analysis;
using Microsoft.Inventory.Ledger;
using Microsoft.PowerBIReports;
using Microsoft.PowerBIReports.Test;
using System.TestLibraries.Security.AccessControl;
using Microsoft.Purchases.History;
using Microsoft.Projects.Resources.Resource;

codeunit 139880 "PowerBI Purchases Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibERM: Codeunit "Library - ERM";
        LibPurch: Codeunit "Library - Purchase";
        LibInv: Codeunit "Library - Inventory";
        LibRandom: Codeunit "Library - Random";
        LibResource: Codeunit "Library - Resource";
        LibJob: Codeunit "Library - Job";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBIAPIRequests: Codeunit "PowerBI API Requests";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        PowerBIAPIEndpoints: Enum "PowerBI API Endpoints";
        PowerBIFilterScenarios: Enum "PowerBI Filter Scenarios";
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Lines - Item Outstd.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'purchOrderNo eq ''' + Format(PurchHeader."No.") + '''');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Lines - Item Outstd.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'purchOrderNo eq ''' + PurchHeader."No." + ''' OR purchOrderNo eq ''' + PurchHeader2."No." + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(PurchLine."Line No.") + ')]'), 'Purchase line not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Item Budget Entries - Purch.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'entryNo eq ' + Format(ItemBudgetEntry."Entry No.") + '');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.entryNo == ' + Format(ItemBudgetEntry."Entry No.") + ')]'), 'Item budget entry not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Item Budget Entries - Purch.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'entryNo eq ' + Format(ItemBudgetEntry."Entry No.") + '');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the item budget entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetPurchValueEntryV2()
    var
        PurchaseHeader: Record "Purchase Header";
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A purchase order is posted with item ledger entry and value entry
        LibPurch.CreatePurchaseOrder(PurchaseHeader);
        PurchaseHeader.Validate("Payment Discount %", 3);
        PurchaseHeader.Modify();

        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Purchase Invoice");
        ValueEntry.SetRange("Document No.", LibPurch.PostPurchaseDocument(PurchaseHeader, true, true));
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.FindLast();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        Commit();

        // [WHEN] Get request for purchase value entry is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Value Entries");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'entryNo eq ' + Format(ValueEntry."Entry No.") + '');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the purchase value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyPurchValueEntryV2(Response, PurchaseHeader, ValueEntry, ItemLedgerEntry);
    end;

    local procedure VerifyPurchValueEntryV2(Response: Text; PurchaseHeader: Record "Purchase Header"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.itemLedgerEntryNo == ' + Format(ItemLedgerEntry."Entry No.") + ')]'), 'Purchase item ledger entry not found.');
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
        Assert.AreEqual(ValueEntry."Return Reason Code", JsonMgt.GetValue('returnReasonCode'), 'Value entry return reason code does not match.');
        Assert.AreEqual(ValueEntry."Job No.", JsonMgt.GetValue('projectNo'), 'Value entry project no. does not match.');
        Assert.AreEqual(ValueEntry.Adjustment ? 'True' : 'False', JsonMgt.GetValue('adjustment'), 'Value entry adjustment does not match.');
        Assert.AreEqual(Format(ValueEntry."Capacity Ledger Entry No." / 1.0, 0, 9), JsonMgt.GetValue('capacityLedgerEntryNo'), 'Value entry capacity ledger entry no. does not match.');
        Assert.AreEqual(Format(ValueEntry."Discount Amount" / 1.0, 0, 9), JsonMgt.GetValue('discountAmount'), 'Value entry discount amount does not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Entry No." / 1.0, 0, 9), JsonMgt.GetValue('itemLedgerEntryNo'), 'Item ledger entry no. does not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Entry Type"), JsonMgt.GetValue('itemLedgerEntryType'), 'Item ledger entry type does not match.');
    end;

    [Test]
    procedure TestGetPurchValueEntryV2OutsideFilter()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        Uri: Codeunit Uri;
        SequenceNoMgt: Codeunit "Sequence No. Mgt.";
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

        SequenceNoMgt.ClearState();

        // [WHEN] Get request for the value entries outside of the query filter is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Value Entries");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'itemLedgerEntryNo eq ' + Format(ItemLedgerEntry."Entry No.") + '');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Lines - Item Received");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'purchaseOrderNo eq ''' + Format(PurchaseHeader."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(PurchaseLine."Line No.") + ')]'), 'Purchase item ledger entry not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purch. Lines - Item Received");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'purchaseOrderNo eq ''' + Format(PurchaseHeader."No.") + ''' OR purchaseOrderNo eq ''' + Format(PurchaseHeader2."No.") + '''');
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Purchases Date");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemPurchasesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
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

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Item Purch. Date Formula")) + '..';

        // [WHEN] GenerateItemPurchasesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Purchases Date");

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemPurchasesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
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
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Purchases Date");

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

    [ConfirmHandler]
    procedure ConfirmPostResJournalLineHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        if (Question = 'Do you want to post the journal lines?') then
            Reply := true;
    end;

    [MessageHandler]
    procedure ConfirmPostingMessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(Message, 'The journal lines were successfully posted.', 'The purchase resource journal line was not posted.');
    end;

    [Test]
    procedure TestGetPurchaseLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Resource: Record Resource;
        Item: Record Item;
        Job: Record Job;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        GLAccountCode: Code[20];
    begin
        // [GIVEN] A purchase order with multiple lines for item, G/L account & resource.
        LibPurch.CreatePurchaseOrder(PurchaseHeader);
        PurchaseHeader."Posting Date" := WorkDate();
        PurchaseHeader.Modify();

        // Create setup data
        LibInv.CreateItemWithUnitPriceAndUnitCost(Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        GLAccountCode := LibERM.CreateGLAccountWithPurchSetup();
        LibResource.CreateResourceNew(Resource);
        LibJob.CreateJob(job);

        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibRandom.RandInt(10));
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountCode, LibRandom.RandInt(10));
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Resource, Resource."No.", LibRandom.RandInt(10));

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.ModifyAll("Requested Receipt Date", WorkDate());
        PurchaseLine.ModifyAll("Promised Receipt Date", WorkDate());
        PurchaseLine.ModifyAll("Job No.", Job."No.");
        Commit();

        // [WHEN] Get request for purchase lines
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purchase Lines");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'orderNo eq ''' + Format(PurchaseHeader."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains normalized purchase line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if PurchaseLine.FindSet() then
            repeat
                VerifyPurchaseLine(Response, PurchaseHeader, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure VerifyPurchaseLine(Response: Text; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(PurchaseLine."Line No.") + ')]'), 'Purchase line not found.');
        Assert.AreEqual(Format(PurchaseHeader."No."), JsonMgt.GetValue('orderNo'), 'Purchase order no does not match.');
        Assert.AreEqual(Format(PurchaseHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Purchase header document type does not match.');
        Assert.AreEqual(PurchaseHeader."Pay-to Vendor No.", JsonMgt.GetValue('payToVendorNo'), 'Purchase header pay-to vendor no does not match.');
        Assert.AreEqual(PurchaseHeader."Buy-from Vendor No.", JsonMgt.GetValue('buyFromVendorNo'), 'Purchase header buy-from vendor no does not match.');
        Assert.AreEqual(PurchaseHeader."Purchaser Code", JsonMgt.GetValue('purchaserCode'), 'Purchase header purchaser code does not match.');
        Assert.AreEqual(PurchaseHeader."Quote No.", JsonMgt.GetValue('quoteNo'), 'Purchase header quote no does not match.');
        Assert.AreEqual(Format(PurchaseHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Purchase header order date does not match.');
        Assert.AreEqual(Format(PurchaseHeader."Document Date", 0, 9), JsonMgt.GetValue('documentDate'), 'Purchase header document date does not match.');
        Assert.AreEqual(Format(PurchaseHeader."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Purchase header due date does not match.');
        Assert.AreEqual(PurchaseHeader."Campaign No.", JsonMgt.GetValue('campaignNo'), 'Purchase header campaign no does not match.');
        Assert.AreEqual(Format(PurchaseLine."Document Type"), JsonMgt.GetValue('purchaseLineDocumentType'), 'Purchase line document type does not match.');
        Assert.AreEqual(PurchaseLine."Document No.", JsonMgt.GetValue('documentNo'), 'Purchase line document no does not match.');
        Assert.AreEqual(Format(PurchaseLine."Line No."), JsonMgt.GetValue('lineNo'), 'Purchase line line no does not match.');
        Assert.AreEqual(PurchaseLine."No.", JsonMgt.GetValue('itemNo'), 'Purchase line item no does not match.');
        Assert.AreEqual(PurchaseLine."Location Code", JsonMgt.GetValue('locationCode'), 'Purchase line location code does not match.');
        Assert.AreEqual(Format(PurchaseLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Purchase line quantity base does not match.');
        Assert.AreEqual(Format(PurchaseLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Purchase line outstanding qty. base does not match.');
        Assert.AreEqual(Format(PurchaseLine."Outstanding Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingAmountLCY'), 'Purchase line outstanding amount (LCY) does not match.');
        Assert.AreEqual(Format(PurchaseLine."Amount" / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Purchase line amount does not match.');
        Assert.AreEqual(Format(PurchaseLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Purchase line unit cost (LCY) does not match.');
        Assert.AreEqual(Format(PurchaseLine."Outstanding Quantity" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQuantity'), 'Purchase line outstanding quantity does not match.');
        Assert.AreEqual(PurchaseLine."Return Reason Code", JsonMgt.GetValue('returnReasonCode'), 'Purchase line return reason code does not match.');
        Assert.AreEqual(Format(PurchaseLine."Planned Receipt Date", 0, 9), JsonMgt.GetValue('plannedReceiptDate'), 'Purchase line planned receipt date does not match.');
        Assert.AreEqual(Format(PurchaseLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Purchase line expected receipt date does not match.');
        Assert.AreEqual(Format(PurchaseLine."Promised Receipt Date", 0, 9), JsonMgt.GetValue('promisedReceiptDate'), 'Purchase line promised receipt date does not match.');
        Assert.AreEqual(Format(PurchaseLine."Requested Receipt Date", 0, 9), JsonMgt.GetValue('requestedReceiptDate'), 'Purchase line requested receipt date does not match.');
        Assert.AreEqual(Format(PurchaseLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Purchase line dimension set ID does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. Rcd. Not Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('qtyRcdNotInvd'), 'Purchase line qty. received not invoiced does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. Rcd. Not Invoiced (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyRcdNotInvdBase'), 'Purchase line qty. received not invoiced (base) does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. to Receive" / 1.0, 0, 9), JsonMgt.GetValue('qtyToReceive'), 'Purchase line qty. to receive does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. to Receive (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyToReceiveBase'), 'Purchase line qty. to receive (base) does not match.');
        Assert.AreEqual(Format(PurchaseLine."A. Rcd. Not Inv. Ex. VAT (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('amtRcdNotInvdExVATLCY'), 'Purchase line amount received not invoiced excl. VAT (LCY) does not match.');
        Assert.AreEqual(Format(PurchaseLine."Amt. Rcd. Not Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('amtRcdNotInvd'), 'Purchase line amount received not invoiced does not match.');
        Assert.AreEqual(Format(PurchaseLine."Amt. Rcd. Not Invoiced (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('amtRcdNotInvdLCY'), 'Purchase line amount received not invoiced (LCY) does not match.');
        Assert.AreEqual(Format(PurchaseLine."Quantity Received" / 1.0, 0, 9), JsonMgt.GetValue('qtyReceived'), 'Purchase line quantity received does not match.');
        Assert.AreEqual(Format(PurchaseLine."Qty. Received (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyReceivedBase'), 'Purchase line quantity received base does not match.');
        Assert.AreEqual(Format(PurchaseLine."Quantity Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('quantityInvoiced'), 'Purchase line quantity invoiced does not match.');
        Assert.AreEqual(Format(PurchaseLine.Type), JsonMgt.GetValue('type'), 'Purchase line type does not match.');
        Assert.AreEqual(Format(PurchaseLine.Description), JsonMgt.GetValue('description'), 'Purchase line description type does not match.');
        Assert.AreEqual(PurchaseLine."Job No.", JsonMgt.GetValue('projectNo'), 'Purchase project no. does not match.');
        Assert.AreEqual(Format(PurchaseLine."Prepmt. Amount Inv. (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('prepmtAmountInvLCY'), 'Purchase line prepmt. amount invoice (LCY) does not match.');
    end;

    [Test]
    procedure TestGetPurchaseInvoiceLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        Resource: Record Resource;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        GLAccountCode: Code[20];
        PurchInvoiceNo: Code[20];
    begin
        // [GIVEN] A purchase invoice with multiple lines for G/L and Resource
        LibPurch.CreatePurchaseInvoice(PurchaseHeader);

        GLAccountCode := LibERM.CreateGLAccountWithPurchSetup();
        LibResource.CreateResourceNew(Resource);

        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountCode, LibRandom.RandInt(10));
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Resource, Resource."No.", LibRandom.RandInt(10));

        PurchInvoiceNo := LibPurch.PostPurchaseDocument(PurchaseHeader, true, true);
        Commit();

        PurchInvHeader.Get(PurchInvoiceNo);

        // [WHEN] Get request for purchase invoice lines
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purchase Invoice Lines");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'documentNo eq ''' + Format(PurchInvHeader."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the posted purchase invoice information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Type, '%1|%2', PurchInvLine.Type::"G/L Account", PurchInvLine.Type::Resource);
        if PurchInvLine.FindSet() then
            repeat
                VerifyPurchaseInvoiceLine(Response, PurchInvHeader, PurchInvLine);
            until PurchInvLine.Next() = 0;
    end;

    local procedure VerifyPurchaseInvoiceLine(Response: Text; PurchInvHeader: Record "Purch. Inv. Header"; PurcInvLine: Record "Purch. Inv. Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(PurcInvLine."Line No.") + ')]'), 'Purchase invoice line not found.');

        // Purchase invoice line assertions
        Assert.AreEqual(Format(PurcInvLine."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Purchase invoice line posting date does not match.');
        Assert.AreEqual(Format(PurcInvLine.Type), JsonMgt.GetValue('type'), 'Purchase invoice line type does not match.');
        Assert.AreEqual(PurcInvLine.Description, JsonMgt.GetValue('description'), 'Purchase invoice line description does not match.');
        Assert.AreEqual(PurcInvLine."Document No.", JsonMgt.GetValue('documentNo'), 'Purchase invoice line document no. does not match.');
        Assert.AreEqual(Format(PurcInvLine."Line No." / 1.0, 0, 9), JsonMgt.GetValue('lineNo'), 'Purchase invoice line no. does not match.');
        Assert.AreEqual(PurcInvLine."No.", JsonMgt.GetValue('no'), 'Purchase invoice line no. does not match.');
        Assert.AreEqual(PurcInvLine."Location Code", JsonMgt.GetValue('locationCode'), 'Purchase invoice location code does not match.');
        Assert.AreEqual(Format(PurcInvLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Purchase invoice quantity base does not match.');
        Assert.AreEqual(Format(PurcInvLine.Amount / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Purchase invoice line amount does not match.');
        Assert.AreEqual(Format(PurcInvLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Purchase invoice line unit cost LCY does not match.');
        Assert.AreEqual(PurcInvLine."Return Reason Code", JsonMgt.GetValue('returnReasonCode'), 'Purchase invoice line return reason code does not match.');
        Assert.AreEqual(Format(PurcInvLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Purchase invoice line expected receipt date does not match.');
        Assert.AreEqual(Format(PurcInvLine."Dimension Set ID" / 1.0, 0, 9), JsonMgt.GetValue('dimensionSetID'), 'Purchase invoice line dimension set ID does not match.');
        Assert.AreEqual(PurcInvLine."Job No.", JsonMgt.GetValue('projectNo'), 'Purchase invoice line project no. does not match.');
        Assert.AreEqual(PurcInvLine."Pay-to Vendor No.", JsonMgt.GetValue('payToVendorNo'), 'Purchase invoice line pay-to vendor does not match.');
        Assert.AreEqual(PurcInvLine."Buy-from Vendor No.", JsonMgt.GetValue('buyFromVendorNo'), 'Purchase invoice line buy-from vendor does not match.');

        // Purchase invoice header assertions
        Assert.AreEqual(PurchInvHeader."No.", JsonMgt.GetValue('purchaseInvoiceDocumentNo'), 'Purchase invoice header no. does not match.');
        Assert.AreEqual(PurchInvHeader."Campaign No.", JsonMgt.GetValue('campaignNo'), 'Purchase invoice header campaign no. does not match.');
        Assert.AreEqual(PurchInvHeader."Purchaser Code", JsonMgt.GetValue('purchaserCode'), 'Purchase invoice header purchaser code does not match.');
        Assert.AreEqual(PurchInvHeader."Quote No.", JsonMgt.GetValue('quoteNo'), 'Purchase invoice header quote no. does not match.');
    end;

    [Test]
    procedure TestGetPurchaseCreditLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        Resource: Record Resource;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        GLAccountCode: Code[20];
        PurchCrMemoNo: Code[20];
    begin
        // [GIVEN] A purchase credit memo with multiple lines for G/L and Resource
        LibPurch.CreatePurchaseCreditMemo(PurchaseHeader);

        GLAccountCode := LibERM.CreateGLAccountWithPurchSetup();
        LibResource.CreateResourceNew(Resource);

        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountCode, LibRandom.RandInt(10));
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Resource, Resource."No.", LibRandom.RandInt(10));

        PurchCrMemoNo := LibPurch.PostPurchaseDocument(PurchaseHeader, true, true);
        Commit();

        PurchCrMemoHeader.Get(PurchCrMemoNo);

        // [WHEN] Get request for purchase credit lines
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Purchase Credit Lines");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'documentNo eq ''' + Format(PurchCrMemoHeader."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the posted purchase credit memo information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        PurchCrMemoLine.SetFilter(Type, '%1|%2', PurchCrMemoLine.Type::"G/L Account", PurchCrMemoLine.Type::Resource);
        if PurchCrMemoLine.FindSet() then
            repeat
                VerifyPurchaseCreditLine(Response, PurchCrMemoHeader, PurchCrMemoLine);
            until PurchCrMemoLine.Next() = 0;
    end;

    local procedure VerifyPurchaseCreditLine(Response: Text; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurcCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(PurcCrMemoLine."Line No.") + ')]'), 'Purchase credit memo line not found.');

        // Purchase credit memo line assertions
        Assert.AreEqual(Format(PurcCrMemoLine."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Purchase credit memo line posting date does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine.Type), JsonMgt.GetValue('type'), 'Purchase credit memo line type does not match.');
        Assert.AreEqual(PurcCrMemoLine.Description, JsonMgt.GetValue('description'), 'Purchase credit memo line description does not match.');
        Assert.AreEqual(PurcCrMemoLine."Document No.", JsonMgt.GetValue('documentNo'), 'Purchase credit memo line document no. does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine."Line No." / 1.0, 0, 9), JsonMgt.GetValue('lineNo'), 'Purchase credit memo line no. does not match.');
        Assert.AreEqual(PurcCrMemoLine."No.", JsonMgt.GetValue('no'), 'Purchase credit memo line no. does not match.');
        Assert.AreEqual(PurcCrMemoLine."Location Code", JsonMgt.GetValue('locationCode'), 'Purchase invoice location code does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Purchase invoice quantity base does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine.Amount / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Purchase credit memo line amount does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Purchase credit memo line unit cost LCY does not match.');
        Assert.AreEqual(PurcCrMemoLine."Return Reason Code", JsonMgt.GetValue('returnReasonCode'), 'Purchase credit memo line return reason code does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Purchase credit memo line expected receipt date does not match.');
        Assert.AreEqual(Format(PurcCrMemoLine."Dimension Set ID" / 1.0, 0, 9), JsonMgt.GetValue('dimensionSetID'), 'Purchase credit memo line dimension set ID does not match.');
        Assert.AreEqual(PurcCrMemoLine."Job No.", JsonMgt.GetValue('projectNo'), 'Purchase credit memo line project no. does not match.');
        Assert.AreEqual(PurcCrMemoLine."Pay-to Vendor No.", JsonMgt.GetValue('payToVendorNo'), 'Purchase credit memo line pay-to vendor does not match.');
        Assert.AreEqual(PurcCrMemoLine."Buy-from Vendor No.", JsonMgt.GetValue('buyFromVendorNo'), 'Purchase credit memo line buy-from vendor does not match.');

        // Purchase credit memo header assertions
        Assert.AreEqual(PurchCrMemoHeader."No.", JsonMgt.GetValue('purchaseCreditMemoDocumentNo'), 'Purchase credit memo header no. does not match.');
        Assert.AreEqual(PurchCrMemoHeader."Campaign No.", JsonMgt.GetValue('campaignNo'), 'Purchase credit memo header campaign no. does not match.');
        Assert.AreEqual(PurchCrMemoHeader."Purchaser Code", JsonMgt.GetValue('purchaserCode'), 'Purchase credit memo header purchaser code does not match.');
    end;
}
