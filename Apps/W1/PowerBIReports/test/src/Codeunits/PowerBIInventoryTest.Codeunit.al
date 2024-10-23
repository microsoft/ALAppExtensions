#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Warehouse.Structure;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Transfer;
using Microsoft.Service.Document;
using Microsoft.Inventory.Ledger;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Journal;
using Microsoft.Assembly.Document;
using Microsoft.Projects.Project.Planning;
using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Planning;
using System.Text;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Projects.Project.Job;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.Setup;
using Microsoft.Warehouse.Document;
using Microsoft.Service.Item;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Setup;
using Microsoft.Inventory.PowerBIReports;
using Microsoft.Service.Test;
using System.TestLibraries.Security.AccessControl;

codeunit 139877 "PowerBI Inventory Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibInv: Codeunit "Library - Inventory";
        LibWhse: Codeunit "Library - Warehouse";
        LibSales: Codeunit "Library - Sales";
        LibPurch: Codeunit "Library - Purchase";
        LibPlanning: Codeunit "Library - Planning";
        LibService: Codeunit "Library - Service";
        LibAssembly: Codeunit "Library - Assembly";
        LibJob: Codeunit "Library - Job";
        LibManufacturing: Codeunit "Library - Manufacturing";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestGetZones()
    var
        Zone: Record Zone;
        Location: Record Location;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A location with multiple zones is created
        LibWhse.CreateFullWMSLocation(Location, 1);
        Zone.SetRange("Location Code", Location.Code);
        Commit();

        // [WHEN] Get request for zones is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Zones, '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('locationCode eq ''%1''', Location.Code));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the zone information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if Zone.FindSet() then
            repeat
                VerifyZone(Response, Zone);
            until Zone.Next() = 0;
    end;

    local procedure VerifyZone(Response: Text; Zone: Record Zone)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.zoneCode == ''%1'')]', Zone.Code)), 'Zone not found.');
        Assert.AreEqual(Zone.Description, JsonMgt.GetValue('zoneDescription'), 'Description did not match.');
        Assert.AreEqual(Zone."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Zone."Bin Type Code", JsonMgt.GetValue('binTypeCode'), 'Bin type code did not match.');
    end;

    [Test]
    procedure TestGetBins()
    var
        Bin: Record Bin;
        Location: Record Location;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A bin is created
        LibWhse.CreateLocation(Location);
        LibWhse.CreateBin(Bin, Location.Code, '', '', '');
        LibWhse.CreateBin(Bin, Location.Code, '', '', '');
        Bin.SetRange("Location Code", Location.Code);
        Commit();

        // [WHEN] Get request for bins is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Bins, '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('locationCode eq ''%1''', Location.Code));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the bin information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if Bin.FindSet() then
            repeat
                VerifyBin(Response, Bin);
            until Bin.Next() = 0;
    end;

    local procedure VerifyBin(Response: Text; Bin: Record Bin)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.binCode == ''%1'')]', Bin.Code)), 'Bin not found.');
        Assert.AreEqual(Bin.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Bin."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Bin."Bin Type Code", JsonMgt.GetValue('binType'), 'Bin type code did not match.');
        Assert.AreEqual(Bin."Zone Code", JsonMgt.GetValue('zoneCode'), 'Zone code did not match.');
    end;

    [Test]
    procedure TestGetSalesLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A sales order is created with multiple types of sales lines
        LibSales.CreateSalesOrder(SalesHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::" ", '', 0);
        Commit();

        // [WHEN] Get request for sales lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Sales Lines - Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', SalesHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the sales line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                VerifySalesLine(Response, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure VerifySalesLine(Response: Text; SalesLine: Record "Sales Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."Outstanding Qty. (Base)" <> 0) then begin
            Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', SalesLine."No.")), 'Sales line not found.');
            Assert.AreEqual(Format(SalesLine."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
            Assert.AreEqual(SalesLine."Sell-to Customer No.", JsonMgt.GetValue('sellToCustomerNo'), 'Sell-to customer no. did not match.');
            Assert.AreEqual(SalesLine."No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
            Assert.AreEqual(Format(SalesLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Outstanding qty. (base) did not match.');
            Assert.AreEqual(Format(SalesLine."Shipment Date", 0, 9), JsonMgt.GetValue('shipmentDate'), 'Shipment date did not match.');
            Assert.AreEqual(SalesLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
            Assert.AreEqual(Format(SalesLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
            Assert.AreEqual(Format(SalesLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
            Assert.AreEqual(SalesLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
        end else
            Assert.IsFalse(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', SalesLine."No.")), 'Sales line not found.');
    end;

    [Test]
    procedure TestGetSalesLinesOutsideFilter()
    var
        SalesLine: Record "Sales Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Sales lines exists outside of the query filter
        SalesLine.Init();
        SalesLine."Type" := SalesLine.Type::Item;
        SalesLine."No." := LibUtility.GenerateRandomCode20(SalesLine.FieldNo("No."), Database::"Sales Line");

        SalesLine."Document Type" := SalesLine."Document Type"::"Return Order";
        SalesLine."Document No." := LibUtility.GenerateRandomCode20(SalesLine.FieldNo("Document No."), Database::"Sales Line");
        SalesLine."Line No." := 1;
        SalesLine."Outstanding Qty. (Base)" := 0;
        SalesLine.Insert();

        SalesLine."Document Type" := SalesLine."Document Type"::Quote;
        SalesLine."Document No." := LibUtility.GenerateRandomCode20(SalesLine.FieldNo("Document No."), Database::"Sales Line");
        SalesLine."Line No." := 1;
        SalesLine."Outstanding Qty. (Base)" := 1;
        SalesLine.Insert();

        Commit();

        // [WHEN] Get request for sales lines outside the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Sales Lines - Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', SalesLine."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the sales line outside the filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetPurchLines()
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A purchase order is created with multiple types of purchase lines
        LibPurch.CreatePurchaseOrder(PurchHeader);
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibInv.CreateItemWithUnitPriceAndUnitCost(
          Item, LibRandom.RandDecInRange(1, 100, 2), LibRandom.RandDecInRange(1, 100, 2));
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, Item."No.", LibRandom.RandInt(100));
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::" ", '', 0);
        Commit();

        // [WHEN] Get request for purchase lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purchase Lines - Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', PurchHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the purchase line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindSet() then
            repeat
                VerifyPurchLine(Response, PurchLine);
            until PurchLine.Next() = 0;
    end;

    local procedure VerifyPurchLine(Response: Text; PurchLine: Record "Purchase Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."Outstanding Qty. (Base)" <> 0) then begin
            Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', PurchLine."No.")), 'Purchase line not found.');
            Assert.AreEqual(Format(PurchLine."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
            Assert.AreEqual(PurchLine."Buy-from Vendor No.", JsonMgt.GetValue('buyFromVendorNo'), 'Buy-from vendor no. did not match.');
            Assert.AreEqual(PurchLine."No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
            Assert.AreEqual(Format(PurchLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Outstanding qty. (base) did not match.');
            Assert.AreEqual(Format(PurchLine."Expected Receipt Date", 0, 9), JsonMgt.GetValue('expectedReceiptDate'), 'Expected receipt date did not match.');
            Assert.AreEqual(PurchLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
            Assert.AreEqual(Format(PurchLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
            Assert.AreEqual(Format(PurchLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
            Assert.AreEqual(PurchLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
        end else
            Assert.IsFalse(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', PurchLine."No.")), 'Purchase line not found.');
    end;

    [Test]
    procedure TestGetPurchLinesOutsideFilter()
    var
        PurchLine: Record "Purchase Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Purchase lines exists outside of the query filter
        PurchLine.Init();
        PurchLine."Type" := PurchLine.Type::Item;
        PurchLine."No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("No."), Database::"Purchase Line");

        PurchLine."Document Type" := PurchLine."Document Type"::"Return Order";
        PurchLine."Document No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Document No."), Database::"Purchase Line");
        PurchLine."Line No." := 1;
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine.Insert();

        PurchLine."Document Type" := PurchLine."Document Type"::Quote;
        PurchLine."Document No." := LibUtility.GenerateRandomCode20(PurchLine.FieldNo("Document No."), Database::"Purchase Line");
        PurchLine."Line No." := 1;
        PurchLine."Outstanding Qty. (Base)" := 1;
        PurchLine.Insert();

        Commit();

        // [WHEN] Get request for purchase lines outside the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Purchase Lines - Outstanding", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', PurchLine."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the purchase line outside the filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetReqLines()
    var
        SalesHeader: Record "Sales Header";
        Item1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        RequisitionLine: Record "Requisition Line";
        Uri: Codeunit Uri;
        Quantity: Decimal;
        ShipmentDate: Date;
        TargetURL: Text;
        Response: Text;
    begin
        UpdateSalesReceivablesSetup();

        // [GIVEN] Multiple items which require replenishment, and requisition lines are created
        LibSales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        Quantity := LibRandom.RandDec(10, 2);

        CreateItem(Item1, Item1."Replenishment System"::Purchase, '', '', '');
        CreateItem(Item2, Item1."Replenishment System"::Purchase, '', '', Item1."Vendor No.");
        CreateItem(Item3, Item1."Replenishment System"::"Prod. Order", '', '', Item1."Vendor No.");

        ShipmentDate := CalcDate('<' + Format(LibRandom.RandInt(10)) + 'D>', WorkDate());
        CreateSalesLine(SalesHeader, Item1."No.", '', ShipmentDate, Quantity, Quantity);
        ShipmentDate := CalcDate('<' + Format(LibRandom.RandInt(10)) + 'D>', ShipmentDate);
        CreateSalesLine(SalesHeader, Item2."No.", '', ShipmentDate, Quantity, Quantity);
        ShipmentDate := CalcDate('<' + Format(LibRandom.RandInt(10)) + 'D>', ShipmentDate);
        CreateSalesLine(SalesHeader, Item3."No.", '', ShipmentDate, Quantity, Quantity);

        LibPlanning.CalculateOrderPlanSales(RequisitionLine);
        Commit();

        // [WHEN] Get request for requisition lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Requisition Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter',
            StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2'' OR itemNo eq ''%3''', Item1."No.", Item2."No.", Item3."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the requisition line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        RequisitionLine.SetRange("Type", RequisitionLine.Type::Item);
        RequisitionLine.SetFilter("No.", '%1|%2|%3', Item1."No.", Item2."No.", Item3."No.");
        if RequisitionLine.FindSet() then
            repeat
                VerifyRequisitionLine(Response, RequisitionLine);
            until RequisitionLine.Next() = 0;

    end;

    local procedure VerifyRequisitionLine(Response: Text; RequisitionLine: Record "Requisition Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', RequisitionLine."No.")), 'Requisition line not found.');
        Assert.AreEqual(RequisitionLine."Worksheet Template Name", JsonMgt.GetValue('worksheetTemplateName'), 'Worksheet template name did not match.');
        Assert.AreEqual(RequisitionLine."Journal Batch Name", JsonMgt.GetValue('journalBatchName'), 'Journal batch name did not match.');
        Assert.AreEqual(Format(RequisitionLine."Planning Line Origin"), JsonMgt.GetValue('planningLineOrigin'), 'Planning line origin did not match.');
        Assert.AreEqual(Format(RequisitionLine."Replenishment System"), JsonMgt.GetValue('replenishmentSystem'), 'Replenishment system did not match.');
        Assert.AreEqual(RequisitionLine."Transfer-from Code", JsonMgt.GetValue('transferFromCode'), 'Transfer-from code did not match.');
        Assert.AreEqual(RequisitionLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(RequisitionLine."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(Format(RequisitionLine."Starting Date", 0, 9), JsonMgt.GetValue('startingDate'), 'Starting date did not match.');
        Assert.AreEqual(Format(RequisitionLine."Order Date", 0, 9), JsonMgt.GetValue('orderDate'), 'Order date did not match.');
        Assert.AreEqual('0001-01-01', JsonMgt.GetValue('transferShipmentDate'), 'Transfer shipment date did not match.');
        Assert.AreEqual(Format(RequisitionLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Quantity (base) did not match.');
    end;


    local procedure UpdateSalesReceivablesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Credit Warnings", SalesReceivablesSetup."Credit Warnings"::"No Warning");
        SalesReceivablesSetup.Validate("Stockout Warning", false);
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure CreateItem(var Item: Record Item; ReplenishmentSystem: Enum "Replenishment System"; RoutingHeaderNo: Code[20]; ProductionBOMNo: Code[20]; VendorNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        LibInv.CreateItem(Item);
        GeneralLedgerSetup.Get();
        Item.Validate("Costing Method", Item."Costing Method"::Standard);
        Item.Validate("Unit Cost", LibRandom.RandDec(20, 2));
        Item.Validate("Replenishment System", ReplenishmentSystem);
        Item.Validate("Rounding Precision", GeneralLedgerSetup."Amount Rounding Precision");
        if VendorNo = '' then
            VendorNo := LibPurch.CreateVendorNo();
        Item.Validate("Vendor No.", VendorNo);
        Item.Validate("Routing No.", RoutingHeaderNo);
        Item.Validate("Production BOM No.", ProductionBOMNo);
        Item.Modify(true);
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; ItemNo: Code[20]; LocationCode: Code[10]; ShipmentDate: Date; Quantity: Decimal; QuantityToShip: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
        SalesLine.Validate("Qty. to Ship", QuantityToShip);
        SalesLine.Validate("Unit Price", LibRandom.RandDec(100, 2));
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate("Shipment Date", ShipmentDate);
        SalesLine.Modify(true);
    end;

    [Test]
    procedure TestGetTransferLines()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A transfer order is posted
        LibInv.CreateTransferHeader(TransferHeader);
        LibInv.CreateItem(Item);
        LibInv.CreateTransferLine(TransferHeader, TransferLine, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        LibInv.CreateItem(Item);
        LibInv.CreateTransferLine(TransferHeader, TransferLine, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        Commit();

        // [WHEN] Get request for transfer lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Transfer Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', TransferHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the transfer line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if TransferLine.FindSet() then
            repeat
                VerifyTransferLine(Response, TransferLine);
            until TransferLine.Next() = 0;
    end;

    local procedure VerifyTransferLine(Response: Text; TransferLine: Record "Transfer Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', TransferLine."Item No.")), 'Transfer line not found.');
        Assert.AreEqual(TransferLine."In-Transit Code", JsonMgt.GetValue('inTransitLocationCode'), 'In-Transit Code did not match.');
        Assert.AreEqual(TransferLine."Transfer-to Code", JsonMgt.GetValue('transferToLocationCode'), 'Transfer-to Code did not match.');
        Assert.AreEqual(TransferLine."Transfer-from Code", JsonMgt.GetValue('transferFromLocationCode'), 'Transfer-from Code did not match.');
        Assert.AreEqual(Format(TransferLine."Qty. in Transit (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyInTransitBase'), 'Qty. in Transit (Base) did not match.');
        Assert.AreEqual(Format(TransferLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Outstanding Qty. (Base) did not match.');
        Assert.AreEqual(Format(TransferLine."Receipt Date", 0, 9), JsonMgt.GetValue('receiptDate'), 'Receipt Date did not match.');
        Assert.AreEqual(Format(TransferLine."Shipment Date", 0, 9), JsonMgt.GetValue('shipmentDate'), 'Shipment Date did not match.');
        Assert.AreEqual(Format(TransferLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension Set ID did not match.');
        Assert.AreEqual(Format(TransferLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per Unit of Measure did not match.');
        Assert.AreEqual(TransferLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of Measure Code did not match.');
    end;

    [Test]
    procedure TestGetTransferLinesOutsideFilter()
    var
        TransferLine: Record "Transfer Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Transfer lines exists outside of the query filter
        TransferLine.Init();
        TransferLine."Document No." := LibUtility.GenerateRandomCode20(TransferLine.FieldNo("Document No."), Database::"Transfer Line");
        TransferLine."Line No." := 1;
        TransferLine."Derived From Line No." := 1;
        TransferLine.Insert();

        Commit();

        // [WHEN] Get request for transfer lines outside the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Transfer Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', TransferLine."Document No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the transfer line outside the filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetServiceLines()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A service order is created with service lines
        LibService.CreateServiceDocumentWithItemServiceLine(ServiceHeader, ServiceHeader."Document Type"::Order);
        LibService.CreateServiceItem(ServiceItem, ServiceHeader."Bill-to Customer No.");
        ServiceItem.Validate("Response Time (Hours)", LibRandom.RandDecInRange(5, 10, 2));
        ServiceItem.Modify(true);
        LibService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Validate("Unit Price", LibRandom.RandIntInRange(3, 5));
        ServiceLine.Modify(true);
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        Commit();

        // [WHEN] Get request for service lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Service Lines - Order", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', ServiceHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the service line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ServiceLine.FindSet() then
            repeat
                VerifyServiceLine(Response, ServiceLine);
            until ServiceLine.Next() = 0;
    end;

    local procedure VerifyServiceLine(Response: Text; ServiceLine: Record "Service Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', ServiceLine."No.")), 'Service line not found.');
        Assert.AreEqual(ServiceLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(ServiceLine."Outstanding Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('outstandingQtyBase'), 'Outstanding Qty. (Base) did not match.');
        Assert.AreEqual(Format(ServiceLine."Needed by Date", 0, 9), JsonMgt.GetValue('neededByDate'), 'Needed by Date did not match.');
        Assert.AreEqual(Format(ServiceLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension Set ID did not match.');
        Assert.AreEqual(Format(ServiceLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per Unit of Measure did not match.');
        Assert.AreEqual(ServiceLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of Measure Code did not match.');
    end;

    [Test]
    procedure TestGetServiceLinesOutsideFilter()
    var
        ServiceLine: Record "Service Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Service lines exists outside of the query filter
        ServiceLine.Init();
        ServiceLine."Document No." := LibUtility.GenerateRandomCode20(ServiceLine.FieldNo("Document No."), Database::"Service Line");

        ServiceLine."Document Type" := ServiceLine."Document Type"::Quote;
        ServiceLine."Line No." := 1;
        ServiceLine."Type" := ServiceLine.Type::Item;
        ServiceLine."No." := LibUtility.GenerateRandomCode20(ServiceLine.FieldNo("No."), Database::"Service Line");
        ServiceLine.Insert();

        ServiceLine."Document Type" := ServiceLine."Document Type"::Order;
        ServiceLine."Line No." := 1;
        ServiceLine."Type" := ServiceLine.Type::Resource;
        ServiceLine."No." := LibUtility.GenerateRandomCode20(ServiceLine.FieldNo("No."), Database::"Service Line");
        ServiceLine.Insert();

        Commit();

        // [WHEN] Get request for service lines outside the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Service Lines - Order", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', ServiceLine."Document No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the service line outside the filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetItemLedgerEntries()
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Sales and purchase documents are created and posted with item ledgers
        LibSales.CreateSalesOrder(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        LibSales.PostSalesDocument(SalesHeader, true, true);

        LibPurch.CreatePurchaseOrder(PurchHeader);
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.FindFirst();
        LibPurch.PostPurchaseDocument(PurchHeader, true, true);

        ItemLedgerEntry.SetFilter("Item No.", '%1|%2', SalesLine."No.", PurchLine."No.");

        Commit();

        // [WHEN] Get request for item ledger entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Microsoft.Inventory.PowerBIReports."Item Ledger Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2''', SalesLine."No.", PurchLine."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the item ledger entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)", "Sales Amount (Actual)");
        if ItemLedgerEntry.FindSet() then
            repeat
                VerifyItemLedgerEntry(Response, ItemLedgerEntry);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure VerifyItemLedgerEntry(Response: Text; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
        BoolText: Text;
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', Format(ItemLedgerEntry."Entry No."))), 'Item ledger entry not found.');
        Assert.AreEqual(Format(ItemLedgerEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Entry type did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Source Type"), JsonMgt.GetValue('sourceType'), 'Source type did not match.');
        Assert.AreEqual(ItemLedgerEntry."Source No.", JsonMgt.GetValue('sourceNo'), 'Source no. did not match.');
        Assert.AreEqual(ItemLedgerEntry."Document No.", JsonMgt.GetValue('documentNo'), 'Document no. did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(ItemLedgerEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(ItemLedgerEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(ItemLedgerEntry."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual('0001-01-01', JsonMgt.GetValue('expirationDate'), 'Expiration date did not match.');
        Assert.AreEqual(ItemLedgerEntry."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(ItemLedgerEntry."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Remaining Quantity" / 1.0, 0, 9), JsonMgt.GetValue('remainingQuantity'), 'Remaining quantity did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Cost amount (actual) did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Sales Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('salesAmountActual'), 'Sales amount (actual) did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        BoolText := 'False';
        if ItemLedgerEntry.Open then
            BoolText := 'True';
        Assert.AreEqual(BoolText, JsonMgt.GetValue('open'), 'Open did not match.');
        BoolText := 'False';
        if ItemLedgerEntry.Positive then
            BoolText := 'True';
        Assert.AreEqual(BoolText, JsonMgt.GetValue('positive'), 'Positive did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Invoiced Quantity" / 1.0, 0, 9), JsonMgt.GetValue('invoicedQuantity'), 'Invoiced quantity did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
    end;

    [Test]
    procedure TestGetWhseActivityLines()
    var
        Item: Record Item;
        WhseActivityLine: Record "Warehouse Activity Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Wrehouse activity lines are created
        LibInv.CreateItem(Item);
        PostWarehouseActivity(Item."No.");
        WhseActivityLine.SetRange("Item No.", Item."No.");

        Commit();

        // [WHEN] Get request for warehouse receipt lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Warehouse Activity Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', Item."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains a take and place warehouse receipt line
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WhseActivityLine.FindSet() then
            repeat
                VerifyWhseActivityLine(Response, WhseActivityLine);
            until WhseActivityLine.Next() = 0;
    end;

    local procedure VerifyWhseActivityLine(Response: Text; WhseActivityLine: Record "Warehouse Activity Line")
    var
        JsonMgt: Codeunit "JSON Management";
        BoolText: Text;
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.actionType == ''%1'')]', Format(WhseActivityLine."Action Type"))), 'Warehouse activity line not found.');
        Assert.AreEqual(WhseActivityLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        BoolText := 'False';
        if WhseActivityLine."Assemble to Order" then
            BoolText := 'True';
        Assert.AreEqual(BoolText, JsonMgt.GetValue('assembleToOrder'), 'Assemble to order did not match.');
        BoolText := 'False';
        if WhseActivityLine."ATO Component" then
            BoolText := 'True';
        Assert.AreEqual(BoolText, JsonMgt.GetValue('atoComponent'), 'ATO component did not match.');
        Assert.AreEqual(WhseActivityLine."Bin Code", JsonMgt.GetValue('binCode'), 'Bin code did not match.');
        Assert.AreEqual(WhseActivityLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(WhseActivityLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(WhseActivityLine."Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyBase'), 'Qty. (base) did not match.');
        Assert.AreEqual(WhseActivityLine."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(WhseActivityLine."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual(Format(WhseActivityLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(WhseActivityLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetWhseEntries()
    var
        Item: Record Item;
        WhseEntry: Record "Warehouse Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Warehouse entries are created;
        LibInv.CreateItem(Item);
        PostWarehouseActivity(Item."No.");
        WhseEntry.SetRange("Item No.", Item."No.");

        Commit();

        // [WHEN] Get request for warehouse entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Warehouse Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', Item."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the warehouse entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WhseEntry.FindSet() then
            repeat
                VerifyWhseEntry(Response, WhseEntry);
            until WhseEntry.Next() = 0;
    end;

    local procedure VerifyWhseEntry(Response: Text; WhseEntry: Record "Warehouse Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', WhseEntry."Item No.")), 'Warehouse entry not found.');
        Assert.AreEqual(WhseEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(WhseEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(WhseEntry."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(WhseEntry."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual(WhseEntry."Zone Code", JsonMgt.GetValue('zoneCode'), 'Zone code did not match.');
        Assert.AreEqual(WhseEntry."Bin Code", JsonMgt.GetValue('binCode'), 'Bin code did not match.');
        Assert.AreEqual(Format(WhseEntry."Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyBase'), 'Qty. (base) did not match.');
        Assert.AreEqual(Format(WhseEntry."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(WhseEntry."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;


    local procedure PostWarehouseActivity(ItemNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        Location: Record Location;
        WhseEmployee: Record "Warehouse Employee";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        LocationCode: Code[10];
        VendorNo: Code[20];
        Quantity: Decimal;
    begin
        LibWhse.CreateFullWMSLocation(Location, 2);
        LibWhse.CreateWarehouseEmployee(WhseEmployee, Location.Code, true);

        LocationCode := Location.Code;
        VendorNo := LibPurch.CreateVendorNo();
        Quantity := LibRandom.RandDec(10, 2);
        LibPurch.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        LibPurch.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", LibRandom.RandDec(50, 2));
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Modify(true);
        LibPurch.ReleasePurchaseDocument(PurchaseHeader);

        LibWhse.CreateWhseReceiptFromPO(PurchaseHeader);
        WhseReceiptLine.SetRange("Source Document", WhseReceiptLine."Source Document"::"Purchase Order");
        WhseReceiptLine.SetRange("Source No.", PurchaseHeader."No.");
        WhseReceiptLine.FindFirst();
        WhseReceiptHeader.Get(WhseReceiptLine."No.");
        LibWhse.PostWhseReceipt(WhseReceiptHeader);
    end;

    [Test]
    procedure TestFromBinWhseJournalLines()
    var
        Item1: Record Item;
        Item2: Record Item;
        WhseJournalLine: Record "Warehouse Journal Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Warehouse journal lines are created
        LibInv.CreateItem(Item1);
        LibInv.CreateItem(Item2);
        CreateWhseJournalLines(Item1."No.", Item2."No.");
        WhseJournalLine.SetFilter("Item No.", '%1|%2', Item1."No.", Item2."No.");
        Commit();

        // [WHEN] Get request for warehouse journal lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Whse. Journal Lines - From Bin", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2''', Item1."No.", Item2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the warehouse journal line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WhseJournalLine.FindSet() then
            repeat
                VerifyFromBinWhseJournalLine(Response, WhseJournalLine);
            until WhseJournalLine.Next() = 0;
    end;

    local procedure VerifyFromBinWhseJournalLine(Response: Text; WhseJournalLine: Record "Warehouse Journal Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', WhseJournalLine."Item No.")), 'Warehouse journal line not found.');
        Assert.AreEqual(WhseJournalLine."From Bin Code", JsonMgt.GetValue('fromBinCode'), 'From bin code did not match.');
        Assert.AreEqual(WhseJournalLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(WhseJournalLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(WhseJournalLine."Qty. (Absolute, Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyBase'), 'Qty. (absolute, base) did not match.');
        Assert.AreEqual(WhseJournalLine."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(WhseJournalLine."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual(WhseJournalLine."From Zone Code", JsonMgt.GetValue('fromZoneCode'), 'From zone code did not match.');
        Assert.AreEqual(Format(WhseJournalLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(WhseJournalLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestToBinWhseJournalLines()
    var
        Item1: Record Item;
        Item2: Record Item;
        WhseJournalLine: Record "Warehouse Journal Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Warehouse journal lines are created
        LibInv.CreateItem(Item1);
        LibInv.CreateItem(Item2);
        CreateWhseJournalLines(Item1."No.", Item2."No.");
        WhseJournalLine.SetFilter("Item No.", '%1|%2', Item1."No.", Item2."No.");
        Commit();

        // [WHEN] Get request for warehouse journal lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Whse. Journal Lines - To Bin", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2''', Item1."No.", Item2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the warehouse journal line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WhseJournalLine.FindSet() then
            repeat
                VerifyToBinWhseJournalLine(Response, WhseJournalLine);
            until WhseJournalLine.Next() = 0;
    end;

    local procedure VerifyToBinWhseJournalLine(Response: Text; WhseJournalLine: Record "Warehouse Journal Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', WhseJournalLine."Item No.")), 'Warehouse journal line not found.');
        Assert.AreEqual(WhseJournalLine."To Bin Code", JsonMgt.GetValue('toBinCode'), 'To bin code did not match.');
        Assert.AreEqual(WhseJournalLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(WhseJournalLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(WhseJournalLine."Qty. (Absolute, Base)" / 1.0, 0, 9), JsonMgt.GetValue('qtyBase'), 'Qty. (absolute, base) did not match.');
        Assert.AreEqual(WhseJournalLine."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(WhseJournalLine."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual(WhseJournalLine."To Zone Code", JsonMgt.GetValue('toZoneCode'), 'To zone code did not match.');
        Assert.AreEqual(Format(WhseJournalLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(WhseJournalLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;


    local procedure CreateWhseJournalLines(Item1No: Code[20]; Item2No: Code[20])
    var
        Bin: Record Bin;
        Zone: Record Zone;
        Location: Record Location;
        WhseEmployee: Record "Warehouse Employee";
        WhseJournalLine: Record "Warehouse Journal Line";
        WhseJournalBatch: Record "Warehouse Journal Batch";
        WhseJournalTemplate: Record "Warehouse Journal Template";
    begin
        LibWhse.CreateFullWMSLocation(Location, 1);
        LibWhse.CreateWarehouseEmployee(WhseEmployee, Location.Code, true);
        Zone.SetRange("Location Code", Location.Code);
        Zone.SetRange("Bin Type Code", LibWhse.SelectBinType(false, false, true, true));
        Zone.FindFirst();
        LibWhse.FindBin(Bin, Location.Code, Zone.Code, 1);
        LibWhse.CreateWarehouseJournalBatch(WhseJournalBatch, WhseJournalTemplate.Type::Item, Location.Code);
        LibWhse.CreateWhseJournalLine(
          WhseJournalLine, WhseJournalBatch."Journal Template Name", WhseJournalBatch.Name, Location.Code, Bin."Zone Code",
          Bin.Code, WhseJournalLine."Entry Type"::"Positive Adjmt.", Item1No, 5);
        LibWhse.CreateWhseJournalLine(
          WhseJournalLine, WhseJournalBatch."Journal Template Name", WhseJournalBatch.Name, Location.Code, Bin."Zone Code",
          Bin.Code, WhseJournalLine."Entry Type"::"Positive Adjmt.", Item2No, 5);
    end;

    [Test]
    procedure TestGetInventoryValue()
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Value entry are posted
        LibInv.CreateItem(Item);
        LibPurch.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Order, LibPurch.CreateVendorNo());
        LibPurch.CreatePurchaseLine(PurchLine, PurchHeader, PurchLine.Type::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        LibPurch.PostPurchaseDocument(PurchHeader, true, true);
        LibSales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibSales.CreateCustomerNo());
        LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        LibSales.PostSalesDocument(SalesHeader, true, true);

        ValueEntry.SetRange("Item No.", Item."No.");
        Commit();

        // [WHEN] Get request for purchase value entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Value Entries - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', Item."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the purchase value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ValueEntry.FindSet() then
            repeat
                VerifyInventoryValue(Response, ValueEntry);
            until ValueEntry.Next() = 0;
    end;

    local procedure VerifyInventoryValue(Response: Text; ValueEntry: Record "Value Entry")
    var
        JsonMgt: Codeunit "JSON Management";

    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', ValueEntry."Entry No.")), 'Value entry not found.');
        Assert.AreEqual(Format(ValueEntry."Valuation Date", 0, 9), JsonMgt.GetValue('valuationDate'), 'Valuation date did not match.');
        Assert.AreEqual(ValueEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Cost amount (actual) did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Expected)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountExpected'), 'Cost amount (expected) did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Posted to G/L" / 1.0, 0, 9), JsonMgt.GetValue('costPostedToGL'), 'Cost posted to G/L did not match.');
        Assert.AreEqual(Format(ValueEntry."Invoiced Quantity" / 1.0, 0, 9), JsonMgt.GetValue('invoicedQuantity'), 'Invoiced quantity did not match.');
        Assert.AreEqual(Format(ValueEntry."Expected Cost Posted to G/L" / 1.0, 0, 9), JsonMgt.GetValue('expectedCostPostedToGL'), 'Expected cost posted to G/L did not match.');
        Assert.AreEqual(ValueEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(ValueEntry."Item Ledger Entry Type"), JsonMgt.GetValue('itemLedgerEntryType'), 'Item ledger entry type did not match.');
        Assert.AreEqual(Format(ValueEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(ValueEntry."Document Type"), JsonMgt.GetValue('documentType'), 'Document type did not match.');
        Assert.AreEqual(Format(ValueEntry."Type"), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(ValueEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestGetInventoryValueOutsideFilter()
    var
        ValueEntry: Record "Value Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Value entry exists outside of the query filter
        PermissionsMock.Assign('SUPER');
        if ValueEntry.FindLast() then;
        ValueEntry.Init();
        ValueEntry."Entry No." += 1;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Item No." := '';
        ValueEntry.Insert();
        PermissionsMock.ClearAssignments();
        Commit();

        // [WHEN] Get request for the value entry outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Value Entries - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('entryNo eq %1', ValueEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the value entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetAssemblyHeaders()
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyHeader2: Record "Assembly Header";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Assembly headers are created
        LibAssembly.CreateAssemblyOrder(AssemblyHeader, CalcDate('<+1M>', WorkDate()), '', 1);
        LibAssembly.CreateAssemblyOrder(AssemblyHeader2, CalcDate('<+1M>', WorkDate()), '', 1);
        AssemblyHeader.SetRange("Document Type", AssemblyHeader."Document Type"::Order);
        AssemblyHeader.SetFilter("No.", '%1|%2', AssemblyHeader."No.", AssemblyHeader2."No.");
        Commit();

        // [WHEN] Get request for assembly headers is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Assembly Headers - Order", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1'' OR documentNo eq ''%2''', AssemblyHeader."No.", AssemblyHeader2."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());


        // [THEN] The response contains the assembly header information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if AssemblyHeader.FindSet() then
            repeat
                VerifyAssemblyHeader(Response, AssemblyHeader);
            until AssemblyHeader.Next() = 0;
    end;

    local procedure VerifyAssemblyHeader(Response: Text; AssemblyHeader: Record "Assembly Header")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.documentNo == ''%1'')]', AssemblyHeader."No.")), 'Assembly header not found.');
        Assert.AreEqual(AssemblyHeader."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(AssemblyHeader.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(Format(AssemblyHeader."Remaining Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(AssemblyHeader."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(AssemblyHeader."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(AssemblyHeader."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(AssemblyHeader.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(Format(AssemblyHeader."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(AssemblyHeader."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetAssemblyHeaderOutsideFilter()
    var
        AssemblyHeader: Record "Assembly Header";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Assembly header exists outside of the query filter
        AssemblyHeader.Init();
        AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::Quote;
        AssemblyHeader."No." := LibUtility.GenerateRandomCode20(AssemblyHeader.FieldNo("No."), Database::"Assembly Header");
        AssemblyHeader.Insert();

        Commit();

        // [WHEN] Get request for the assembly header outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Assembly Headers - Order", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', AssemblyHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the assembly header outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetAssemblyLines()
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Assembly lines are created
        LibAssembly.CreateAssemblyOrder(AssemblyHeader, CalcDate('<+1M>', WorkDate()), '', LibRandom.RandIntInRange(2, 5));
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        Commit();

        // [WHEN] Get request for assembly lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Assembly Lines - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', AssemblyHeader."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the assembly header information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if AssemblyLine.FindSet() then
            repeat
                VerifyAssemblyLine(Response, AssemblyLine);
            until AssemblyLine.Next() = 0;
    end;

    local procedure VerifyAssemblyLine(Response: Text; AssemblyLine: Record "Assembly Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', AssemblyLine."No.")), 'Assembly line not found.');
        Assert.AreEqual(Format(AssemblyLine."Remaining Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQuantity'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(AssemblyLine."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(AssemblyLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(AssemblyLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(AssemblyLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(AssemblyLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetAssemblyLineOutsideFilter()
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Assembly lines exist outside of the query filter
        AssemblyHeader.Init();
        AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::Order;
        AssemblyHeader."No." := LibUtility.GenerateRandomCode20(AssemblyHeader.FieldNo("No."), Database::"Assembly Header");
        AssemblyHeader.Insert();
        AssemblyLine.Init();
        AssemblyLine."Document Type" := AssemblyHeader."Document Type";
        AssemblyLine."Document No." := AssemblyHeader."No.";
        AssemblyLine.Type := AssemblyLine.Type::Resource;
        AssemblyLine."No." := LibUtility.GenerateRandomCode20(AssemblyLine.FieldNo("No."), Database::"Assembly Line");
        AssemblyLine.Insert();

        Commit();

        // [WHEN] Get request for the assembly line outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Assembly Lines - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', AssemblyHeader."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the assembly line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetJobPlanningLines()
    var
        Item1: Record Item;
        Item2: Record Item;
        Job: Record Job;
        JobTask: Record "Job Task";
        JobPlanningLine: Record "Job Planning Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Job planning lines are created
        LibInv.CreateItem(Item1);
        LibInv.CreateItem(Item2);
        LibJob.CreateJob(Job);
        LibJob.CreateJobTask(Job, JobTask);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", Item1."No.");
        JobPlanningLine.Modify(true);
        LibJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::"Both Budget and Billable", JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", Item2."No.");
        JobPlanningLine.Modify(true);
        JobPlanningLine.SetFilter("No.", '%1|%2', Item1."No.", Item2."No.");

        Commit();

        // [WHEN] Get request for job planning lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Job Planning Lines - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2''', Item1."No.", Item2."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the job planning line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if JobPlanningLine.FindSet() then
            repeat
                VerifyJobPlanningLine(Response, JobPlanningLine);
            until JobPlanningLine.Next() = 0;
    end;

    local procedure VerifyJobPlanningLine(Response: Text; JobPlanningLine: Record "Job Planning Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', JobPlanningLine."No.")), 'Job planning line not found.');
        Assert.AreEqual(Format(JobPlanningLine."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Planning Date", 0, 9), JsonMgt.GetValue('planningDate'), 'Planning date did not match.');
        Assert.AreEqual(JobPlanningLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(JobPlanningLine."Document No.", JsonMgt.GetValue('documentNo'), 'Document no. did not match.');
        Assert.AreEqual(Format(JobPlanningLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(JobPlanningLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetJobPlanningLineOutsideFilter()
    var
        JobPlanningLine: Record "Job Planning Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Job planning line exists outside of the query filter
        JobPlanningLine.Init();

        JobPlanningLine."Job No." := LibUtility.GenerateRandomCode20(JobPlanningLine.FieldNo("Job No."), Database::"Job Planning Line");
        JobPlanningLine."Job Task No." := LibUtility.GenerateRandomCode20(JobPlanningLine.FieldNo("Job Task No."), Database::"Job Planning Line");
        JobPlanningLine."Document No." := LibUtility.GenerateRandomCode20(JobPlanningLine.FieldNo("Document No."), Database::"Job Planning Line");

        JobPlanningLine."Line No." := 1;
        JobPlanningLine."Line Type" := JobPlanningLine."Line Type"::"Both Budget and Billable";
        JobPlanningLine.Status := JobPlanningLine.Status::Order;
        JobPlanningLine.Type := JobPlanningLine.Type::Resource;
        JobPlanningLine."No." := LibUtility.GenerateRandomCode20(JobPlanningLine.FieldNo("No."), Database::"Job Planning Line");
        JobPlanningLine.Insert();

        JobPlanningLine."Line No." := 2;
        JobPlanningLine."Line Type" := JobPlanningLine."Line Type"::"Both Budget and Billable";
        JobPlanningLine.Status := JobPlanningLine.Status::Quote;
        JobPlanningLine.Type := JobPlanningLine.Type::Item;
        JobPlanningLine."No." := LibUtility.GenerateRandomCode20(JobPlanningLine.FieldNo("No."), Database::"Job Planning Line");
        JobPlanningLine.Insert();

        Commit();

        // [WHEN] Get request for the job planning line outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Job Planning Lines - Item", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', JobPlanningLine."Document No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the job planning line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetProdOrderLines()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order lines are created
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        ProdOrderLine.SetRange("Item No.", Item."No.");
        Commit();

        // [WHEN] Get request for production order lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Lines - Invt.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', Item."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ProdOrderLine.FindSet() then
            repeat
                VerifyProdOrderLine(Response, ProdOrderLine);
            until ProdOrderLine.Next() = 0;
    end;

    local procedure VerifyProdOrderLine(Response: Text; ProdOrderLine: Record "Prod. Order Line")
    var
        JsonMgt: Codeunit "JSON Management";

    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.documentNo == ''%1'')]', ProdOrderLine."Prod. Order No.")), 'Production order line not found.');
        Assert.AreEqual(Format(ProdOrderLine.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(ProdOrderLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Starting Date", 0, 9), JsonMgt.GetValue('startingDate'), 'Starting date did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(ProdOrderLine."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetProdOrderLineOutsideFilter()
    var
        ProdOrderLine: Record "Prod. Order Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order line exists outside of the query filter
        ProdOrderLine.Init();
        ProdOrderLine.Status := ProdOrderLine.Status::Finished;
        ProdOrderLine."Prod. Order No." := LibUtility.GenerateRandomCode20(ProdOrderLine.FieldNo("Prod. Order No."), Database::"Prod. Order Line");
        ProdOrderLine."Line No." := 1;
        ProdOrderLine."Item No." := LibUtility.GenerateRandomCode20(ProdOrderLine.FieldNo("Item No."), Database::"Prod. Order Line");
        ProdOrderLine.Insert();
        Commit();

        // [WHEN] Get request for the production order line outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Lines - Invt.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', ProdOrderLine."Prod. Order No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the production order line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestGetProdOrderCompLines()
    var
        Item: Record Item;
        ItemComp: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdOrder: Record "Production Order";
        ProdOrderComp: Record "Prod. Order Component";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order component lines are created
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');
        LibInv.CreateItem(ItemComp);
        LibManufacturing.CreateCertifiedProductionBOM(ProdBOMHeader, ItemComp."No.", LibRandom.RandDecInRange(1, 10, 2));
        Item.Validate("Production BOM No.", ProdBOMHeader."No.");
        Item.Modify(true);

        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        ProdOrderComp.SetRange("Item No.", ItemComp."No.");
        Commit();

        // [WHEN] Get request for production order component lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Comp. - Invt.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', ItemComp."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order component line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ProdOrderComp.FindSet() then
            repeat
                VerifyProdOrderCompLine(Response, ProdOrderComp);
            until ProdOrderComp.Next() = 0;
    end;

    local procedure VerifyProdOrderCompLine(Response: Text; ProdOrderComp: Record "Prod. Order Component")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.documentNo == ''%1'')]', ProdOrderComp."Prod. Order No.")), 'Production order component line not found.');
        Assert.AreEqual(Format(ProdOrderComp.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(ProdOrderComp."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(ProdOrderComp."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestGetProdOrderCompLineOutsideFilter()
    var
        ProdOrderComp: Record "Prod. Order Component";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order component line exists outside of the query filter
        ProdOrderComp.Init();
        ProdOrderComp.Status := ProdOrderComp.Status::Finished;
        ProdOrderComp."Prod. Order No." := LibUtility.GenerateRandomCode20(ProdOrderComp.FieldNo("Prod. Order No."), Database::"Prod. Order Component");
        ProdOrderComp."Line No." := 1;
        ProdOrderComp."Item No." := LibUtility.GenerateRandomCode20(ProdOrderComp.FieldNo("Item No."), Database::"Prod. Order Component");
        ProdOrderComp.Insert();
        Commit();

        // [WHEN] Get request for the production order component line outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Comp. - Invt.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('documentNo eq ''%1''', ProdOrderComp."Prod. Order No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the production order component line outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    procedure TestPlanningCompLines()
    var
        Item1: Record Item;
        Item2: Record Item;
        PlanningComponent: Record "Planning Component";
        RequisitionLine: Record "Requisition Line";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Planning component lines are created
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");
        ReqWkshTemplate.FindFirst();
        LibPlanning.CreateRequisitionWkshName(RequisitionWkshName, ReqWkshTemplate.Name);
        LibPlanning.CreateRequisitionLine(RequisitionLine, RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name);
        LibInv.CreateItem(Item1);
        LibInv.CreateItem(Item2);
        LibPlanning.CreatePlanningComponent(PlanningComponent, RequisitionLine);
        PlanningComponent.Validate("Item No.", Item1."No.");
        LibPlanning.CreatePlanningComponent(PlanningComponent, RequisitionLine);
        PlanningComponent.Validate("Item No.", Item2."No.");
        PlanningComponent.SetFilter("Item No.", '%1|%2', Item1."No.", Item2."No.");
        Commit();

        // [WHEN] Get request for planning component lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Planning Components", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1'' OR itemNo eq ''%2''', Item1."No.", Item2."No."));
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the planning component line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if PlanningComponent.FindSet() then
            repeat
                VerifyPlanningComponent(Response, PlanningComponent);
            until PlanningComponent.Next() = 0;
    end;

    local procedure VerifyPlanningComponent(Response: Text; PlanningComponent: Record "Planning Component")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', PlanningComponent."Item No.")), 'Planning component not found.');
        Assert.AreEqual(PlanningComponent."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(PlanningComponent."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(PlanningComponent."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(PlanningComponent."Expected Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('expectedQuantityBase'), 'Expected quantity (base) did not match.');
        Assert.AreEqual(Format(PlanningComponent."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(PlanningComponent."Qty. per Unit of Measure" / 1.0, 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Qty. per unit of measure did not match.');
        Assert.AreEqual(PlanningComponent."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code did not match.');
    end;

    [Test]
    procedure TestPlanningCompLineOutsideFilter()
    var
        PlanningComponent: Record "Planning Component";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Planning component line exists outside of the query filter
        PlanningComponent.Init();
        PlanningComponent."Worksheet Template Name" := LibUtility.GenerateRandomCode(PlanningComponent.FieldNo("Worksheet Template Name"), Database::"Planning Component");
        PlanningComponent."Worksheet Batch Name" := LibUtility.GenerateRandomCode(PlanningComponent.FieldNo("Worksheet Batch Name"), Database::"Planning Component");
        PlanningComponent."Worksheet Line No." := 1;
        PlanningComponent."Line No." := 1;
        PlanningComponent."Item No." := LibUtility.GenerateRandomCode20(PlanningComponent.FieldNo("Item No."), Database::"Planning Component");
        PlanningComponent."Planning Line Origin" := PlanningComponent."Planning Line Origin"::"Order Planning";
        PlanningComponent.Insert();
        Commit();

        // [WHEN] Get request for the planning component line outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Planning Components", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', PlanningComponent."Item No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the planning component line outside of the query filter
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
}

#pragma warning restore AA0247
#pragma warning restore AA0137
#pragma warning restore AA0217
#pragma warning restore AA0205
#pragma warning restore AA0210