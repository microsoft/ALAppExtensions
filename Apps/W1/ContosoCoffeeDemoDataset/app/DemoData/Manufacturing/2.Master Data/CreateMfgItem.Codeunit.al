codeunit 4770 "Create Mfg Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Item = rm;

    trigger OnRun()
    var
        ContosoUnitOfMeasure: Codeunit "Contoso Unit of Measure";
    begin
        ManufacturingDemoDataSetup.Get();

        DefaultUOMCode := CommonUOM.Piece();

        CreateBOMAndRoutingItems();
        CreateItemTrackingItems();
        CreateFlushingItems();
        CreateVariantsPhantomBOMItems();

        InsertItemVariants();

        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(SPBOM1103(), CommonUOM.Set(), 4, 0, 0, 0, 0);

        CalcStandardCost()
    end;

    local procedure CreateBOMAndRoutingItems()
    begin
        // Contoso coffee 
        // Manufacturing scenario #1: BOM/Routing/Standard Cost/Prod Order
        ContosoItem.InsertItem(SPSCM1009(), Enum::"Item Type"::Inventory, AirpotTok, ContosoUtilities.AdjustPrice(399), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), MfgPostingGroup.Finished(), Enum::"Costing Method"::Standard, DefaultUOMCode, MfgItemCategory.CommercialModelCode(), '',
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 0.001, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ManufacturingMedia.GetAirPotPicture(), '');

        ContosoItem.InsertItem('SP-SCM1008', Enum::"Item Type"::Inventory, AirpotLiteTok, ContosoUtilities.AdjustPrice(349), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), MfgPostingGroup.Finished(), Enum::"Costing Method"::Standard, DefaultUOMCode, MfgItemCategory.CommercialModelCode(), '',
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 1, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ManufacturingMedia.GetAirPotLiteWhitePicture(), '');

        ContosoItem.InsertItem(SPBOM2000(), Enum::"Item Type"::Inventory, ReservoirAssemblyTok, 0, 0, CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 1, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM2001(), Enum::"Item Type"::Inventory, ReservoirTok, 0, ContosoUtilities.AdjustPrice(14.94), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '266666', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM2002(), Enum::"Item Type"::Inventory, HeatingElementTok, 0, ContosoUtilities.AdjustPrice(24.24), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '45455', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM2003(), Enum::"Item Type"::Inventory, WaterTubingTok, 0, ContosoUtilities.AdjustPrice(6.93), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '11111', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM2004(), Enum::"Item Type"::Inventory, ReservoirTestKitTok, 0, ContosoUtilities.AdjustPrice(18), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'A-12122', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1101(), Enum::"Item Type"::Inventory, HousingAirpotTok, 0, ContosoUtilities.AdjustPrice(36.26), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'ADG-4577', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1102(), Enum::"Item Type"::Inventory, FilterBasketTok, 0, ContosoUtilities.AdjustPrice(28.13), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'GG-78827', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1103(), Enum::"Item Type"::Inventory, FootTok, 0, ContosoUtilities.AdjustPrice(2.99), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '4577-4555', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1104(), Enum::"Item Type"::Inventory, WarmingPlateTok, 0, ContosoUtilities.AdjustPrice(14.61), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'WW4577', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1105(), Enum::"Item Type"::Inventory, SwitchOnOffTok, 0, ContosoUtilities.AdjustPrice(3.11), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'HH-45888', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1106(), Enum::"Item Type"::Inventory, OnOffLightTok, 0, ContosoUtilities.AdjustPrice(3.05), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'PP-45656', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1107(), Enum::"Item Type"::Inventory, CircuitBoardTok, 0, ContosoUtilities.AdjustPrice(6.23), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'PP-7397', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1108(), Enum::"Item Type"::Inventory, PowerCordTok, 0, ContosoUtilities.AdjustPrice(5.99), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '45888', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1109(), Enum::"Item Type"::Inventory, GlassCarafeTok, 0, ContosoUtilities.AdjustPrice(16.01), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '45889', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');
    end;

    local procedure CreateItemTrackingItems()
    var
        CommonItemTracking: Codeunit "Create Common Item Tracking";
    begin
        // Manufacturing scenario #2: Item Tracking: consumption/output
        // Dependency scenario #1
        ContosoItem.InsertItem(SPSCM1011(), Enum::"Item Type"::Inventory, AirpotDuoTok, ContosoUtilities.AdjustPrice(499), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), MfgPostingGroup.Finished(), Enum::"Costing Method"::Specific, DefaultUOMCode, MfgItemCategory.CommercialModelCode(), CommonItemTracking.SNSpecificTrackingCode(),
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 1, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ManufacturingMedia.GetAirPotDuoPicture(), '');  //Item Tracking SNALL

        ContosoItem.InsertItem(SPBOM1201(), Enum::"Item Type"::Inventory, HousingAirpotDuoTok, 0, ContosoUtilities.AdjustPrice(34.1), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'A-4577', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1207(), Enum::"Item Type"::Inventory, IoTSensorTok, 0, ContosoUtilities.AdjustPrice(8.88), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), CommonItemTracking.SNSpecificTrackingCode(),
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '2777775', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');  //Item Tracking SNALL

        ContosoItem.InsertItem(SPBOM1208(), Enum::"Item Type"::Inventory, FaciaPanelWithDisplayTok, 0, ContosoUtilities.AdjustPrice(14.11), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '88-45888', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');
    end;

    local procedure CreateFlushingItems()
    begin
        // Manufacturing scenario #3: Flushing
        // Dependency scenario #1 (reuse components)
        ContosoItem.InsertItem(SPSCM1004(), Enum::"Item Type"::Inventory, AutoDripTok, ContosoUtilities.AdjustPrice(179), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), MfgPostingGroup.Finished(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.ConsumerModelCode(), '',
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 1, '', '', Enum::"Flushing Method"::Backward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ManufacturingMedia.GetAutoDripPicture(), '');

        ContosoItem.InsertItem(SPBOM1301(), Enum::"Item Type"::Inventory, HousingAutoDripTok, 0, ContosoUtilities.AdjustPrice(32.22), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '4577-AA', Enum::"Flushing Method"::Backward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1302(), Enum::"Item Type"::Inventory, ControlPanelDisplayTok, 0, ContosoUtilities.AdjustPrice(5.03), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '4577-BB', Enum::"Flushing Method"::Backward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1303(), Enum::"Item Type"::Inventory, ButtonTok, 0, ContosoUtilities.AdjustPrice(2.89), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'T5555-FF', Enum::"Flushing Method"::Forward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1304(), Enum::"Item Type"::Inventory, StillCarafeTok, 0, ContosoUtilities.AdjustPrice(42.02), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), 'FR 48888', Enum::"Flushing Method"::Backward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM1305(), Enum::"Item Type"::Inventory, ScrewHexM3Tok, 0, ContosoUtilities.AdjustPrice(0.39), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 1, CommonVendor.DomesticVendor1(), '22222', Enum::"Flushing Method"::Forward, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');
    end;

    local procedure CreateVariantsPhantomBOMItems()
    begin
        // Manufacturing scenario #4: Variants, Phantom BOM
        // Dependency scenario #1,2,3 (reuse components)
        ContosoItem.InsertItem(SPSCM1006(), Enum::"Item Type"::Inventory, AutoDripLiteTok, ContosoUtilities.AdjustPrice(149), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), MfgPostingGroup.Finished(), Enum::"Costing Method"::FIFO, DefaultUOMCode, MfgItemCategory.ConsumerModelCode(), '',
            0, '', '', 10, Enum::"Replenishment System"::"Prod. Order", 1, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ManufacturingMedia.GetAutoDripLiteBlackPicture(), '');

        ContosoItem.InsertItem(SPBOM3001(), Enum::"Item Type"::Inventory, PaintBlackTok, 0, ContosoUtilities.AdjustPrice(1.6), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, CommonUOM.Can(), MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 0.001, CommonVendor.DomesticVendor1(), '4599-B1', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM3002(), Enum::"Item Type"::Inventory, PaintRedTok, 0, ContosoUtilities.AdjustPrice(1.6), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, CommonUOM.Can(), MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 0.001, CommonVendor.DomesticVendor1(), '4599-B2', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');

        ContosoItem.InsertItem(SPBOM3003(), Enum::"Item Type"::Inventory, PaintWhiteTok, 0, ContosoUtilities.AdjustPrice(1.6), CommonPostingGroup.RawMaterial(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.RawMaterial(), Enum::"Costing Method"::FIFO, CommonUOM.Can(), MfgItemCategory.PartCode(), '',
            0, '', '', 0, Enum::"Replenishment System"::Purchase, 0.001, CommonVendor.DomesticVendor1(), '4599-B3', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::"Lot-for-Lot", true, '<1W>', ContosoUtilities.EmptyPicture(), '');
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        ManufacturingMedia: Codeunit "Manufacturing Media";
        ContosoUtilities: Codeunit "Contoso Utilities";
        MfgPostingGroup: Codeunit "Create Mfg Posting Group";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoItem: Codeunit "Contoso Item";
        CommonUOM: Codeunit "Create Common Unit Of Measure";
        MfgItemCategory: Codeunit "Create Mfg Item Category";
        CommonVendor: Codeunit "Create Common Customer/Vendor";

        // Contoso coffee 
        // Products
        AirpotDuoTok: Label 'Airpot Duo', MaxLength = 100;
        AirpotTok: Label 'Airpot', MaxLength = 100;
        AirpotLiteTok: Label 'Airpot lite', MaxLength = 100;
        AutoDripTok: Label 'AutoDrip', MaxLength = 100;
        AutoDripLiteTok: Label 'AutoDripLite', MaxLength = 100;
        AutoDripLiteBlackTok: Label 'AutoDripLite - Black', MaxLength = 30;
        AutoDripLiteRedTok: Label 'AutoDripLite - Red', MaxLength = 30;
        AutoDripLiteWhiteTok: Label 'AutoDripLite - White', MaxLength = 30;
        BlackTok: Label 'BLACK', MaxLength = 10;
        WhiteTok: Label 'WHITE', MaxLength = 10;
        RedTok: Label 'RED', MaxLength = 10;

        // Assembly
        ReservoirAssemblyTok: Label 'Reservoir Assembly', MaxLength = 100;

        //Components
        HousingAirpotDuoTok: Label 'Housing Airpot Duo', MaxLength = 100;
        HousingAirpotTok: Label 'Housing Airpot', MaxLength = 100;
        HousingAutoDripTok: Label 'Housing AutoDrip', MaxLength = 100;
        FilterBasketTok: Label 'Coffee filter basket', MaxLength = 100;
        FootTok: Label 'Foot, adjustable, rubber', MaxLength = 100;
        WarmingPlateTok: Label 'Warming plate', MaxLength = 100;
        SwitchOnOffTok: Label 'Switch on/off', MaxLength = 100;
        OnOffLightTok: Label 'On/off light', MaxLength = 100;
        ControlPanelDisplayTok: Label 'Control panel display', MaxLength = 100;
        ButtonTok: Label 'Button', MaxLength = 100;
        ScrewHexM3Tok: Label 'Screw Hex M3, Zinc', MaxLength = 100;
        CircuitBoardTok: Label 'Circuit board', MaxLength = 100;
        PowerCordTok: Label 'Power cord', MaxLength = 100;
        IoTSensorTok: Label 'IoT Sensor', MaxLength = 100;
        FaciaPanelWithDisplayTok: Label 'Facia Panel with display', MaxLength = 100;
        GlassCarafeTok: Label 'Glass Carafe', MaxLength = 100;
        StillCarafeTok: Label 'Stainless steel thermal carafe', MaxLength = 100;
        ReservoirTok: Label 'Reservoir', MaxLength = 100;
        HeatingElementTok: Label 'Heating element', MaxLength = 100;
        WaterTubingTok: Label 'Water tubing', MaxLength = 100;
        ReservoirTestKitTok: Label 'Reservoir testing kit', MaxLength = 100;
        PaintBlackTok: Label 'Paint, black', MaxLength = 100;
        PaintWhiteTok: Label 'Paint, white', MaxLength = 100;
        PaintRedTok: Label 'Paint, red', MaxLength = 100;
        DefaultUOMCode: Code[10];

    local procedure InsertItemVariants()
    begin
        ContosoItem.InsertItemVariant(SPSCM1006(), BlackTok, AutoDripLiteBlackTok);
        ContosoItem.InsertItemVariant(SPSCM1006(), WhiteTok, AutoDripLiteWhiteTok);
        ContosoItem.InsertItemVariant(SPSCM1006(), RedTok, AutoDripLiteRedTok);
    end;

    local procedure CalcStandardCost()
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

    procedure SPSCM1004(): Code[20]
    begin
        exit('SP-SCM1004');
    end;

    procedure SPSCM1006(): Code[20]
    begin
        exit('SP-SCM1006');
    end;

    procedure SPSCM1009(): Code[20]
    begin
        exit('SP-SCM1009');
    end;

    procedure SPSCM1011(): Code[20]
    begin
        exit('SP-SCM1011');
    end;

    procedure SPBOM1101(): Code[20]
    begin
        exit('SP-BOM1101');
    end;

    procedure SPBOM1102(): Code[20]
    begin
        exit('SP-BOM1102');
    end;

    procedure SPBOM1103(): Code[20]
    begin
        exit('SP-BOM1103');
    end;

    procedure SPBOM1104(): Code[20]
    begin
        exit('SP-BOM1104');
    end;

    procedure SPBOM1105(): Code[20]
    begin
        exit('SP-BOM1105');
    end;

    procedure SPBOM1106(): Code[20]
    begin
        exit('SP-BOM1106');
    end;

    procedure SPBOM1107(): Code[20]
    begin
        exit('SP-BOM1107');
    end;

    procedure SPBOM1108(): Code[20]
    begin
        exit('SP-BOM1108');
    end;

    procedure SPBOM1109(): Code[20]
    begin
        exit('SP-BOM1109');
    end;

    procedure SPBOM1201(): Code[20]
    begin
        exit('SP-BOM1201');
    end;

    procedure SPBOM1207(): Code[20]
    begin
        exit('SP-BOM1207');
    end;

    procedure SPBOM1208(): Code[20]
    begin
        exit('SP-BOM1208');
    end;

    procedure SPBOM1301(): Code[20]
    begin
        exit('SP-BOM1301');
    end;

    procedure SPBOM1302(): Code[20]
    begin
        exit('SP-BOM1302');
    end;

    procedure SPBOM1303(): Code[20]
    begin
        exit('SP-BOM1303');
    end;

    procedure SPBOM1304(): Code[20]
    begin
        exit('SP-BOM1304');
    end;

    procedure SPBOM1305(): Code[20]
    begin
        exit('SP-BOM1305');
    end;

    procedure SPBOM2000(): Code[20]
    begin
        exit('SP-BOM2000');
    end;

    procedure SPBOM2001(): Code[20]
    begin
        exit('SP-BOM2001');
    end;

    procedure SPBOM2002(): Code[20]
    begin
        exit('SP-BOM2002');
    end;

    procedure SPBOM2003(): Code[20]
    begin
        exit('SP-BOM2003');
    end;

    procedure SPBOM2004(): Code[20]
    begin
        exit('SP-BOM2004');
    end;

    procedure SPBOM3001(): Code[20]
    begin
        exit('SP-BOM3001');
    end;

    procedure SPBOM3002(): Code[20]
    begin
        exit('SP-BOM3002');
    end;

    procedure SPBOM3003(): Code[20]
    begin
        exit('SP-BOM3003');
    end;
}