namespace Microsoft.Finance.PowerBIReports.Test;

using Microsoft.CRM.Opportunity;
using Microsoft.Inventory.Analysis;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Sales.Document;
using Microsoft.PowerBIReports;
using Microsoft.PowerBIReports.Test;
using System.TestLibraries.Security.AccessControl;
using System.Text;
using System.Utilities;

codeunit 139881 "PowerBI Sales Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibERM: Codeunit "Library - ERM";
        LibSales: Codeunit "Library - Sales";
        LibInv: Codeunit "Library - Inventory";
        LibRandom: Codeunit "Library - Random";
        LibMarketing: Codeunit "Library - Marketing";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        PowerBIAPIRequests: Codeunit "PowerBI API Requests";
        PowerBIAPIEndpoints: Enum "PowerBI API Endpoints";
        PowerBIFilterScenarios: Enum "PowerBI Filter Scenarios";
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Item Budget Names");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'budgetName eq ''' + Format(ItemBudgetName.Name) + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.budgetName == ''' + Format(ItemBudgetName.Name) + ''')]'), 'Item budget name not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Sales Line - Item Outstanding");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'salesOrderNo eq ''' + Format(SalesHeader."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(SalesLine."Line No.") + ')]'), 'Sales line not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Item Budget Entries - Sales");
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Value Entries - Sales");
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.itemLedgerEntryNo == ' + Format(ItemLedgerEntry."Entry No.") + ')]'), 'Sales item ledger entry not found.');
        Assert.AreEqual(SalesHeader."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Salesperson code does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Value entry entry no does not match.');
        Assert.AreEqual(Format(ValueEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Value entry entry type does not match.');
        Assert.AreEqual(ValueEntry."Document No.", JsonMgt.GetValue('documentNo'), 'Value entry document no does not match.');
        Assert.AreEqual(Format(ValueEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Value entry document type does not match.');
        Assert.AreEqual(Format(ValueEntry."Invoiced Quantity" / 1.0, 0, 9), JsonMgt.GetValue('invoicedQuantity'), 'Value entry invoiced quantity does not match.');
        Assert.AreEqual(Format(ValueEntry."Sales Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('salesAmountActual'), 'Value entry sales amount actual does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Value entry cost amount actual does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Non-Invtbl.)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountNonInvtbl'), 'Value entry cost amount non-invtbl does not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Posted to G/L" / 1.0, 0, 9), JsonMgt.GetValue('costPostedToGL'), 'Value entry cost posted to G/L does not match.');
        Assert.AreEqual(ValueEntry."Source No.", JsonMgt.GetValue('customerNo'), 'Value entry customer no does not match.');
        Assert.AreEqual(Format(ValueEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Value entry posting date does not match.');
        Assert.AreEqual(Format(ValueEntry."Document Date", 0, 9), JsonMgt.GetValue('documentDate'), 'Value entry posting date does not match.');
        Assert.AreEqual(ValueEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Value entry item no does not match.');
        Assert.AreEqual(ValueEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Value entry location code does not match.');
        Assert.AreEqual(Format(ValueEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Value entry Dimension Set ID does not match.');
        Assert.AreEqual(Format(ValueEntry."Return Reason Code"), JsonMgt.GetValue('returnReasonCode'), 'Value entry return reason code does not match.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Sales Line - Item Shipped");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'salesOrderNo eq ''' + Format(SalesHeader."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(SalesLine."Line No.") + ')]'), 'Sales item ledger entry not found.');
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Sales Date");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
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

        ExpectedFilterTxt := '' + Format(CalcDate(PBISetup."Item Sales Date Formula")) + '..';

        // [WHEN] GenerateItemSalesReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Sales Date");

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateItemSalesReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
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
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Sales Date");

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

    [Test]
    procedure TestGetSalesLine()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A sales order with line
        LibSales.CreateSalesOrder(SalesHeader);
        SalesHeader."Quote Valid Until Date" := WorkDate();
        SalesHeader."Posting Date" := WorkDate();
        SalesHeader.Modify();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine."Requested Delivery Date" := WorkDate();
        SalesLine."Promised Delivery Date" := WorkDate();
        SalesLine.Modify();
        Commit();

        // [WHEN] Get request for sales lines
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Sales Lines");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'orderNo eq ''' + Format(SalesHeader."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains normalized sales line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        SalesLine.SetAutoCalcFields("Posting Date");
        if SalesLine.FindSet() then
            repeat
                VerifySalesLine(Response, SalesHeader, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure VerifySalesLine(Response: Text; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.lineNo == ' + Format(SalesLine."Line No.") + ')]'), 'Sales line not found.');
        Assert.AreEqual(Format(SalesHeader."No."), JsonMgt.GetValue('orderNo'), 'Sales order no does not match.');
        Assert.AreEqual(Format(SalesHeader."Document Type"), JsonMgt.GetValue('documentType'), 'Sales header document type does not match.');
        Assert.AreEqual(SalesHeader."Bill-to Customer No.", JsonMgt.GetValue('billToCustomerNo'), 'Sales header bill-to customer no does not match.');
        Assert.AreEqual(SalesHeader."Sell-to Customer No.", JsonMgt.GetValue('sellToCustomerNo'), 'Sales header sell-to customer no does not match.');
        Assert.AreEqual(Format(SalesHeader."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Sales header order date does not match.');
        Assert.AreEqual(SalesHeader."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Sales header salesperson code does not match.');
        Assert.AreEqual(SalesHeader."Opportunity No.", JsonMgt.GetValue('opportunityNo'), 'Sales header opportunity no does not match.');
        Assert.AreEqual(SalesHeader."Quote No.", JsonMgt.GetValue('quoteNo'), 'Sales header quote no does not match.');
        Assert.AreEqual(Format(SalesHeader."Quote Valid Until Date", 0, 9), JsonMgt.GetValue('quoteValidUntilDate'), 'Sales header quote valid until date does not match.');
        Assert.AreEqual(Format(SalesHeader."Document Date", 0, 9), JsonMgt.GetValue('documentDate'), 'Sales header document date does not match.');
        Assert.AreEqual(Format(SalesHeader."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Sales header due date does not match.');
        Assert.AreEqual(SalesHeader."Campaign No.", JsonMgt.GetValue('campaignNo'), 'Sales header campaign no does not match.');

        Assert.AreEqual(Format(SalesLine."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Sales line posting date does not match.');
        Assert.AreEqual(Format(SalesLine."Document Type"), JsonMgt.GetValue('salesLineDocumentType'), 'Sales line document type does not match.');
        Assert.AreEqual(SalesLine."Document No.", JsonMgt.GetValue('documentNo'), 'Sales line document no does not match.');
        Assert.AreEqual(Format(SalesLine."Line No."), JsonMgt.GetValue('lineNo'), 'Sales line line no does not match.');
        Assert.AreEqual(SalesLine."No.", JsonMgt.GetValue('itemNo'), 'Sales line item no does not match.');
        Assert.AreEqual(SalesLine."Location Code", JsonMgt.GetValue('locationCode'), 'Sales line location code does not match.');
        Assert.AreEqual(Format(SalesLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Sales line quantity base does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Sales line outstanding qty base does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingAmountLCY'), 'Sales line outstanding amount lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Amount" / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Sales line amount does not match.');
        Assert.AreEqual(Format(SalesLine."Unit Cost (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('unitCostLCY'), 'Sales line unit cost lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Outstanding Quantity" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQuantity'), 'Sales line outstanding quantity does not match.');
        Assert.AreEqual(SalesLine."Return Reason Code", JsonMgt.GetValue('returnReasonCode'), 'Sales line return reason code does not match.');
        Assert.AreEqual(Format(SalesLine."Shipment Date", 0, 9), JsonMgt.GetValue('shipmentDate'), 'Sales line shipment date does not match.');
        Assert.AreEqual(Format(SalesLine."Planned Shipment Date", 0, 9), JsonMgt.GetValue('plannedShipmentDate'), 'Sales line planned shipment date does not match.');
        Assert.AreEqual(Format(SalesLine."Planned Delivery Date", 0, 9), JsonMgt.GetValue('plannedDeliveryDate'), 'Sales line planned Delivery date does not match.');
        Assert.AreEqual(Format(SalesLine."Requested Delivery Date", 0, 9), JsonMgt.GetValue('requestedDeliveryDate'), 'Sales line requested Delivery date does not match.');
        Assert.AreEqual(Format(SalesLine."Promised Delivery Date", 0, 9), JsonMgt.GetValue('promisedDeliveryDate'), 'Sales line promised Delivery date does not match.');
        Assert.AreEqual(Format(SalesLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Sales line dimension set id does not match.');
        Assert.AreEqual(Format(SalesLine."Return Qty. Rcd. Not Invd." / 1.0, 0, 9), JsonMgt.GetValue('returnQtyRcdNotInvd'), 'Sales line return qty rcd not invd does not match.');
        Assert.AreEqual(Format(SalesLine."Return Qty. Received (Base)" / 1.0, 0, 9), JsonMgt.GetValue('returnQtyReceivedBase'), 'Sales line return qty received base does not match.');
        Assert.AreEqual(Format(SalesLine."Return Qty. to Receive (Base)" / 1.0, 0, 9), JsonMgt.GetValue('returnQtyToReceiveBase'), 'Sales line return qty to receive base does not match.');
        Assert.AreEqual(Format(SalesLine."Return Rcd. Not Invd. (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('returnRcdNotInvdLCY'), 'Sales line return rcd not invd lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Qty. Shipped (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityShippedBase'), 'Sales line qty shipped base does not match.');
        Assert.AreEqual(Format(SalesLine."Qty. to Ship (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityToShipBase'), 'Sales line qty to ship base does not match.');
        Assert.AreEqual(Format(SalesLine."Qty. Shipped Not Invd. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyShippedNotInvdBase'), 'Sales line qty shipped not invd base does not match.');
        Assert.AreEqual(Format(SalesLine."Shipped Not Inv. (LCY) No VAT" / 1.0, 0, 9), JsonMgt.GetValue('shippedNotInvoicedLCYNoVAT'), 'Sales line shipped not invoiced lcy does not match.');
        Assert.AreEqual(Format(SalesLine."Shipped Not Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('shippedNotInvoiced'), 'Sales line shipped not invoiced does not match.');
        Assert.AreEqual(Format(SalesLine."Quantity Invoiced" / 1.0, 0, 9), JsonMgt.GetValue('quantityInvoiced'), 'Sales line quantity invoiced does not match.');
    end;

    [Test]
    procedure TestGetOpportunity()
    var
        Opportunity: Record Opportunity;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A Opportunity is created from a contact.
        LibMarketing.CreateOpportunity(Opportunity, LibMarketing.CreatePersonContactNo());
        Commit();

        // [WHEN] Get request for Opportunity is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Opportunity");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'opportunityNo eq ''' + Format(Opportunity."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the Opportunity information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyOpportunity(Response, Opportunity);
    end;

    local procedure VerifyOpportunity(Response: Text; Opportunity: Record Opportunity)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.opportunityNo == ''' + Format(Opportunity."No.") + ''')]'), 'Opportunity not found.');
        Assert.AreEqual(Opportunity.Description, JsonMgt.GetValue('opportunityDescription'), 'Opportunity Description does not match.');
        Assert.AreEqual(Opportunity."Sales Cycle Code", JsonMgt.GetValue('opportunitySalesCycle'), 'Opportunity Sales Cycle Code does not match.');
        Assert.AreEqual(Format(Opportunity."Creation Date", 0, 9), JsonMgt.GetValue('opportunityCreationDate'), 'Opportunity Creation Date does not match.');
        Assert.AreEqual(Format(Opportunity.Status), JsonMgt.GetValue('opportunityStatus'), 'Opportunity Status does not match.');
        Assert.AreEqual(Opportunity.Closed ? 'True' : 'False', JsonMgt.GetValue('opportunityClosed'), 'Opportunity Closed does not match.');
        Assert.AreEqual(Format(Opportunity."Sales Document No."), JsonMgt.GetValue('opportunitySalesDocumentNo'), 'Opportunity Sales Document No does not match.');
        Assert.AreEqual(Format(Opportunity."Sales Document Type"), JsonMgt.GetValue('opportunitySalesDocumentType'), 'Opportunity Sales Document Type does not match.');
        Assert.AreEqual(Format(Opportunity."Priority"), JsonMgt.GetValue('opportunityPriority'), 'Opportunity Priority does not match.');
        Assert.AreEqual(Format(Opportunity."Campaign No."), JsonMgt.GetValue('opportunityCampaignNo'), 'Opportunity Campaign No does not match.');
        Assert.AreEqual(Format(Opportunity."Segment No."), JsonMgt.GetValue('opportunitySegmentNo'), 'Opportunity Segment No does not match.');
    end;

    [Test]
    procedure TestGetOpportunityEntry()
    var
        OpportunityEntry: Record "Opportunity Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A Opportunity with Opportunity Entry is created
        if OpportunityEntry.FindLast() then;
        OpportunityEntry.Init();
        OpportunityEntry."Entry No." += 1;
        OpportunityEntry."Opportunity No." := Format(LibRandom.RandInt(100));
        OpportunityEntry."Salesperson Code" := Format(LibRandom.RandInt(100));
        OpportunityEntry.Active := true;
        OpportunityEntry."Action Taken" := OpportunityEntry."Action Taken"::Next;
        OpportunityEntry."Date of Change" := WorkDate();
        OpportunityEntry."Estimated Close Date" := WorkDate();
        OpportunityEntry."Estimated Value (LCY)" := LibRandom.RandDecInRange(1, 100, 2);
        OpportunityEntry."Estimated Value (LCY)" := LibRandom.RandDecInRange(1, 100, 2);
        OpportunityEntry."Completed %" := LibRandom.RandDecInRange(1, 100, 2);
        OpportunityEntry."Chances of Success %" := LibRandom.RandDecInRange(1, 100, 2);
        OpportunityEntry."Probability %" := LibRandom.RandDecInRange(1, 100, 2);
        OpportunityEntry."Sales Cycle Code" := Format(LibRandom.RandInt(100));
        OpportunityEntry."Sales Cycle Stage" := LibRandom.RandInt(100);
        OpportunityEntry."Sales Cycle Stage Description" := CopyStr(LibRandom.RandText(20), 1, MaxStrLen(OpportunityEntry."Sales Cycle Stage Description"));
        OpportunityEntry."Contact No." := Format(LibRandom.RandInt(100));
        OpportunityEntry.Insert();
        Commit();

        // [WHEN] Get request for Opportunity Entry is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Opportunity Entries");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'opportunityEntryEntryNo eq ' + Format(OpportunityEntry."Entry No.") + '');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the opportunity entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyOpportunityEntry(Response, OpportunityEntry);
    end;

    local procedure VerifyOpportunityEntry(Response: Text; OpportunityEntry: Record "Opportunity Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.opportunityEntryEntryNo == ' + Format(OpportunityEntry."Entry No.") + ')]'), 'Opportunity Entry No not found.');
        Assert.AreEqual(OpportunityEntry."Opportunity No.", JsonMgt.GetValue('opportunityEntryOpportunity'), 'Opportunity Entry Opportunity No does not match.');
        Assert.AreEqual(OpportunityEntry."Salesperson Code", JsonMgt.GetValue('salespersonCode'), 'Opportunity Entry Salesperson does not match.');
        Assert.AreEqual(OpportunityEntry.Active ? 'True' : 'False', JsonMgt.GetValue('opportunityEntryActive'), 'Opportunity Entry Active does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Action Taken"), JsonMgt.GetValue('opportunityEntryActionTaken'), 'Opportunity Entry Action taken does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Date of Change", 0, 9), JsonMgt.GetValue('opportunityEntryDateChange'), 'Opportunity EntryDate of Change does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Estimated Close Date", 0, 9), JsonMgt.GetValue('opportunityEntryEstCloseDate'), 'Opportunity Entry Estimated Close Date does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Estimated Value (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('opportunityEntryEstValue'), 'Opportunity Entry Estimated value lcy does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Calcd. Current Value (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('opportunityEntryCalcCurrentValue'), 'Opportunity Entry calculated current value lcy does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Completed %" / 1.0, 0, 9), JsonMgt.GetValue('opportunityEntryCompleted'), 'Opportunity Entry Completed % does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Chances of Success %" / 1.0, 0, 9), JsonMgt.GetValue('opportunityEntryChanceSuccess'), 'Opportunity Entry Chance of Success % does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Probability %" / 1.0, 0, 9), JsonMgt.GetValue('opportunityEntryProbability'), 'Opportunity Entry Probability % does not match.');
        Assert.AreEqual(OpportunityEntry."Sales Cycle Code", JsonMgt.GetValue('opportunityEntrySalesCycleCode'), 'Opportunity Entry Sales Cycle Code does not match.');
        Assert.AreEqual(Format(OpportunityEntry."Sales Cycle Stage"), JsonMgt.GetValue('opportunityEntrySalesCycleStage'), 'Opportunity Entry Sales Cycle Stage does not match.');
        Assert.AreEqual(OpportunityEntry."Sales Cycle Stage Description", JsonMgt.GetValue('opportunityEntrySalesCycleStageDescription'), 'Opportunity Entry Sales Cycle Stage Description does not match.');
        Assert.AreEqual(OpportunityEntry."Close Opportunity Code", JsonMgt.GetValue('opportunityEntryCloseOpportunityCode'), 'Opportunity Entry Close Opportunity Code does not match.');
        Assert.AreEqual(OpportunityEntry."Contact No.", JsonMgt.GetValue('opportunityContactNo'), 'Opportunity Entry Contact No does not match.');
    end;

    [Test]
    procedure TestGetSalesCycleStage()
    var
        SalesCycle: Record "Sales Cycle";
        SalesCycleStage: Record "Sales Cycle Stage";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A Sales Cycle Stage is created
        if SalesCycle.FindLast() then;
        SalesCycle.Init();
        SalesCycle.Code := CopyStr(LibRandom.RandText(10), 1, 10);
        SalesCycle.Insert();


        if SalesCycleStage.FindLast() then;
        SalesCycleStage.Init();
        SalesCycleStage."Sales Cycle Code" := SalesCycle.Code;
        SalesCycleStage.Description := CopyStr(LibRandom.RandText(100), 1, 100);
        SalesCycleStage.Insert();
        Commit();

        // [WHEN] Get request for Sales Cycle Stage is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Sales Cycle Stages");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'salesCycleCode eq ''' + SalesCycle.Code + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the sales cycle stage information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifySalesCycleStage(Response, SalesCycleStage);
    end;

    local procedure VerifySalesCycleStage(Response: Text; SalesCycleStage: Record "Sales Cycle Stage")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.salesCycleCode == ''' + SalesCycleStage."Sales Cycle Code" + ''')]'), 'Sales Cycle Code not found.');
        Assert.AreEqual(SalesCycleStage."Sales Cycle Code", JsonMgt.GetValue('salesCycleCode'), 'Sales cycle code does not match.');
        Assert.AreEqual(Format(SalesCycleStage.Stage, 0, 9), JsonMgt.GetValue('salesCycleStage'), 'Sales cycle stage does not match.');
        Assert.AreEqual(SalesCycleStage.Description, JsonMgt.GetValue('salesCycleStageDescription'), 'Sales cycle description does not match.');
    end;

    [Test]
    procedure TestCloseOpportunityCode()
    var
        CloseOpportunityCode: Record "Close Opportunity Code";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        Initialize();

        // [GIVEN] A Close Opportunity Code is created
        if CloseOpportunityCode.FindLast() then;
        CloseOpportunityCode.Init();
        CloseOpportunityCode.Code := CopyStr(LibRandom.RandText(10), 1, 10);
        CloseOpportunityCode.Description := CopyStr(LibRandom.RandText(100), 1, 100);
        CloseOpportunityCode.Type := CloseOpportunityCode.Type::Won;
        CloseOpportunityCode.Insert();

        Commit();

        // [WHEN] Get request for  Close Opportunity Code is made
        TargetURL := PowerBIAPIRequests.GetEndpointUrl(PowerBIAPIEndpoints::"Close Opporturnity Codes");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'closeOpportunityCode eq ''' + CloseOpportunityCode.Code + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the close oppportunity code information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyCloseOpportunityCode(Response, CloseOpportunityCode);
    end;

    local procedure VerifyCloseOpportunityCode(Response: Text; CloseOpportunityCode: Record "Close Opportunity Code")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.closeOpportunityCode == ''' + CloseOpportunityCode.Code + ''')]'), 'Sales Cycle Code not found.');
        Assert.AreEqual(CloseOpportunityCode.Code, JsonMgt.GetValue('closeOpportunityCode'), 'Close opportunity code does not match.');
        Assert.AreEqual(CloseOpportunityCode.Description, JsonMgt.GetValue('closeOpportunityDescription'), 'Close opportunity description does not match.');
        Assert.AreEqual(Format(CloseOpportunityCode.Type), JsonMgt.GetValue('closeOpportunityType'), 'Close opportunity type does not match.');
    end;
}
