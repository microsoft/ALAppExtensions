codeunit 4790 "Create Whse ZonesBinsClasses"
{
    Permissions = tabledata "Zone" = rim,
        tabledata "Bin Type" = rim,
        tabledata "Bin Template" = rim,
        tabledata "Bin" = rim,
        tabledata "Warehouse Class" = rim;

    var
        DoInsertTriggers: Boolean;

    trigger OnRun()
    begin
        CreateCollection(false);
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

    local procedure CreateBinTemplate(
        Code: Code[20];
        Description: Text[100];
        LocationCode: Code[10];
        BinDescription: Text[50];
        ZoneCode: Code[10];
        BinTypeCode: Code[10];
        WarehouseClassCode: Code[10];
        BlockMovement: Option;
        BinRanking: Integer;
        MaximumCubage: Decimal;
        MaximumWeight: Decimal;
        Dedicated: Boolean
    )
    var
        BinTemplate: Record "Bin Template";
    begin
        if BinTemplate.Get(Code) then
            exit;
        BinTemplate.Init();
        BinTemplate."Code" := Code;
        BinTemplate."Description" := Description;
        BinTemplate."Location Code" := LocationCode;
        BinTemplate."Bin Description" := BinDescription;
        BinTemplate."Zone Code" := ZoneCode;
        BinTemplate."Bin Type Code" := BinTypeCode;
        BinTemplate."Warehouse Class Code" := WarehouseClassCode;
        BinTemplate."Block Movement" := BlockMovement;
        BinTemplate."Bin Ranking" := BinRanking;
        BinTemplate."Maximum Cubage" := MaximumCubage;
        BinTemplate."Maximum Weight" := MaximumWeight;
        BinTemplate."Dedicated" := Dedicated;
        BinTemplate.Insert(DoInsertTriggers);
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
        CreateZone('WHITE', 'ADJUSTMENT', 'Virtual for Adjustment', 'QC', '', 0, false);
        CreateZone('WHITE', 'BULK', 'Storage Zone', 'PUT AWAY', '', 50, false);
        CreateZone('WHITE', 'CROSS-DOCK', 'Cross-Dock', 'PUTPICK', '', 0, true);
        CreateZone('WHITE', 'PICK', 'Picking Zone', 'PUTPICK', '', 100, false);
        CreateZone('WHITE', 'PRODUCTION', 'Production', 'QC', '', 5, false);
        CreateZone('WHITE', 'QC', 'Quality Assurance Zone', 'QC', '', 0, false);
        CreateZone('WHITE', 'RECEIVE', 'Receiving Zone', 'RECEIVE', '', 10, false);
        CreateZone('WHITE', 'SHIP', 'Shipping Zone', 'SHIP', '', 200, false);
        CreateZone('WHITE', 'STAGE', 'Staging Zone', 'PICK', '', 5, false);

        CreateWarehouseClass('COLD', '2 degrees Celsius');
        CreateWarehouseClass('DRY', 'Not to exceed 60 % humidity');
        CreateWarehouseClass('FROZEN', '- 8 degrees Celsius');
        CreateWarehouseClass('HEATED', 'Heated to 15 degrees Celsius');
        CreateWarehouseClass('NONSTATIC', 'Anti static area');

        CreateBinType('PICK', 'Pick', false, false, false, true);
        CreateBinType('PUT AWAY', 'Put Away type', false, false, true, false);
        CreateBinType('PUTPICK', 'Put Away and Pick', false, false, true, true);
        CreateBinType('QC', 'No type', true, false, false, false);
        CreateBinType('RECEIVE', 'Receive type', true, false, false, false);
        CreateBinType('SHIP', 'Ship type', false, true, false, false);

        CreateBin('SILVER', 'S-01-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-01-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-01-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-02-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-02-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-02-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-03-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-03-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-03-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0005', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0006', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0007', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0008', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0009', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0010', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0011', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0012', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0013', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0014', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-04-0015', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-07-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-07-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-07-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-07-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-08-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-08-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-08-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-08-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0001', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0002', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0003', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0004', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0005', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('SILVER', 'S-09-0006', '', '', '', '', 0, 0, 0, 0, true, false, false);
        CreateBin('WHITE', 'W-01-0001', '', 'PICK', 'PUTPICK', '', 0, 100, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-01-0002', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-01-0003', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-02-0001', '', 'PICK', 'PUTPICK', '', 0, 100, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-02-0002', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-02-0003', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-03-0001', '', 'PICK', 'PUTPICK', '', 0, 100, 2500, 15000, true, false, false);
        CreateBin('WHITE', 'W-03-0002', '', 'PICK', 'PUTPICK', '', 0, 90, 280, 200, true, false, false);
        CreateBin('WHITE', 'W-03-0003', '', 'PICK', 'PUTPICK', '', 0, 90, 280, 200, true, false, false);
        CreateBin('WHITE', 'W-04-0001', '', 'PICK', 'PUTPICK', '', 0, 100, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0002', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0003', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, true, false, false);
        CreateBin('WHITE', 'W-04-0004', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, true, false, false);
        CreateBin('WHITE', 'W-04-0005', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, true, false, false);
        CreateBin('WHITE', 'W-04-0006', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0007', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0008', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0009', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0010', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0011', '', 'PICK', 'PUTPICK', '', 0, 90, 250, 150, true, false, false);
        CreateBin('WHITE', 'W-04-0012', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-04-0013', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-04-0014', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-04-0015', '', 'PICK', 'PUTPICK', '', 0, 90, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0001', '', 'BULK', 'PUT AWAY', '', 0, 60, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0002', '', 'BULK', 'PUT AWAY', '', 0, 60, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0003', '', 'BULK', 'PUT AWAY', '', 0, 60, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0004', '', 'BULK', 'PUT AWAY', '', 0, 60, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0005', '', 'BULK', 'PUT AWAY', '', 0, 60, 1500, 1000, true, false, false);
        CreateBin('WHITE', 'W-05-0006', '', 'BULK', 'PUT AWAY', '', 0, 50, 1500, 1000, true, false, false);
        CreateBin('WHITE', 'W-05-0007', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0008', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0009', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0010', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0011', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0012', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0013', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0014', '', 'BULK', 'PUT AWAY', '', 0, 50, 15000, 15000, false, false, false);
        CreateBin('WHITE', 'W-05-0015', '', 'BULK', 'PUT AWAY', '', 0, 50, 3000, 2000, true, false, false);
        CreateBin('WHITE', 'W-05-0016', '', 'BULK', 'PUT AWAY', '', 0, 50, 3000, 2000, true, false, false);
        CreateBin('WHITE', 'W-05-0017', '', 'BULK', 'PUT AWAY', '', 0, 50, 3000, 2000, true, false, false);
        CreateBin('WHITE', 'W-06-0001', '', 'STAGE', 'PICK', '', 0, 0, 10000, 30000, false, false, false);
        CreateBin('WHITE', 'W-06-0002', '', 'STAGE', 'PICK', '', 0, 0, 10000, 30000, true, false, false);
        CreateBin('WHITE', 'W-06-0003', '', 'STAGE', 'PICK', '', 0, 0, 3000, 3000, true, false, false);
        CreateBin('WHITE', 'W-06-0004', '', 'STAGE', 'PICK', '', 0, 0, 3000, 3000, true, false, false);
        CreateBin('WHITE', 'W-06-0005', '', 'STAGE', 'PICK', '', 0, 0, 300, 300, true, false, false);
        CreateBin('WHITE', 'W-06-0006', '', 'STAGE', 'PICK', '', 0, 0, 300, 300, true, false, false);
        CreateBin('WHITE', 'W-07-0001', '', 'PRODUCTION', 'QC', '', 0, 0, 20000, 30000, true, false, true);
        CreateBin('WHITE', 'W-07-0002', '', 'PRODUCTION', 'QC', '', 0, 0, 20000, 30000, true, false, true);
        CreateBin('WHITE', 'W-07-0003', '', 'PRODUCTION', 'QC', '', 0, 0, 20000, 30000, true, false, true);
        CreateBin('WHITE', 'W-07-0004', '', 'PRODUCTION', 'QC', '', 0, 0, 20000, 30000, true, false, true);
        CreateBin('WHITE', 'W-08-0001', '', 'RECEIVE', 'RECEIVE', '', 0, 0, 100000, 100000, true, false, false);
        CreateBin('WHITE', 'W-08-0002', '', 'RECEIVE', 'RECEIVE', '', 0, 0, 100000, 100000, true, false, false);
        CreateBin('WHITE', 'W-08-0003', '', 'RECEIVE', 'RECEIVE', '', 0, 0, 100000, 100000, true, false, false);
        CreateBin('WHITE', 'W-08-0004', '', 'RECEIVE', 'RECEIVE', '', 0, 0, 100000, 100000, true, false, false);
        CreateBin('WHITE', 'W-09-0001', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, false, false, false);
        CreateBin('WHITE', 'W-09-0002', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, false, false, false);
        CreateBin('WHITE', 'W-09-0003', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-09-0004', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-09-0005', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-09-0006', '', 'SHIP', 'SHIP', '', 0, 200, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-10-0001', '', 'QC', 'QC', '', 0, 0, 20000, 30000, false, false, false);
        CreateBin('WHITE', 'W-10-0002', '', 'QC', 'QC', '', 0, 0, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-11-0001', '', 'ADJUSTMENT', 'QC', '', 0, 0, 20000, 30000, false, false, false);
        CreateBin('WHITE', 'W-11-0002', '', 'ADJUSTMENT', 'QC', '', 0, 0, 20000, 30000, true, false, false);
        CreateBin('WHITE', 'W-14-0001', '', 'CROSS-DOCK', 'PUTPICK', '', 0, 500, 0, 0, true, true, false);
        CreateBin('WHITE', 'W-14-0002', '', 'CROSS-DOCK', 'PUTPICK', '', 0, 500, 0, 0, true, true, false);
        CreateBin('WHITE', 'W-14-0003', '', 'CROSS-DOCK', 'PUTPICK', '', 0, 500, 0, 0, true, true, false);
        CreateBin('WHITE', 'W-14-0004', '', 'CROSS-DOCK', 'PUTPICK', '', 0, 500, 0, 0, true, true, false);
    end;

}
