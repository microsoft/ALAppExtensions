codeunit 4784 "Create Mfg No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(WorkCenter(), WorkCentersLbl, 'W10', 'W99990', '', '', 10, true, true);
        ContosoNoSeries.InsertNoSeries(ProductionBOM(), ProductionBOMsLbl, 'P10', 'P99990', '', '', 10, true, true);
        ContosoNoSeries.InsertNoSeries(MachineCenter(), MachineCentersLbl, 'M10', 'M99990', '', '', 10, true, true);
        ContosoNoSeries.InsertNoSeries(Routing(), RoutingLbl, 'R10', 'R99990', '', '', 10, true, true);

        ContosoNoSeries.InsertNoSeries(SimulatedOrder(), SimulatedOrdersLbl, '1001', '2999', '2995', '', 1, false, false);

        ContosoNoSeries.InsertNoSeries(PlannedOrder(), PlannedOrdersLbl, '101001', '102999', '102995', '', 1, false, false);
        ContosoNoSeries.InsertNoSeries(FirmPlannedOrder(), FirmPlannedOrdersLbl, '101001', '102999', '102995', '', 1, false, false);
        ContosoNoSeries.InsertNoSeries(ReleasedOrderCode(), ReleasedOrdersLbl, '101001', '102999', '102995', '', 1, false, false);
    end;

    var
        WorkCenterTok: Label 'WORKCTR', MaxLength = 20;
        WorkCentersLbl: Label 'Work Centers', MaxLength = 100;
        ProductionBOMTok: Label 'PRODBOM', MaxLength = 20;
        ProductionBOMsLbl: Label 'Production BOMs', MaxLength = 100;
        MachineCenterTok: Label 'MACHCTR', MaxLength = 20;
        MachineCentersLbl: Label 'Machine Centers', MaxLength = 100;
        RoutingTok: Label 'ROUTING', MaxLength = 20;
        RoutingLbl: Label 'Routings', MaxLength = 100;
        SimulatedTok: Label 'M-SIM', MaxLength = 20;
        SimulatedOrdersLbl: Label 'Simulated orders', MaxLength = 100;
        PlannedOrderTok: Label 'M-PLAN', MaxLength = 20;
        PlannedOrdersLbl: Label 'Planned orders', MaxLength = 100;
        FirmPlannedOrderTok: Label 'M-FIRMP', MaxLength = 20;
        FirmPlannedOrdersLbl: Label 'Firm Planned orders', MaxLength = 100;
        ReleasedOrderTok: Label 'M-REL', MaxLength = 20;
        ReleasedOrdersLbl: Label 'Released orders', MaxLength = 100;

    procedure WorkCenter(): Code[20]
    begin
        exit(WorkCenterTok)
    end;

    procedure ProductionBOM(): Code[20]
    begin
        exit(ProductionBOMTok);
    end;

    procedure MachineCenter(): Code[20]
    begin
        exit(MachineCenterTok);
    end;

    procedure Routing(): Code[20]
    begin
        exit(RoutingTok);
    end;

    procedure SimulatedOrder(): Code[20]
    begin
        exit(SimulatedTok);
    end;

    procedure PlannedOrder(): Code[20]
    begin
        exit(PlannedOrderTok);
    end;

    procedure FirmPlannedOrder(): Code[20]
    begin
        exit(FirmPlannedOrderTok);
    end;

    procedure ReleasedOrderCode(): Code[20]
    begin
        exit(ReleasedOrderTok);
    end;
}