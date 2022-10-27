codeunit 4778 "Create Mfg Work Center"
{
    Permissions = tabledata "Capacity Constrained Resource" = rim,
        tabledata "Machine Center" = rim,
        tabledata "Work Center" = rim,
        tabledata "Work Center Group" = ri;

    trigger OnRun()
    var
        WorkCenterCode: Code[20];
    begin
        ManufacturingDemoDataSetup.Get();

        InserWorkCenterGroup('1', XProductiondepartmentTok);

        WorkCenterCode := '100';
        InsertWorkCenter(WorkCenterCode, XAssemblydepartmentTok, '', '1', 1.2, 0, 0, '', XMINUTESTok, 3, 100, 0, 0, 0.0001, 0, XOneshiftTok, 0, false, ManufacturingDemoDataSetup."Manufact Code", '');
        InsertMachineCenter('110', XFlushManualTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('120', XFlushBackTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Backward);
        InsertMachineCenter('130', XFlushForwardTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Forward);


        WorkCenterCode := '200';
        InsertWorkCenter(WorkCenterCode, XPackingdepartmentTok, '', '1', 1.5, 0, 0, '', XMINUTESTok, 1, 100, 0, 0, 0.0001, 0, XOneshiftTok, 0, false, ManufacturingDemoDataSetup."Manufact Code", '');
        InsertMachineCenter('210', XPackingtable1Tok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('220', XPackingtable2Tok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('230', XPackingMachineTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Backward);

        WorkCenterCode := '300';
        InsertWorkCenter(WorkCenterCode, XPaintingdepartmentTok, '', '1', 1.7, 0, 0, '', XMINUTESTok, 1, 100, 0, 0, 0.0001, 0, XTwoshiftsTok, 0, false, ManufacturingDemoDataSetup."Manufact Code", '');
        InsertMachineCenter('310', XPaintingCabinTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('330', XDryingCabinTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('340', XPaintinginspectionTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);

        WorkCenterCode := '400';
        InsertWorkCenter(WorkCenterCode, XMachinedepartmentTok, '', '1', 2.5, 0, 0, '', XMINUTESTok, 1, 100, 0, 0, 0.0001, 0, XTwoshiftsTok, 0, false, ManufacturingDemoDataSetup."Manufact Code", '');
        InsertMachineCenter('410', XDrillingmachineTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('420', XCNCmachineTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('430', XMachinedeburrTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertMachineCenter('440', XMachineinspectionTok, WorkCenterCode, 0, '', 1, 100, 0, 0, ManufacturingDemoDataSetup."Manufact Code", FlushingMethod::Manual);
        InsertConstrainedCapacity('420', 1, 90, 5);

        InserWorkCenterGroup('5', XSuncontractorsTok);
        InsertWorkCenter('500', XSubcontractorTok, '', '5', 0, 0, 0, '', XMINUTESTok, 100, 100, 0, 0, 0.0001, 0, XOneshiftTok, 1, false, ManufacturingDemoDataSetup."Retail Code", '82000');

        CalcMachineCenterCalendar.InitializeRequest(AdjustManufacturingdata.AdjustDate(19020101D), AdjustManufacturingdata.AdjustDate(19031231D));
        CalcMachineCenterCalendar.UseRequestPage(false);
        CalcMachineCenterCalendar.RunModal();

        CalculateWorkCenterCalendar.InitializeRequest(AdjustManufacturingdata.AdjustDate(19020101D), AdjustManufacturingdata.AdjustDate(19031231D));
        CalculateWorkCenterCalendar.UseRequestPage(false);
        CalculateWorkCenterCalendar.RunModal();
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        CalculateWorkCenterCalendar: Report "Calculate Work Center Calendar";
        CalcMachineCenterCalendar: Report "Calc. Machine Center Calendar";
        AdjustManufacturingData: Codeunit "Adjust Manufacturing Data";
        FlushingMethod: Enum "Flushing Method Routing";
        XSuncontractorsTok: Label 'Subcontractors', MaxLength = 30;
        XProductiondepartmentTok: Label 'Production department', MaxLength = 30;
        XAssemblydepartmentTok: Label 'Assembly department', MaxLength = 30;
        XMINUTESTok: Label 'MINUTES', Comment = 'Max length 10, must be the same as in CreateMfgUnitofMeasures codeunit';
        XPackingdepartmentTok: Label 'Packing department';
        XPaintingdepartmentTok: Label 'Painting department';
        XMachinedepartmentTok: Label 'Machine department';
        XSubcontractorTok: Label 'Subcontractor';
        XOneshiftTok: Label 'One shift', MaxLength = 10;
        XTwoshiftsTok: Label 'Two shifts', MaxLength = 10;
        XFlushManualTok: Label 'Flushing Manual', MaxLength = 30;
        XFlushBackTok: Label 'Flushing Backward', MaxLength = 30;
        XFlushForwardTok: Label 'Flushing Forward', MaxLength = 30;
        XPackingtable1Tok: Label 'Packing table 1', MaxLength = 30;
        XPackingtable2Tok: Label 'Packing table 2', MaxLength = 30;
        XPackingMachineTok: Label 'Packing Machine', MaxLength = 30;
        XPaintingCabinTok: Label 'Painting Cabin', MaxLength = 30;
        XDryingCabinTok: Label 'Drying Cabin', MaxLength = 30;
        XPaintinginspectionTok: Label 'Painting inspection', MaxLength = 30;
        XDrillingmachineTok: Label 'Drilling machine', MaxLength = 30;
        XCNCmachineTok: Label 'CNC machine', MaxLength = 30;
        XMachinedeburrTok: Label 'Machine deburr', MaxLength = 30;
        XMachineinspectionTok: Label 'Machine inspection', MaxLength = 30;

    local procedure InserWorkCenterGroup("Code": Code[10]; Name: Text[30])
    var
        WorkCenterGroup: Record "Work Center Group";
    begin
        WorkCenterGroup.Validate(Code, Code);
        WorkCenterGroup.Validate(Name, Name);
        WorkCenterGroup.Insert();
    end;

    local procedure InsertWorkCenter(No: Code[20]; Name: Text[30]; AltWorkCenter: Code[20]; WorkCenterGroupCode: Code[10]; DirectUnitCost: Decimal; IndirectCostPct: Decimal; QueueTime: Decimal;
                                   QueueUnitOfMeasure: Text[10]; UnitOfMeasureCode: Text[10]; Capacity: Decimal; Efficiency: Decimal; MaxEfficiency: Decimal; MinEfficiency: Decimal;
                                   CalRoundPrecision: Decimal; SimulationType: Option Moves,Critical,"Moves when necessary"; ShopCalendarCode: Code[10]; UnitCostCalc: Option Time,Units;
                                   SpecificUnitCost: Boolean; GenProdPostGrp: Code[20]; SubcontractorNo: Code[20])
    var
        WorkCenter: Record "Work Center";
    begin
        WorkCenter.Validate("No.", No);
        WorkCenter.Validate(Name, Name);
        WorkCenter.Validate("Alternate Work Center", AltWorkCenter);
        WorkCenter.Insert();

        WorkCenter.Validate("Work Center Group Code", WorkCenterGroupCode);
        WorkCenter.Validate("Direct Unit Cost", DirectUnitCost);
        WorkCenter.Validate("Indirect Cost %", IndirectCostPct);
        WorkCenter.Validate("Queue Time", QueueTime);
        WorkCenter.Validate("Queue Time Unit of Meas. Code", QueueUnitOfMeasure);
        WorkCenter.Validate("Unit of Measure Code", UnitOfMeasureCode);
        WorkCenter.Validate(Capacity, Capacity);
        WorkCenter.Validate(Efficiency, Efficiency);
        WorkCenter.Validate("Maximum Efficiency", MaxEfficiency);
        WorkCenter.Validate("Minimum Efficiency", MinEfficiency);
        WorkCenter.Validate("Calendar Rounding Precision", CalRoundPrecision);
        WorkCenter.Validate("Simulation Type", SimulationType);
        WorkCenter.Validate("Shop Calendar Code", ShopCalendarCode);
        WorkCenter.Validate("Unit Cost Calculation", UnitCostCalc);
        WorkCenter.Validate("Specific Unit Cost", SpecificUnitCost);
        WorkCenter.Validate("Gen. Prod. Posting Group", GenProdPostGrp);
        if SubcontractorNo <> '' then
            WorkCenter.Validate("Subcontractor No.", SubcontractorNo);

        OnBeforeWorkCenterModify(WorkCenter);

        WorkCenter.Modify();
    end;

    local procedure InsertMachineCenter(No: Code[20]; Name: Text[30]; WorkCenterNo: Code[20]; QueueTime: Decimal; QueueUnitOfMeasure: Text[10]; Capacity: Decimal; Efficiency: Decimal;
                                      MaxEfficiency: Decimal; MinEfficiency: Decimal; GenProdPostGrp: Code[20]; FlushingMethod: Enum "Flushing Method Routing")
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
    begin
        MachineCenter.Validate("No.", No);
        MachineCenter.Validate(Name, Name);
        MachineCenter.Insert();
        WorkCenter.Get(WorkCenterNo);
        MachineCenter.Validate("Setup Time Unit of Meas. Code", WorkCenter."Unit of Measure Code");
        MachineCenter.Validate("Wait Time Unit of Meas. Code", WorkCenter."Unit of Measure Code");
        MachineCenter.Validate("Move Time Unit of Meas. Code", WorkCenter."Unit of Measure Code");
        MachineCenter.Validate("Work Center No.", WorkCenterNo);
        MachineCenter.Validate("Queue Time", QueueTime);
        MachineCenter.Validate("Queue Time Unit of Meas. Code", QueueUnitOfMeasure);
        MachineCenter.Validate(Capacity, Capacity);
        MachineCenter.Validate(Efficiency, Efficiency);
        MachineCenter.Validate("Maximum Efficiency", MaxEfficiency);
        MachineCenter.Validate("Minimum Efficiency", MinEfficiency);
        MachineCenter.Validate("Gen. Prod. Posting Group", GenProdPostGrp);
        MachineCenter.Validate("Flushing Method", FlushingMethod);
        MachineCenter.Modify();
    end;

    local procedure InsertConstrainedCapacity(No: Code[20]; Type: Option "Work Center","Machine Center"; CriticalLoadPct: Decimal; DampeningPct: Decimal)
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
        CapacityConstrainedResource: Record "Capacity Constrained Resource";
    begin
        CapacityConstrainedResource.Validate("Capacity Type", Type);
        CapacityConstrainedResource.Validate("Capacity No.", No);
        CapacityConstrainedResource.Insert();
        case CapacityConstrainedResource."Capacity Type" of
            "Capacity Type"::"Work Center":
                begin
                    WorkCenter.Get(No);
                    CapacityConstrainedResource.Name := WorkCenter.Name;
                    CapacityConstrainedResource."Work Center No." := WorkCenter."No."
                end;
            "Capacity Type"::"Machine Center":
                begin
                    MachineCenter.Get(CapacityConstrainedResource."Capacity No.");
                    CapacityConstrainedResource.Name := MachineCenter.Name;
                    CapacityConstrainedResource."Work Center No." := MachineCenter."Work Center No."
                end;
        end;
        CapacityConstrainedResource.Validate("Critical Load %", CriticalLoadPct);
        CapacityConstrainedResource.Validate("Dampener (% of Total Capacity)", DampeningPct);
        CapacityConstrainedResource.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWorkCenterModify(var WorkCenter: Record "Work Center")
    begin
    end;
}