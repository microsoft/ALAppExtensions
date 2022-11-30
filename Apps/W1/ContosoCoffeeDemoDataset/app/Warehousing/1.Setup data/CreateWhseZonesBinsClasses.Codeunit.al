codeunit 4790 "Create Whse ZonesBinsClasses"
{
    Permissions = tabledata "Zone" = rim,
        tabledata "Bin Type" = rim,
        tabledata "Bin Template" = rim,
        tabledata "Bin" = rim,
        tabledata "Warehouse Class" = rim;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;
        XADJUSTMENTTok: Label 'ADJUSTMENT', Locked = true;
        XBULKTok: Label 'BULK', Locked = true;
        XCROSSDOCKTok: Label 'CROSS-DOCK', Locked = true;
        XPICKTok: Label 'PICK', Locked = true;
        XPUTAWAYTok: Label 'PUTAWAY', Locked = true;
        XPUTPICKTok: Label 'PUTPICK', Locked = true;
        XQCTok: Label 'QC', Locked = true;
        XRECEIVETok: Label 'RECEIVE', Locked = true;
        XSHIPTok: Label 'SHIP', Locked = true;
        XCOLDTok: Label 'COLD', Locked = true;
        XFROZENTok: Label 'FROZEN', Locked = true;
        XADJUSTMENTDescTok: Label 'Virtual for Adjustment', MaxLength = 100;
        XBULKDescTok: Label 'Bulk Storage', MaxLength = 100;
        XCROSSDOCKDescTok: Label 'Cross-Dock', MaxLength = 100;
        XPICKDescTok: Label 'Pick', MaxLength = 100;
        XPUTAWAYDescTok: Label 'Put Away', MaxLength = 100;
        XPUTPICKDescTok: Label 'Put Away and Pick', MaxLength = 100;
        XQCDescTok: Label 'Quality Control', MaxLength = 100;
        XRECEIVEDescTok: Label 'Receiving', MaxLength = 100;
        XSHIPDescTok: Label 'Shipping', MaxLength = 100;
        XNoTypeDescTok: Label 'No type', MaxLength = 100;
        XCOLDDescTok: Label '2 degrees Celsius', MaxLength = 100;
        XFROZENDescTok: Label '-8 degrees Celsius', MaxLength = 100;

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
        Empty: Boolean;
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
        Bin."Empty" := Empty;
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
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XADJUSTMENTTok, XADJUSTMENTDescTok, XQCTok, '', 0, false);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XBULKTok, XBULKDescTok, XPUTAWAYTok, '', 50, false);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XCROSSDOCKTok, XCROSSDOCKDescTok, XPUTPICKTok, '', 0, true);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XPICKTok, XPICKDescTok, XPUTPICKTok, '', 100, false);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XQCTok, XQCDescTok, XQCTok, '', 0, false);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XRECEIVETok, XRECEIVEDescTok, XRECEIVETok, '', 10, false);
        CreateZone(WhseDemoDataSetup."Location Advanced Logistics", XSHIPTok, XSHIPDescTok, XSHIPTok, '', 200, false);

        CreateWarehouseClass(XCOLDTok, XCOLDDescTok);
        CreateWarehouseClass(XFROZENTok, XFROZENDescTok);

        CreateBinType(XPICKTok, XPICKDescTok, false, false, false, true);
        CreateBinType(XPUTAWAYTok, XPUTAWAYDescTok, false, false, true, false);
        CreateBinType(XPUTPICKTok, XPUTPICKDescTok, false, false, true, true);
        CreateBinType(XQCTok, XNoTypeDescTok, true, false, false, false);
        CreateBinType(XRECEIVETok, XRECEIVEDescTok, true, false, false, false);
        CreateBinType(XSHIPTok, XSHIPDescTok, false, true, false, false);

        CreateBin(WhseDemoDataSetup."Location Basic", 'S-01-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-01-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-01-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-02-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-02-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-02-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-03-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-03-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-03-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0005', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0006', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0007', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0008', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0009', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0010', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0011', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0012', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0013', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0014', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-04-0015', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-07-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-07-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-07-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-07-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-08-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-08-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-08-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-08-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0005', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Basic", 'S-09-0006', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-01-0001', '', XPICKTok, XPUTPICKTok, '', 0, 100, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-01-0002', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-01-0003', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-02-0001', '', XPICKTok, XPUTPICKTok, '', 0, 100, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-02-0002', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-02-0003', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-03-0001', '', XPICKTok, XPUTPICKTok, '', 0, 100, 2500, 15000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-03-0002', '', XPICKTok, XPUTPICKTok, '', 0, 90, 280, 200, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-03-0003', '', XPICKTok, XPUTPICKTok, '', 0, 90, 280, 200, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0001', '', XPICKTok, XPUTPICKTok, '', 0, 100, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0002', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0003', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0004', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0005', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0006', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0007', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0008', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0009', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0010', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0011', '', XPICKTok, XPUTPICKTok, '', 0, 90, 250, 150, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0012', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0013', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0014', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-04-0015', '', XPICKTok, XPUTPICKTok, '', 0, 90, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0001', '', XBULKTok, XPUTAWAYTok, '', 0, 60, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0002', '', XBULKTok, XPUTAWAYTok, '', 0, 60, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0003', '', XBULKTok, XPUTAWAYTok, '', 0, 60, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0004', '', XBULKTok, XPUTAWAYTok, '', 0, 60, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0005', '', XBULKTok, XPUTAWAYTok, '', 0, 60, 1500, 1000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0006', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 1500, 1000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0007', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0008', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0009', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0010', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0011', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0012', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0013', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0014', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 15000, 15000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0015', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 3000, 2000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0016', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 3000, 2000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-05-0017', '', XBULKTok, XPUTAWAYTok, '', 0, 50, 3000, 2000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0001', '', 'STAGE', XPICKTok, '', 0, 0, 10000, 30000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0002', '', 'STAGE', XPICKTok, '', 0, 0, 10000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0003', '', 'STAGE', XPICKTok, '', 0, 0, 3000, 3000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0004', '', 'STAGE', XPICKTok, '', 0, 0, 3000, 3000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0005', '', 'STAGE', XPICKTok, '', 0, 0, 300, 300, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-06-0006', '', 'STAGE', XPICKTok, '', 0, 0, 300, 300, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-07-0001', '', 'PRODUCTION', XQCTok, '', 0, 0, 20000, 30000, true, false, true);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-07-0002', '', 'PRODUCTION', XQCTok, '', 0, 0, 20000, 30000, true, false, true);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-07-0003', '', 'PRODUCTION', XQCTok, '', 0, 0, 20000, 30000, true, false, true);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-07-0004', '', 'PRODUCTION', XQCTok, '', 0, 0, 20000, 30000, true, false, true);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-08-0001', '', XRECEIVETok, XRECEIVETok, '', 0, 0, 100000, 100000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-08-0002', '', XRECEIVETok, XRECEIVETok, '', 0, 0, 100000, 100000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-08-0003', '', XRECEIVETok, XRECEIVETok, '', 0, 0, 100000, 100000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-08-0004', '', XRECEIVETok, XRECEIVETok, '', 0, 0, 100000, 100000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0001', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0002', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0003', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0004', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0005', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-09-0006', '', XSHIPTok, XSHIPTok, '', 0, 200, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-10-0001', '', XQCTok, XQCTok, '', 0, 0, 20000, 30000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-10-0002', '', XQCTok, XQCTok, '', 0, 0, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-11-0001', '', XADJUSTMENTTok, XQCTok, '', 0, 0, 20000, 30000, false, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-11-0002', '', XADJUSTMENTTok, XQCTok, '', 0, 0, 20000, 30000, true, false, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-14-0001', '', XCROSSDOCKTok, XPUTPICKTok, '', 0, 500, 0, 0, true, true, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-14-0002', '', XCROSSDOCKTok, XPUTPICKTok, '', 0, 500, 0, 0, true, true, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-14-0003', '', XCROSSDOCKTok, XPUTPICKTok, '', 0, 500, 0, 0, true, true, false);
        CreateBin(WhseDemoDataSetup."Location Advanced Logistics", 'W-14-0004', '', XCROSSDOCKTok, XPUTPICKTok, '', 0, 500, 0, 0, true, true, false);
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
