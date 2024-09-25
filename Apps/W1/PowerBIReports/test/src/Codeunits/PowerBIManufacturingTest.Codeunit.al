#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Journal;
using Microsoft.PowerBIReports;
using Microsoft.Manufacturing.PowerBIReports;
using Microsoft.Inventory.Journal;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using System.Text;
using Microsoft.Inventory.Location;
using System.TestLibraries.Security.AccessControl;

codeunit 139878 "PowerBI Manufacturing Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibManufacturing: Codeunit "Library - Manufacturing";
        LibInv: Codeunit "Library - Inventory";
        LibWhse: Codeunit "Library - Warehouse";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestGetCalendarEntries()
    var
        WorkCenter: Record "Work Center";
        CalendarEntry: Record "Calendar Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        Index: Integer;
    begin
        // [GIVEN] Calendar entries are created
        LibManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        CalendarEntry.SetRange("No.", WorkCenter."No.");
        Commit();

        // [WHEN] Get request for calendar entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Calendar Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('no eq ''%1''', WorkCenter."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the calendar entries information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if CalendarEntry.FindSet() then
            repeat
                VerifyCalendarEntry(Response, CalendarEntry, Index);
                Index += 1;
            until CalendarEntry.Next() = 0;
    end;

    local procedure VerifyCalendarEntry(Response: Text; CalendarEntry: Record "Calendar Entry"; Index: Integer)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[%1]', Index)), 'Calendar entry not found.');
        Assert.AreEqual(Format(CalendarEntry."Capacity Type"), JsonMgt.GetValue('capacityType'), 'Calendar entry capacity type does not match.');
        Assert.AreEqual(CalendarEntry."No.", JsonMgt.GetValue('no'), 'Calendar no does not match.');
        Assert.AreEqual(CalendarEntry."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Calendar entry work center group code does not match.');
        Assert.AreEqual(Format(CalendarEntry.Date, 0, 9), JsonMgt.GetValue('date'), 'Calendar entry date does not match.');
        Assert.AreEqual(Format(CalendarEntry."Capacity (Effective)" / 1.0, 0, 9), JsonMgt.GetValue('capacityEffective'), 'Calendar entry capacity effective does not match.');
    end;

    [Test]
    procedure TestGetMachineCenters()
    var
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Machine centers are created
        LibManufacturing.CreateWorkCenter(WorkCenter);
        LibManufacturing.CreateMachineCenter(MachineCenter, WorkCenter."No.", 1);
        LibManufacturing.CreateMachineCenter(MachineCenter, WorkCenter."No.", 1);
        MachineCenter.SetRange("Work Center No.", WorkCenter."No.");
        Commit();

        // [WHEN] Get request for machine centers is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Machine Centers", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('workCenterNo eq ''%1''', WorkCenter."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the machine centers information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if MachineCenter.FindSet() then
            repeat
                VerifyMachineCenter(Response, MachineCenter);
            until MachineCenter.Next() = 0;
    end;

    local procedure VerifyMachineCenter(Response: Text; MachineCenter: Record "Machine Center")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', MachineCenter."No.")), 'Machine center not found.');
        Assert.AreEqual(MachineCenter.Name, JsonMgt.GetValue('name'), 'Machine center name does not match.');
        Assert.AreEqual(MachineCenter."Work Center No.", JsonMgt.GetValue('workCenterNo'), 'Machine center work center no does not match.');
    end;

    [Test]
    procedure TestGetWorkCenters()
    var
        WorkCenterGroup: Record "Work Center Group";
        WorkCenter: Record "Work Center";
        WorkCenter2: Record "Work Center";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Work centers are created
        LibManufacturing.CreateWorkCenterGroup(WorkCenterGroup);
        LibManufacturing.CreateWorkCenter(WorkCenter);
        LibManufacturing.CreateWorkCenter(WorkCenter2);
        WorkCenter.SetFilter("No.", '%1|%2', WorkCenter."No.", WorkCenter2."No.");
        Commit();

        // [WHEN] Get request for work centers is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Work Centers", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('no eq ''%1'' OR no eq ''%2''', WorkCenter."No.", WorkCenter2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the work centers information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WorkCenter.FindSet() then
            repeat
                VerifyWorkCenter(Response, WorkCenter);
            until WorkCenter.Next() = 0;
    end;

    local procedure VerifyWorkCenter(Response: Text; WorkCenter: Record "Work Center")
    var
        WorkCenterGroup: Record "Work Center Group";
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.no == ''%1'')]', WorkCenter."No.")), 'Work center not found.');
        Assert.AreEqual(WorkCenter.Name, JsonMgt.GetValue('name'), 'Work center name does not match.');
        Assert.AreEqual(WorkCenter."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Work center work center group code does not match.');
        WorkCenterGroup.Get(WorkCenter."Work Center Group Code");
        Assert.AreEqual(WorkCenterGroup.Name, JsonMgt.GetValue('workCenterGroupName'), 'Work center work center group name does not match.');
    end;

    [Test]
    procedure TestGetProdOrderLines()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        Location: Record Location;
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

        LibWhse.CreateLocation(Location);
        LibManufacturing.CreateProductionOrder(ProdOrder, ProdOrder.Status::Released, ProdOrder."Source Type"::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        ProdOrder.Validate("Location Code", Location.Code);
        ProdOrder.Modify(true);
        LibManufacturing.RefreshProdOrder(ProdOrder, false, true, true, true, false);
        LibManufacturing.CreateProductionOrder(ProdOrder, ProdOrder.Status::Released, ProdOrder."Source Type"::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        ProdOrder.Validate("Location Code", Location.Code);
        ProdOrder.Modify(true);
        LibManufacturing.RefreshProdOrder(ProdOrder, false, true, true, true, false);

        ProdOrderLine.SetRange("Item No.", Item."No.");
        Commit();

        // [WHEN] Get request for production order lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Lines - Manuf.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', Item."No."));
        UriBuilder.GetUri(Uri);
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
        Location: Record Location;
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.prodOrderNo == ''%1'')]', ProdOrderLine."Prod. Order No.")), 'Production order line not found.');
        Assert.AreEqual(Format(ProdOrderLine.Status), JsonMgt.GetValue('prodOrderStatus'), 'Status did not match.');
        Assert.AreEqual(ProdOrderLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(ProdOrderLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(ProdOrderLine."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Routing Reference No."), JsonMgt.GetValue('routingReferenceNo'), 'Routing reference no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Location.Get(ProdOrderLine."Location Code");
        Assert.AreEqual(Location.Name, JsonMgt.GetValue('locationName'), 'Location name did not match.');
    end;

    [Test]
    procedure TestGetProdOrderCompLines()
    var
        Item: Record Item;
        ItemComp: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrderComp: Record "Prod. Order Component";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order components are created
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');
        LibInv.CreateItem(ItemComp);
        CreateBOMForItem(Item, ItemComp);

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
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Comp. - Manuf.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', ItemComp."No."));
        UriBuilder.GetUri(Uri);
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.prodOrderNo == ''%1'')]', ProdOrderComp."Prod. Order No.")), 'Production order component not found.');
        Assert.AreEqual(Format(ProdOrderComp.Status), JsonMgt.GetValue('prodOrderStatus'), 'Status did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Prod. Order Line No."), JsonMgt.GetValue('prodOrderLineNo'), 'Production order line no. did not match.');
        Assert.AreEqual(ProdOrderComp."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(ProdOrderComp."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Expected Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('expectedQtyBase'), 'Expected quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(ProdOrderComp."Routing Link Code", JsonMgt.GetValue('routingLinkCode'), 'Routing link code did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestGetProdOrderRoutingLines()
    var
        Item: Record Item;
        WorkCenter: Record "Work Center";
        ProdOrder: Record "Production Order";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production order routing lines are created
        LibInv.CreateItem(Item);
        CreateRoutingForItem(Item);
        Item.Validate("Replenishment System", Item."Replenishment System"::"Prod. Order");
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

        ProdOrderRoutingLine.SetRange("No.", WorkCenter."No.");
        Commit();

        // [WHEN] Get request for production order routing lines is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Routing Lines", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('no eq ''%1''', WorkCenter."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order routing line information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ProdOrderRoutingLine.FindSet() then
            repeat
                VerifyProdOrderRoutingLine(Response, ProdOrderRoutingLine);
            until ProdOrderRoutingLine.Next() = 0;
    end;

    local procedure VerifyProdOrderRoutingLine(Response: Text; ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@prodOrderNo == ''%1'')]', ProdOrderRoutingLine."Prod. Order No.")), 'Production order routing line not found.');
        Assert.AreEqual(Format(ProdOrderRoutingLine.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Type"), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(ProdOrderRoutingLine.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Expected Capacity Need" / 1.0, 0, 9), JsonMgt.GetValue('expectedCapacityNeed'), 'Expected capacity need did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Expected Operation Cost Amt." / 1.0, 0, 9), JsonMgt.GetValue('expectedOperationCostAmt'), 'Expected operation cost amount did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Expected Capacity Ovhd. Cost" / 1.0, 0, 9), JsonMgt.GetValue('expectedCapacityOvhdCost'), 'Expected capacity overhead cost did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Ending Date", 0, 9), JsonMgt.GetValue('endingDate'), 'Ending date did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing no. did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Routing Reference No."), JsonMgt.GetValue('routingReferenceNo'), 'Routing reference no. did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Operation No.", JsonMgt.GetValue('operationNo'), 'Operation no. did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Work center group code did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Routing Link Code", JsonMgt.GetValue('routingLinkCode'), 'Routing link code did not match.');
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure TestGetProdItemLedgerEntries()
    var
        Item: Record Item;
        ItemComp: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Item is created with production BOM and routing
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');

        CreateRoutingForItem(Item);

        LibInv.CreateItem(ItemComp);
        CreateBOMForItem(Item, ItemComp);

        // [GIVEN] Production order is posted with consumption and output
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine.FindFirst();
        Commit();

        LibManufacturing.OpenProductionJournal(ProdOrder, ProdOrderLine."Line No.");
        ItemLedgerEntry.SetRange("Order No.", ProdOrder."No.");
        Commit();

        // [WHEN] Get request for production item ledger entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Ledger Entries - Prod.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('orderNo eq ''%1''', ProdOrder."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production item ledger entries information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ItemLedgerEntry.FindSet() then
            repeat
                VerifyProdItemLedgerEntry(Response, ItemLedgerEntry);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure VerifyProdItemLedgerEntry(Response: Text; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.itemNo == ''%1'')]', ItemLedgerEntry."Item No.")), 'Item ledger entry not found.');
        Assert.AreEqual(Format(ItemLedgerEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Entry type did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Order Type"), JsonMgt.GetValue('orderType'), 'Order type did not match.');
        Assert.AreEqual(ItemLedgerEntry."Order No.", JsonMgt.GetValue('orderNo'), 'Order no. did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Order Line No."), JsonMgt.GetValue('orderLineNo'), 'Order line no. did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(ItemLedgerEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(ItemLedgerEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(ItemLedgerEntry."Serial No.", JsonMgt.GetValue('serialNo'), 'Serial no. did not match.');
        Assert.AreEqual(ItemLedgerEntry."Lot No.", JsonMgt.GetValue('lotNo'), 'Lot no. did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Cost amount (actual) did not match.');
        Assert.AreEqual(Format(ItemLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestGetProdItemLedgerEntriesOutsideFilter()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Item ledger entries exist outside of the query filter
        PermissionsMock.Assign('SUPER');
        if ItemLedgerEntry.FindLast() then;
        ItemLedgerEntry.Init();

        ItemLedgerEntry."Entry No." += 1;
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
        ItemLedgerEntry."Item No." := LibUtility.GenerateRandomCode20(ItemLedgerEntry.FieldNo("Item No."), Database::"Item Ledger Entry");
        ItemLedgerEntry.Insert();

        ItemLedgerEntry."Entry No." += 1;
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::"Positive Adjmt.";
        ItemLedgerEntry.Insert();

        ItemLedgerEntry."Entry No." += 1;
        ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::"Assembly Consumption";
        ItemLedgerEntry.Insert();
        PermissionsMock.ClearAssignments();
        Commit();

        // [WHEN] Get request for the item ledger entries outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Item Ledger Entries - Prod.", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('itemNo eq ''%1''', ItemLedgerEntry."Item No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the item ledger entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure TestCapacityLedgerEntry()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Item is created with routing
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');

        CreateRoutingForItem(Item);

        // [GIVEN] Production order is posted capacity
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine.FindFirst();
        Commit();

        LibManufacturing.OpenProductionJournal(ProdOrder, ProdOrderLine."Line No.");
        CapacityLedgerEntry.SetRange("Order No.", ProdOrder."No.");
        Commit();

        // [WHEN] Get request for production item ledger entries is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Capacity Ledger Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('orderNo eq ''%1''', ProdOrder."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production item ledger entries information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if CapacityLedgerEntry.FindSet() then
            repeat
                VerifyCapacityLedgerEntry(Response, CapacityLedgerEntry);
            until CapacityLedgerEntry.Next() = 0;
    end;

    local procedure VerifyCapacityLedgerEntry(Response: Text; CapacityLedgerEntry: Record "Capacity Ledger Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.orderNo == ''%1'')]', CapacityLedgerEntry."Order No.")), 'Capacity ledger entry not found.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Order Type"), JsonMgt.GetValue('orderType'), 'Order type did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Order No.", JsonMgt.GetValue('orderNo'), 'Order no. did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Order Line No."), JsonMgt.GetValue('orderLineNo'), 'Order line no. did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(CapacityLedgerEntry."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(CapacityLedgerEntry.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Setup Time" / 1.0, 0, 9), JsonMgt.GetValue('setupTime'), 'Setup time did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Run Time" / 1.0, 0, 9), JsonMgt.GetValue('runTime'), 'Run time did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Stop Time" / 1.0, 0, 9), JsonMgt.GetValue('stopTime'), 'Stop time did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Output Quantity" / 1.0, 0, 9), JsonMgt.GetValue('outputQuantity'), 'Output quantity did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Scrap Quantity" / 1.0, 0, 9), JsonMgt.GetValue('scrapQuantity'), 'Scrap quantity did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Direct Cost" / 1.0, 0, 9), JsonMgt.GetValue('directCost'), 'Direct cost did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Overhead Cost" / 1.0, 0, 9), JsonMgt.GetValue('overheadCost'), 'Overhead cost did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing no. did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Routing Reference No."), JsonMgt.GetValue('routingReferenceNo'), 'Routing reference no. did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Operation No.", JsonMgt.GetValue('operationNo'), 'Operation no. did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Work center group code did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Scrap Code", JsonMgt.GetValue('scrapCode'), 'Scrap code did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestProdOrderCapNeeded()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrder2: Record "Production Order";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Item is created with routing
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::Manual,
            '', '');

        CreateRoutingForItem(Item);

        // [GIVEN] Production order is posted capacity
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder,
            ProdOrder.Status::Released,
            ProdOrder."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        LibManufacturing.CreateAndRefreshProductionOrder(
            ProdOrder2,
            ProdOrder2.Status::Released,
            ProdOrder2."Source Type"::Item,
            Item."No.",
            LibRandom.RandDecInRange(1, 10, 2));
        ProdOrderRoutingLine.SetFilter("Prod. Order No.", '%1|%2', ProdOrder."No.", ProdOrder2."No.");
        // ProdOrderCapNeeded.SetFilter("Prod. Order No.", '%1|%2', ProdOrder."No.", ProdOrder2."No.");
        Commit();

        // [WHEN] Get request for production order capacity needed is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Prod. Order Capacity Needs", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', StrSubstNo('prodOrderNo eq ''%1'' OR prodOrderNo eq ''%2''', ProdOrder."No.", ProdOrder2."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order capacity needed information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if ProdOrderRoutingLine.FindSet() then
            repeat
                VerifyProdOrderCapNeeded(Response, ProdOrderRoutingLine);
            until ProdOrderRoutingLine.Next() = 0;
    end;

    local procedure VerifyProdOrderCapNeeded(Response: Text; ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        ProdOrderCapNeeded: Record "Prod. Order Capacity Need";
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.prodOrderNo == ''%1'')]', ProdOrderRoutingLine."Prod. Order No.")), 'Production order capacity need not found.');
        Assert.AreEqual(Format(ProdOrderRoutingLine.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Prod. Order No.", JsonMgt.GetValue('prodOrderNo'), 'Production order no. did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing no. did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Routing Reference No."), JsonMgt.GetValue('routingReferenceNo'), 'Routing reference no. did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Operation No.", JsonMgt.GetValue('operationNo'), 'Operation no. did not match.');
        ProdOrderCapNeeded.SetRange(Status, ProdOrderRoutingLine.Status);
        ProdOrderCapNeeded.SetRange("Prod. Order No.", ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderCapNeeded.SetRange("Routing No.", ProdOrderRoutingLine."Routing No.");
        ProdOrderCapNeeded.SetRange("Operation No.", ProdOrderRoutingLine."Operation No.");
        ProdOrderCapNeeded.CalcSums("Allocated Time");
        Assert.AreEqual(Format(ProdOrderCapNeeded."Allocated Time" / 1.0, 0, 9), JsonMgt.GetValue('allocatedTime'), 'Allocated time did not match.');
    end;

    local procedure CreateRoutingForItem(var Item: Record Item)
    var
        WorkCenter: Record "Work Center";
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
    begin
        LibManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        LibManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibManufacturing.CreateRoutingLine(
            RoutingHeader,
            RoutingLine,
            '',
            Format(LibRandom.RandInt(100)),
            RoutingLine.Type::"Work Center",
            WorkCenter."No.");
        RoutingLine.Validate("Setup Time", LibRandom.RandDecInRange(10, 100, 0));
        RoutingLine.Modify(true);
        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);
        Item.Validate("Routing No.", RoutingHeader."No.");
        Item.Modify(true);
    end;

    local procedure CreateBOMForItem(var Item: Record Item; ItemComp: Record Item)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibManufacturing.CreateCertifiedProductionBOM(ProdBOMHeader, ItemComp."No.", LibRandom.RandDecInRange(1, 10, 2));
        Item.Validate("Production BOM No.", ProdBOMHeader."No.");
        Item.Modify(true);
        LibInv.CreateItemJournalLineInItemTemplate(ItemJournalLine, ItemComp."No.", '', '', 10000);
        LibInv.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
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

    [ModalPageHandler]
    procedure ProductionJournalModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        ProductionJournal.Post.Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Manufacturing Start Date" := Today();
        PBISetup."Manufacturing End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Manufacturing Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', CalcDate(PBISetup."Manufacturing Date Formula"));

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateFilter();

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Start/End Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Start/End Date";

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Manufacturing Start Date" := Today();
        PBISetup."Manufacturing End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Format(CreateDateTime(Today(), 0T)), Format(CreateDateTime(Today() + 10, 0T)));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = "Relative Date"
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::"Relative Date";

        // [GIVEN] A mock date formula value
        Evaluate(PBISetup."Manufacturing Date Formula", '30D');
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..', Format(CreateDateTime(CalcDate(PBISetup."Manufacturing Date Formula"), 0T)));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Manuf. Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateManufacturingReportDateTimeFilter
        // [GIVEN] Power BI setup record is created with Load Date Type = " "
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PBISetup."Manufacturing Load Date Type" := PBISetup."Manufacturing Load Date Type"::" ";
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PBIMgt.GenerateManufacturingReportDateTimeFilter();

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