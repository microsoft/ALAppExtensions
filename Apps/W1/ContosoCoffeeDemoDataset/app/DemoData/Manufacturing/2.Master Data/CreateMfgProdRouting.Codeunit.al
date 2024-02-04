codeunit 4772 "Create Mfg Prod. Routing"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Item" = rm,
        tabledata "Routing Header" = rm;

    trigger OnRun()
    begin
        CreateRoutingLinks();

        Scenario1();
        Scenario3Flushing();
        Scenario5Subcontracting();
    end;

    var
        ContosoManufacturing: Codeunit "Contoso Manufacturing";
        MfgItem: Codeunit "Create Mfg Item";
        MfgCapacity: Codeunit "Create Mfg Capacity";
        ReservoirAssyTok: Label 'Reservoir Assembly', MaxLength = 30;
        AirpotSerialTok: Label 'Airpot - Serial', MaxLength = 30;
        AutoDripTok: Label 'AutoDrip', MaxLength = 30;
        AirpotParallelTok: Label 'Airpot - Parallel', MaxLength = 30;
        AirpotSubcontr1Tok: Label 'Airpot - Subcontracting 1', MaxLength = 30;
        AirpotSubcontr2Tok: Label 'Airpot - Subcontracting 2', MaxLength = 30;
        ReservAssemblyTok: Label 'Reservoir assembly', MaxLength = 30;
        ElectricalWiringTok: Label 'Electrical wiring', MaxLength = 30;
        TestingTok: Label 'Testing', MaxLength = 30;
        UnitAssemblyTok: Label 'Unit assembly', MaxLength = 30;
        BodyAssemblyTok: Label 'Body assembly', MaxLength = 30;
        PackingTok: Label 'Packing', MaxLength = 30;
        AssemblingTok: Label 'Assembling', MaxLength = 50;
        InspectionTok: Label 'Inspection', MaxLength = 50;

    local procedure Scenario1()
    begin
        ContosoManufacturing.InsertRoutingHeader(SPBOM2000(), ReservoirAssyTok, 0);
        ContosoManufacturing.InsertRoutingLine(SPBOM2000(), '', OperationNo10(), OperationNo20(), "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), ReservAssemblyTok, 15, 5, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPBOM2000(), '', OperationNo20(), '30', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), ElectricalWiringTok, 15, 8, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPBOM2000(), '', '30', '', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), TestingTok, 10, 9, 1, 0, '', 0);
        CertifyRouting(SPBOM2000());
        UpdateItems(MfgItem.SPBOM2000(), SPBOM2000());

        ContosoManufacturing.InsertRoutingHeader(SPSCM1009SERIAL(), AirpotSerialTok, 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SERIAL(), '', OperationNo10(), OperationNo20(), "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), BodyAssemblyTok, 20, 15, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SERIAL(), '', OperationNo20(), '30', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter110(), ElectricalWiringTok, 20, 18, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SERIAL(), '', '30', '40', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), TestingTok, 10, 9, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SERIAL(), '', '40', '', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter210(), PackingTok, 10, 8, 1, 0, '', 0);
        CertifyRouting(SPSCM1009SERIAL());
        UpdateItems(MfgItem.SPSCM1009(), SPSCM1009SERIAL());

        ContosoManufacturing.InsertRoutingHeader(SPSCM1009PARALLEL(), AirpotParallelTok, 1);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009PARALLEL(), '', '05', (OperationNo10() + '|' + OperationNo20()), "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), '', 0, 0, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009PARALLEL(), '', OperationNo10(), '30', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), BodyAssemblyTok, 20, 15, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009PARALLEL(), '', OperationNo20(), '30', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter110(), ElectricalWiringTok, 20, 18, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009PARALLEL(), '', '30', '40', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), TestingTok, 10, 9, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009PARALLEL(), '', '40', '', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter210(), PackingTok, 10, 8, 1, 0, '', 0);
        CertifyRouting(SPSCM1009PARALLEL());
    end;

    local procedure Scenario3Flushing()
    begin
        ContosoManufacturing.InsertRoutingHeader(SPSCM1004(), AutoDripTok, 0);

        ContosoManufacturing.InsertRoutingLine(SPSCM1004(), '', OperationNo10(), OperationNo20(), "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter130(), BodyAssemblyTok, 20, 15, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1004(), '', OperationNo20(), '30', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter110(), ElectricalWiringTok, 20, 18, 1, 0, RoutingLink100(), 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1004(), '', '30', '', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter230(), PackingTok, 10, 8, 1, 0, '', 0);

        CertifyRouting(SPSCM1004());
        UpdateItems(MfgItem.SPSCM1004(), SPSCM1004());
    end;

    local procedure Scenario5Subcontracting()
    begin
        ContosoManufacturing.InsertRoutingHeader(SPSCM1009SUB1(), AirpotSubcontr1Tok, 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SUB1(), '', OperationNo10(), OperationNo20(), "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter500(), BodyAssemblyTok, 0, 25, 100, 0, '', 28.12);  //Currency  
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SUB1(), '', OperationNo20(), '30', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter110(), ElectricalWiringTok, 60, 18, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SUB1(), '', '30', '40', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter100(), TestingTok, 10, 9, 1, 0, '', 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SUB1(), '', '40', '', "Capacity Type Routing"::"Machine Center", MfgCapacity.MachineCenter210(), PackingTok, 10, 8, 1, 0, '', 0);
        CertifyRouting(SPSCM1009SUB1());

        ContosoManufacturing.InsertRoutingHeader(SPSCM1009SUB2(), AirpotSubcontr2Tok, 0);
        ContosoManufacturing.InsertRoutingLine(SPSCM1009SUB2(), '', OperationNo10(), '', "Capacity Type Routing"::"Work Center", MfgCapacity.WorkCenter500(), UnitAssemblyTok, 0, 25, 100, 0, '', 45.32);  //Currency
        CertifyRouting(SPSCM1009SUB2());
    end;

    local procedure CreateRoutingLinks()
    begin
        ContosoManufacturing.InsertRoutingLink(RoutingLink100(), AssemblingTok);
        ContosoManufacturing.InsertRoutingLink(RoutingLink300(), InspectionTok);
    end;

    local procedure UpdateItems(ItemNo: Code[20]; RoutingNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("Routing No.", RoutingNo);
        Item.Modify(true);
    end;

    local procedure CertifyRouting(RoutingNo: Code[20])
    var
        RoutingHeader: Record "Routing Header";
    begin
        RoutingHeader.Get(RoutingNo);
        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);
    end;

    procedure OperationNo10(): Code[10]
    begin
        exit('10');
    end;

    procedure OperationNo20(): Code[10]
    begin
        exit('20');
    end;

    procedure OperationNo30(): Code[10]
    begin
        exit('30');
    end;

    procedure RoutingLink100(): Code[10]
    begin
        exit('100');
    end;

    procedure RoutingLink300(): Code[10]
    begin
        exit('300');
    end;

    procedure SPBOM2000(): Code[20]
    begin
        exit('SP-BOM2000');
    end;

    procedure SPSCM1009SERIAL(): Code[20]
    begin
        exit('SP-SCM1009-SERIAL');
    end;

    procedure SPSCM1009PARALLEL(): Code[20]
    begin
        exit('SP-SCM1009-PARALLEL');
    end;

    procedure SPSCM1004(): Code[20]
    begin
        exit('SP-SCM1004');
    end;

    procedure SPSCM1009SUB1(): Code[20]
    begin
        exit('SP-SCM1009-SUB-1');
    end;

    procedure SPSCM1009SUB2(): Code[20]
    begin
        exit('SP-SCM1009-SUB-2');
    end;
}