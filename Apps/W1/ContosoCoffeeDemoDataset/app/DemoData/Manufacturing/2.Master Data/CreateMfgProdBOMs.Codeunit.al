codeunit 4771 "Create Mfg Prod. BOMs"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Item" = rm,
        tabledata "Production BOM Header" = rm;

    trigger OnRun()
    begin
        Scenario1();
        Scenario2();
        Scenario3();
        Scenario4();

        LowLevelCodeCalculator.Calculate(false);
    end;

    var
        LowLevelCodeCalculator: Codeunit "Low-Level Code Calculator";
        ContosoManufacturing: Codeunit "Contoso Manufacturing";
        ContosoUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
        MfgItem: Codeunit "Create Mfg Item";
        CreateMfgProdRouting: Codeunit "Create Mfg Prod. Routing";
        AirpotDuoTok: Label 'Airpot Duo', MaxLength = 30;
        AirpotTok: Label 'Airpot', MaxLength = 30;
        AutoDripTok: Label 'AutoDrip', MaxLength = 30;
        AutoDripLiteBaseTok: Label 'AutoDripLite - Base', MaxLength = 30;
        AutoDripLiteBlackTok: Label 'AutoDripLite - Black', MaxLength = 30;
        AutoDripLiteRedTok: Label 'AutoDripLite - Red', MaxLength = 30;
        AutoDripLiteWhiteTok: Label 'AutoDripLite - White', MaxLength = 30;
        ReservoirAssemblyTok: Label 'Reservoir Assembly.', MaxLength = 30;

    local procedure Scenario1()
    begin
        // Manufacturing scenario #1: BOM/Routing/Standard Cost/Prod Order
        ContosoManufacturing.InsertProductionBOMHeader(SPBOM2000(), ReservoirAssemblyTok, ContosoUnitOfMeasure.Piece());

        ContosoManufacturing.InsertProductionBOMLine(SPBOM2000(), '', 1, MfgItem.SPBOM2001(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPBOM2000(), '', 1, MfgItem.SPBOM2002(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPBOM2000(), '', 1, MfgItem.SPBOM2003(), Enum::"Quantity Calculation Formula"::" ", 2, '');
        ContosoManufacturing.InsertProductionBOMLine(SPBOM2000(), '', 1, MfgItem.SPBOM2004(), Enum::"Quantity Calculation Formula"::"Fixed Quantity", 1, '');

        CertifyProdBOM(SPBOM2000());
        UpdateItems(MfgItem.SPBOM2000(), SPBOM2000());


        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1009(), AirpotTok, ContosoUnitOfMeasure.Piece());

        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1101(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM2000(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1102(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1103(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1104(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1105(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1106(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1107(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1108(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1009(), '', 1, MfgItem.SPBOM1109(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1009());
        UpdateItems(MfgItem.SPSCM1009(), SPSCM1009());
    end;

    local procedure Scenario2()
    begin
        // Manufacturing scenario #2: Item Tracking: consumption/output
        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1011(), AirpotDuoTok, ContosoUnitOfMeasure.Piece());

        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1201(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM2000(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1102(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1103(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1104(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1107(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1108(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1207(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1208(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1011(), '', 1, MfgItem.SPBOM1109(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1011());
        UpdateItems(MfgItem.SPSCM1011(), SPSCM1011());
    end;

    local procedure Scenario3()
    begin
        // Manufacturing scenario #3: Flushing
        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1004(), AutoDripTok, ContosoUnitOfMeasure.Piece());

        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1301(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM2000(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1305(), Enum::"Quantity Calculation Formula"::" ", 12, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1102(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1103(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1302(), Enum::"Quantity Calculation Formula"::" ", 1, CreateMfgProdRouting.RoutingLink100());
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1303(), Enum::"Quantity Calculation Formula"::" ", 1, CreateMfgProdRouting.RoutingLink100());
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1107(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1108(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1004(), '', 1, MfgItem.SPBOM1304(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1004());
        UpdateItems(MfgItem.SPSCM1004(), SPSCM1004());
    end;

    local procedure Scenario4()
    begin
        // Manufacturing scenario #4: Variants, Phantom BOM
        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1006BASE(), AutoDripLiteBaseTok, ContosoUnitOfMeasure.Piece());

        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1301(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM2000(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1102(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1103(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1105(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1107(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1108(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BASE(), '', 1, MfgItem.SPBOM1109(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1006BASE());

        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1006RED(), AutoDripLiteRedTok, ContosoUnitOfMeasure.Piece());
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006RED(), '', 1, MfgItem.SPBOM3002(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006RED(), '', 2, SPSCM1006BASE(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1006RED());

        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1006WHITE(), AutoDripLiteWhiteTok, ContosoUnitOfMeasure.Piece());
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006WHITE(), '', 1, MfgItem.SPBOM3003(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006WHITE(), '', 2, SPSCM1006BASE(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1006WHITE());

        ContosoManufacturing.InsertProductionBOMHeader(SPSCM1006BLACK(), AutoDripLiteBlackTok, ContosoUnitOfMeasure.Piece());
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BLACK(), '', 1, MfgItem.SPBOM3001(), Enum::"Quantity Calculation Formula"::" ", 1, '');
        ContosoManufacturing.InsertProductionBOMLine(SPSCM1006BLACK(), '', 2, SPSCM1006BASE(), Enum::"Quantity Calculation Formula"::" ", 1, '');

        CertifyProdBOM(SPSCM1006BLACK());
        UpdateItems(MfgItem.SPSCM1006(), SPSCM1006BLACK());
    end;


    local procedure UpdateItems(ItemNo: Code[20]; ProdBOMNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("Production BOM No.", ProdBOMNo);
        Item.Modify(true);
    end;

    local procedure CertifyProdBOM(ProdBOMNo: Code[20])
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        ProductionBOMHeader.Get(ProdBOMNo);
        ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::Certified);
        ProductionBOMHeader.Modify(true);
    end;

    procedure SPBOM2000(): Code[20]
    begin
        exit('SP-BOM2000');
    end;

    procedure SPSCM1009(): Code[20]
    begin
        exit('SP-SCM1009');
    end;

    procedure SPSCM1011(): Code[20]
    begin
        exit('SP-SCM1011');
    end;

    procedure SPSCM1004(): Code[20]
    begin
        exit('SP-SCM1004');
    end;

    procedure SPSCM1006BASE(): Code[20]
    begin
        exit('SP-SCM1006-BASE');
    end;

    procedure SPSCM1006RED(): Code[20]
    begin
        exit('SP-SCM1006-RED');
    end;

    procedure SPSCM1006WHITE(): Code[20]
    begin
        exit('SP-SCM1006-WHITE');
    end;

    procedure SPSCM1006BLACK(): Code[20]
    begin
        exit('SP-SCM1006-BLACK');
    end;
}

