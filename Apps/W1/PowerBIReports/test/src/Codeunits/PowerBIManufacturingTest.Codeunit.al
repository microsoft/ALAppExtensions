namespace Microsoft.Finance.PowerBIReports.Test;

using System.Utilities;
using Microsoft.Inventory.Costing;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Journal;
using Microsoft.PowerBIReports;
using Microsoft.Inventory.Journal;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Setup;
using System.Text;
using Microsoft.Inventory.Location;
using System.TestLibraries.Security.AccessControl;
using Microsoft.PowerBIReports.Test;

codeunit 139878 "PowerBI Manufacturing Test"
{
    Subtype = Test;
    Access = Internal;
    TestPermissions = Disabled;

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
        PowerBIAPIRequests: Codeunit "PowerBI API Requests";
        PowerBIAPIEndpoints: Enum "PowerBI API Endpoints";
        PowerBIFilterScenarios: Enum "PowerBI Filter Scenarios";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestInventoryAdjmtEntries()
    var
        InventoryAdjmtEntry: Record "Inventory Adjmt. Entry (Order)";
        Item: Record Item;
        LibraryUtility: Codeunit "Library - Utility";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        Index: Integer;
    begin

        // [GIVEN] Inventory Adjmt. entries are created

        InventoryAdjmtEntry.Init();
        LibInv.CreateItem(Item);
        InventoryAdjmtEntry."Order Type" := InventoryAdjmtEntry."Order Type"::Production;
        InventoryAdjmtEntry.Validate("Order No.", LibraryUtility.GenerateRandomCode(InventoryAdjmtEntry.FieldNo("Order No."), Database::"Inventory Adjmt. Entry (Order)"));
        InventoryAdjmtEntry.Validate("Order Line No.", LibRandom.RandInt(10000));
        InventoryAdjmtEntry.Validate("Item No.", Item."No.");
        InventoryAdjmtEntry.Validate("Single-Level Material Cost", Item."Single-Level Material Cost");
        InventoryAdjmtEntry.Validate("Single-Level Capacity Cost", Item."Single-Level Capacity Cost");
        InventoryAdjmtEntry.Validate("Single-Level Subcontrd. Cost", Item."Single-Level Subcontrd. Cost");
        InventoryAdjmtEntry.Validate("Single-Level Cap. Ovhd Cost", item."Single-Level Cap. Ovhd Cost");
        InventoryAdjmtEntry.Validate("Single-Level Mfg. Ovhd Cost", item."Single-Level Mfg. Ovhd Cost");
        InventoryAdjmtEntry.Validate("Is Finished", true);
        InventoryAdjmtEntry.Validate("Completely Invoiced", true);
        InventoryAdjmtEntry.Insert();
        Commit();

        // [WHEN] Get request for Inventory Adjmt. entries is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Inv. Adj. Ent Order");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'itemNo eq ''' + Item."No." + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the Inventory Adjmt. entries information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        InventoryAdjmtEntry.SetFilter(InventoryAdjmtEntry."Item No.", Item."No.");
        if InventoryAdjmtEntry.FindSet() then begin
            Index := 0;
            repeat
                VerifyInventoryAdjmtEntries(Response, InventoryAdjmtEntry, Index);
                Index += 1;
            until InventoryAdjmtEntry.Next() = 0;
        end;
    end;

    local procedure VerifyInventoryAdjmtEntries(Response: Text; InventoryAdjmtEntry: Record "Inventory Adjmt. Entry (Order)"; Index: Integer)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[' + Format(Index) + ']'), 'Inventory Adjustment Entry not found.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Item No."), JsonMgt.GetValue('itemNo'), 'Inventory Adjustment entry item no does not match');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Order Line No."), JsonMgt.GetValue('orderLineNo'), 'Inventory Adjustment entry orderLineNo does not match.');
        Assert.AreEqual(InventoryAdjmtEntry."Order No.", JsonMgt.GetValue('orderNo'), 'Inventory Adjustment entry orderNo does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Single-Level Material Cost" / 1.0, 0, 9), JsonMgt.GetValue('singleLevelMaterialCost'), 'Inventory Adjustment entry singleLevelMaterialCost does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Single-Level Capacity Cost" / 1.0, 0, 9), JsonMgt.GetValue('singleLevelCapacityCost'), 'Inventory Adjustment entry singleLevelCapacityCost does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Single-Level Subcontrd. Cost" / 1.0, 0, 9), JsonMgt.GetValue('singleLevelSubcontrdCost'), 'Inventory Adjustment entry singleLevelSubcontrdCost does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Single-Level Cap. Ovhd Cost" / 1.0, 0, 9), JsonMgt.GetValue('singleLevelCapOvhdCost'), 'Inventory Adjustment entry singleLevelCapOvhdCost does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Single-Level Mfg. Ovhd Cost" / 1.0, 0, 9), JsonMgt.GetValue('singleLevelMfgOvhdCost'), 'Inventory Adjustment entry singleLevelMfgOvhdCost does not match.');
        Assert.AreEqual(InventoryAdjmtEntry."Is Finished" ? 'True' : 'False', JsonMgt.GetValue('iSFinished'), 'Inventory Adjustment entry iSFinished does not match.');
        Assert.AreEqual(InventoryAdjmtEntry."Completely Invoiced" ? 'True' : 'False', JsonMgt.GetValue('completelyInvoiced'), 'Inventory Adjustmentr entry completely invoiced does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Indirect Cost %" / 1.0, 0, 9), JsonMgt.GetValue('indirectCostPercent'), 'Inventory Adjustment entry indirect cost percentage does not match.');
        Assert.AreEqual(Format(InventoryAdjmtEntry."Overhead Rate" / 1.0, 0, 9), JsonMgt.GetValue('overheadRate'), 'Inventory Adjustment entry overhead rate does not match.');
    end;


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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Calendar Entries");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'no eq ''' + Format(WorkCenter."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the calendar entries information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if CalendarEntry.FindSet() then begin
            Index := 0;
            repeat
                VerifyCalendarEntry(Response, CalendarEntry, Index);
                Index += 1;
            until CalendarEntry.Next() = 0;
        end;
    end;

    local procedure VerifyCalendarEntry(Response: Text; CalendarEntry: Record "Calendar Entry"; Index: Integer)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[' + Format(Index) + ']'), 'Calendar entry not found.');
        Assert.AreEqual(Format(CalendarEntry."Capacity Type"), JsonMgt.GetValue('capacityType'), 'Calendar entry capacity type does not match.');
        Assert.AreEqual(CalendarEntry."No.", JsonMgt.GetValue('no'), 'Calendar no does not match.');
        Assert.AreEqual(CalendarEntry."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Calendar entry work center group code does not match.');
        Assert.AreEqual(Format(CalendarEntry.Date, 0, 9), JsonMgt.GetValue('date'), 'Calendar entry date does not match.');
        Assert.AreEqual(Format(CalendarEntry."Capacity (Effective)" / 1.0, 0, 9), JsonMgt.GetValue('capacityEffective'), 'Calendar entry capacity effective does not match.');
        Assert.AreEqual(Format(CalendarEntry."Capacity (Total)" / 1.0, 0, 9), JsonMgt.GetValue('capacityTotal'), 'Calendar entry capacity total does not match.');
        Assert.AreEqual(CalendarEntry."Work Center No.", JsonMgt.GetValue('workCenterNo'), 'Work center no. does not match.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Machine Centers");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'workCenterNo eq ''' + Format(WorkCenter."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.no == ''' + Format(MachineCenter."No.") + ''')]'), 'Machine center not found.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Work Centers");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'no eq ''' + Format(WorkCenter."No.") + ''' or no eq ''' + Format(WorkCenter2."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.no == ''' + Format(WorkCenter."No.") + ''')]'), 'Work center not found.');
        Assert.AreEqual(WorkCenter.Name, JsonMgt.GetValue('name'), 'Work center name does not match.');
        Assert.AreEqual(WorkCenter."Work Center Group Code", JsonMgt.GetValue('workCenterGroupCode'), 'Work center work center group code does not match.');
        Assert.AreEqual(WorkCenter."Subcontractor No.", JsonMgt.GetValue('subcontractorNo'), 'Subcontractor no. does not match.');
        Assert.AreEqual(WorkCenter."Unit of Measure Code", JsonMgt.GetValue('unitOfMeasureCode'), 'Unit of measure code does not match.');
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
            Item."Flushing Method"::"Pick + Manual",
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Prod. Order Lines - Manuf.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'itemNo eq ''' + Format(Item."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.prodOrderNo == ''' + Format(ProdOrderLine."Prod. Order No.") + ''')]'), 'Production order line not found.');
        Assert.AreEqual(Format(ProdOrderLine.Status), JsonMgt.GetValue('prodOrderStatus'), 'Status did not match.');
        Assert.AreEqual(ProdOrderLine."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Quantity (Base)" / 1.0, 0, 9), JsonMgt.GetValue('quantityBase'), 'Quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(ProdOrderLine."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(ProdOrderLine."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Routing Reference No."), JsonMgt.GetValue('routingReferenceNo'), 'Routing reference no. did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Routing Type"), JsonMgt.GetValue('routingType'), 'Routing Type did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Finished Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('finishedQtyBase'), 'Finished Quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Scrap %" / 1.0, 0, 9), JsonMgt.GetValue('scrapPrc'), 'Scrap % did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Overhead Rate" / 1.0, 0, 9), JsonMgt.GetValue('overheadRate'), 'Overhead rate did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Planning Level Code", 0, 9), JsonMgt.GetValue('planningLevelCode'), 'PLanning level code did not match.');
        Assert.AreEqual(Format(ProdOrderLine."Indirect Cost %", 0, 9), JsonMgt.GetValue('indirectCostPercent'), 'Indirect cost percentage did not match.');
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
            Item."Flushing Method"::"Pick + Manual",
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Prod. Order Comp. - Manuf.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'itemNo eq ''' + Format(ItemComp."No.") + '''');
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
        Location: Record Location;
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.prodOrderNo == ''' + Format(ProdOrderComp."Prod. Order No.") + ''')]'), 'Production order component not found.');
        Assert.AreEqual(Format(ProdOrderComp.Status), JsonMgt.GetValue('prodOrderStatus'), 'Status did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Prod. Order No."), JsonMgt.GetValue('prodOrderNo'), 'Production order no did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Prod. Order Line No."), JsonMgt.GetValue('prodOrderLineNo'), 'Production order line no. did not match.');
        Assert.AreEqual(ProdOrderComp."Item No.", JsonMgt.GetValue('itemNo'), 'Item no. did not match.');
        Assert.AreEqual(ProdOrderComp."Location Code", JsonMgt.GetValue('locationCode'), 'Location code did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Expected Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('expectedQtyBase'), 'Expected quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Remaining Qty. (Base)" / 1.0, 0, 9), JsonMgt.GetValue('remainingQtyBase'), 'Remaining quantity (base) did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due date did not match.');
        Assert.AreEqual(ProdOrderComp."Routing Link Code", JsonMgt.GetValue('routingLinkCode'), 'Routing link code did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(ProdOrderComp."Cost Amount" / 1.0, 0, 9), JsonMgt.GetValue('costAmount'), 'Cost amount did not match.');
        if Location.Get(ProdOrderComp."Location Code") then
            Assert.AreEqual(Location.Name, JsonMgt.GetValue('locationName'), 'Location name did not match.');
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Prod. Order Routing Lines");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'no eq ''' + Format(WorkCenter."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@prodOrderNo == ''' + Format(ProdOrderRoutingLine."Prod. Order No.") + ''')]'), 'Production order routing line not found.');
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
        Assert.AreEqual(Format(ProdOrderRoutingLine."Routing Status"), JsonMgt.GetValue('routingStatus'), 'Routing status did not match.');
        Assert.AreEqual(ProdOrderRoutingLine."Work Center No.", JsonMgt.GetValue('workCenterNo'), 'Work Center no. did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Setup Time" / 1.0, 0, 9), JsonMgt.GetValue('setupTime'), 'Setup time did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Run Time" / 1.0, 0, 9), JsonMgt.GetValue('runTime'), 'Run time did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Wait Time" / 1.0, 0, 9), JsonMgt.GetValue('waitTime'), 'Wait time did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Move Time" / 1.0, 0, 9), JsonMgt.GetValue('moveTime'), 'Move time did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Starting Date-Time"), JsonMgt.GetValue('startingDateTime'), 'Starting date-time did not match.');
        Assert.AreEqual(Format(ProdOrderRoutingLine."Ending Date-Time"), JsonMgt.GetValue('endingDateTime'), 'Ending date-time did not match.');
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
            Item."Flushing Method"::"Pick + Manual",
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Item Ledger Entries - Prod.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'orderNo eq ''' + Format(ProdOrder."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.itemNo == ''' + Format(ItemLedgerEntry."Item No.") + ''')]'), 'Item ledger entry not found.');
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
        Assert.AreEqual(ItemLedgerEntry.Positive ? 'True' : 'False', JsonMgt.GetValue('positive'), 'Positive did not match');
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Item Ledger Entries - Prod.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'itemNo eq ''' + Format(ItemLedgerEntry."Item No.") + '''');
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
            Item."Flushing Method"::"Pick + Manual",
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
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Capacity Ledger Entries");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'orderNo eq ''' + Format(ProdOrder."No.") + '''');
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
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.orderNo == ''' + Format(CapacityLedgerEntry."Order No.") + ''')]'), 'Capacity ledger entry not found.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Entry no. did not match.');
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
        Assert.AreEqual(CapacityLedgerEntry."Work Center No.", JsonMgt.GetValue('workCenterNo'), 'Work center no did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Work Shift Code", JsonMgt.GetValue('workShiftCode'), 'Work shift code did not match.');
        Assert.AreEqual(CapacityLedgerEntry.Subcontracting ? 'True' : 'False', JsonMgt.GetValue('subcontracting'), 'Subcontracting did not match');
        Assert.AreEqual(Format(CapacityLedgerEntry."Qty. per Cap. Unit of Measure", 0, 9), JsonMgt.GetValue('qtyPerCapUnitOfMeasure'), 'Quanity per capacity unit of measure did not match.');
        Assert.AreEqual(CapacityLedgerEntry."Cap. Unit of Measure Code", JsonMgt.GetValue('capUnitOfMeasureCode'), 'Capacity unit of measure code did not match.');
        Assert.AreEqual(Format(CapacityLedgerEntry."Qty. per Unit of Measure", 0, 9), JsonMgt.GetValue('qtyPerUnitOfMeasure'), 'Quantity per unit of measure did not match.');
    end;

    [Test]
    procedure TestProdOrderCapNeeded()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrder2: Record "Production Order";
        JsonMgt: Codeunit "JSON Management";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
        Index: Integer;
    begin
        // [GIVEN] Item is created with routing
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::"Pick + Manual",
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
        Commit();

        // [WHEN] Get request for production order capacity needed is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Prod. Order Capacity Needs");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'prodOrderNo eq ''' + Format(ProdOrder."No.") + ''' or prodOrderNo eq ''' + Format(ProdOrder2."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order capacity needed information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        JsonMgt.InitializeObject(Response);
        for Index := 0 to JsonMgt.GetCount() - 1 do begin
            Assert.IsTrue(JsonMgt.SelectItemFromRoot('$..value', Index), 'Production order capacity need not found.');
            VerifyProdOrderCapNeeded(JsonMgt);
        end;
    end;

    local procedure VerifyProdOrderCapNeeded(var JsonMgt: Codeunit "JSON Management")
    var
        ProdOrderCapNeeded: Record "Prod. Order Capacity Need";
    begin
        ProdOrderCapNeeded.SetFilter(Status, JsonMgt.GetValue('status'));
        ProdOrderCapNeeded.SetRange("Prod. Order No.", JsonMgt.GetValue('prodOrderNo'));
        ProdOrderCapNeeded.SetRange("Routing No.", JsonMgt.GetValue('routingNo'));
        ProdOrderCapNeeded.SetRange("Operation No.", JsonMgt.GetValue('operationNo'));
        ProdOrderCapNeeded.SetFilter("Routing Reference No.", JsonMgt.GetValue('routingReferenceNo'));
        ProdOrderCapNeeded.SetRange("Requested Only", JsonMgt.GetValue('requestedOnly') = 'True');
        ProdOrderCapNeeded.SetFilter("Line No.", JsonMgt.GetValue('lineNo'));
        ProdOrderCapNeeded.FindFirst();
        Assert.AreEqual(Format(ProdOrderCapNeeded."Allocated Time" / 1.0, 0, 9), JsonMgt.GetValue('allocatedTime'), 'Allocated time did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded."Requested Only" ? 'True' : 'False'), JsonMgt.GetValue('requestedOnly'), 'Requested only did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded."Work Center No."), JsonMgt.GetValue('workCenterNo'), 'Work Center No. did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded."Work Center Group Code"), JsonMgt.GetValue('workCenterGroupCode'), 'Work Center Group Code did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded.Date, 0, 9), JsonMgt.GetValue('date'), 'Date did not match.');
        Assert.AreEqual(ProdOrderCapNeeded."No.", JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded."Needed Time (ms)" / 1.0, 0, 9), JsonMgt.GetValue('neededTimeMs'), 'Needed Time (ms) did not match.');
        Assert.AreEqual(Format(ProdOrderCapNeeded."Needed Time" / 1.0, 0, 9), JsonMgt.GetValue('neededTime'), 'Needed time did not match.');
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

        ExpectedFilterTxt := Format(Today()) + '..' + Format(Today() + 10);

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
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

        ExpectedFilterTxt := Format(CalcDate(PBISetup."Manufacturing Date Formula")) + '..';

        // [WHEN] GenerateManufacturingReportDateFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date");

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
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
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date");

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
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

        ExpectedFilterTxt := Format(CreateDateTime(Today(), 0T)) + '..' + Format(CreateDateTime(Today() + 10, 0T));

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date Time");

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_RelativeDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
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

        ExpectedFilterTxt := Format(CreateDateTime(CalcDate(PBISetup."Manufacturing Date Formula"), 0T)) + '..';

        // [WHEN] GenerateManufacturingReportDateTimeFilter executes 
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date Time");

        // [THEN] A filter text of format "%1.." should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateManufacturingReportDateTimeFilter_Blank()
    var
        PBISetup: Record "PowerBI Reports Setup";
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
        ActualFilterTxt := PowerBIAPIRequests.GetFilterForQueryScenario(PowerBIFilterScenarios::"Manufacturing Date Time");

        // [THEN] A blank filter text should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestManufacturingSetup()
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] "Show Capacity In" is set in Manufacturing Setup
        LibManufacturing.CreateCapacityUnitOfMeasure(CapacityUnitOfMeasure, Enum::"Capacity Unit of Measure"::Minutes);
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Show Capacity In", CapacityUnitOfMeasure.Code);
        ManufacturingSetup.Modify(true);
        Commit();

        // [WHEN] Get request for manufacturing setup is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Manufacturing Setup");
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the capacity unit of measure as specified in Manufacturing Setup 
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyManufacturingSetup(Response, CapacityUnitOfMeasure);
    end;

    local procedure VerifyManufacturingSetup(Response: Text; CapacityUnitOfMeasure: Record "Capacity Unit of Measure")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.showCapacityIn == ''' + Format(CapacityUnitOfMeasure.Code) + ''')]'), 'Show Capacity In not found.');
        Assert.AreEqual(CapacityUnitOfMeasure.Code, JsonMgt.GetValue('showCapacityIn'), 'Capacity Unit of Measure did not match.');
    end;

    [Test]
    procedure TestGetProductionOrders()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ProdOrder2: Record "Production Order";
        Location: Record Location;
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Production orders are created
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::"Pick + Manual",
            '', '');

        LibWhse.CreateLocation(Location);
        LibManufacturing.CreateProductionOrder(ProdOrder, ProdOrder.Status::Released, ProdOrder."Source Type"::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        ProdOrder.Validate("Location Code", Location.Code);
        ProdOrder.Modify(true);
        LibManufacturing.RefreshProdOrder(ProdOrder, false, true, true, true, false);

        LibManufacturing.CreateProductionOrder(ProdOrder2, ProdOrder2.Status::Released, ProdOrder2."Source Type"::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        ProdOrder2.Validate("Location Code", Location.Code);
        ProdOrder.Modify(true);
        LibManufacturing.RefreshProdOrder(ProdOrder2, false, true, true, true, false);
        Commit();

        // [WHEN] Get request for production orders is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Production Orders");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'status eq ''' + Format(ProdOrder.Status) + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the production order information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyProductionOrder(Response, ProdOrder);
        VerifyProductionOrder(Response, ProdOrder2);
    end;

    local procedure VerifyProductionOrder(Response: Text; ProdOrder: Record "Production Order")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.no == ''' + Format(ProdOrder."No.") + ''')]'), 'Production order not found.');
        Assert.AreEqual(ProdOrder."No.", JsonMgt.GetValue('no'), 'Production Order No. did not match.');
        Assert.AreEqual(Format(ProdOrder.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(Format(ProdOrder."Source Type"), JsonMgt.GetValue('sourceType'), 'Source type did not match.');
        Assert.AreEqual(ProdOrder."Source No.", JsonMgt.GetValue('sourceNo'), 'Source No. did not match.');
        Assert.AreEqual(ProdOrder."Routing No.", JsonMgt.GetValue('routingNo'), 'Routing No. did not match.');
        Assert.AreEqual(Format(ProdOrder."Starting Date", 0, 9), JsonMgt.GetValue('startingDate'), 'Starting Date did not match.');
        Assert.AreEqual(Format(ProdOrder."Ending Date", 0, 9), JsonMgt.GetValue('endingDate'), 'Ending Date did not match.');
        Assert.AreEqual(Format(ProdOrder."Due Date", 0, 9), JsonMgt.GetValue('dueDate'), 'Due Date did not match.');
        Assert.AreEqual(Format(ProdOrder.Quantity / 1.0, 0, 9), JsonMgt.GetValue('quantity'), 'Quantity did not match.');
        Assert.AreEqual(ProdOrder.Description, JsonMgt.GetValue('description'), 'Description did not match');
    end;

    [Test]
    procedure TestGetRoutingLinks()
    var
        RoutingLink: Record "Routing Link";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Routing links are created
        LibManufacturing.CreateRoutingLink(RoutingLink);

        Commit();

        // [WHEN] Get request for routing links is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Routing Links");
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the routing link information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if RoutingLink.FindSet() then
            repeat
                VerifyRoutingLinks(Response, RoutingLink);
            until RoutingLink.Next() = 0;
    end;

    local procedure VerifyRoutingLinks(Response: Text; RoutingLink: Record "Routing Link")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.code == ''' + Format(RoutingLink.Code) + ''')]'), 'Routing link not found.');
        Assert.AreEqual(RoutingLink.Code, JsonMgt.GetValue('code'), 'Routing Link Code did not match.');
        Assert.AreEqual(RoutingLink.Description, JsonMgt.GetValue('description'), 'Description did not match.');
    end;

    [Test]
    procedure TestGetRoutings()
    var
        RoutingHeader: Record "Routing Header";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Routing headers are created
        LibManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Parallel);
        LibManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        Commit();

        // [WHEN] Get request for routing headers is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::Routings);
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the routing header information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if RoutingHeader.FindSet() then
            repeat
                VerifyRoutingHeaders(Response, RoutingHeader);
            until RoutingHeader.Next() = 0;
    end;

    local procedure VerifyRoutingHeaders(Response: Text; RoutingHeader: Record "Routing Header")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.no == ''' + Format(RoutingHeader."No.") + ''')]'), 'Routing header not found.');
        Assert.AreEqual(RoutingHeader."No.", JsonMgt.GetValue('no'), 'Routing header no. did not match.');
        Assert.AreEqual(Format(RoutingHeader.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(RoutingHeader.Status), JsonMgt.GetValue('status'), 'Status did not match.');
        Assert.AreEqual(RoutingHeader.Description, JsonMgt.GetValue('description'), 'Description did not match.');
    end;

    [Test]
    procedure TestGetWorkCenterGroups()
    var
        WorkCenterGroup: Record "Work Center Group";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Work center groups are created
        LibManufacturing.CreateWorkCenterGroup(WorkCenterGroup);
        LibManufacturing.CreateWorkCenterGroup(WorkCenterGroup);

        Commit();

        // [WHEN] Get request for work center groups is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Work Center Groups");
        UriBuilder.Init(TargetURL);
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the work center group information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        if WorkCenterGroup.FindSet() then
            repeat
                VerifyWorkCenterGroups(Response, WorkCenterGroup);
            until WorkCenterGroup.Next() = 0;
    end;

    local procedure VerifyWorkCenterGroups(Response: Text; WorkCenterGroup: Record "Work Center Group")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.code == ''' + Format(WorkCenterGroup.Code) + ''')]'), 'Work center group not found.');
        Assert.AreEqual(WorkCenterGroup.Code, JsonMgt.GetValue('code'), 'Code did not match.');
        Assert.AreEqual(WorkCenterGroup.Name, JsonMgt.GetValue('name'), 'Name did not match.');
    end;

    [Test]
    procedure TestGetManufacturingValueEntries()
    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ValueEntry: Record "Value Entry";
        Location: Record Location;
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Manufacturing value entries are created
        LibManufacturing.CreateItemManufacturing(
            Item,
            Item."Costing Method"::Standard,
            LibRandom.RandDecInRange(1, 10, 2),
            Item."Reordering Policy"::Order,
            Item."Flushing Method"::"Pick + Manual",
            '', '');

        LibWhse.CreateLocation(Location);
        LibManufacturing.CreateProductionOrder(ProdOrder, ProdOrder.Status::Released, ProdOrder."Source Type"::Item, Item."No.", LibRandom.RandDecInRange(1, 10, 2));
        ProdOrder.Validate("Location Code", Location.Code);
        ProdOrder.Modify(true);
        LibManufacturing.RefreshProdOrder(ProdOrder, false, true, true, true, false);

        LibManufacturing.OutputJournalExplodeRouting(ProdOrder);
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Output);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();

        LibInv.UpdateInventoryPostingSetup(Location);

        LibInv.CreateInventoryPostingGroup(InventoryPostingGroup);
        LibInv.CreateInventoryPostingSetup(InventoryPostingSetup, Location.Code, InventoryPostingGroup.Code);
        LibInv.PostItemJournalBatch(ItemJournalBatch);

        ValueEntry.SetRange("Item Ledger Entry Type", Enum::"Item Ledger Entry Type"::Output);
        ValueEntry.FindLast();

        Commit();

        // [WHEN] Get request for manufacturing value entries is made
        TargetURL := PowerBIAPIRequests.GetEndpointURL(PowerBIAPIEndpoints::"Value Entries - Manuf.");
        UriBuilder.Init(TargetURL);
        UriBuilder.AddODataQueryParameter('$filter', 'itemNo eq ''' + Format(Item."No.") + '''');
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the manufacturing value entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyManufacturingValueEntry(Response, ValueEntry);
    end;

    local procedure VerifyManufacturingValueEntry(Response: Text; ValueEntry: Record "Value Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot('$..value[?(@.entryNo == ' + Format(ValueEntry."Entry No.") + ')]'), 'Value entry not found.');
        Assert.AreEqual(Format(ValueEntry."Entry No."), JsonMgt.GetValue('entryNo'), 'Entry No. did not match.');
        Assert.AreEqual(Format(ValueEntry."Item No."), JsonMgt.GetValue('itemNo'), 'Item No. did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Actual)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountActual'), 'Cost Amount (Actual) did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost per Unit" / 1.0, 0, 9), JsonMgt.GetValue('costPerUnit'), 'Cost Per Unit did not match.');
        Assert.AreEqual(Format(ValueEntry."Item Ledger Entry Quantity", 0, 9), JsonMgt.GetValue('itemLedgerEntryQuantity'), 'Item Ledger Entry Quantity did not match.');
        Assert.AreEqual(Format(ValueEntry."Valued Quantity", 0, 9), JsonMgt.GetValue('valuedQuantity'), 'Valued Quantity did not match.');
        Assert.AreEqual(ValueEntry."Location Code", JsonMgt.GetValue('locationCode'), 'Location Code did not match.');
        Assert.AreEqual(Format(ValueEntry."Item Ledger Entry Type"), JsonMgt.GetValue('itemLedgerEntryType'), 'Item Ledger Entry Type did not match.');
        Assert.AreEqual(Format(ValueEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting Date did not match.');
        Assert.AreEqual(Format(ValueEntry.Type), JsonMgt.GetValue('type'), 'Type did not match.');
        Assert.AreEqual(Format(ValueEntry."No."), JsonMgt.GetValue('no'), 'No. did not match.');
        Assert.AreEqual(Format(ValueEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(ValueEntry."Valuation Date", 0, 9), JsonMgt.GetValue('valuationDate'), 'Valuation Date did not match.');
        Assert.AreEqual(Format(ValueEntry."Entry Type"), JsonMgt.GetValue('entryType'), 'Entry Type did not match.');
        Assert.AreEqual(Format(ValueEntry."Capacity Ledger Entry No."), JsonMgt.GetValue('capacityLedgerEntryNo'), 'Capacity ledger entry No. did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Amount (Expected)" / 1.0, 0, 9), JsonMgt.GetValue('costAmountExpected'), 'Cost Amount (Expected) did not match.');
        Assert.AreEqual(Format(ValueEntry."Cost Posted to G/L" / 1.0, 0, 9), JsonMgt.GetValue('costPostedtoGL'), 'Cost posted to G/L did not match.');
        Assert.AreEqual(Format(ValueEntry."Expected Cost Posted to G/L" / 1.0, 0, 9), JsonMgt.GetValue('expectedCostPostedtoGL'), 'Expected cost posted to G/L did not match.');
        Assert.AreEqual(Format(ValueEntry."Order Type"), JsonMgt.GetValue('orderType'), 'Order Type did not match.');
        Assert.AreEqual(Format(ValueEntry."Order No."), JsonMgt.GetValue('orderNo'), 'Order No. did not match.');
        Assert.AreEqual(Format(ValueEntry."Expected Cost" ? 'True' : 'False'), JsonMgt.GetValue('expectedCost'), 'Expected cost did not match.');
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