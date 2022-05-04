codeunit 4770 "Create Mfg Item"
{
    Permissions = tabledata "Item" = ri,
    tabledata "Item Category" = ri,
    tabledata "Item Tracking Code" = ri,
    tabledata "Item Unit of Measure" = ri,
    tabledata "Item Variant" = ri;

    trigger OnRun()
    begin
        ManufacturingDemoDataSetup.Get();

        CreateItemCategories();

        CreateBOMAndRoutingItems();
        CreateItemTracking();
        CreateFlushingItems();
        CreateVariantsPhantomBOMItems();

        CalcStandartCost()
    end;

    local procedure CreateBOMAndRoutingItems()
    begin
        // Contoso coffee 
        // Manufacturing scenario #1: BOM/Routing/Standard Cost/Prod Order
        InsertData('SP-SCM1009', XAirpotTok, AdjustManufacturingData.AdjustPrice(399), AdjustManufacturingData.AdjustPrice(0), '', '', 0,
                    ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoDataSetup."Finished Code", CostingMethod::Standard, FlushingMethod::Manual, '', 10, '', 0,
                    ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '', ReplenishmentSystem::"Prod. Order", 0.001,
                    '<1W>', 0, XCMCommerTok, ManufacturingDemoFiles.GetAirPotPicture(), '');

        InsertData('SP-SCM1008', XAirpotLiteTok, AdjustManufacturingData.AdjustPrice(349), AdjustManufacturingData.AdjustPrice(0), '', '', 0,
                    ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoDataSetup."Finished Code", CostingMethod::Standard, FlushingMethod::Manual, '', 10, '', 0,
                    ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '', ReplenishmentSystem::"Prod. Order", 1,
                    '<1W>', 0, XCMCommerTok, ManufacturingDemoFiles.GetAirPotLiteWhitePicture(), '');

        InsertData('SP-BOM2000', XReservoirAssyTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(0), '', '', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 10, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::"Prod. Order", 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM2001', XReservoirTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(14.94), '81000', '266666', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM2002', XHeatingElementTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(24.24), '81000', '45455', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM2003', XWaterTubingTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(6.93), '81000', '11111', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM2004', XReservoirTestKitTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(18), '81000', 'A-12122', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1101', XHousingAirpotTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(36.26), '81000', 'ADG-4577', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1102', XFilterBasketTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(28.13), '81000', 'GG-78827', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1103', XFootTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(2.99), '81000', '4577-4555', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertItemUnitOfMeasure('SP-BOM1103', XSETTok, 4);

        InsertData('SP-BOM1104', XWarmingPlateTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(14.61), '81000', 'WW4577', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1105', XSwitchOnOffTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(3.11), '81000', 'HH-45888', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1106', XOnOffLightTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(3.05), '81000', 'PP-45656', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1107', XCircuitBoardTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(6.23), '81000', 'PP-7397', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1108', XPowerCordTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(5.99), '81000', '45888', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1109', XGlassCarafeTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(16.01), '81000', '45889', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');
    end;

    local procedure CreateItemTracking()
    begin
        // Manufacturing scenario #2: Item Tracking: consumption/output
        // Dependency scenario #1
        InsertItemTrackingCode(XSNPRODTok, XSNPRODspecifictrackingLbl, true, false, false, false);

        InsertData('SP-SCM1011', XAirpotDuoTok, AdjustManufacturingData.AdjustPrice(499), AdjustManufacturingData.AdjustPrice(0), '', '', 0,
                    ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoDataSetup."Finished Code", CostingMethod::Specific, FlushingMethod::Manual, '', 10, '', 0,
                    ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '', ReplenishmentSystem::"Prod. Order", 1, '<1W>', 0,
                    XCMCommerTok, ManufacturingDemoFiles.GetAirPotDuoPicture(), '');  //Item Tracking SNALL

        InsertData('SP-BOM1201', XHousingAirpotDuoTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(34.1), '81000', 'A-4577', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1207', XIoTSensorTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(8.88), '81000', '2777775', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');  //Item Tracking SNALL

        InsertData('SP-BOM1208', XFaciaPanelWithDisplayTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(14.11), '81000', '88-45888', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');
    end;

    local procedure CreateFlushingItems()
    begin
        // Manufacturing scenario #3: Flushing
        // Dependency scenario #1 (reuse components)
        InsertData('SP-SCM1004', XAutoDripTok, AdjustManufacturingData.AdjustPrice(179), AdjustManufacturingData.AdjustPrice(0), '', '', 0,
                    ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoDataSetup."Finished Code", CostingMethod::FIFO, FlushingMethod::Backward, '', 10, '', 0,
                    ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '', ReplenishmentSystem::"Prod. Order", 1, '<1W>', 0,
                    XCMConsumTok, ManufacturingDemoFiles.GetAutoDripPicture(), '');

        InsertData('SP-BOM1301', XHousingAutoDripTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(32.22), '81000', '4577-AA', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Backward, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1302', XControlPanelDisplayTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(5.03), '81000', '4577-BB', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Forward, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1303', XButtonTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(2.89), '81000', 'T5555-FF', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Forward, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1304', XStillCarafeTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(42.02), '81000', 'FR 48888', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Backward, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-BOM1305', XScrewHexM3Tok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(0.39), '81000', '22222', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Forward, '', 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 1, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');
    end;

    local procedure CreateVariantsPhantomBOMItems()
    begin
        // Manufacturing scenario #4: Variants, Phantom BOM
        // Dependency scenario #1,2,3 (reuse components)
        InsertData('SP-SCM1006', XAutoDripLiteTok, AdjustManufacturingData.AdjustPrice(149), AdjustManufacturingData.AdjustPrice(0), '', '', 0,
                    ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoDataSetup."Finished Code", CostingMethod::FIFO, FlushingMethod::Manual, '', 10, '', 0,
                    ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '', ReplenishmentSystem::"Prod. Order", 1,
                    '<1W>', 0, XCMConsumTok, ManufacturingDemoFiles.GetAutoDripLiteBlackPicture(), '');

        InsertItemVariant('SP-SCM1006', XBlackTok, XAutoDripLiteBlackTok, '');
        InsertItemVariant('SP-SCM1006', XWhiteTok, XAutoDripLiteWhiteTok, '');
        InsertItemVariant('SP-SCM1006', XRedTok, XAutoDripLiteRedTok, '');

        InsertData('SP-SCM3001', XPaintBlackTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(1.6), '81000', '4599-B1', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, XCANTok, 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 0.001, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-SCM3002', XPaintRedTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(1.6), '81000', '4599-B2', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, XCANTok, 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 0.001, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');

        InsertData('SP-SCM3003', XPaintWhiteTok, AdjustManufacturingData.AdjustPrice(0), AdjustManufacturingData.AdjustPrice(1.6), '81000', '4599-B3', 0, '', '',
                    CostingMethod::FIFO, FlushingMethod::Manual, XCANTok, 0, '', 0, ReorderingPolicy::"Lot-for-Lot", true, ManufacturingPolicy::"Make-to-Stock", 0, 0, 0, 0, 0, '',
                    ReplenishmentSystem::Purchase, 0.001, '<1W>', 0, XPartsTok, ManufacturingDemoFiles.GetNoPicture(), '');
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        AdjustManufacturingData: Codeunit "Adjust Manufacturing Data";
        ManufacturingDemoFiles: Codeunit "Manufacturing Demo Files";

        // Contoso coffee 
        // Products
        XAirpotDuoTok: Label 'Airpot Duo', MaxLength = 30;
        XAirpotTok: Label 'Airpot', MaxLength = 30;
        XAirpotLiteTok: Label 'Airpot lite', MaxLength = 30;
        XAutoDripTok: Label 'AutoDrip', MaxLength = 30;
        XAutoDripLiteTok: Label 'AutoDripLite', MaxLength = 30;
        XAutoDripLiteBlackTok: Label 'AutoDripLite - Black', MaxLength = 30;
        XAutoDripLiteRedTok: Label 'AutoDripLite - Red', MaxLength = 30;
        XAutoDripLiteWhiteTok: Label 'AutoDripLite - White', MaxLength = 30;
        XBlackTok: Label 'BLACK', MaxLength = 10;
        XWhiteTok: Label 'WHITE', MaxLength = 10;
        XRedTok: Label 'RED', MaxLength = 10;

        // Assembly
        XReservoirAssyTok: Label 'Reservoir Assy.', MaxLength = 30;

        //Components
        XHousingAirpotDuoTok: Label 'Housing Airpot Duo', MaxLength = 30;
        XHousingAirpotTok: Label 'Housing Airpot', MaxLength = 30;
        XHousingAutoDripTok: Label 'Housing AutoDrip', MaxLength = 30;
        XFilterBasketTok: Label 'Coffee filter basket', MaxLength = 30;
        XFootTok: Label 'Foot, adjustable, rubber', MaxLength = 30;
        XWarmingPlateTok: Label 'Warming plate', MaxLength = 30;
        XSwitchOnOffTok: Label 'Switch on/off', MaxLength = 30;
        XOnOffLightTok: Label 'On/off light', MaxLength = 30;
        XControlPanelDisplayTok: Label 'Control panel display', MaxLength = 30;
        XButtonTok: Label 'Button', MaxLength = 30;
        XScrewHexM3Tok: Label 'Screw Hex M3, Zink', MaxLength = 30;
        XCircuitBoardTok: Label 'Circuit board', MaxLength = 30;
        XPowerCordTok: Label 'Power cord', MaxLength = 30;
        XIoTSensorTok: Label 'IoT Sensor', MaxLength = 30;
        XFaciaPanelWithDisplayTok: Label 'Facia Panel with display', MaxLength = 30;
        XGlassCarafeTok: Label 'Glass Carafe', MaxLength = 30;
        XStillCarafeTok: Label 'Stainless still thermal carafe', MaxLength = 30;
        XReservoirTok: Label 'Reservoir.', MaxLength = 30;
        XHeatingElementTok: Label 'Heating element.', MaxLength = 30;
        XWaterTubingTok: Label 'Water tubing', MaxLength = 30;
        XReservoirTestKitTok: Label 'Reservoir testing kit', MaxLength = 30;
        XPaintBlackTok: Label 'Paint, black', MaxLength = 30;
        XPaintWhiteTok: Label 'Paint, white', MaxLength = 30;
        XPaintRedTok: Label 'Paint, red', MaxLength = 30;
        XPCSTok: Label 'PCS', MaxLength = 10, Comment = 'Must be the same as in CreateMfgUnitofMeasures codeunit';
        XCANTok: Label 'CAN', MaxLength = 10, Comment = 'Must be the same as in CreateMfgUnitofMeasures codeunit';
        XSETTok: Label 'SET', MaxLength = 10, Comment = 'Must be the same as in CreateMfgUnitofMeasures codeunit';
        XCMTok: Label 'CM', MaxLength = 20;
        XCoffeeMakersTok: Label 'Coffee Makers', MaxLength = 30;
        XPartsTok: Label 'PARTS', MaxLength = 20;
        XPartsLCTok: Label 'Parts', MaxLength = 30;
        XCMConsumTok: Label 'CM_Consum', MaxLength = 20;
        XConsumerModelsTok: Label 'Consumer Models', MaxLength = 30;
        XCMCommerTok: Label 'CM_Commer', MaxLength = 20;
        XCommercialModelsTok: Label 'Commercial Models', MaxLength = 30;
        XSNPRODTok: Label 'SN-PROD', MaxLength = 10;
        XSNPRODspecifictrackingLbl: Label 'SN specific tracking for manufacturing', MaxLength = 50;
        FlushingMethod: enum "Flushing Method";
        CostingMethod: enum "Costing Method";
        ReorderingPolicy: Enum "Reordering Policy";
        ManufacturingPolicy: Enum "Manufacturing Policy";
        ReplenishmentSystem: Enum "Replenishment System";

    local procedure CreateItemCategories()
    begin
        InsertItemCategory(XCMTok, XCoffeeMakersTok, '');
        InsertItemCategory(XPartsTok, XPartsLCTok, '');

        InsertItemCategory(XCMConsumTok, XConsumerModelsTok, XCMTok);
        InsertItemCategory(XCMCommerTok, XCommercialModelsTok, XCMTok);
    end;

    local procedure InsertData("No.": Code[20]; Description: Text[30]; UnitPrice: Decimal; LastDirectCost: Decimal; VendorNo: Code[20]; VendorItemNo: Text[20];
                                "Minimum Qty. on Hand": Decimal; GenProdPostingGr: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: enum "Costing Method";
                                FlushingMethod: enum "Flushing Method"; BaseUnitOfMeasure: code[10]; CostingLotSize: Decimal; LastSerialNo: Code[10]; ScrapPct: Decimal;
                                ReorderingPolicy: Enum "Reordering Policy"; IncludeInventory: Boolean; ManufacturingPolicy: Enum "Manufacturing Policy";
                                DiscrOrderQty: Decimal; MinimumLotSize: Decimal; MaximumLotSize: Decimal; SafetyStock: Decimal; LotMultiple: Decimal;
                                SafetyLeadTime: Text[20]; ReplenishmentSystem: Enum "Replenishment System"; RoundPrecision: Decimal; TimeBucket: Code[20];
                                ReorderQty: Decimal; CategoryCode: Code[20]; ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
    var
        Item: Record Item;
        ObjInStream: InStream;
    begin
        if item.Get("No.") then
            exit;

        Item.Init();
        Item.Validate("No.", "No.");
        Item.Validate(Description, Description);
        Item.Validate("Vendor No.", VendorNo);
        Item.Validate("Vendor Item No.", VendorItemNo);

        if BaseUnitOfMeasure <> '' then
            Item."Base Unit of Measure" := BaseUnitOfMeasure
        else
            Item."Base Unit of Measure" := XPCSTok;
        Item.Validate("Item Category Code", CategoryCode);

        Item."Sales Unit of Measure" := Item."Base Unit of Measure";
        Item."Purch. Unit of Measure" := Item."Base Unit of Measure";

        if InventoryPostingGroup <> '' then
            Item."Inventory Posting Group" := InventoryPostingGroup
        else
            Item."Inventory Posting Group" := ManufacturingDemoDataSetup."Raw Mat Code";

        if GenProdPostingGr <> '' then
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGr)
        else
            Item.Validate("Gen. Prod. Posting Group", ManufacturingDemoDataSetup."Raw Mat Code");

        Item."Costing Method" := CostingMethod;
        Item."Flushing Method" := FlushingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);

        Item.Validate("Lot Size", CostingLotSize);
        Item.Validate("Serial Nos.", LastSerialNo);
        Item.Validate("Scrap %", ScrapPct);
        Item.Validate("Include Inventory", IncludeInventory);
        Item.Validate("Manufacturing Policy", ManufacturingPolicy);
        Item.Validate("Discrete Order Quantity", DiscrOrderQty);
        Item.Validate("Minimum Order Quantity", MinimumLotSize);
        Item.Validate("Maximum Order Quantity", MaximumLotSize);
        Item.Validate("Safety Stock Quantity", SafetyStock);
        Item.Validate("Order Multiple", LotMultiple);
        Evaluate(Item."Safety Lead Time", SafetyLeadTime);
        Item.Validate("Safety Lead Time");
        Item.Validate("Replenishment System", ReplenishmentSystem);
        Item.Validate("Rounding Precision", RoundPrecision);
        Evaluate(Item."Time Bucket", TimeBucket);
        Item.Validate("Time Bucket");
        Item.Validate("Reorder Point", "Minimum Qty. on Hand");
        Item.Validate("Reorder Quantity", ReorderQty);
        Item.Validate("Reordering Policy", ReorderingPolicy);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;


        OnBeforeItemInsert(Item);

        Item.Insert();

        InsertItemUnitOfMeasure(Item."No.", Item."Base Unit of Measure", 1);
    end;

    local procedure InsertItemUnitOfMeasure(ItemNo: Code[20]; UnitOfMeasureCode: Text[10]; QtyPerStockedQty: Decimal)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure."Item No." := ItemNo;
        ItemUnitofMeasure.Code := UnitOfMeasureCode;
        ItemUnitofMeasure."Qty. per Unit of Measure" := QtyPerStockedQty;
        ItemUnitofMeasure.Insert();
    end;

    local procedure InsertItemVariant(ItemNo: Code[20]; "Code": Code[10]; Description: Text[30]; Description2: Text[30])
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.Validate(Code, Code);
        ItemVariant.Validate("Item No.", ItemNo);
        ItemVariant.Validate(Description, Description);
        ItemVariant.Validate("Description 2", Description2);
        ItemVariant.Insert();
    end;

    local procedure InsertItemCategory(ChildCategoryCode: Code[20]; ChildCategoryDescription: Text[30]; ParentCategoryCode: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        if ItemCategory.Get(ChildCategoryCode) then
            exit;

        ItemCategory.Init();
        ItemCategory.Validate(Code, ChildCategoryCode);
        ItemCategory.Validate("Parent Category", ParentCategoryCode);
        ItemCategory.Validate(Description, ChildCategoryDescription);
        ItemCategory.Insert(true);
    end;

    local procedure InsertItemTrackingCode("Code": Code[10]; Description: Text[50]; "SN Specific Tracking": Boolean; "Lot Specific Tracking": Boolean; "Man. Warranty Date Entry Reqd.": Boolean; "Man. Expir. Date Entry Reqd.": Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ItemTrackingCode.Init();
        ItemTrackingCode.Validate(Code, Code);
        ItemTrackingCode.Validate(Description, Description);
        ItemTrackingCode.Validate("SN Specific Tracking", "SN Specific Tracking");
        ItemTrackingCode.Validate("Lot Specific Tracking", "Lot Specific Tracking");
        ItemTrackingCode.Validate("Use Expiration Dates", true);
        ItemTrackingCode.Validate("Man. Warranty Date Entry Reqd.", "Man. Warranty Date Entry Reqd.");
        ItemTrackingCode.Validate("Man. Expir. Date Entry Reqd.", "Man. Expir. Date Entry Reqd.");
        ItemTrackingCode.Insert();
    end;

    local procedure CalcStandartCost()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        CalculateStandardCost: Codeunit "Calculate Standard Cost";
        ItemCostManagement: Codeunit ItemCostManagement;
    begin
        CalculateStandardCost.SetProperties(WorkDate(), true, false, false, '', true);
        CalculateStandardCost.CalcItems(Item, TempItem);

        if TempItem.Find('-') then
            repeat
                ItemCostManagement.UpdateStdCostShares(TempItem);
            until TempItem.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemInsert(var Item: Record Item)
    begin
    end;
}