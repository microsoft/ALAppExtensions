codeunit 4790 "Create Whse ZonesBinsClasses"
{
    Permissions = tabledata "Zone" = ri,
        tabledata "Bin Type" = ri,
        tabledata "Bin Template" = ri,
        tabledata "Bin" = ri,
        tabledata "Warehouse Class" = ri;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;
        ADJUSTMENTTok: Label 'ADJUSTMENT', Locked = true;
        BULKTok: Label 'BULK', Locked = true;
        CROSSDOCKTok: Label 'CROSS-DOCK', Locked = true;
        PICKTok: Label 'PICK', Locked = true;
        PUTAWAYTok: Label 'PUTAWAY', Locked = true;
        PUTPICKTok: Label 'PUTPICK', Locked = true;
        QCTok: Label 'QC', Locked = true;
        RECEIVETok: Label 'RECEIVE', Locked = true;
        SHIPTok: Label 'SHIP', Locked = true;
        OPERTok: Label 'OPERATION', Locked = true;
        COLDTok: Label 'COLD', Locked = true;
        FROZENTok: Label 'FROZEN', Locked = true;
        ADJUSTMENTDescTok: Label 'Virtual for Adjustment', MaxLength = 100;
        BULKDescTok: Label 'Bulk Storage', MaxLength = 100;
        CROSSDOCKDescTok: Label 'Cross-Dock', MaxLength = 100;
        PICKDescTok: Label 'Pick', MaxLength = 100;
        PUTAWAYDescTok: Label 'Put Away', MaxLength = 100;
        PUTPICKDescTok: Label 'Put Away and Pick', MaxLength = 100;
        QCDescTok: Label 'Quality Control', MaxLength = 100;
        RECEIVEDescTok: Label 'Receiving', MaxLength = 100;
        SHIPDescTok: Label 'Shipping', MaxLength = 100;
        OPERDescTok: Label 'Operations', MaxLength = 100;
        NoTypeDescTok: Label 'No type', MaxLength = 100;
        COLDDescTok: Label '2 degrees Celsius', MaxLength = 100;
        FROZENDescTok: Label '-8 degrees Celsius', MaxLength = 100;

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();
        CreateCollection(false);
        OnAfterCreateZonesBinsClasses();
    end;

    local procedure CreateZone(
        LocationCode: Code[10];
        Code: Code[10];
        Description: Text[100];
        BinTypeCode: Code[10];
        WarehouseClassCode: Code[10];
        ZoneRanking: Integer;
        CrossDockBinZone: Boolean
    )
    var
        Zone: Record "Zone";
    begin
        if Zone.Get(LocationCode, Code) then
            exit;
        Zone.Init();
        Zone."Location Code" := LocationCode;
        Zone."Code" := Code;
        Zone."Description" := Description;
        Zone."Bin Type Code" := BinTypeCode;
        Zone."Warehouse Class Code" := WarehouseClassCode;
        Zone."Zone Ranking" := ZoneRanking;
        Zone."Cross-Dock Bin Zone" := CrossDockBinZone;
        Zone.Insert(DoInsertTriggers);
    end;

    local procedure CreateBinType(
        Code: Code[10];
        Description: Text[100];
        Receive: Boolean;
        Ship: Boolean;
        PutAway: Boolean;
        Pick: Boolean
    )
    var
        BinType: Record "Bin Type";
    begin
        if BinType.Get(Code) then
            exit;
        BinType.Init();
        BinType."Code" := Code;
        BinType."Description" := Description;
        BinType."Receive" := Receive;
        BinType."Ship" := Ship;
        BinType."Put Away" := PutAway;
        BinType."Pick" := Pick;
        BinType.Insert(DoInsertTriggers);
    end;

    local procedure CreateBin(
        LocationCode: Code[10];
        Code: Code[20];
        Description: Text[100];
        ZoneCode: Code[10];
        BinTypeCode: Code[10];
        WarehouseClassCode: Code[10];
        BlockMovement: Option;
        BinRanking: Integer;
        MaximumCubage: Decimal;
        MaximumWeight: Decimal;
        CrossDockBin: Boolean;
        Dedicated: Boolean
    )
    var
        Bin: Record "Bin";
        IsHandled: Boolean;
    begin
        if Bin.Get(LocationCode, Code) then
            exit;
        Bin.Init();
        Bin."Location Code" := LocationCode;
        Bin."Code" := Code;
        Bin."Description" := Description;
        Bin."Zone Code" := ZoneCode;
        Bin."Bin Type Code" := BinTypeCode;
        Bin."Warehouse Class Code" := WarehouseClassCode;
        Bin."Block Movement" := BlockMovement;
        Bin."Bin Ranking" := BinRanking;
        Bin."Maximum Cubage" := MaximumCubage;
        Bin."Maximum Weight" := MaximumWeight;
        Bin."Cross-Dock Bin" := CrossDockBin;
        Bin."Dedicated" := Dedicated;

        IsHandled := false;
        OnBeforeInsertCreateBin(Bin, IsHandled);
        if not IsHandled then
            Bin.Insert(DoInsertTriggers);
    end;

    local procedure CreateWarehouseClass(
        Code: Code[10];
        Description: Text[100]
    )
    var
        WarehouseClass: Record "Warehouse Class";
    begin
        if WarehouseClass.Get(Code) then
            exit;
        WarehouseClass.Init();
        WarehouseClass."Code" := Code;
        WarehouseClass."Description" := Description;
        WarehouseClass.Insert(DoInsertTriggers);
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateBinType(PICKTok, PICKDescTok, false, false, false, true);
        CreateBinType(PUTAWAYTok, PUTAWAYDescTok, false, false, true, false);
        CreateBinType(PUTPICKTok, PUTPICKDescTok, false, false, true, true);
        CreateBinType(QCTok, NoTypeDescTok, false, false, false, false);
        CreateBinType(RECEIVETok, RECEIVEDescTok, true, false, false, false);
        CreateBinType(SHIPTok, SHIPDescTok, false, true, false, false);

        CreateZone(WhseDemoDataSetup."Location Directed Pick", ADJUSTMENTTok, ADJUSTMENTDescTok, QCTok, '', 0, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", BULKTok, BULKDescTok, PUTAWAYTok, '', 50, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", CROSSDOCKTok, CROSSDOCKDescTok, PUTPICKTok, '', 0, true);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", PICKTok, PICKDescTok, PUTPICKTok, '', 100, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", QCTok, QCDescTok, QCTok, '', 0, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", RECEIVETok, RECEIVEDescTok, RECEIVETok, '', 10, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", SHIPTok, SHIPDescTok, SHIPTok, '', 200, false);
        CreateZone(WhseDemoDataSetup."Location Directed Pick", OPERTok, OPERDescTok, QCTok, '', 5, false);

        CreateWarehouseClass(COLDTok, COLDDescTok);
        CreateWarehouseClass(FROZENTok, FROZENDescTok);


        CreateBin(WhseDemoDataSetup."Location Bin", 'S-1-01', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-1-02', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-1-03', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-1-04', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-1-05', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-2-01', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-2-02', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-2-03', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-2-04', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-2-05', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-3-01', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-3-02', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-3-03', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-3-04', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-3-05', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-01', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-02', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-03', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-04', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-05', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-06', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-07', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-08', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-09', '', '', '', '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Bin", 'S-4-10', '', '', '', '', 0, 0, 0, 0, false, false);

        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0001', '', PICKTok, PUTPICKTok, '', 0, 100, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0002', '', PICKTok, PUTPICKTok, '', 0, 90, 250, 150, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-01-0003', '', PICKTok, PUTPICKTok, '', 0, 90, 250, 150, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0001', '', PICKTok, PUTPICKTok, '', 0, 100, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0002', '', PICKTok, PUTPICKTok, '', 0, 90, 250, 150, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-02-0003', '', PICKTok, PUTPICKTok, '', 0, 90, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0001', '', PICKTok, PUTPICKTok, '', 0, 100, 2500, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0002', '', PICKTok, PUTPICKTok, '', 0, 90, 280, 200, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-03-0003', '', PICKTok, PUTPICKTok, '', 0, 90, 280, 200, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0001', '', PICKTok, PUTPICKTok, '', 0, 100, 500000, 500000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0002', '', PICKTok, PUTPICKTok, '', 0, 90, 250, 150, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0003', '', PICKTok, PUTPICKTok, '', 0, 90, 1500000, 1500000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0004', '', PICKTok, PUTPICKTok, '', 0, 90, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-04-0005', '', PICKTok, PUTPICKTok, '', 0, 90, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0001', '', BULKTok, PUTAWAYTok, '', 0, 60, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0002', '', BULKTok, PUTAWAYTok, '', 0, 60, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0003', '', BULKTok, PUTAWAYTok, '', 0, 60, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0004', '', BULKTok, PUTAWAYTok, '', 0, 60, 15000, 15000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-05-0005', '', BULKTok, PUTAWAYTok, '', 0, 60, 1500, 1000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-07-0001', '', OPERTok, QCTok, '', 0, 0, 20000, 30000, false, true);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-07-0002', '', OPERTok, QCTok, '', 0, 0, 20000, 30000, false, true);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-07-0003', '', OPERTok, QCTok, '', 0, 0, 20000, 30000, false, true);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-07-0004', '', OPERTok, QCTok, '', 0, 0, 20000, 30000, false, true);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-07-0005', '', OPERTok, QCTok, '', 0, 0, 20000, 30000, false, true);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-08-0001', '', RECEIVETok, RECEIVETok, '', 0, 0, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-08-0002', '', RECEIVETok, RECEIVETok, '', 0, 0, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-08-0003', '', RECEIVETok, RECEIVETok, '', 0, 0, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-09-0001', '', SHIPTok, SHIPTok, '', 0, 200, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-09-0002', '', SHIPTok, SHIPTok, '', 0, 200, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-09-0003', '', SHIPTok, SHIPTok, '', 0, 200, 5000000, 5000000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-10-0001', '', QCTok, QCTok, '', 0, 0, 20000, 30000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-10-0002', '', QCTok, QCTok, '', 0, 0, 20000, 30000, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-99-0001', '', ADJUSTMENTTok, QCTok, '', 0, 0, 0, 0, false, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0001', '', CROSSDOCKTok, PUTPICKTok, '', 0, 500, 0, 0, true, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0002', '', CROSSDOCKTok, PUTPICKTok, '', 0, 500, 0, 0, true, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0003', '', CROSSDOCKTok, PUTPICKTok, '', 0, 500, 0, 0, true, false);
        CreateBin(WhseDemoDataSetup."Location Directed Pick", 'W-14-0004', '', CROSSDOCKTok, PUTPICKTok, '', 0, 500, 0, 0, true, false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateZonesBinsClasses()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCreateBin(var Bin: Record Bin; var IsHandled: Boolean)
    begin
    end;

}
