codeunit 4763 "Contoso Manufacturing"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Stop = rim,
        tabledata Scrap = rim,
        tabledata "Production BOM Header" = rim,
        tabledata "Production BOM Line" = rim,
        tabledata "Routing Header" = rim,
        tabledata "Routing Line" = rim,
        tabledata "Work Center" = rim,
        tabledata "Work Center Group" = rim,
        tabledata "Machine Center" = rim,
        tabledata "Capacity Constrained Resource" = rim,
        tabledata "Routing Link" = rim,
        tabledata "Shop Calendar" = rim,
        tabledata "Work Shift" = rim,
        tabledata "Shop Calendar Working Days" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertStop(StopCode: Code[20]; Description: Text[100])
    var
        Stop: Record Stop;
        Exists: Boolean;
    begin
        if Stop.Get(StopCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Stop.Validate(Code, StopCode);
        Stop.Validate(Description, Description);

        if Exists then
            Stop.Modify(true)
        else
            Stop.Insert(true);
    end;

    procedure InsertScrap(ScrapCode: Code[10]; Description: Text[50])
    var
        Scrap: Record Scrap;
        Exists: Boolean;
    begin
        if Scrap.Get(ScrapCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Scrap.Validate(Code, ScrapCode);
        Scrap.Validate(Description, Description);

        if Exists then
            Scrap.Modify(true)
        else
            Scrap.Insert(true);
    end;

    procedure InsertProductionBOMHeader(BOMCode: Code[20]; Description: Text[30]; UnitOfMeasureCode: Text[10])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        Exists: Boolean;
    begin
        if ProductionBOMHeader.Get(BOMCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ProductionBOMHeader.Validate("No.", BOMCode);
        ProductionBOMHeader.Validate(Description, Description);
        ProductionBOMHeader.Validate("Unit of Measure Code", UnitOfMeasureCode);

        if Exists then
            ProductionBOMHeader.Modify(true)
        else
            ProductionBOMHeader.Insert(true);
    end;

    procedure InsertProductionBOMLine(BOMCode: Code[20]; VersionCode: Code[20]; Type: Option " ",Item,"Production BOM"; No: Code[20]; CalcFormula: Enum "Quantity Calculation Formula"; QuantityPer: Decimal; RoutingLinkCode: Code[10])
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        ProductionBOMLine.Validate("Production BOM No.", BOMCode);
        ProductionBOMLine.Validate("Version Code", VersionCode);
        ProductionBOMLine.Validate("Line No.", GetNextProductionBOMLineNo(BOMCode, VersionCode));
        ProductionBOMLine.Validate(Type, Type);
        ProductionBOMLine.Validate("No.", No);
        ProductionBOMLine.Validate("Quantity per", QuantityPer);
        ProductionBOMLine.Validate("Calculation Formula", CalcFormula);
        ProductionBOMLine.Validate("Routing Link Code", RoutingLinkCode);
        ProductionBOMLine.Insert(true);
    end;

    local procedure GetNextProductionBOMLineNo(BOMCode: Code[20]; VersionCode: Code[20]): Integer
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        ProductionBOMLine.SetRange("Production BOM No.", BOMCode);
        ProductionBOMLine.SetRange("Version Code", VersionCode);
        ProductionBOMLine.SetCurrentKey("Line No.");

        if ProductionBOMLine.FindLast() then
            exit(ProductionBOMLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertRoutingHeader(RoutingNo: Code[20]; Description: Text[30]; Type: Option Serial,Parallel)
    var
        RoutingHeader: Record "Routing Header";
        Exists: Boolean;
    begin
        if RoutingHeader.Get(RoutingNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RoutingHeader.Validate("No.", RoutingNo);
        RoutingHeader.Validate(Description, Description);
        RoutingHeader.Validate(Type, Type);

        if Exists then
            RoutingHeader.Modify(true)
        else
            RoutingHeader.Insert(true);
    end;

    procedure InsertRoutingLine(RoutingNo: Code[20]; VersionCode: Code[20]; OperationNo: Code[10]; NextOperationNo: Code[10]; Type: Enum "Capacity Type Routing"; No: Code[20]; Description: Text[30]; SetupTime: Decimal; RunTime: Decimal; ConcurrentCapacity: Decimal; SendAheadQty: Decimal; RoutingLinkCode: Code[10]; UnitCostPer: Decimal)
    var
        RoutingLine: Record "Routing Line";
        Exists: Boolean;
    begin
        if RoutingLine.Get(RoutingNo, VersionCode, OperationNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RoutingLine.Validate("Routing No.", RoutingNo);
        RoutingLine.Validate("Version Code", VersionCode);
        RoutingLine.Validate("Operation No.", OperationNo);
        RoutingLine.Validate("Next Operation No.", NextOperationNo);
        RoutingLine.Validate(Type, Type);
        RoutingLine.Validate("No.", No);
        RoutingLine.Validate(Description, Description);
        RoutingLine.Validate("Setup Time", SetupTime);
        RoutingLine.Validate("Run Time", RunTime);
        RoutingLine.Validate("Concurrent Capacities", ConcurrentCapacity);
        RoutingLine.Validate("Send-Ahead Quantity", SendAheadQty);
        RoutingLine.Validate("Routing Link Code", RoutingLinkCode);
        RoutingLine.Validate("Unit Cost per", UnitCostPer);

        if Exists then
            RoutingLine.Modify(true)
        else
            RoutingLine.Insert(true);
    end;

    procedure InsertWorkCenter(No: Code[20]; Name: Text[30]; WorkCenterGroupCode: Code[10]; DirectUnitCost: Decimal; CapUnitOfMeasureCode: Text[10]; Capacity: Decimal; ShopCalendarCode: Code[10]; UnitCostCalc: Option Time,Units; GenProdPostGrp: Code[20]; SubcontractorNo: Code[20])
    var
        WorkCenter: Record "Work Center";
        Exists: Boolean;
    begin
        if WorkCenter.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WorkCenter.Validate("No.", No);
        WorkCenter.Validate(Name, Name);
        WorkCenter.Validate("Work Center Group Code", WorkCenterGroupCode);
        WorkCenter.Validate("Direct Unit Cost", DirectUnitCost);
        WorkCenter.Validate(Capacity, Capacity);
        WorkCenter.Validate("Shop Calendar Code", ShopCalendarCode);
        WorkCenter.Validate("Unit Cost Calculation", UnitCostCalc);
        WorkCenter.Validate("Gen. Prod. Posting Group", GenProdPostGrp);
        WorkCenter.Validate("Subcontractor No.", SubcontractorNo);

        if Exists then
            WorkCenter.Modify(true)
        else
            WorkCenter.Insert(true);

        if CapUnitOfMeasureCode <> '' then begin
            WorkCenter.Validate("Unit of Measure Code", CapUnitOfMeasureCode);
            WorkCenter.Modify(true);
        end;
    end;

    procedure InsertWorkCenterGroup(WorkCenterGroupCode: Code[10]; Name: Text[30])
    var
        WorkCenterGroup: Record "Work Center Group";
        Exists: Boolean;
    begin
        if WorkCenterGroup.Get(WorkCenterGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WorkCenterGroup.Validate(Code, WorkCenterGroupCode);
        WorkCenterGroup.Validate(Name, Name);

        if Exists then
            WorkCenterGroup.Modify(true)
        else
            WorkCenterGroup.Insert(true);
    end;

    procedure InsertMachineCenter(No: Code[20]; Name: Text[30]; WorkCenterNo: Code[20]; Capacity: Decimal; GenProdPostGrp: Code[20]; FlushingMethod: Enum "Flushing Method Routing")
    var
        MachineCenter: Record "Machine Center";
        Exists: Boolean;
    begin
        if MachineCenter.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        MachineCenter.Validate("No.", No);
        MachineCenter.Validate(Name, Name);
        MachineCenter.Validate("Work Center No.", WorkCenterNo);
        MachineCenter.Validate(Capacity, Capacity);
        MachineCenter.Validate("Gen. Prod. Posting Group", GenProdPostGrp);
        MachineCenter.Validate("Flushing Method", FlushingMethod);

        if Exists then
            MachineCenter.Modify(true)
        else
            MachineCenter.Insert(true);
    end;

    procedure InsertCapacityConstrainedResource(No: Code[20]; Type: Option "Work Center","Machine Center"; CriticalLoadPct: Decimal; DampeningPct: Decimal)
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
        CapacityConstrainedResource: Record "Capacity Constrained Resource";
        Exists: Boolean;
    begin
        if CapacityConstrainedResource.Get(Type, No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CapacityConstrainedResource.Validate("Capacity Type", Type);
        CapacityConstrainedResource.Validate("Capacity No.", No);

        case CapacityConstrainedResource."Capacity Type" of
            "Capacity Type"::"Work Center":
                begin
                    WorkCenter.Get(No);
                    CapacityConstrainedResource.Validate(Name, WorkCenter.Name);
                    CapacityConstrainedResource.Validate("Work Center No.", WorkCenter."No.")
                end;
            "Capacity Type"::"Machine Center":
                begin
                    MachineCenter.Get(CapacityConstrainedResource."Capacity No.");
                    CapacityConstrainedResource.Validate(Name, MachineCenter.Name);
                    CapacityConstrainedResource.Validate("Work Center No.", MachineCenter."Work Center No.")
                end;
        end;

        CapacityConstrainedResource.Validate("Critical Load %", CriticalLoadPct);
        CapacityConstrainedResource.Validate("Dampener (% of Total Capacity)", DampeningPct);

        if Exists then
            CapacityConstrainedResource.Modify(true)
        else
            CapacityConstrainedResource.Insert(true);
    end;

    procedure InsertRoutingLink(RoutingLinkCode: Code[10]; Description: Text[100])
    var
        RoutingLink: Record "Routing Link";
        Exists: Boolean;
    begin
        if RoutingLink.Get(RoutingLinkCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RoutingLink.Validate(Code, RoutingLinkCode);
        RoutingLink.Validate(Description, Description);

        if Exists then
            RoutingLink.Modify(true)
        else
            RoutingLink.Insert(true);
    end;

    procedure InsertWorkShift(WorkShiftCode: Code[10]; Description: Text[100])
    var
        WorkShift: Record "Work Shift";
        Exists: Boolean;
    begin
        if WorkShift.Get(WorkShiftCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WorkShift.Validate(Code, WorkShiftCode);
        WorkShift.Validate(Description, Description);

        if Exists then
            WorkShift.Modify(true)
        else
            WorkShift.Insert(true);
    end;

    procedure InsertShopCalendar(ShopCalendarCode: Code[10]; Description: Text[100])
    var
        ShopCalendar: Record "Shop Calendar";
        Exists: Boolean;
    begin
        if ShopCalendar.Get(ShopCalendarCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShopCalendar.Validate(Code, ShopCalendarCode);
        ShopCalendar.Validate(Description, Description);

        if Exists then
            ShopCalendar.Modify(true)
        else
            ShopCalendar.Insert(true);
    end;

    procedure InsertShopCalendarWorkingDays(ShopCalendarCode: Code[10]; Day: Option Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday; StartingTime: Time; EndingTime: Time; WorkShiftCode: Code[10])
    var
        ShopCalendarWorkingDays: Record "Shop Calendar Working Days";
        Exists: Boolean;
    begin
        if ShopCalendarWorkingDays.Get(ShopCalendarCode, Day, StartingTime, EndingTime, WorkShiftCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShopCalendarWorkingDays.Validate("Shop Calendar Code", ShopCalendarCode);
        ShopCalendarWorkingDays.Validate(Day, Day);
        ShopCalendarWorkingDays.Validate("Starting Time", StartingTime);
        ShopCalendarWorkingDays.Validate("Ending Time", EndingTime);
        ShopCalendarWorkingDays.Validate("Work Shift Code", WorkShiftCode);

        if Exists then
            ShopCalendarWorkingDays.Modify(true)
        else
            ShopCalendarWorkingDays.Insert(true);
    end;
}