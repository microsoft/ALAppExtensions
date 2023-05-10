codeunit 4771 "Create Mfg Prod. BOMs"
{
    Permissions = tabledata "Item" = rm,
    tabledata "Production BOM Header" = rim,
    tabledata "Production BOM Line" = ri,
    tabledata "Production BOM Version" = rm;

    trigger OnRun()
    begin
        Scenario1();
        Scenario2();
        Scenario3();
        Scenario4();

        LowLevelCodeCalculator.Calculate(false);
    end;

    var
        ProductionBOMLine: Record "Production BOM Line";
        LowLevelCodeCalculator: Codeunit "Low-Level Code Calculator";
        AdjustManufacturingData: Codeunit "Adjust Manufacturing Data";
        PreviousBOMNo: Code[20];
        XPCSTok: Label 'PCS', MaxLength = 10;
        XAirpotDuoTok: Label 'Airpot Duo', MaxLength = 30;
        XAirpotTok: Label 'Airpot', MaxLength = 30;
        XAutoDripTok: Label 'AutoDrip', MaxLength = 30;
        XAutoDripLiteBaseTok: Label 'AutoDripLite - Base', MaxLength = 30;
        XAutoDripLiteBlackTok: Label 'AutoDripLite - Black', MaxLength = 30;
        XAutoDripLiteRedTok: Label 'AutoDripLite - Red', MaxLength = 30;
        XAutoDripLiteWhiteTok: Label 'AutoDripLite - White', MaxLength = 30;
        XReservoirAssyTok: Label 'Reservoir Assy.', MaxLength = 30;

    local procedure Scenario1()
    var
        ProductionBomNo: Code[20];
    begin
        // Manufacturing scenario #1: BOM/Routing/Standard Cost/Prod Order
        ProductionBomNo := 'SP-BOM2000';

        InsertDataHeader(ProductionBomNo, '', XReservoirAssyTok, XPCSTok, 19020101D);

        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2001', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2002', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2003', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 2, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2004', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::"Fixed Quantity", 1, '', '', '', 0, 0D, 0D); // Fixed Qty

        CertifyProdBOM(ProductionBomNo, '');
        UpdateItems('SP-BOM2000', ProductionBomNo);


        ProductionBomNo := 'SP-SCM1009';
        InsertDataHeader(ProductionBomNo, '', XAirpotTok, XPCSTok, 19020101D);

        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1101', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2000', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1102', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1103', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1104', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1105', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1106', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1107', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1108', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1109', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');
        UpdateItems('SP-SCM1009', ProductionBomNo);
    end;

    local procedure Scenario2()
    var
        ProductionBomNo: Code[20];
    begin
        // Manufacturing scenario #2: Item Tracking: consumption/output
        ProductionBomNo := 'SP-SCM1011';
        InsertDataHeader(ProductionBomNo, '', XAirpotDuoTok, XPCSTok, 19020101D);

        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1201', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2000', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1102', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1103', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1104', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1107', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1108', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1207', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1208', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1109', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');
        UpdateItems('SP-SCM1011', ProductionBomNo);
    end;

    local procedure Scenario3()
    var
        ProductionBomNo: Code[20];
    begin
        // Manufacturing scenario #3: Flushing
        ProductionBomNo := 'SP-SCM1004';
        InsertDataHeader(ProductionBomNo, '', XAutoDripTok, XPCSTok, 19020101D);

        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1301', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2000', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1305', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 12, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1102', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1103', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1302', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '100', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1303', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '100', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1107', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1108', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1304', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');
        UpdateItems('SP-SCM1004', ProductionBomNo);
    end;

    local procedure Scenario4()
    var
        ProductionBomNo: Code[20];
    begin
        // Manufacturing scenario #4: Variants, Phantom BOM
        ProductionBomNo := 'SP-SCM1006-BASE';
        InsertDataHeader(ProductionBomNo, '', XAutoDripLiteBaseTok, XPCSTok, 19020101D);

        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1301', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM2000', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1102', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1103', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1105', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1107', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1108', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-BOM1109', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');

        ProductionBomNo := 'SP-SCM1006-RED';
        InsertDataHeader(ProductionBomNo, '', XAutoDripLiteRedTok, XPCSTok, 19020101D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-SCM3002', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 2, 'SP-SCM1006-BASE', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');

        ProductionBomNo := 'SP-SCM1006-WHITE';
        InsertDataHeader(ProductionBomNo, '', XAutoDripLiteWhiteTok, XPCSTok, 19020101D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-SCM3003', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 2, 'SP-SCM1006-BASE', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');

        ProductionBomNo := 'SP-SCM1006-BLACK';
        InsertDataHeader(ProductionBomNo, '', XAutoDripLiteBlackTok, XPCSTok, 19020101D);
        InsertDataLine(ProductionBomNo, '', 1, 'SP-SCM3001', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);
        InsertDataLine(ProductionBomNo, '', 2, 'SP-SCM1006-Base', 0, 0, 0, 0, Enum::"Quantity Calculation Formula"::" ", 1, '', '', '', 0, 0D, 0D);

        CertifyProdBOM(ProductionBomNo, '');
        UpdateItems('SP-SCM1006', ProductionBomNo);
    end;

    local procedure InsertDataHeader(ProdBOMNo: Code[20]; ProdVersion: Code[10]; Description: Text[30]; UnitOfMeasureCode: Text[10]; StartingDate: Date)
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        if not ProductionBOMHeader.Get(ProdBOMNo) then begin
            ProductionBOMHeader.Validate("No.", ProdBOMNo);
            ProductionBOMHeader.Validate(Description, Description);
            ProductionBOMHeader."Unit of Measure Code" := UnitOfMeasureCode;
            ProductionBOMHeader.Insert();
        end;
        if ProdVersion <> '' then begin
            ProductionBOMVersion.Validate("Production BOM No.", ProdBOMNo);
            ProductionBOMVersion.Validate("Version Code", ProdVersion);
            ProductionBOMVersion.Insert();
            ProductionBOMVersion.Validate("Unit of Measure Code", UnitOfMeasureCode);
            ProductionBOMVersion.Validate(Description, Description);
            ProductionBOMVersion.Validate("Starting Date", AdjustManufacturingData.AdjustDate(StartingDate));
            ProductionBOMVersion.Modify();
        end;
    end;

    local procedure InsertDataLine(ProdBOMNo: Code[20]; VersionCode: Code[10]; Type: Option " ",Item,"Production BOM"; No: Code[20]; Length: Decimal; Width: Decimal;
                                    Weight: Decimal; Depth: Decimal; CalcFormula: Enum "Quantity Calculation Formula"; QuantityPer: Decimal; Position: Code[10];
                                    LeadTimeOffset: Code[20]; RoutingLinkCode: Code[10]; ScrapPct: Decimal; StartingDate: Date; EndingDate: Date)
    begin
        ProductionBOMLine.Validate("Production BOM No.", ProdBOMNo);
        ProductionBOMLine.Validate("Version Code", VersionCode);

        case PreviousBOMNo of
            ProdBOMNo:
                begin
                    ProductionBOMLine."Line No." := ProductionBOMLine."Line No." + 10000;
                    ProductionBOMLine.Validate("Line No.", ProductionBOMLine."Line No.");
                end;
            else begin
                    ProductionBOMLine."Line No." := 10000;
                    PreviousBOMNo := ProdBOMNo;
                    ProductionBOMLine.Validate("Line No.", ProductionBOMLine."Line No.");
                end;
        end;

        ProductionBOMLine.Validate(Type, Type);
        ProductionBOMLine.Validate("No.", No);
        ProductionBOMLine.Validate(Length, Length);
        ProductionBOMLine.Validate(Width, Width);
        ProductionBOMLine.Validate(Weight, Weight);
        ProductionBOMLine.Validate(Depth, Depth);
        ProductionBOMLine.Validate("Quantity per", QuantityPer);
        ProductionBOMLine.Validate("Calculation Formula", CalcFormula);
        ProductionBOMLine.Validate(Position, Position);
        Evaluate(ProductionBOMLine."Lead-Time Offset", LeadTimeOffset);
        ProductionBOMLine.Validate("Lead-Time Offset");
        ProductionBOMLine.Validate("Routing Link Code", RoutingLinkCode);
        ProductionBOMLine.Validate("Scrap %", ScrapPct);
        ProductionBOMLine.Validate("Starting Date", StartingDate);
        ProductionBOMLine.Validate("Ending Date", EndingDate);
        ProductionBOMLine.Insert();
    end;

    local procedure UpdateItems(ItemNo: Code[20]; ProdBOMNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item."Production BOM No." := ProdBOMNo;
        Item.Modify();
    end;

    local procedure CertifyProdBOM(ProdBOMNo: Code[20]; VersionCode: Code[10])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        if VersionCode <> '' then begin
            ProductionBOMVersion.Get(ProdBOMNo, VersionCode);
            ProductionBOMVersion.Validate(Status, ProductionBOMVersion.Status::Certified);
            ProductionBOMVersion.Modify();
        end else begin
            ProductionBOMHeader.Get(ProdBOMNo);
            ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::Certified);
            ProductionBOMHeader.Modify();
        end;
    end;
}

