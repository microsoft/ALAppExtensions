#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Inventory.Analysis;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Ledger;
using System.Text;
using Microsoft.Inventory.Item;
using Microsoft.PowerBIReports;
using Microsoft.Sales.PowerBIReports;
using System.TestLibraries.Security.AccessControl;

codeunit 139881 "PowerBI Sales Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibERM: Codeunit "Library - ERM";
        LibSales: Codeunit "Library - Sales";
        LibInv: Codeunit "Library - Inventory";
        LibRandom: Codeunit "Library - Random";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        IsInitialized: Boolean;
        ResponseEmptyErr: Label 'Response should not be empty.';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetItemBudget()
    var
        ItemBudgetName: Record "Item Budget Name";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] An item budget name exists
        LibERM.CreateItemBudgetName(ItemBudgetName, "Analysis Area Type"::Sales);
        Commit();

        // [WHEN] Get request for item budget name is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Budget Names", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('budgetName eq ''%1''', ItemBudgetName.Name));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the item budget name information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyItemBudget(Response, ItemBudgetName);
    end;

    local procedure VerifyItemBudget(Response: Text; ItemBudgetName: Record "Item Budget Name")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.budgetName == ''%1'')]', ItemBudgetName.Name)), 'Item budget name not found.');
        Assert.AreEqual(Format(ItemBudgetName."Analysis Area"), JsonMgt.GetValue('analysisArea'), 'Item Budget name analysis area does not match.');
        Assert.AreEqual(ItemBudgetName.Description, JsonMgt.GetValue('budgetDescription'), 'Item Budget name description does not match.');
    end;

    [Test]
    procedure TestGetOutstandingSalesOrderLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] An outstanding sales order with multiple lines exists
        LibSales.CreateSalesOrder(SalesHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        Commit();

        // [WHEN] Get request for outstanding sales order line is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Sales Line - Item Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('salesOrderNo eq ''%1''', SalesHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the outstanding sales order information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                VerifySalesOrderLine(Response, SalesHeader, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure VerifySalesOrderLine(Response: Text; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.lineNo == %1)]', SalesLine."Line No.")), 'Sales line not found.');
        Assert.AreEqual(Format(SalesHeader."No."), JsonMgt.GetValue('salesOrderNo'), 'Sales order no does not match.');
        Assert.AreEqual(Format(SalesHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Sales header document type does not match.');
        Assert.AreEqual(SalesHeader."Bill-to Customer No.", JsonMgt.GetValue('customerNo'), 'Sales header customer no does not match.');
        Assert.AreEqual(Format(SalesHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Sales header order date does not match.');
        Assert.AreEqual(SalesHeader."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Sales header salesperson code does not match.');
        Assert.AreEqual(Format(SalesLine."Document Type"), JsonMgt.GetValue('salesLineDocumentType'), 'Sales line document type does not match.');
        Assert.AreEqual(SalesLine."Document No.", JsonMgt.GetValue('documentNo'), 'Sales line document no does not match.');
        Assert.AreEqual(SalesLine."No.", JsonMgt.GetValue('itemNo'), 'Sales line item no does not match.');
        Assert.AreEqual(SalesLine."Location Code", JsonMgt.GetValue('locationCode'), 'Sales line location code does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Sales line outstanding qty base does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingAmountLCY'), 'Sales line outstanding amount lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Sales line unit cost lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Quantity" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQuantity'), 'Sales line outstanding quantity does not match.');
        Assert.AreEqual(Format(SalesLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Sales line dimension set id does not match.');
    end;

    [Test]
    procedure TestGetSalesItemBudgetEntry()
    var
        ItemBudgetName: Record "Item Budget Name";
        ItemBudgetEntry: Record "Item Budget Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] An item budget entry exists
        LibERM.CreateItemBudgetName(ItemBudgetName, "Analysis Area Type"::Sales);
        LibInv.CreateItemBudgetEntry(
            ItemBudgetEntry,
            ItemBudgetEntry."Analysis Area"::Sales,
            ItemBudgetName.Name,
            WorkDate(),
            LibInv.CreateItemNo());
        Commit();

        // [WHEN] Get request for outstanding sales order line is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Budget Entries - Sales", '');
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
        Assert.AreEqual(Format(ItemBudgetEntry."Sales Amount" / 1.0, 0, 9), JsonMgt.GetValue('salesAmount'), 'Item budget entry sales amount does not match.');
        Assert.AreEqual(Format(ItemBudgetEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Item budget entry dimension set id does not match.');
    end;

    [Test]
    procedure TestGetSalesValueEntry()
    var
        SalesHeader: Record "Sales Header";
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A sales order is posted with item ledger entry and value entry
        LibSales.CreateSalesOrder(SalesHeader);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document No.", LibSales.PostSalesDocument(SalesHeader, true, true));
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.FindLast();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        Commit();

        // [WHEN] Get request for sales value entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Value Entries - Sales", '');
        LibGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response contains the sales value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifySalesValueEntry(Response, SalesHeader, ValueEntry, ItemLedgerEntry);
    end;

    local procedure VerifySalesValueEntry(Response: Text; SalesHeader: Record "Sales Header"; ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemLedgerEntryNo == %1)]', ItemLedgerEntry."Entry No.")), 'Sales item ledger entry not found.');
        Assert.AreEqual(SalesHeader."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Salesperson code does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Value entry entry no does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Value entry entry type does not match.');
        Assert.AreEqual(ValueEntry."Document No.", JsonMgt.GetValue('documentNo'), 'Value entry document no does not match.');
        Assert.AreEqual(Format(ValueEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Value entry document type does not match.');
        Assert.AreEqual(Format(ValueEntry."Invoiced Quantity" / 1.0, 0, 9), JsonMgt.GetValue('invoicedQuantity'), 'Value entry invoiced quantity does not match.');
        Assert.AreEqual(Format(ValueEntry."Sales Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('salesAmountActual'), 'Value entry sales amount actual does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Value entry cost amount actual does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Non-Invtbl.)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountNonInvtbl'), 'Value entry cost amount non-invtbl does not match.');
        Assert.AreEqual(ValueEntry."Source No.", JsonMgt.GetValue('customerNo'), 'Value entry customer no does not match.');
        Assert.AreEqual(Format(ValueEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Value entry posting date does not match.');
        Assert.AreEqual(ValueEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Value entry item no does not match.');
        Assert.AreEqual(ValueEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Value entry location code does not match.');
        Assert.AreEqual(Format(ValueEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Value entry dimension set id does not match.');
    end;

    [Test]
    procedure TestGetShippedNotInvoiced()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A sales order with multiple lines is shipped but not invoiced
        LibSales.CreateSalesOrder(SalesHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibSales.PostSalesDocument(SalesHeader, true, false);
        Commit();

        // [WHEN] Get request for shipped not invoiced sales order is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Sales Line - Item Shipped", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('salesOrderNo eq ''%1''', SalesHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the shipped not invoiced sales order information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                VerifyShippedNotInvoiced(Response, SalesHeader, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure VerifyShippedNotInvoiced(Response: Text; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.lineNo == %1)]', SalesLine."Line No.")), 'Sales item ledger entry not found.');
        Assert.AreEqual(Format(SalesHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Sales header document type does not match.');
        Assert.AreEqual(SalesHeader."Bill-to Customer No.", JsonMgt.GetValue('customerNo'), 'Sales header customer no does not match.');
        Assert.AreEqual(Format(SalesHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Sales header order date does not match.');
        Assert.AreEqual(SalesHeader."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Sales header salesperson code does not match.');
        Assert.AreEqual(Format(SalesLine."Document Type"), JsonMgt.GetValue('salesLineDocumentType'), 'Sales line document type does not match.');
        Assert.AreEqual(SalesLine."Document No.", JsonMgt.GetValue('documentNo'), 'Sales line document no does not match.');
        Assert.AreEqual(Format(SalesLine."Line No."), JsonMgt.GetValue('lineNo'), 'Sales line line no does not match.');
        Assert.AreEqual(SalesLine."No.", JsonMgt.GetValue('itemNo'), 'Sales line item no does not match.');
        Assert.AreEqual(SalesLine."Location Code", JsonMgt.GetValue('locationCode'), 'Sales line location code does not match.');
        Assert.AreEqual(Format(SalesLine."Qty. Shipped Not Invd. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyShippedNotInvdBase'), 'Sales line qty shipped not invd base does not match.');
        Assert.AreEqual(Format(SalesLine."Shipped Not Inv. (LCY) No VAT" / 1.0, 0, 9), JsonMgt.GetValue('shippedNotInvoicedLCY'), 'Sales line shipped not invoiced lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Sales line unit cost lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Shipped Not Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('shippedNotInvoiced'), 'Sales line shipped not invoiced does not match.');
        Assert.AreEqual(Format(SalesLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Sales line dimension set id does not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Item Sales Start Date" := Today();
        PBISetup."Item Sales End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Item Sales Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Item Sales Date Formula"));

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Sales Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateItemSalesReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Item Sales Load Date Type" := PBISetup."Item Sales Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateItemSalesReportDateFilter();

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