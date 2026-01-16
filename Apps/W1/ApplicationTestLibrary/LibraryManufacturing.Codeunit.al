#pragma warning disable AL0801
/// <summary>
/// Provides utility functions for creating and managing manufacturing-related entities in test scenarios, including production orders, BOMs, routings, and work centers.
/// </summary>
codeunit 132202 "Library - Manufacturing"
{

    trigger OnRun()
    begin
    end;

    var
        ManufacturingSetup: Record "Manufacturing Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        Assert: Codeunit Assert;
        BOMItemLineNo: Integer;
        BatchName: Label 'DEFAULT', Comment = 'Default Batch';
        OutputConsumpMismatchTxt: Label 'Output Cost in Prod. Order %1, line %2 does not match Consumption.';
        OutputVarianceMismatchTxt: Label 'Output Cost including Variance in Prod. Order %1, line %2 does not match total Standard Cost of Produced Item.';
        Text003Msg: Label 'Inbound Whse. Requests are created.';
        Text004Msg: Label 'No Inbound Whse. Request is created.';
        Text005Msg: Label 'Inbound Whse. Requests have already been created.';

    procedure AddProdBOMItem(var MfgItem: Record Item; SubItemNo: Code[20]; Qty: Decimal)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMLine: Record "Production BOM Line";
        subItem: Record Item;
    begin
        if MfgItem.IsMfgItem() then
            ProdBOMHeader.Get(MfgItem."Production BOM No.")
        else begin
            ProdBOMHeader."No." := CopyStr(MfgItem."No." + 'BOM', 1, MaxStrLen(ProdBOMHeader."No."));
            ProdBOMHeader.Status := ProdBOMHeader.Status::Certified;
            ProdBOMHeader.Insert();
            MfgItem."Production BOM No." := ProdBOMHeader."No.";
            MfgItem."Replenishment System" := MfgItem."Replenishment System"::"Prod. Order";
            MfgItem.Modify();
        end;
        ProdBOMLine."Production BOM No." := ProdBOMHeader."No.";
        BOMItemLineNo += 1;
        ProdBOMLine."Line No." := BOMItemLineNo;
        ProdBOMLine.Type := ProdBOMLine.Type::Item;
        ProdBOMLine."No." := SubItemNo;
        subItem.Get(SubItemNo);
        ProdBOMLine."Unit of Measure Code" := subItem."Base Unit of Measure";
        ProdBOMLine.Quantity := Qty;
        ProdBOMLine.Insert();
    end;

    procedure CalculateConsumption(ProductionOrderNo: Code[20]; ItemJournalTemplateName: Code[10]; ItemJournalBatchName: Code[10])
    var
        ProductionOrder: Record "Production Order";
        CalcConsumption: Report "Calc. Consumption";
        CalcBasedOn: Option "Actual Output","Expected Output";
    begin
        CalcConsumption.InitializeRequest(WorkDate(), CalcBasedOn::"Expected Output");
        CalcConsumption.SetTemplateAndBatchName(ItemJournalTemplateName, ItemJournalBatchName);
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        ProductionOrder.SetRange("No.", ProductionOrderNo);
        CalcConsumption.SetTableView(ProductionOrder);
        CalcConsumption.UseRequestPage(false);
        CalcConsumption.RunModal();
    end;

    procedure CalculateConsumptionForJournal(var ProductionOrder: Record "Production Order"; var ProdOrderComponent: Record "Prod. Order Component"; PostingDate: Date; ActualOutput: Boolean)
    var
        TmpProductionOrder: Record "Production Order";
        TmpProdOrderComponent: Record "Prod. Order Component";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        CalcConsumption: Report "Calc. Consumption";
        CalcBasedOn: Option "Actual Output","Expected Output";
    begin
        Commit();
        if ActualOutput then
            CalcBasedOn := CalcBasedOn::"Actual Output"
        else
            CalcBasedOn := CalcBasedOn::"Expected Output";
        CalcConsumption.InitializeRequest(PostingDate, CalcBasedOn);
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Consumption);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        CalcConsumption.SetTemplateAndBatchName(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
        if ProductionOrder.HasFilter then
            TmpProductionOrder.CopyFilters(ProductionOrder)
        else begin
            ProductionOrder.Get(ProductionOrder.Status, ProductionOrder."No.");
            TmpProductionOrder.SetRange(Status, ProductionOrder.Status);
            TmpProductionOrder.SetRange("No.", ProductionOrder."No.");
        end;
        CalcConsumption.SetTableView(TmpProductionOrder);
        if ProdOrderComponent.HasFilter then
            TmpProdOrderComponent.CopyFilters(ProdOrderComponent)
        else begin
            ProdOrderComponent.Get(ProdOrderComponent.Status, ProdOrderComponent."Prod. Order No.",
              ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Line No.");
            TmpProdOrderComponent.SetRange(Status, ProdOrderComponent.Status);
            TmpProdOrderComponent.SetRange("Prod. Order No.", ProdOrderComponent."Prod. Order No.");
            TmpProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderComponent."Prod. Order Line No.");
            TmpProdOrderComponent.SetRange("Line No.", ProdOrderComponent."Line No.");
        end;
        CalcConsumption.SetTableView(TmpProdOrderComponent);
        CalcConsumption.UseRequestPage(false);
        CalcConsumption.RunModal();
    end;

    procedure CalculateMachCenterCalendar(var MachineCenter: Record "Machine Center"; StartingDate: Date; EndingDate: Date)
    var
        TmpMachineCenter: Record "Machine Center";
        CalcMachineCenterCalendar: Report "Calc. Machine Center Calendar";
    begin
        Commit();
        CalcMachineCenterCalendar.InitializeRequest(StartingDate, EndingDate);
        if MachineCenter.HasFilter then
            TmpMachineCenter.CopyFilters(MachineCenter)
        else begin
            MachineCenter.Get(MachineCenter."No.");
            TmpMachineCenter.SetRange("No.", MachineCenter."No.");
        end;
        CalcMachineCenterCalendar.SetTableView(TmpMachineCenter);
        CalcMachineCenterCalendar.UseRequestPage(false);
        CalcMachineCenterCalendar.RunModal();
    end;

    procedure CalculateWorksheetPlan(var Item: Record Item; OrderDate: Date; ToDate: Date)
    var
        TempItem: Record Item temporary;
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        CalculatePlanPlanWksh: Report "Calculate Plan - Plan. Wksh.";
    begin
        Commit();
        CalculatePlanPlanWksh.InitializeRequest(OrderDate, ToDate, false);
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::Planning);
        ReqWkshTemplate.FindFirst();
        RequisitionWkshName.SetRange("Worksheet Template Name", ReqWkshTemplate.Name);
        RequisitionWkshName.FindFirst();
        CalculatePlanPlanWksh.SetTemplAndWorksheet(RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name, true);
        if Item.HasFilter then
            TempItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TempItem.SetRange("No.", Item."No.");
        end;
        CalculatePlanPlanWksh.SetTableView(TempItem);
        CalculatePlanPlanWksh.UseRequestPage(false);
        CalculatePlanPlanWksh.RunModal();
    end;

    procedure CalculateSubcontractOrder(var WorkCenter: Record "Work Center")
    var
        RequisitionLine: Record "Requisition Line";
        CalculateSubcontracts: Report "Calculate Subcontracts";
    begin
        RequisitionLineForSubcontractOrder(RequisitionLine);
        CalculateSubcontracts.SetWkShLine(RequisitionLine);
        CalculateSubcontracts.SetTableView(WorkCenter);
        CalculateSubcontracts.UseRequestPage(false);
        CalculateSubcontracts.RunModal();
    end;

    procedure CalculateWorkCenterCalendar(var WorkCenter: Record "Work Center"; StartingDate: Date; EndingDate: Date)
    var
        TmpWorkCenter: Record "Work Center";
        CalculateWorkCenterCalendarReport: Report "Calculate Work Center Calendar";
    begin
        Commit();
        CalculateWorkCenterCalendarReport.InitializeRequest(StartingDate, EndingDate);
        if WorkCenter.HasFilter then
            TmpWorkCenter.CopyFilters(WorkCenter)
        else begin
            WorkCenter.Get(WorkCenter."No.");
            TmpWorkCenter.SetRange("No.", WorkCenter."No.");
        end;
        CalculateWorkCenterCalendarReport.SetTableView(TmpWorkCenter);
        CalculateWorkCenterCalendarReport.UseRequestPage(false);
        CalculateWorkCenterCalendarReport.RunModal();
    end;

    procedure CalculateSubcontractOrderWithProdOrderRoutingLine(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        RequisitionLine: Record "Requisition Line";
        TmpProdOrderRoutingLine: Record "Prod. Order Routing Line";
        CalculateSubcontracts: Report "Calculate Subcontracts";
    begin
        if ProdOrderRoutingLine.HasFilter then
            TmpProdOrderRoutingLine.CopyFilters(ProdOrderRoutingLine)
        else begin
            ProdOrderRoutingLine.Get(ProdOrderRoutingLine."No.");
            TmpProdOrderRoutingLine.SetRange("No.", ProdOrderRoutingLine."No.");
        end;

        RequisitionLineForSubcontractOrder(RequisitionLine);
        CalculateSubcontracts.SetWkShLine(RequisitionLine);
        CalculateSubcontracts.SetTableView(TmpProdOrderRoutingLine);
        CalculateSubcontracts.UseRequestPage(false);
        CalculateSubcontracts.RunModal();
    end;

    procedure ChangeProdOrderStatus(var ProductionOrder: Record "Production Order"; NewStatus: Enum "Production Order Status"; PostingDate: Date; UpdateUnitCost: Boolean)
    var
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
    begin
        ProdOrderStatusMgt.ChangeProdOrderStatus(ProductionOrder, NewStatus, PostingDate, UpdateUnitCost);
    end;

    procedure ChangeStatusPlannedToFinished(ProductionOrderNo: Code[20]): Code[20]
    var
        ProductionOrder: Record "Production Order";
    begin
        ProductionOrder.Get(ProductionOrder.Status::Planned, ProductionOrderNo);
        ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Released, WorkDate(), false);
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        ProductionOrder.SetRange("Source No.", ProductionOrder."Source No.");
        ProductionOrder.FindFirst();
        ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Finished, WorkDate(), false);
        exit(ProductionOrder."No.");
    end;

    procedure ChangeStatusReleasedToFinished(ProductionOrderNo: Code[20])
    var
        ProductionOrder: Record "Production Order";
    begin
        ProductionOrder.Get(ProductionOrder.Status::Released, ProductionOrderNo);
        ChangeProdOrderStatus(ProductionOrder, ProductionOrder.Status::Finished, WorkDate(), false);
    end;

    procedure ChangeProuctionOrderStatus(ProductionOrderNo: Code[20]; FromStatus: Enum "Production Order Status"; ToStatus: Enum "Production Order Status"): Code[20]
    var
        ProductionOrder: Record "Production Order";
    begin
        ProductionOrder.Get(FromStatus, ProductionOrderNo);
        ChangeProdOrderStatus(ProductionOrder, ToStatus, WorkDate(), true);
        ProductionOrder.SetRange(Status, ToStatus);
        ProductionOrder.SetRange("Source No.", ProductionOrder."Source No.");
        ProductionOrder.FindFirst();
        exit(ProductionOrder."No.");
    end;

    procedure ChangeStatusFirmPlanToReleased(ProductionOrderNo: Code[20]): Code[20]
    var
        ProductionOrder: Record "Production Order";
    begin
        exit(ChangeProuctionOrderStatus(ProductionOrderNo, ProductionOrder.Status::"Firm Planned", ProductionOrder.Status::Released));
    end;

    procedure ChangeStatusSimulatedToReleased(ProductionOrderNo: Code[20]): Code[20]
    var
        ProductionOrder: Record "Production Order";
    begin
        exit(ChangeProuctionOrderStatus(ProductionOrderNo, ProductionOrder.Status::Simulated, ProductionOrder.Status::Released));
    end;

    procedure CheckProductionOrderCost(ProdOrder: Record "Production Order"; VerifyVarianceinOutput: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ProdOrderLine: Record "Prod. Order Line";
        ConsumptionCost: Decimal;
        OutpuCostwithoutVariance: Decimal;
        OutputCostinclVariance: Decimal;
        RefOutputCostinclVariance: Decimal;
    begin
        ProdOrderLine.SetRange(Status, ProdOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProdOrder."No.");
        if ProdOrderLine.FindSet() then begin
            OutpuCostwithoutVariance := 0;
            ConsumptionCost := 0;
            repeat
                ItemLedgerEntry.SetRange("Order Line No.", ProdOrderLine."Line No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        ItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Consumption then
                            ConsumptionCost += ItemLedgerEntry."Cost Amount (Expected)" + ItemLedgerEntry."Cost Amount (Actual)"
                        else
                            if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Output then begin
                                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                                if VerifyVarianceinOutput then begin
                                    ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                                    ValueEntry.CalcSums("Cost Amount (Actual)");
                                    OutputCostinclVariance := Round(ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision());
                                end;
                                ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::Variance);
                                ValueEntry.CalcSums("Cost Amount (Actual)");
                                OutpuCostwithoutVariance += ValueEntry."Cost Amount (Actual)";
                            end;
                    until ItemLedgerEntry.Next() = 0;
                Assert.AreEqual(
                  -ConsumptionCost, OutpuCostwithoutVariance,
                  StrSubstNo(OutputConsumpMismatchTxt, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No."));
                if VerifyVarianceinOutput then begin
                    RefOutputCostinclVariance :=
                      Round(ProdOrderLine."Unit Cost" * ProdOrderLine.Quantity, LibraryERM.GetAmountRoundingPrecision());
                    Assert.AreEqual(
                      -RefOutputCostinclVariance, OutputCostinclVariance,
                      StrSubstNo(OutputVarianceMismatchTxt, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No."));
                end;
            until ProdOrderLine.Next() = 0;
        end;
    end;

    procedure CreateAndRefreshProductionOrder(var ProductionOrder: Record "Production Order"; ProdOrderStatus: Enum "Production Order Status"; SourceType: Enum "Prod. Order Source Type"; SourceNo: Code[20]; Quantity: Decimal)
    begin
        CreateProductionOrder(ProductionOrder, ProdOrderStatus, SourceType, SourceNo, Quantity);
        RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

#if not CLEAN26
    [Obsolete('Moved to LibraryInventory', '26.0')]
    procedure CreateBOMComponent(var BOMComponent: Record "BOM Component"; ParentItemNo: Code[20]; Type: Enum "BOM Component Type"; No: Code[20]; QuantityPer: Decimal; UnitOfMeasureCode: Code[10])
    begin
        LibraryInventory.CreateBOMComponent(BOMComponent, ParentItemNo, Type, No, QuantityPer, UnitOfMeasureCode);
    end;
#endif

    procedure CreateCalendarAbsenceEntry(var CalendarAbsenceEntry: Record "Calendar Absence Entry"; CapacityType: Enum "Capacity Type"; No: Code[20]; Date: Date; StartingTime: Time; EndingTime: Time; Capacity: Decimal)
    begin
        CalendarAbsenceEntry.Init();
        CalendarAbsenceEntry.Validate("Capacity Type", CapacityType);
        CalendarAbsenceEntry.Validate("No.", No);
        CalendarAbsenceEntry.Validate(Date, Date);
        CalendarAbsenceEntry.Validate("Starting Time", StartingTime);
        CalendarAbsenceEntry.Validate("Ending Time", EndingTime);
        CalendarAbsenceEntry.Insert(true);
        CalendarAbsenceEntry.Validate(Capacity, Capacity);
        CalendarAbsenceEntry.Modify(true);
    end;

    procedure CreateCapacityConstrainedResource(var CapacityConstrainedResource: Record "Capacity Constrained Resource"; CapacityType: Enum "Capacity Type"; CapacityNo: Code[20])
    begin
        Clear(CapacityConstrainedResource);
        CapacityConstrainedResource.Init();
        CapacityConstrainedResource.Validate("Capacity Type", CapacityType);
        CapacityConstrainedResource.Validate("Capacity No.", CapacityNo);
        CapacityConstrainedResource.Insert(true);
    end;

    procedure CreateCapacityUnitOfMeasure(var CapacityUnitOfMeasure: Record "Capacity Unit of Measure"; Type: Enum "Capacity Unit of Measure")
    begin
        CapacityUnitOfMeasure.Init();
        CapacityUnitOfMeasure.Validate(
          Code, LibraryUtility.GenerateRandomCode(CapacityUnitOfMeasure.FieldNo(Code), DATABASE::"Capacity Unit of Measure"));
        CapacityUnitOfMeasure.Insert(true);
        CapacityUnitOfMeasure.Validate(Type, Type);
        CapacityUnitOfMeasure.Modify(true);
    end;

    procedure CreateFamily(var Family: Record Family)
    begin
        Family.Init();
        Family.Validate("No.", LibraryUtility.GenerateRandomCode(Family.FieldNo("No."), DATABASE::Family));
        Family.Insert(true);
        Family.Validate(Description, Family."No.");
        Family.Modify(true);
    end;

    procedure CreateFamilyLine(var FamilyLine: Record "Family Line"; FamilyNo: Code[20]; ItemNo: Code[20]; Qty: Decimal)
    var
        RecRef: RecordRef;
    begin
        FamilyLine.Init();
        FamilyLine.Validate("Family No.", FamilyNo);
        RecRef.GetTable(FamilyLine);
        FamilyLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FamilyLine.FieldNo("Line No.")));
        FamilyLine.Insert(true);
        FamilyLine.Validate("Item No.", ItemNo);
        FamilyLine.Validate(Quantity, Qty);
        FamilyLine.Modify(true);
    end;

    procedure CreateProdItemJournal(var ItemJournalBatch: Record "Item Journal Batch"; ItemNo: Code[20]; ItemJournalTemplateType: Enum "Item Journal Template Type"; ProductionOrderNo: Code[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        // Create Journals for Consumption and Output.
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplateType, ItemJournalTemplate.Name);
        if ItemJournalTemplateType = ItemJournalTemplateType::Consumption then
            CalculateConsumption(ProductionOrderNo, ItemJournalTemplate.Name, ItemJournalBatch.Name)
        else begin
            CreateOutputJournal(ItemJournalLine, ItemJournalTemplate, ItemJournalBatch, ItemNo, ProductionOrderNo);
            OutputJnlExplodeRoute(ItemJournalLine);
            UpdateOutputJournal(ProductionOrderNo);
        end;
    end;

    procedure CreateItemManufacturing(var Item: Record Item; CostingMethod: Enum "Costing Method"; UnitCost: Decimal; ReorderPolicy: Enum "Reordering Policy"; FlushingMethod: Enum "Flushing Method"; RoutingNo: Code[20]; ProductionBOMNo: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        // Create Item extended for Manufacturing.
        LibraryInventory.CreateItemManufacturing(Item);
        Item.Validate("Costing Method", CostingMethod);
        if Item."Costing Method" = Item."Costing Method"::Standard then
            Item.Validate("Standard Cost", UnitCost)
        else begin
            Item.Validate("Unit Cost", UnitCost);
            Item.Validate("Last Direct Cost", Item."Unit Cost");
        end;

        Item.Validate("Reordering Policy", ReorderPolicy);
        Item.Validate("Flushing Method", FlushingMethod);

        if ProductionBOMNo <> '' then begin
            InventoryPostingSetup.FindLast();
            Item.Validate("Replenishment System", Item."Replenishment System"::"Prod. Order");
            Item.Validate("Routing No.", RoutingNo);
            Item.Validate("Production BOM No.", ProductionBOMNo);
            Item.Validate("Inventory Posting Group", InventoryPostingSetup."Invt. Posting Group Code");
        end;
        Item.Modify(true);
    end;

    procedure CreateMachineCenter(var MachineCenter: Record "Machine Center"; WorkCenterNo: Code[20]; Capacity: Decimal)
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
        LibraryUtility.UpdateSetupNoSeriesCode(
          DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Machine Center Nos."));

        Clear(MachineCenter);
        MachineCenter.Insert(true);
        MachineCenter.Validate("Work Center No.", WorkCenterNo);
        MachineCenter.Validate(Capacity, Capacity);
        MachineCenter.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        MachineCenter.Modify(true);
    end;

    procedure CreateMachineCenterWithCalendar(var MachineCenter: Record "Machine Center"; WorkCenterNo: Code[20]; Capacity: Decimal)
    begin
        CreateMachineCenter(MachineCenter, WorkCenterNo, Capacity);
        CalculateMachCenterCalendar(MachineCenter, CalcDate('<-1M>', WorkDate()), CalcDate('<1M>', WorkDate()));
    end;

    procedure CreateOutputJournal(var ItemJournalLine: Record "Item Journal Line"; ItemJournalTemplate: Record "Item Journal Template"; ItemJournalBatch: Record "Item Journal Batch"; ItemNo: Code[20]; ProductionOrderNo: Code[20])
    begin
        // Create Output Journal.
        if ItemJournalTemplate.Type <> ItemJournalTemplate.Type::Output then
            exit;
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Output;

        LibraryInventory.CreateItemJnlLineWithNoItem(
          ItemJournalLine, ItemJournalBatch, ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalLine."Entry Type");
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProductionOrderNo);
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Modify(true);
        Commit();
    end;

    procedure CreateProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProdOrderStatus: Enum "Production Order Status"; ProdOrderNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; Qty: Decimal)
    begin
        ProdOrderLine.Init();
        ProdOrderLine.Validate(Status, ProdOrderStatus);
        ProdOrderLine.Validate("Prod. Order No.", ProdOrderNo);
        ProdOrderLine.Validate("Line No.", LibraryUtility.GetNewRecNo(ProdOrderLine, ProdOrderLine.FieldNo("Line No.")));
        ProdOrderLine.Validate("Item No.", ItemNo);
        ProdOrderLine.Validate("Variant Code", VariantCode);
        ProdOrderLine.Validate("Location Code", LocationCode);
        ProdOrderLine.Validate(Quantity, Qty);

        ProdOrderLine.Insert(true);
    end;

    procedure CreateProductionBOMCommentLine(ProductionBOMLine: Record "Production BOM Line")
    var
        ProductionBOMCommentLine: Record "Production BOM Comment Line";
        LineNo: Integer;
    begin
        ProductionBOMCommentLine.SetRange("Production BOM No.", ProductionBOMLine."Production BOM No.");
        ProductionBOMCommentLine.SetRange("Version Code", ProductionBOMLine."Version Code");
        ProductionBOMCommentLine.SetRange("BOM Line No.", ProductionBOMLine."Line No.");
        if ProductionBOMCommentLine.FindLast() then;
        LineNo := ProductionBOMCommentLine."Line No." + 10000;

        ProductionBOMCommentLine.Init();
        ProductionBOMCommentLine.Validate("Production BOM No.", ProductionBOMLine."Production BOM No.");
        ProductionBOMCommentLine.Validate("BOM Line No.", ProductionBOMLine."Line No.");
        ProductionBOMCommentLine.Validate("Version Code", ProductionBOMLine."Version Code");
        ProductionBOMCommentLine.Validate("Line No.", LineNo);
        ProductionBOMCommentLine.Validate(Comment, LibraryUtility.GenerateGUID());
        ProductionBOMCommentLine.Insert(true);
    end;

    procedure CreateProductionBOM(var Item: Record Item; NoOfComps: Integer)
    var
        Item1: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
        LibraryAssembly: Codeunit "Library - Assembly";
        "count": Integer;
    begin
        CreateProductionBOMHeader(ProductionBOMHeader, Item."Base Unit of Measure");

        for count := 1 to NoOfComps do begin
            LibraryAssembly.CreateItem(Item1, Item."Costing Method"::Standard, Item."Replenishment System"::Purchase, '', '');
            CreateProductionBOMLine(
              ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, Item1."No.", 1);
        end;

        ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::Certified);
        ProductionBOMHeader.Modify(true);
        Item.Validate("Production BOM No.", ProductionBOMHeader."No.");
        Item.Modify(true);
    end;

    procedure CreateProductionBOMHeader(var ProductionBOMHeader: Record "Production BOM Header"; UnitOfMeasureCode: Code[10]): Code[20]
    begin
        LibraryUtility.UpdateSetupNoSeriesCode(
          DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Production BOM Nos."));

        Clear(ProductionBOMHeader);
        ProductionBOMHeader.Insert(true);
        ProductionBOMHeader.Validate("Unit of Measure Code", UnitOfMeasureCode);
        ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::New);
        ProductionBOMHeader.Modify(true);
        exit(ProductionBOMHeader."No.");
    end;

    procedure CreateProductionBOMLine(var ProductionBOMHeader: Record "Production BOM Header"; var ProductionBOMLine: Record "Production BOM Line"; VersionCode: Code[20]; Type: Enum "Production BOM Line Type"; No: Code[20]; QuantityPer: Decimal)
    var
        RecRef: RecordRef;
    begin
        ProductionBOMLine.Init();
        ProductionBOMLine.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.Validate("Version Code", VersionCode);
        RecRef.GetTable(ProductionBOMLine);
        ProductionBOMLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ProductionBOMLine.FieldNo("Line No.")));
        ProductionBOMLine.Insert(true);
        ProductionBOMLine.Validate(Type, Type);
        ProductionBOMLine.Validate("No.", No);
        ProductionBOMLine.Validate("Quantity per", QuantityPer);
        ProductionBOMLine.Modify(true);
    end;

    procedure CreateCertifiedProductionBOM(var ProductionBOMHeader: Record "Production BOM Header"; ItemNo: Code[20]; QuantityPer: Decimal): Code[20]
    var
        Item: Record Item;
        ProductionBOMLine: Record "Production BOM Line";
    begin
        Item.Get(ItemNo);
        CreateProductionBOMHeader(ProductionBOMHeader, Item."Base Unit of Measure");
        CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, ItemNo, QuantityPer);
        UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);
        exit(ProductionBOMHeader."No.");
    end;

    procedure CreateCertifProdBOMWithTwoComp(var ProductionBOMHeader: Record "Production BOM Header"; ItemNo: Code[20]; ItemNo2: Code[20]; QuantityPer: Decimal): Code[20]
    var
        Item: Record Item;
        ProductionBOMLine: Record "Production BOM Line";
    begin
        // Create Production BOM.
        Item.Get(ItemNo);
        CreateProductionBOMHeader(ProductionBOMHeader, Item."Base Unit of Measure");
        CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, ItemNo, QuantityPer);
        CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, ItemNo2, QuantityPer);
        UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);
        exit(ProductionBOMHeader."No.");
    end;

    procedure CreateProductionBOMVersion(var ProductionBomVersion: Record "Production BOM Version"; BomNo: Code[20]; Version: Code[20]; UOMCode: Code[10])
    begin
        ProductionBomVersion.Init();
        ProductionBomVersion.Validate("Production BOM No.", BomNo);
        ProductionBomVersion.Validate("Version Code", Version);
        ProductionBomVersion.Insert(true);
        ProductionBomVersion.Validate("Unit of Measure Code", UOMCode);
        ProductionBomVersion.Modify(true);
    end;

    procedure CreateProductionBOMVersion(var ProductionBomVersion: Record "Production BOM Version"; BomNo: Code[20]; Version: Code[20]; UOMCode: Code[10]; StartingDate: Date)
    begin
        CreateProductionBOMVersion(ProductionBomVersion, BomNo, Version, UOMCode);
        ProductionBomVersion.Validate("Starting Date", StartingDate);
        ProductionBomVersion.Modify(true);
    end;

    procedure CreateProductionForecastEntry(var ProductionForecastEntry: Record "Production Forecast Entry"; ProductionForecastName: Code[10]; ItemNo: Code[20]; LocationCode: Code[10]; ForecastDate: Date; ComponentForecast: Boolean)
    begin
        Clear(ProductionForecastEntry);
        ProductionForecastEntry.Init();
        ProductionForecastEntry.Validate("Production Forecast Name", ProductionForecastName);
        ProductionForecastEntry.Validate("Item No.", ItemNo);
        ProductionForecastEntry.Validate("Location Code", LocationCode);
        ProductionForecastEntry.Validate("Forecast Date", ForecastDate);
        ProductionForecastEntry.Validate("Component Forecast", ComponentForecast);
        ProductionForecastEntry.Insert(true);
    end;

    procedure CreateProductionForecastEntry(var ProductionForecastEntry: Record "Production Forecast Entry"; ProductionForecastName: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; ForecastDate: Date; ComponentForecast: Boolean)
    begin
        ProductionForecastEntry.Init();
        ProductionForecastEntry.Validate("Production Forecast Name", ProductionForecastName);
        ProductionForecastEntry.Validate("Item No.", ItemNo);
        ProductionForecastEntry.Validate("Variant Code", VariantCode);
        ProductionForecastEntry.Validate("Location Code", LocationCode);
        ProductionForecastEntry.Validate("Forecast Date", ForecastDate);
        ProductionForecastEntry.Validate("Component Forecast", ComponentForecast);
        ProductionForecastEntry.Insert(true);
    end;

    procedure CreateProductionForecastName(var ProductionForecastName: Record "Production Forecast Name")
    begin
        Clear(ProductionForecastName);
        ProductionForecastName.Init();
        ProductionForecastName.Validate(
          Name, LibraryUtility.GenerateRandomCode(ProductionForecastName.FieldNo(Name), DATABASE::"Production Forecast Name"));
        ProductionForecastName.Validate(Description, ProductionForecastName.Name);
        ProductionForecastName.Insert(true);
    end;

    procedure CreateProductionOrder(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; SourceType: Enum "Prod. Order Source Type"; SourceNo: Code[20]; Quantity: Decimal)
    begin
        case Status of
            ProductionOrder.Status::Simulated:
                LibraryUtility.UpdateSetupNoSeriesCode(
                  DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Simulated Order Nos."));
            ProductionOrder.Status::Planned:
                LibraryUtility.UpdateSetupNoSeriesCode(
                  DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Planned Order Nos."));
            ProductionOrder.Status::"Firm Planned":
                LibraryUtility.UpdateSetupNoSeriesCode(
                  DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Firm Planned Order Nos."));
            ProductionOrder.Status::Released:
                LibraryUtility.UpdateSetupNoSeriesCode(
                  DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Released Order Nos."));
        end;

        Clear(ProductionOrder);
        ProductionOrder.Init();
        ProductionOrder.Validate(Status, Status);
        ProductionOrder.Insert(true);
        ProductionOrder.Validate("Source Type", SourceType);
        ProductionOrder.Validate("Source No.", SourceNo);
        ProductionOrder.Validate(Quantity, Quantity);
        ProductionOrder.Modify(true);
    end;

    procedure CreateProductionOrderComponent(var ProdOrderComponent: Record "Prod. Order Component"; Status: Enum "Production Order Status"; ProdOrderNo: Code[20]; ProdOrderLineNo: Integer)
    var
        RecRef: RecordRef;
    begin
        ProdOrderComponent.Init();
        ProdOrderComponent.Validate(Status, Status);
        ProdOrderComponent.Validate("Prod. Order No.", ProdOrderNo);
        ProdOrderComponent.Validate("Prod. Order Line No.", ProdOrderLineNo);
        RecRef.GetTable(ProdOrderComponent);
        ProdOrderComponent.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ProdOrderComponent.FieldNo("Line No.")));
        ProdOrderComponent.Insert(true);
    end;

    procedure CreateProductionOrderFromSalesOrder(SalesHeader: Record "Sales Header"; ProdOrderStatus: Enum "Production Order Status"; OrderType: Enum "Create Production Order Type")
    var
        SalesLine: Record "Sales Line";
        CreateProdOrderFromSale: Codeunit "Create Prod. Order from Sale";
        EndLoop: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            CreateProdOrderFromSale.CreateProductionOrder(SalesLine, ProdOrderStatus, OrderType);
            if OrderType = OrderType::ProjectOrder then
                EndLoop := true;
        until (SalesLine.Next() = 0) or EndLoop;
    end;

    procedure CreateProductionRouting(var Item: Record Item; NoOfLines: Integer)
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        "count": Integer;
    begin
        CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        CreateWorkCenter(WorkCenter);

        for count := 1 to NoOfLines do
            if count mod 2 = 0 then begin
                RoutingLine.Validate(Type, RoutingLine.Type::"Work Center");
                CreateRoutingLineSetup(RoutingLine, RoutingHeader, WorkCenter."No.",
                  CopyStr(
                    LibraryUtility.GenerateRandomCode(RoutingLine.FieldNo("Operation No."), DATABASE::"Routing Line"), 1,
                    LibraryUtility.GetFieldLength(DATABASE::"Routing Line", RoutingLine.FieldNo("Operation No."))),
                  LibraryRandom.RandDec(10, 2), LibraryRandom.RandDec(10, 2));
            end else begin
                CreateMachineCenter(MachineCenter, WorkCenter."No.", LibraryRandom.RandInt(5));
                RoutingLine.Validate(Type, RoutingLine.Type::"Machine Center");
                CreateRoutingLineSetup(RoutingLine, RoutingHeader, MachineCenter."No.",
                  CopyStr(
                    LibraryUtility.GenerateRandomCode(RoutingLine.FieldNo("Operation No."), DATABASE::"Routing Line"), 1,
                    LibraryUtility.GetFieldLength(DATABASE::"Routing Line", RoutingLine.FieldNo("Operation No."))),
                  LibraryRandom.RandDec(10, 2), LibraryRandom.RandDec(10, 2));
            end;

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);
        Item.Validate("Routing No.", RoutingHeader."No.");
        Item.Modify(true);
    end;

    procedure CreateRegisteredAbsence(var RegisteredAbsence: Record "Registered Absence"; CapacityType: Enum "Capacity Type"; No: Code[20]; Date: Date; StartingTime: Time; EndingTime: Time)
    begin
        RegisteredAbsence.Init();
        RegisteredAbsence.Validate("Capacity Type", CapacityType);
        RegisteredAbsence.Validate("No.", No);
        RegisteredAbsence.Validate(Date, Date);
        RegisteredAbsence.Validate("Starting Time", StartingTime);
        RegisteredAbsence.Validate("Ending Time", EndingTime);
        RegisteredAbsence.Insert(true);
    end;

    procedure CreateRoutingHeader(var RoutingHeader: Record "Routing Header"; Type: Option)
    begin
        LibraryUtility.UpdateSetupNoSeriesCode(
          DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Routing Nos."));

        Clear(RoutingHeader);
        RoutingHeader.Insert(true);
        RoutingHeader.Validate(Type, Type);
        RoutingHeader.Validate(Status, RoutingHeader.Status::New);
        RoutingHeader.Modify(true);
    end;

    procedure CreateRoutingLine(var RoutingHeader: Record "Routing Header"; var RoutingLine: Record "Routing Line"; VersionCode: Code[20]; OperationNo: Code[10]; Type: Enum "Capacity Type Routing"; No: Code[20])
    begin
        RoutingLine.Init();
        RoutingLine.Validate("Routing No.", RoutingHeader."No.");
        RoutingLine.Validate("Version Code", VersionCode);
        if OperationNo = '' then
            OperationNo := LibraryUtility.GenerateRandomCode(RoutingLine.FieldNo("Operation No."), DATABASE::"Routing Line");
        RoutingLine.Validate("Operation No.", OperationNo);
        RoutingLine.Insert(true);
        RoutingLine.Validate(Type, Type);
        RoutingLine.Validate("No.", No);
        RoutingLine.Modify(true);
    end;

    procedure CreateRoutingLineSetup(var RoutingLine: Record "Routing Line"; RoutingHeader: Record "Routing Header"; CenterNo: Code[20]; OperationNo: Code[10]; SetupTime: Decimal; RunTime: Decimal)
    begin
        // Create Routing Lines with required fields.
        CreateRoutingLine(
          RoutingHeader, RoutingLine, '', OperationNo, RoutingLine.Type, CenterNo);
        RoutingLine.Validate("Setup Time", SetupTime);
        RoutingLine.Validate("Run Time", RunTime);
        RoutingLine.Validate("Concurrent Capacities", 1);
        RoutingLine.Modify(true);
    end;

    procedure CreateRoutingLink(var RoutingLink: Record "Routing Link")
    begin
        RoutingLink.Init();
        RoutingLink.Validate(Code, LibraryUtility.GenerateRandomCode(RoutingLink.FieldNo(Code), DATABASE::"Routing Link"));
        RoutingLink.Insert(true);
    end;

    procedure CreateQualityMeasure(var QualityMeasure: Record "Quality Measure")
    begin
        QualityMeasure.Init();
        QualityMeasure.Validate(Code, LibraryUtility.GenerateRandomCode(QualityMeasure.FieldNo(Code), DATABASE::"Quality Measure"));
        QualityMeasure.Insert(true);
    end;

    procedure CreateRoutingQualityMeasureLine(var RoutingQualityMeasure: Record "Routing Quality Measure"; RoutingLine: Record "Routing Line"; QualityMeasure: Record "Quality Measure")
    begin
        RoutingQualityMeasure.Init();
        RoutingQualityMeasure.Validate("Routing No.", RoutingLine."Routing No.");
        RoutingQualityMeasure.Validate("Operation No.", RoutingLine."Operation No.");
        RoutingQualityMeasure.Validate("Qlty Measure Code", QualityMeasure.Code);
        RoutingQualityMeasure.Insert(true);
    end;

    procedure CreateRoutingVersion(var RoutingVersion: Record "Routing Version"; RoutingNo: Code[20]; VersionCode: Code[20])
    begin
        RoutingVersion.Init();
        RoutingVersion.Validate("Routing No.", RoutingNo);
        RoutingVersion.Validate("Version Code", VersionCode);
        RoutingVersion.Insert(true);
    end;

    procedure CreateShopCalendarCode(var ShopCalendar: Record "Shop Calendar"): Code[10]
    begin
        ShopCalendar.Init();
        ShopCalendar.Validate(Code, LibraryUtility.GenerateRandomCode(ShopCalendar.FieldNo(Code), DATABASE::"Shop Calendar"));
        ShopCalendar.Insert(true);
        exit(ShopCalendar.Code);
    end;

    local procedure CreateShopCalendarCustomTime(FromDay: Option; ToDay: Option; FromTime: Time; ToTime: Time): Code[10]
    var
        ShopCalendarWorkingDays: Record "Shop Calendar Working Days";
        ShopCalendar: Record "Shop Calendar";
        WorkShift: Record "Work Shift";
        ShopCalendarCode: Code[10];
        WorkShiftCode: Code[10];
        Day: Integer;
    begin
        // Create Shop Calendar Working Days.
        ShopCalendarCode := CreateShopCalendarCode(ShopCalendar);
        WorkShiftCode := CreateWorkShiftCode(WorkShift);
        ShopCalendarWorkingDays.SetRange("Shop Calendar Code", ShopCalendarCode);

        for Day := FromDay to ToDay do
            CreateShopCalendarWorkingDays(
              ShopCalendarWorkingDays, ShopCalendarCode, Day, WorkShiftCode, FromTime, ToTime);

        exit(ShopCalendarCode);
    end;

    procedure CreateShopCalendarWorkingDays(var ShopCalendarWorkingDays: Record "Shop Calendar Working Days"; ShopCalendarCode: Code[10]; Day: Option; WorkShiftCode: Code[10]; StartingTime: Time; EndingTime: Time)
    begin
        ShopCalendarWorkingDays.Init();
        ShopCalendarWorkingDays.Validate("Shop Calendar Code", ShopCalendarCode);
        ShopCalendarWorkingDays.Validate(Day, Day);
        ShopCalendarWorkingDays.Validate("Starting Time", StartingTime);
        ShopCalendarWorkingDays.Validate("Ending Time", EndingTime);
        ShopCalendarWorkingDays.Validate("Work Shift Code", WorkShiftCode);
        ShopCalendarWorkingDays.Insert(true);
    end;

    procedure CreateStandardTask(var StandardTask: Record "Standard Task")
    begin
        StandardTask.Init();
        StandardTask.Validate(Code, LibraryUtility.GenerateRandomCode(StandardTask.FieldNo(Code), DATABASE::"Standard Task"));
        StandardTask.Insert(true);
    end;

    procedure CreateWorkCenter(var WorkCenter: Record "Work Center")
    begin
        CreateWorkCenterCustomTime(WorkCenter, 080000T, 160000T);
    end;

    procedure CreateWorkCenterCustomTime(var WorkCenter: Record "Work Center"; FromTime: Time; ToTime: Time)
    begin
        CreateWorkCenterWithoutShopCalendar(WorkCenter);
        WorkCenter.Validate(
          "Shop Calendar Code", UpdateShopCalendarWorkingDaysCustomTime(FromTime, ToTime));
        WorkCenter.Modify(true);
    end;

    procedure CreateWorkCenterFullWorkingWeek(var WorkCenter: Record "Work Center"; FromTime: Time; ToTime: Time)
    begin
        CreateWorkCenterWithoutShopCalendar(WorkCenter);
        WorkCenter.Validate(
          "Shop Calendar Code", UpdateShopCalendarFullWorkingWeekCustomTime(FromTime, ToTime));
        WorkCenter.Modify(true);
    end;

    procedure CreateWorkCenterGroup(var WorkCenterGroup: Record "Work Center Group")
    begin
        WorkCenterGroup.Init();
        WorkCenterGroup.Validate(Code, LibraryUtility.GenerateRandomCode(WorkCenterGroup.FieldNo(Code), DATABASE::"Work Center Group"));
        WorkCenterGroup.Insert(true);
    end;

    procedure CreateWorkCenterWithCalendar(var WorkCenter: Record "Work Center")
    begin
        CreateWorkCenter(WorkCenter);
        CalculateWorkCenterCalendar(WorkCenter, CalcDate('<-1M>', WorkDate()), CalcDate('<1M>', WorkDate()));
    end;

    local procedure CreateWorkCenterWithoutShopCalendar(var WorkCenter: Record "Work Center")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
        WorkCenterGroup: Record "Work Center Group";
    begin
        CreateWorkCenterGroup(WorkCenterGroup);
        CreateCapacityUnitOfMeasure(CapacityUnitOfMeasure, CapacityUnitOfMeasure.Type::Minutes);
        LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
        LibraryUtility.UpdateSetupNoSeriesCode(
          DATABASE::"Manufacturing Setup", ManufacturingSetup.FieldNo("Work Center Nos."));

        Clear(WorkCenter);
        WorkCenter.Insert(true);
        WorkCenter.Validate("Work Center Group Code", WorkCenterGroup.Code);
        WorkCenter.Validate("Unit of Measure Code", CapacityUnitOfMeasure.Code);
        WorkCenter.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        WorkCenter.Modify(true);
    end;

    procedure CreateWorkShiftCode(var WorkShift: Record "Work Shift"): Code[10]
    begin
        WorkShift.Init();
        WorkShift.Validate(Code, LibraryUtility.GenerateRandomCode(WorkShift.FieldNo(Code), DATABASE::"Work Shift"));
        WorkShift.Insert(true);
        exit(WorkShift.Code);
    end;

    procedure CreateInboundWhseReqFromProdOrder(ProductionOrder: Record "Production Order")
    var
        WhseOutputProdRelease: Codeunit "Whse.-Output Prod. Release";
    begin
        if WhseOutputProdRelease.CheckWhseRqst(ProductionOrder) then
            Message(Text005Msg)
        else begin
            Clear(WhseOutputProdRelease);
            if WhseOutputProdRelease.Release(ProductionOrder) then
                Message(Text003Msg)
            else
                Message(Text004Msg);
        end;
    end;

    procedure CreateWhsePickFromProduction(ProductionOrder: Record "Production Order")
    begin
        ProductionOrder.SetHideValidationDialog(true);
        ProductionOrder.CreatePick(CopyStr(UserId(), 1, 50), 0, false, false, false);
    end;

    procedure OpenProductionJournal(ProductionOrder: Record "Production Order"; ProductionOrderLineNo: Integer)
    var
        ProductionJournalMgt: Codeunit "Production Journal Mgt";
    begin
        ProductionJournalMgt.Handling(ProductionOrder, ProductionOrderLineNo);
    end;

    procedure OutputJournalExplodeRouting(ProductionOrder: Record "Production Order")
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Output);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name,
          ItemJournalLine."Entry Type"::Output, '', 0);
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProductionOrder."No.");
        ItemJournalLine.Modify(true);
        CODEUNIT.Run(CODEUNIT::"Output Jnl.-Expl. Route", ItemJournalLine);
    end;

    procedure OutputJnlExplodeRoute(var ItemJournalLine: Record "Item Journal Line")
    var
        OutputJnlExplRouteCodeunit: Codeunit "Output Jnl.-Expl. Route";
    begin
        Clear(OutputJnlExplRouteCodeunit);
        OutputJnlExplRouteCodeunit.Run(ItemJournalLine);
    end;

    procedure OutputJournalExplodeOrderLineRouting(var ItemJournalBatch: Record "Item Journal Batch"; ProdOrderLine: Record "Prod. Order Line"; PostingDate: Date)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Output);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name,
          ItemJournalLine."Entry Type"::Output, '', 0);
        ItemJournalLine.Validate("Posting Date", PostingDate);
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProdOrderLine."Prod. Order No.");
        ItemJournalLine.Validate("Order Line No.", ProdOrderLine."Line No.");
        ItemJournalLine.Modify(true);
        CODEUNIT.Run(CODEUNIT::"Output Jnl.-Expl. Route", ItemJournalLine);
    end;

    procedure PostConsumptionJournal()
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Consumption);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
    end;

    procedure PostOutputJournal()
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Output);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();
        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
    end;

    procedure RefreshProdOrder(var ProductionOrder: Record "Production Order"; Forward: Boolean; CalcLines: Boolean; CalcRoutings: Boolean; CalcComponents: Boolean; CreateInbRqst: Boolean)
    var
        TmpProductionOrder: Record "Production Order";
        RefreshProductionOrder: Report "Refresh Production Order";
        TempTransactionType: TransactionType;
        Direction: Option Forward,Backward;
    begin
        Commit();
        TempTransactionType := CurrentTransactionType;
        CurrentTransactionType(TRANSACTIONTYPE::Update);

        if Forward then
            Direction := Direction::Forward
        else
            Direction := Direction::Backward;
        if ProductionOrder.HasFilter then
            TmpProductionOrder.CopyFilters(ProductionOrder)
        else begin
            ProductionOrder.Get(ProductionOrder.Status, ProductionOrder."No.");
            TmpProductionOrder.SetRange(Status, ProductionOrder.Status);
            TmpProductionOrder.SetRange("No.", ProductionOrder."No.");
        end;
        RefreshProductionOrder.InitializeRequest(Direction, CalcLines, CalcRoutings, CalcComponents, CreateInbRqst);
        RefreshProductionOrder.SetTableView(TmpProductionOrder);
        RefreshProductionOrder.UseRequestPage := false;
        RefreshProductionOrder.RunModal();

        Commit();
        CurrentTransactionType(TempTransactionType);
    end;

    procedure RunReplanProductionOrder(var ProductionOrder: Record "Production Order"; NewDirection: Option; NewCalcMethod: Option)
    var
        TmpProductionOrder: Record "Production Order";
        ReplanProductionOrder: Report "Replan Production Order";
    begin
        Commit();
        ReplanProductionOrder.InitializeRequest(NewDirection, NewCalcMethod);
        if ProductionOrder.HasFilter then
            TmpProductionOrder.CopyFilters(ProductionOrder)
        else begin
            ProductionOrder.Get(ProductionOrder.Status, ProductionOrder."No.");
            TmpProductionOrder.SetRange(Status, ProductionOrder.Status);
            TmpProductionOrder.SetRange("No.", ProductionOrder."No.");
        end;
        ReplanProductionOrder.SetTableView(TmpProductionOrder);
        ReplanProductionOrder.UseRequestPage(false);
        ReplanProductionOrder.RunModal();
    end;

    procedure RunRollUpStandardCost(var Item: Record Item; StandardCostWorksheetName: Code[10])
    var
        Item2: Record Item;
        RollUpStandardCost: Report "Roll Up Standard Cost";
    begin
        Commit();
        if Item.HasFilter then
            Item2.CopyFilters(Item)
        else begin
            Item2.Get(Item."No.");
            Item2.SetRange("No.", Item."No.");
        end;
        RollUpStandardCost.SetTableView(Item2);
        RollUpStandardCost.SetStdCostWksh(StandardCostWorksheetName);
        RollUpStandardCost.UseRequestPage(false);
        RollUpStandardCost.RunModal();
    end;

    local procedure RequisitionLineForSubcontractOrder(var RequisitionLine: Record "Requisition Line")
    var
        ReqJnlManagement: Codeunit ReqJnlManagement;
        JnlSelected: Boolean;
        Handled: Boolean;
    begin
        ReqJnlManagement.WkshTemplateSelection(PAGE::"Subcontracting Worksheet", false, "Req. Worksheet Template Type"::"For. Labor", RequisitionLine, JnlSelected);
        if not JnlSelected then
            Error('');
        RequisitionLine."Worksheet Template Name" := CopyStr(Format("Req. Worksheet Template Type"::"For. Labor"), 1, MaxStrLen(RequisitionLine."Worksheet Template Name"));
        RequisitionLine."Journal Batch Name" := BatchName;
        OnBeforeOpenJournal(RequisitionLine, Handled);
        if Handled then
            exit;
        ReqJnlManagement.OpenJnl(RequisitionLine."Journal Batch Name", RequisitionLine);
    end;

    procedure SuggestCapacityStandardCost(var WorkCenter: Record "Work Center"; var MachineCenter: Record "Machine Center"; StandardCostWorksheetName: Code[10]; StandardCostAdjustmentFactor: Integer; StandardCostRoundingMethod: Code[10])
    var
        TmpWorkCenter: Record "Work Center";
        TmpMachineCenter: Record "Machine Center";
        SuggestCapacityStandardCostReport: Report "Suggest Capacity Standard Cost";
    begin
        Clear(SuggestCapacityStandardCostReport);
        SuggestCapacityStandardCostReport.Initialize(
          StandardCostWorksheetName, StandardCostAdjustmentFactor, 0, 0, StandardCostRoundingMethod, '', '');
        if WorkCenter.HasFilter then
            TmpWorkCenter.CopyFilters(WorkCenter)
        else begin
            WorkCenter.Get(WorkCenter."No.");
            TmpWorkCenter.SetRange("No.", WorkCenter."No.");
        end;
        SuggestCapacityStandardCostReport.SetTableView(TmpWorkCenter);

        if MachineCenter.HasFilter then
            TmpMachineCenter.CopyFilters(MachineCenter)
        else begin
            MachineCenter.Get(MachineCenter."No.");
            TmpMachineCenter.SetRange("No.", MachineCenter."No.");
        end;
        SuggestCapacityStandardCostReport.SetTableView(TmpMachineCenter);
        SuggestCapacityStandardCostReport.UseRequestPage(false);
        SuggestCapacityStandardCostReport.Run();
    end;

    procedure UpdateManufacturingSetup(var ManufacturingSetup: Record "Manufacturing Setup"; ShowCapacityIn: Code[10]; ComponentsAtLocation: Code[10]; DocNoIsProdOrderNo: Boolean; CostInclSetup: Boolean; DynamicLowLevelCode: Boolean)
    begin
        // Update Manufacturing Setup.
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Doc. No. Is Prod. Order No.", DocNoIsProdOrderNo);
        ManufacturingSetup.Validate("Cost Incl. Setup", CostInclSetup);
        ManufacturingSetup.Validate("Show Capacity In", ShowCapacityIn);
        ManufacturingSetup.Validate("Components at Location", ComponentsAtLocation);
        ManufacturingSetup.Validate("Dynamic Low-Level Code", DynamicLowLevelCode);
        ManufacturingSetup.Modify(true);
    end;

    procedure UpdateOutputJournal(ProductionOrderNo: Code[20])
    var
        ItemJournalLine: Record "Item Journal Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ItemJournalLine.SetRange("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.SetRange("Order No.", ProductionOrderNo);
        ItemJournalLine.FindSet();
        repeat
            ProdOrderRoutingLine.SetRange("Routing No.", ItemJournalLine."Routing No.");
            case ItemJournalLine.Type of
                ItemJournalLine.Type::"Work Center":
                    ProdOrderRoutingLine.SetRange(Type, ProdOrderRoutingLine.Type::"Work Center");
                ItemJournalLine.Type::"Machine Center":
                    ProdOrderRoutingLine.SetRange(Type, ProdOrderRoutingLine.Type::"Machine Center");
            end;
            ProdOrderRoutingLine.SetRange("No.", ItemJournalLine."No.");
            ProdOrderRoutingLine.FindFirst();
            ItemJournalLine.Validate("Setup Time", ProdOrderRoutingLine."Setup Time");
            ItemJournalLine.Validate("Run Time", ProdOrderRoutingLine."Run Time");
            ItemJournalLine.Modify(true);
        until ItemJournalLine.Next() = 0;
    end;

    procedure UpdateProductionBOMStatus(var ProductionBOMHeader: Record "Production BOM Header"; NewStatus: Enum "BOM Status")
    begin
        ProductionBOMHeader.Validate(Status, NewStatus);
        ProductionBOMHeader.Modify(true);
    end;

    procedure UpdateProductionBOMVersionStatus(var ProductionBOMVersion: Record "Production BOM Version"; NewStatus: Enum "BOM Status")
    begin
        ProductionBOMVersion.Validate(Status, NewStatus);
        ProductionBOMVersion.Modify(true);
    end;

    procedure UpdateRoutingStatus(var RoutingHeader: Record "Routing Header"; NewStatus: Enum "Routing Status")
    begin
        RoutingHeader.Validate(Status, NewStatus);
        RoutingHeader.Modify(true);
    end;

    procedure UpdateShopCalendarFullWorkingWeekCustomTime(FromTime: Time; ToTime: Time): Code[10]
    var
        ShopCalendarWorkingDays: Record "Shop Calendar Working Days";
    begin
        exit(CreateShopCalendarCustomTime(ShopCalendarWorkingDays.Day::Monday, ShopCalendarWorkingDays.Day::Sunday, FromTime, ToTime));
    end;

    procedure UpdateShopCalendarWorkingDays(): Code[10]
    begin
        // Create Shop Calendar Working Days using 8 hrs daily work shift.
        exit(UpdateShopCalendarWorkingDaysCustomTime(080000T, 160000T));
    end;

    procedure UpdateShopCalendarWorkingDaysCustomTime(FromTime: Time; ToTime: Time): Code[10]
    var
        ShopCalendarWorkingDays: Record "Shop Calendar Working Days";
    begin
        exit(CreateShopCalendarCustomTime(ShopCalendarWorkingDays.Day::Monday, ShopCalendarWorkingDays.Day::Friday, FromTime, ToTime));
    end;

    procedure UpdateFinishOrderWithoutOutputInManufacturingSetup(FinishOrderWithoutOutput: Boolean)
    begin
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Finish Order without Output", FinishOrderWithoutOutput);
        ManufacturingSetup.Modify(true);
    end;

    procedure UpdateUnitCost(var ProductionOrder: Record "Production Order"; CalcMethod: Option; UpdateReservations: Boolean)
    var
        TmpProductionOrder: Record "Production Order";
        UpdateUnitCostReport: Report "Update Unit Cost";
    begin
        Clear(UpdateUnitCostReport);
        UpdateUnitCostReport.InitializeRequest(CalcMethod, UpdateReservations);
        if ProductionOrder.HasFilter then
            TmpProductionOrder.CopyFilters(ProductionOrder)
        else begin
            ProductionOrder.Get(ProductionOrder.Status, ProductionOrder."No.");
            TmpProductionOrder.SetRange(Status, ProductionOrder.Status);
            TmpProductionOrder.SetRange("No.", ProductionOrder."No.");
        end;
        UpdateUnitCostReport.SetTableView(TmpProductionOrder);
        UpdateUnitCostReport.UseRequestPage(false);
        UpdateUnitCostReport.Run();
    end;

    procedure FindLastOperationNo(RoutingNo: Code[20]): Code[10]
    var
        RoutingLine: Record "Routing Line";
    begin
        RoutingLine.SetLoadFields("Routing No.", "Operation No.");
        RoutingLine.SetRange("Routing No.", RoutingNo);
        if RoutingLine.FindLast() then
            exit(RoutingLine."Operation No.");
    end;

    procedure UpdateNonInventoryCostToProductionInManufacturingSetup(IncludeNonInventoryCostToProduction: Boolean)
    begin
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Inc. Non. Inv. Cost To Prod", IncludeNonInventoryCostToProduction);
        ManufacturingSetup.Modify(true);
    end;

    procedure UpdateLoadSKUCostOnManufacturingInManufacturingSetup(LoadSKUCostOnManufacturing: Boolean)
    begin
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Load SKU Cost on Manufacturing", LoadSKUCostOnManufacturing);
        ManufacturingSetup.Modify(true);
    end;

    [Normal]
    procedure UpdateProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; FieldNo: Integer; Value: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(ProdOrderLine);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(Value);
        RecRef.SetTable(ProdOrderLine);
        ProdOrderLine.Modify(true);
    end;

    [Normal]
    procedure UpdateProdOrderComp(var ProdOrderComponent: Record "Prod. Order Component"; FieldNo: Integer; Value: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(ProdOrderComponent);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(Value);
        RecRef.SetTable(ProdOrderComponent);
        ProdOrderComponent.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJournal(var RequisitionLine: Record "Requisition Line"; var Handled: Boolean)
    begin
    end;

    // Move from Library Patterns

    procedure CreateConsumptionJournalLine(var ItemJournalBatch: Record "Item Journal Batch"; ProdOrderLine: Record "Prod. Order Line"; ComponentItem: Record Item; PostingDate: Date; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; UnitCost: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        EntryType: Enum "Item Ledger Entry Type";
    begin
        LibraryInventory.CreateItemJournalBatchByType(ItemJournalBatch, ItemJournalBatch."Template Type"::Consumption);
        EntryType := ItemJournalLine."Entry Type"::"Negative Adjmt.";
        if ComponentItem.IsNonInventoriableType() then
            EntryType := ItemJournalLine."Entry Type"::Consumption;
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch, ComponentItem, LocationCode, VariantCode, PostingDate,
          EntryType, Qty, 0);
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Consumption);
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProdOrderLine."Prod. Order No.");
        ItemJournalLine.Validate("Order Line No.", ProdOrderLine."Line No.");
        if ItemJournalLine."Location Code" <> LocationCode then // required for CH
            ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Validate("Unit Cost", UnitCost);
        ItemJournalLine.Modify(true);
    end;

    procedure CreateOutputJournalLine(var ItemJournalBatch: Record "Item Journal Batch"; ProdOrderLine: Record "Prod. Order Line"; PostingDate: Date; Qty: Decimal; UnitCost: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
        RoutingLine: Record "Routing Line";
    begin
        LibraryInventory.CreateItemJournalBatchByType(ItemJournalBatch, ItemJournalBatch."Template Type"::Output);
        Item.Get(ProdOrderLine."Item No.");
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch, Item, ProdOrderLine."Location Code", ProdOrderLine."Variant Code", PostingDate,
          ItemJournalLine."Entry Type"::"Positive Adjmt.", 0, 0);
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Output);
        ItemJournalLine.Validate("Order Type", ItemJournalLine."Order Type"::Production);
        ItemJournalLine.Validate("Order No.", ProdOrderLine."Prod. Order No.");
        ItemJournalLine.Validate("Order Line No.", ProdOrderLine."Line No.");
        ItemJournalLine.Validate("Item No.", ProdOrderLine."Item No.");
        RoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
        if RoutingLine.FindFirst() then
            ItemJournalLine.Validate("Operation No.", RoutingLine."Operation No.");
        ItemJournalLine.Validate("Output Quantity", Qty);
        ItemJournalLine.Validate("Unit Cost", UnitCost);
        ItemJournalLine.Modify();
    end;

    procedure CreateProductionBOM(var ProductionBOMHeader: Record "Production BOM Header"; var ParentItem: Record Item; ChildItem: Record Item; ChildItemQtyPer: Decimal; RoutingLinkCode: Code[10])
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        CreateProductionBOMHeader(ProductionBOMHeader, ParentItem."Base Unit of Measure");
        CreateProductionBOMLine(
          ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, ChildItem."No.", ChildItemQtyPer);
        ProductionBOMLine.Validate("Routing Link Code", RoutingLinkCode);
        ProductionBOMLine.Modify();

        ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::Certified);
        ProductionBOMHeader.Modify();

        ParentItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ParentItem.Modify();
    end;

    procedure CreateProductionOrder(var ProductionOrder: Record "Production Order"; ProdOrderStatus: Enum "Production Order Status"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; DueDate: Date)
    var
        ProdOrderLine: Record "Prod. Order Line";
        NoSeries: Codeunit "No. Series";
        ProdNoSeries: Code[20];
    begin
        ProdNoSeries := LibraryUtility.GetGlobalNoSeriesCode();
        ManufacturingSetup.Get();
        case ProdOrderStatus of
            ProductionOrder.Status::Simulated:
                if ManufacturingSetup."Simulated Order Nos." <> ProdNoSeries then begin
                    ManufacturingSetup."Simulated Order Nos." := ProdNoSeries;
                    ManufacturingSetup.Modify();
                end;
            ProductionOrder.Status::Planned:
                if ManufacturingSetup."Planned Order Nos." <> ProdNoSeries then begin
                    ManufacturingSetup."Planned Order Nos." := ProdNoSeries;
                    ManufacturingSetup.Modify();
                end;
            ProductionOrder.Status::"Firm Planned":
                if ManufacturingSetup."Firm Planned Order Nos." <> ProdNoSeries then begin
                    ManufacturingSetup."Firm Planned Order Nos." := ProdNoSeries;
                    ManufacturingSetup.Modify();
                end;
            ProductionOrder.Status::Released:
                if ManufacturingSetup."Released Order Nos." <> ProdNoSeries then begin
                    ManufacturingSetup."Released Order Nos." := ProdNoSeries;
                    ManufacturingSetup.Modify();
                end;
        end;

        Clear(ProductionOrder);
        ProductionOrder."No." := NoSeries.GetNextNo(ProdNoSeries);
        ProductionOrder.Status := ProdOrderStatus;
        ProductionOrder.Validate("Source Type", ProductionOrder."Source Type"::Item);
        ProductionOrder.Validate("Source No.", Item."No.");
        ProductionOrder.Validate(Quantity, Qty);
        ProductionOrder.Validate("Location Code", LocationCode);
        ProductionOrder.Validate("Due Date", DueDate);
        ProductionOrder.Insert(true);
        RefreshProdOrder(ProductionOrder, false, true, true, true, true);
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.ModifyAll("Variant Code", VariantCode);
    end;

    procedure CreateRouting(var RoutingHeader: Record "Routing Header"; var Item: Record Item; RoutingLinkCode: Code[10]; DirectUnitCost: Decimal)
    var
        RoutingLine: Record "Routing Line";
        WorkCenter: Record "Work Center";
    begin
        CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        WorkCenter.FindFirst();
        WorkCenter.Validate("Direct Unit Cost", DirectUnitCost);
        WorkCenter.Modify();

        CreateRoutingLine(RoutingHeader, RoutingLine, '', '', RoutingLine.Type::"Work Center", WorkCenter."No.");
        RoutingLine.Validate("Routing Link Code", RoutingLinkCode);
        RoutingLine.Validate("Run Time", 1);
        RoutingLine.Modify();

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify();

        Item.Validate("Routing No.", RoutingHeader."No.");
        Item.Modify();
    end;

    procedure CreateRoutingforWorkCenter(var RoutingHeader: Record "Routing Header"; var Item: Record Item; WorkCenterNo: Code[20])
    var
        RoutingLine: Record "Routing Line";
    begin
        CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        CreateRoutingLine(RoutingHeader, RoutingLine, '', '', RoutingLine.Type::"Work Center", WorkCenterNo);
        RoutingLine.Validate("Run Time", 1);
        RoutingLine.Modify();

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify();

        Item.Validate("Routing No.", RoutingHeader."No.");
        Item.Modify();
    end;

    procedure CreateProdOrderUsingPlanning(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; DocumentNo: Code[20]; SourceNo: Code[20])
    var
        SalesOrderPlanning: Page "Sales Order Planning";
    begin
        SalesOrderPlanning.SetSalesOrder(DocumentNo);
        SalesOrderPlanning.BuildForm();
        SalesOrderPlanning.CreateProdOrder();
        Clear(ProductionOrder);
        ProductionOrder.SetRange(Status, Status);
        ProductionOrder.SetRange("Source No.", SourceNo);
        ProductionOrder.FindLast();
    end;

    procedure CreatePlanningRoutingLine(var PlanningRoutingLine: Record "Planning Routing Line"; var RequisitionLine: Record "Requisition Line"; OperationNo: Code[10])
    begin
        PlanningRoutingLine.Init();
        PlanningRoutingLine.Validate("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        PlanningRoutingLine.Validate("Worksheet Batch Name", RequisitionLine."Journal Batch Name");
        PlanningRoutingLine.Validate("Worksheet Line No.", RequisitionLine."Line No.");
        PlanningRoutingLine.Validate("Operation No.", OperationNo);
        PlanningRoutingLine.Insert(true);
    end;

    procedure PostConsumption(ProdOrderLine: Record "Prod. Order Line"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; UnitCost: Decimal)
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        CreateConsumptionJournalLine(ItemJournalBatch, ProdOrderLine, Item, PostingDate, LocationCode, VariantCode, Qty, UnitCost);
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    procedure PostOutput(ProdOrderLine: Record "Prod. Order Line"; Qty: Decimal; PostingDate: Date; UnitCost: Decimal)
    var
        ItemJournalBatch: Record "Item Journal Batch";
        Item: Record Item;
    begin
        Item.Get(ProdOrderLine."Item No.");
        CreateOutputJournalLine(ItemJournalBatch, ProdOrderLine, PostingDate, Qty, UnitCost);
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    procedure CreateProdOrderItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderLine: Record "Prod. Order Line"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateProdOrderItemTracking(ReservEntry, ProdOrderLine, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateProdOrderItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderLine: Record "Prod. Order Line"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ProdOrderLine);
        LibraryItemTracking.ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure CreateProdOrderCompItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderComp: Record "Prod. Order Component"; SerialNo: Code[50]; LotNo: Code[50]; QtyBase: Decimal)
    var
        ITemTrackingSetup: Record "Item Tracking Setup";
    begin
        ItemTrackingSetup."Serial No." := SerialNo;
        ItemTrackingSetup."Lot No." := LotNo;
        CreateProdOrderCompItemTracking(ReservEntry, ProdOrderComp, ITemTrackingSetup, QtyBase);
    end;

    procedure CreateProdOrderCompItemTracking(var ReservEntry: Record "Reservation Entry"; ProdOrderComp: Record "Prod. Order Component"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ProdOrderComp);
        LibraryItemTracking.ItemTracking(ReservEntry, RecRef, ItemTrackingSetup, QtyBase);
    end;

    procedure PostOutputWithItemTracking(ProdOrderLine: Record "Prod. Order Line"; Qty: Decimal; RunTime: Decimal; PostingDate: Date; UnitCost: Decimal; SerialNo: Code[50]; LotNo: Code[50])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
        ReservEntry: Record "Reservation Entry";
    begin
        Item.Get(ProdOrderLine."Item No.");
        CreateOutputJournalLine(ItemJournalBatch, ProdOrderLine, PostingDate, Qty, UnitCost);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.FindFirst();
        ItemJournalLine.Validate("Run Time", RunTime);
        ItemJournalLine.Modify();
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservEntry, ItemJournalLine, SerialNo, LotNo, Qty);
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    procedure SetComponentsAtLocation(LocationCode: Code[10])
    begin
        ManufacturingSetup.Get();
        ManufacturingSetup.Validate("Components at Location", LocationCode);
        ManufacturingSetup.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Item Tracking", 'OnItemTracking', '', false, false)]
    local procedure OnItemTracking(RecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; ItemTrackingSetup: Record "Item Tracking Setup"; QtyBase: Decimal; sender: Codeunit "Library - Item Tracking")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderCompLine: Record "Prod. Order Component";
    begin
        case RecRef.Number of
            DATABASE::"Prod. Order Line":
                begin
                    RecRef.SetTable(ProdOrderLine);
                    // COPY FROM COD 99000837: CallItemTracking
                    if ProdOrderLine.Status = ProdOrderLine.Status::Finished then
                        exit;
                    ProdOrderLine.TestField("Item No.");
                    // COPY END
                    sender.InsertItemTracking(
                        ReservEntry, ProdOrderLine.Quantity > 0,
                        ProdOrderLine."Item No.", ProdOrderLine."Location Code", ProdOrderLine."Variant Code",
                        QtyBase, ProdOrderLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Prod. Order Line", ProdOrderLine.Status.AsInteger(), ProdOrderLine."Prod. Order No.",
                        '', ProdOrderLine."Line No.", 0, ProdOrderLine."Due Date");
                end;
            DATABASE::"Prod. Order Component":
                begin
                    RecRef.SetTable(ProdOrderCompLine);
                    // COPY FROM COD 99000838: CallItemTracking
                    if ProdOrderCompLine.Status = ProdOrderCompLine.Status::Finished then
                        exit;
                    ProdOrderCompLine.TestField("Item No.");
                    // COPY END
                    sender.InsertItemTracking(
                        ReservEntry, ProdOrderCompLine.Quantity < 0,
                        ProdOrderCompLine."Item No.", ProdOrderCompLine."Location Code", ProdOrderCompLine."Variant Code",
                        -QtyBase, ProdOrderCompLine."Qty. per Unit of Measure", ItemTrackingSetup,
                        DATABASE::"Prod. Order Component", ProdOrderCompLine.Status.AsInteger(), ProdOrderCompLine."Prod. Order No.",
                        '', ProdOrderCompLine."Prod. Order Line No.", ProdOrderCompLine."Line No.", ProdOrderCompLine."Due Date");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Assembly", 'OnCreateMultipleLvlTreeOnCreateBOM', '', false, false)]
    local procedure OnCreateMultipleLvlTreeOnCreateBOM(var Item: Record Item; NoOfComps: Integer; var BOMCreated: Boolean)
    begin
        if Item."Replenishment System" = Item."Replenishment System"::"Prod. Order" then begin
            CreateProductionBOM(Item, NoOfComps);
            BOMCreated := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnGetTableNosWithGlobalDimensionCode', '', false, false)]
    local procedure OnGetTableNosWithGlobalDimensionCode(var TableBuffer: Record "Integer" temporary; sender: Codeunit "Library - Dimension")
    begin
        sender.AddTable(TableBuffer, DATABASE::"Work Center");
    end;
}
