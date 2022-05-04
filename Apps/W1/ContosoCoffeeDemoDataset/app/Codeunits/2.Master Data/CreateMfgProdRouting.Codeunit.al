codeunit 4772 "Create Mfg Prod. Routing"
{
    Permissions = tabledata "Item" = rm,
        tabledata "Routing Header" = rim,
        tabledata "Routing Line" = ri,
        tabledata "Routing Version" = rim;

    trigger OnRun()
    begin
        Scenario1();
        Scenario3Flushing();
        Scenario5Subcontracting();

        OnAfterAllDataInsert();
    end;

    var
        RoutingLine: Record "Routing Line";
        AdjustManufacturingData: Codeunit "Adjust Manufacturing Data";
        CapacityType: Enum "Capacity Type Routing";
        XReservoirAssyTok: Label 'Reservoir Assy.', MaxLength = 30;
        XAirpotSerialTok: Label 'Airpot - Serial', MaxLength = 30;
        XAutoDripTok: Label 'AutoDrip', MaxLength = 30;
        XAirpotParallelTok: Label 'Airpot - Parallel', MaxLength = 30;
        XAirpotSubcontr1Tok: Label 'Airpot - Subcontracting 1', MaxLength = 30;
        XAirpotSubcontr2Tok: Label 'Airpot - Subcontracting 2', MaxLength = 30;
        XReservAssemblyTok: Label 'Reservoir assembly', MaxLength = 30;
        XElectricalWiringTok: Label 'Electrical wiring', MaxLength = 30;
        XTestingTok: Label 'Testing', MaxLength = 30;
        XUnitAssemblyTok: Label 'Unit assembly', MaxLength = 30;
        XBodyAssemblyTok: Label 'Body assembly', MaxLength = 30;
        XPackingTok: Label 'Packing', MaxLength = 30;

    local procedure Scenario1()
    var
        ProductionRoutningNo: Code[20];
    begin
        ProductionRoutningNo := 'SP-BOM2000';
        InsertDataHeader(ProductionRoutningNo, '', XReservoirAssyTok, 0, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '10', '20', CapacityType::"Work Center", '100', XReservAssemblyTok, 15, 5, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '20', '30', CapacityType::"Work Center", '100', XElectricalWiringTok, 15, 8, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '30', '', CapacityType::"Work Center", '100', XTestingTok, 10, 9, 0, 0, 0, 0, 0, 1, 0, '', 0);

        CertifyRouting(ProductionRoutningNo, '');
        UpdateItems('SP-BOM2000', ProductionRoutningNo);


        ProductionRoutningNo := 'SP-SCM1009-SERIAL';
        InsertDataHeader(ProductionRoutningNo, '', XAirpotSerialTok, 0, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '10', '20', CapacityType::"Work Center", '100', XBodyAssemblyTok, 20, 15, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '20', '30', CapacityType::"Machine Center", '110', XElectricalWiringTok, 20, 18, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '30', '40', CapacityType::"Work Center", '100', XTestingTok, 10, 9, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '40', '', CapacityType::"Machine Center", '210', XPackingTok, 10, 8, 0, 0, 0, 0, 0, 1, 0, '', 0);

        CertifyRouting(ProductionRoutningNo, '');
        UpdateItems('SP-SCM1009', ProductionRoutningNo);

        ProductionRoutningNo := 'SP-SCM1009-PARALLEL';
        InsertDataHeader(ProductionRoutningNo, '', XAirpotParallelTok, 1, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '5', '10|20', CapacityType::"Work Center", '100', '', 0, 0, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '10', '30', CapacityType::"Work Center", '100', XBodyAssemblyTok, 20, 15, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '20', '30', CapacityType::"Machine Center", '110', XElectricalWiringTok, 20, 18, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '30', '40', CapacityType::"Work Center", '100', XTestingTok, 10, 9, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '40', '', CapacityType::"Machine Center", '210', XPackingTok, 10, 8, 0, 0, 0, 0, 0, 1, 0, '', 0);

        CertifyRouting(ProductionRoutningNo, '');
    end;

    local procedure Scenario3Flushing()
    var
        ProductionRoutningNo: Code[20];
    begin
        ProductionRoutningNo := 'SP-SCM1004';
        InsertDataHeader(ProductionRoutningNo, '', XAutoDripTok, 0, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '10', '20', CapacityType::"Work Center", '100', XBodyAssemblyTok, 20, 15, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '20', '30', CapacityType::"Machine Center", '110', XElectricalWiringTok, 20, 18, 0, 0, 0, 0, 0, 1, 0, '100', 0);
        InsertDataLine(ProductionRoutningNo, '', '30', '', CapacityType::"Machine Center", '210', XPackingTok, 10, 8, 0, 0, 0, 0, 0, 1, 0, '', 0);

        CertifyRouting(ProductionRoutningNo, '');
        UpdateItems('SP-SCM1004', ProductionRoutningNo);
    end;

    local procedure Scenario5Subcontracting()
    var
        ProductionRoutningNo: Code[20];
    begin
        ProductionRoutningNo := 'SP-SCM1009-SUB-1';
        InsertDataHeader(ProductionRoutningNo, '', XAirpotSubcontr1Tok, 0, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '10', '20', CapacityType::"Work Center", '500', XBodyAssemblyTok, 0, 25, 0, 0, 0, 0, 0, 100, 0, '', 28.12);  //Currency  
        InsertDataLine(ProductionRoutningNo, '', '20', '30', CapacityType::"Machine Center", '110', XElectricalWiringTok, 60, 18, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '30', '40', CapacityType::"Work Center", '100', XTestingTok, 10, 9, 0, 0, 0, 0, 0, 1, 0, '', 0);
        InsertDataLine(ProductionRoutningNo, '', '40', '', CapacityType::"Machine Center", '210', XPackingTok, 10, 8, 0, 0, 0, 0, 0, 1, 0, '', 0);

        CertifyRouting(ProductionRoutningNo, '');

        ProductionRoutningNo := 'SP-SCM1009-SUB-2';
        InsertDataHeader(ProductionRoutningNo, '', XAirpotSubcontr2Tok, 0, 19020101D);

        InsertDataLine(ProductionRoutningNo, '', '10', '', CapacityType::"Work Center", '500', XUnitAssemblyTok, 0, 25, 0, 0, 0, 0, 0, 100, 0, '', 45.32);  //Currency

        CertifyRouting(ProductionRoutningNo, '');
    end;

    local procedure InsertDataHeader(RoutingNo: Code[20]; RtngVersionCode: Code[10]; Description: Text[30]; Type: Option Serial,Parallel; StartingDate: Date)
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
    begin
        if not RoutingHeader.Get(RoutingNo) then begin
            RoutingHeader.Validate("No.", RoutingNo);
            RoutingHeader.Insert();
            RoutingHeader.Validate(Description, Description);
            RoutingHeader.Validate(Type, Type);
            RoutingHeader.Modify();
        end;
        if RtngVersionCode <> '' then begin
            RoutingVersion.Validate("Routing No.", RoutingNo);
            RoutingVersion.Validate("Version Code", RtngVersionCode);
            RoutingVersion.Insert();
            RoutingVersion.Validate(Description, Description);
            RoutingVersion.Validate("Starting Date", AdjustManufacturingData.AdjustDate(StartingDate));
            RoutingVersion.Modify();
        end;
    end;

    local procedure InsertDataLine(RoutingNo: Code[20]; VersionCode: Code[10]; OperationNo: Code[10]; NextOperationNo: Code[10]; Type: Enum "Capacity Type Routing";
        No: Code[20]; Description: Text[30]; SetupTime: Decimal; RunTime: Decimal; WaitTime: Decimal; MoveTime: Decimal; FixedScrapQty: Decimal; LotSize: Decimal;
        ScrapFactorPct: Decimal; ConcurrCapacity: Decimal; SendAheadQty: Decimal; RtngLinkCode: Code[10]; UnitCostPer: Decimal)
    begin
        RoutingLine.Validate("Routing No.", RoutingNo);
        RoutingLine.Validate("Version Code", VersionCode);
        RoutingLine.Validate("Operation No.", OperationNo);
        RoutingLine.Validate("Next Operation No.", NextOperationNo);
        RoutingLine.Validate(Type, Type);
        RoutingLine.Validate("No.", No);
        RoutingLine.Validate(Description, Description);
        RoutingLine.Validate("Setup Time", SetupTime);
        RoutingLine.Validate("Run Time", RunTime);
        RoutingLine.Validate("Wait Time", WaitTime);
        RoutingLine.Validate("Move Time", MoveTime);
        RoutingLine.Validate("Fixed Scrap Quantity", FixedScrapQty);
        RoutingLine.Validate("Lot Size", LotSize);
        RoutingLine.Validate("Scrap Factor %", ScrapFactorPct);
        RoutingLine.Validate("Concurrent Capacities", ConcurrCapacity);
        RoutingLine.Validate("Send-Ahead Quantity", SendAheadQty);
        RoutingLine.Validate("Routing Link Code", RtngLinkCode);
        RoutingLine.Validate("Unit Cost per", UnitCostPer);
        RoutingLine.Insert();

        OnAfterRoutingLineInsert(RoutingLine);
    end;

    local procedure UpdateItems(ItemNo: Code[20]; RoutingNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("Routing No.", RoutingNo);
        Item.Modify();
    end;

    local procedure CertifyRouting(RoutingNo: Code[20]; VersionCode: Code[10])
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
    begin
        if VersionCode <> '' then begin
            RoutingVersion.Get(RoutingNo, VersionCode);
            RoutingVersion.Validate(Status, RoutingVersion.Status::Certified);
            RoutingVersion.Modify();
        end else begin
            RoutingHeader.Get(RoutingNo);
            RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
            RoutingHeader.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAllDataInsert()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRoutingLineInsert(var RoutingLine: Record "Routing Line")
    begin
    end;
}