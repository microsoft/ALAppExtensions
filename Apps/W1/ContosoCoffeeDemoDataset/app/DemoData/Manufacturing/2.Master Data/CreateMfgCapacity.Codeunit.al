codeunit 4775 "Create Mfg Capacity"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateWorkShiftsAndShopCalendars();
        CreateWorkAndMachineCenters();
    end;

    var
        ContosoManufacturing: Codeunit "Contoso Manufacturing";
        OneShiftTok: Label 'One shift', MaxLength = 10;
        OneShiftMondayFridayTok: Label 'One shift Monday-Friday', MaxLength = 50;
        TwoShiftsTok: Label 'Two shifts', MaxLength = 10;
        TwoShiftsMondayFridayTok: Label 'Two shifts Monday-Friday', MaxLength = 50;
        FirstShiftTok: Label '1st shift', MaxLength = 50;
        SecondShiftTok: Label '2nd shift', MaxLength = 50;
        SubcontractorsTok: Label 'Subcontractors', MaxLength = 30;
        ProductionDepartmentTok: Label 'Production department', MaxLength = 30;
        AssemblyDepartmentTok: Label 'Assembly department', MaxLength = 30;
        PackingDepartmentTok: Label 'Packing department';
        PaintingDepartmentTok: Label 'Painting department';
        MachineDepartmentTok: Label 'Machine department';
        SubcontractorTok: Label 'Subcontractor';
        FlushManualTok: Label 'Flushing Manual', MaxLength = 30;
        FlushBackTok: Label 'Flushing Backward', MaxLength = 30;
        FlushForwardTok: Label 'Flushing Forward', MaxLength = 30;
        PackingTable1Tok: Label 'Packing table 1', MaxLength = 30;
        PackingTable2Tok: Label 'Packing table 2', MaxLength = 30;
        PackingMachineTok: Label 'Packing Machine', MaxLength = 30;
        PaintingCabinTok: Label 'Painting Cabin', MaxLength = 30;
        DryingCabinTok: Label 'Drying Cabin', MaxLength = 30;
        PaintingInspectionTok: Label 'Painting inspection', MaxLength = 30;
        DrillingMachineTok: Label 'Drilling machine', MaxLength = 30;
        CNCMachineTok: Label 'CNC machine', MaxLength = 30;
        MachineDeburrTok: Label 'Machine deburr', MaxLength = 30;
        MachineInspectionTok: Label 'Machine inspection', MaxLength = 30;

    local procedure CreateWorkShiftsAndShopCalendars()
    begin
        // 1 shift
        ContosoManufacturing.InsertShopCalendar(ShopCalendarOneShift(), OneShiftMondayFridayTok);
        ContosoManufacturing.InsertWorkShift(WorkShift1(), FirstShiftTok);

        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarOneShift(), 0, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarOneShift(), 1, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarOneShift(), 2, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarOneShift(), 3, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarOneShift(), 4, 080000T, 160000T, WorkShift1());

        // 2 shifts
        ContosoManufacturing.InsertShopCalendar(ShopCalendarTwoShifts(), TwoShiftsMondayFridayTok);
        ContosoManufacturing.InsertWorkShift(WorkShift2(), SecondShiftTok);

        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 0, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 1, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 2, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 3, 080000T, 160000T, WorkShift1());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 4, 080000T, 160000T, WorkShift1());

        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 0, 160000T, 230000T, WorkShift2());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 1, 160000T, 230000T, WorkShift2());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 2, 160000T, 230000T, WorkShift2());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 3, 160000T, 230000T, WorkShift2());
        ContosoManufacturing.InsertShopCalendarWorkingDays(ShopCalendarTwoShifts(), 4, 160000T, 230000T, WorkShift2());
    end;

    local procedure CreateWorkAndMachineCenters()
    var
        CalcMachineCenterCalendar: Report "Calc. Machine Center Calendar";
        CalculateWorkCenterCalendar: Report "Calculate Work Center Calendar";
        ContosoUtilities: Codeunit "Contoso Utilities";
        MfgPostingGroup: Codeunit "Create Mfg Posting Group";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        MfgCapUnitOfMeasure: Codeunit "Create Mfg Cap Unit of Measure";
        MfgVendor: Codeunit "Create Mfg Vendor";
    begin
        ContosoManufacturing.InsertWorkCenterGroup(WorkCenterGroup1(), ProductionDepartmentTok);

        ContosoManufacturing.InsertWorkCenter(WorkCenter100(), AssemblyDepartmentTok, WorkCenterGroup1(), 1.2, MfgCapUnitOfMeasure.Minutes(), 3, ShopCalendarOneShift(), 0, MfgPostingGroup.Manufacturing(), '');
        ContosoManufacturing.InsertMachineCenter(MachineCenter110(), FlushManualTok, WorkCenter100(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('120', FlushBackTok, WorkCenter100(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Backward);
        ContosoManufacturing.InsertMachineCenter(MachineCenter130(), FlushForwardTok, WorkCenter100(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Forward);

        ContosoManufacturing.InsertWorkCenter(WorkCenter200(), PackingDepartmentTok, WorkCenterGroup1(), 1.5, MfgCapUnitOfMeasure.Minutes(), 1, ShopCalendarOneShift(), 0, MfgPostingGroup.Manufacturing(), '');
        ContosoManufacturing.InsertMachineCenter(MachineCenter210(), PackingTable1Tok, WorkCenter200(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('220', PackingTable2Tok, WorkCenter200(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter(MachineCenter230(), PackingMachineTok, WorkCenter200(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Backward);

        ContosoManufacturing.InsertWorkCenter(WorkCenter300(), PaintingDepartmentTok, WorkCenterGroup1(), 1.7, MfgCapUnitOfMeasure.Minutes(), 1, ShopCalendarTwoShifts(), 0, MfgPostingGroup.Manufacturing(), '');
        ContosoManufacturing.InsertMachineCenter('310', PaintingCabinTok, WorkCenter300(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('330', DryingCabinTok, WorkCenter300(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('340', PaintingInspectionTok, WorkCenter300(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);

        ContosoManufacturing.InsertWorkCenter(WorkCenter400(), MachineDepartmentTok, WorkCenterGroup1(), 2.5, MfgCapUnitOfMeasure.Minutes(), 1, ShopCalendarTwoShifts(), 0, MfgPostingGroup.Manufacturing(), '');
        ContosoManufacturing.InsertMachineCenter('410', DrillingMachineTok, WorkCenter400(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('420', CNCMachineTok, WorkCenter400(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('430', MachineDeburrTok, WorkCenter400(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertMachineCenter('440', MachineInspectionTok, WorkCenter400(), 1, MfgPostingGroup.Manufacturing(), Enum::"Flushing Method Routing"::Manual);
        ContosoManufacturing.InsertCapacityConstrainedResource('420', 1, 90, 5);

        ContosoManufacturing.InsertWorkCenterGroup(WorkCenterGroup5(), SubcontractorsTok);
        ContosoManufacturing.InsertWorkCenter(WorkCenter500(), SubcontractorTok, WorkCenterGroup5(), 0, MfgCapUnitOfMeasure.Minutes(), 100, ShopCalendarOneShift(), 1, CommonPostingGroup.Retail(), MfgVendor.SubcontractorVendor());


        CalcMachineCenterCalendar.InitializeRequest(ContosoUtilities.AdjustDate(19020101D), ContosoUtilities.AdjustDate(19031231D));
        CalcMachineCenterCalendar.UseRequestPage(false);
        CalcMachineCenterCalendar.RunModal();

        CalculateWorkCenterCalendar.InitializeRequest(ContosoUtilities.AdjustDate(19020101D), ContosoUtilities.AdjustDate(19031231D));
        CalculateWorkCenterCalendar.UseRequestPage(false);
        CalculateWorkCenterCalendar.RunModal();
    end;

    procedure WorkShift1(): Code[10]
    begin
        exit('1');
    end;

    procedure WorkShift2(): Code[10]
    begin
        exit('2');
    end;

    procedure ShopCalendarOneShift(): Code[10]
    begin
        exit(OneShiftTok);
    end;

    procedure ShopCalendarTwoShifts(): Code[10]
    begin
        exit(TwoShiftsTok);
    end;


    procedure WorkCenterGroup1(): Code[10]
    begin
        exit('1');
    end;

    procedure WorkCenterGroup5(): Code[10]
    begin
        exit('5');
    end;

    procedure WorkCenter100(): Code[10]
    begin
        exit('100');
    end;

    procedure WorkCenter200(): Code[10]
    begin
        exit('200');
    end;

    procedure WorkCenter300(): Code[10]
    begin
        exit('300');
    end;

    procedure WorkCenter400(): Code[10]
    begin
        exit('400');
    end;

    procedure WorkCenter500(): Code[10]
    begin
        exit('500')
    end;

    procedure MachineCenter110(): Code[20]
    begin
        exit('110');
    end;

    procedure MachineCenter130(): Code[20]
    begin
        exit('130');
    end;

    procedure MachineCenter210(): Code[20]
    begin
        exit('210');
    end;

    procedure MachineCenter230(): Code[20]
    begin
        exit('230');
    end;
}