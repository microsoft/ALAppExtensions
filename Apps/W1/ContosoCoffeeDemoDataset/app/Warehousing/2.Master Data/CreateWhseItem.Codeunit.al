codeunit 4793 "Create Whse Item"
{
    Permissions = tabledata "Item" = rim,
        tabledata "Unit of Measure" = rim,
        tabledata "Item Unit of Measure" = rim;

    var
        DoInsertTriggers: Boolean;

    trigger OnRun()
    begin
        CreateCollection(false);
    end;

    local procedure TextAsGuid(InputText: Text) OutputGuid: Guid
    begin
        Evaluate(OutputGuid, InputText);
    end;

    local procedure TextAsDateFormula(InputText: Text) OutputDateFormula: DateFormula
    begin
        Evaluate(OutputDateFormula, InputText);
    end;

    local procedure CreateItem(
        No: Code[20];
        NoTwo: Code[20];
        Description: Text[100];
        SearchDescription: Code[100];
        DescriptionTwo: Text[50];
        BaseUnitofMeasure: Code[10];
        PriceUnitConversion: Integer;
        Type: Enum "Item Type";
        InventoryPostingGroup: Code[20];
        ShelfNo: Code[10];
        ItemDiscGroup: Code[20];
        AllowInvoiceDisc: Boolean;
        StatisticsGroup: Integer;
        CommissionGroup: Integer;
        UnitPrice: Decimal;
        PriceProfitCalculation: Enum "Item Price Profit Calculation";
        Profit: Decimal;
        CostingMethod: Enum "Costing Method";
        UnitCost: Decimal;
        StandardCost: Decimal;
        LastDirectCost: Decimal;
        IndirectCost: Decimal;
        CostisAdjusted: Boolean;
        AllowOnlineAdjustment: Boolean;
        VendorNo: Code[20];
        VendorItemNo: Text[50];
        LeadTimeCalculation: DateFormula;
        ReorderPoint: Decimal;
        MaximumInventory: Decimal;
        ReorderQuantity: Decimal;
        AlternativeItemNo: Code[20];
        UnitListPrice: Decimal;
        DutyDue: Decimal;
        DutyCode: Code[10];
        GrossWeight: Decimal;
        NetWeight: Decimal;
        UnitsperParcel: Decimal;
        UnitVolume: Decimal;
        Durability: Code[10];
        FreightType: Code[10];
        TariffNo: Code[20];
        DutyUnitConversion: Decimal;
        CountryRegionPurchasedCode: Code[10];
        BudgetQuantity: Decimal;
        BudgetedAmount: Decimal;
        BudgetProfit: Decimal;
        Blocked: Boolean;
        BlockReason: Text[250];
        LastDateTimeModified: DateTime;
        LastDateModified: Date;
        LastTimeModified: Time;
        PriceIncludesVAT: Boolean;
        VATBusPostingGrPrice: Code[20];
        GenProdPostingGroup: Code[20];
        CountryRegionofOriginCode: Code[10];
        AutomaticExtTexts: Boolean;
        NoSeries: Code[20];
        TaxGroupCode: Code[20];
        VATProdPostingGroup: Code[20];
        Reserve: Enum "Reserve Method";
        GlobalDimensionOneCode: Code[20];
        GlobalDimensionTwoCode: Code[20];
        StockoutWarning: Option;
        PreventNegativeInventory: Option;
        VariantMandatoryifExists: Option;
        ApplicationWkshUserID: Code[128];
        CoupledtoCRM: Boolean;
        AssemblyPolicy: Enum "Assembly Policy";
        GTIN: Code[14];
        DefaultDeferralTemplateCode: Code[10];
        LowLevelCode: Integer;
        LotSize: Decimal;
        SerialNos: Code[20];
        LastUnitCostCalcDate: Date;
        RolledupMaterialCost: Decimal;
        RolledupCapacityCost: Decimal;
        Scrap: Decimal;
        InventoryValueZero: Boolean;
        DiscreteOrderQuantity: Integer;
        MinimumOrderQuantity: Decimal;
        MaximumOrderQuantity: Decimal;
        SafetyStockQuantity: Decimal;
        OrderMultiple: Decimal;
        SafetyLeadTime: DateFormula;
        FlushingMethod: Enum "Flushing Method";
        ReplenishmentSystem: Enum "Replenishment System";
        RoundingPrecision: Decimal;
        SalesUnitofMeasure: Code[10];
        PurchUnitofMeasure: Code[10];
        TimeBucket: DateFormula;
        ReorderingPolicy: Enum "Reordering Policy";
        IncludeInventory: Boolean;
        ManufacturingPolicy: Enum "Manufacturing Policy";
        ReschedulingPeriod: DateFormula;
        LotAccumulationPeriod: DateFormula;
        DampenerPeriod: DateFormula;
        DampenerQuantity: Decimal;
        OverflowLevel: Decimal;
        ManufacturerCode: Code[10];
        ItemCategoryCode: Code[20];
        CreatedFromNonstockItem: Boolean;
        PurchasingCode: Code[10];
        ServiceItemGroup: Code[10];
        ItemTrackingCode: Code[10];
        LotNos: Code[20];
        ExpirationCalculation: DateFormula;
        WarehouseClassCode: Code[10];
        SpecialEquipmentCode: Code[10];
        PutawayTemplateCode: Code[10];
        PutawayUnitofMeasureCode: Code[10];
        PhysInvtCountingPeriodCode: Code[10];
        LastCountingPeriodUpdate: Date;
        UseCrossDocking: Boolean;
        NextCountingStartDate: Date;
        NextCountingEndDate: Date;
        UnitofMeasureId: GUID;
        TaxGroupId: GUID;
        SalesBlocked: Boolean;
        PurchasingBlocked: Boolean;
        ItemCategoryId: GUID;
        InventoryPostingGroupId: GUID;
        GenProdPostingGroupId: GUID;
        OverReceiptCode: Code[20];
        HasSalesForecast: Boolean;
        RoutingNo: Code[20];
        ProductionBOMNo: Code[20];
        SingleLevelMaterialCost: Decimal;
        SingleLevelCapacityCost: Decimal;
        SingleLevelSubcontrdCost: Decimal;
        SingleLevelCapOvhdCost: Decimal;
        SingleLevelMfgOvhdCost: Decimal;
        OverheadRate: Decimal;
        RolledupSubcontractedCost: Decimal;
        RolledupMfgOvhdCost: Decimal;
        RolledupCapOverheadCost: Decimal;
        OrderTrackingPolicy: Enum "Order Tracking Policy";
        Critical: Boolean;
        CommonItemNo: Code[20]
    )
    var
        Item: Record "Item";
    begin
        Item.Init();
        Item."No." := No;
        Item."No. 2" := NoTwo;
        Item."Description" := Description;
        Item."Search Description" := SearchDescription;
        Item."Description 2" := DescriptionTwo;
        Item."Base Unit of Measure" := BaseUnitofMeasure;
        Item."Price Unit Conversion" := PriceUnitConversion;
        Item."Type" := Type;
        Item."Inventory Posting Group" := InventoryPostingGroup;
        Item."Shelf No." := ShelfNo;
        Item."Item Disc. Group" := ItemDiscGroup;
        Item."Allow Invoice Disc." := AllowInvoiceDisc;
        Item."Statistics Group" := StatisticsGroup;
        Item."Commission Group" := CommissionGroup;
        Item."Unit Price" := UnitPrice;
        Item."Price/Profit Calculation" := PriceProfitCalculation;
        Item."Profit %" := Profit;
        Item."Costing Method" := CostingMethod;
        Item."Unit Cost" := UnitCost;
        Item."Standard Cost" := StandardCost;
        Item."Last Direct Cost" := LastDirectCost;
        Item."Indirect Cost %" := IndirectCost;
        Item."Cost is Adjusted" := CostisAdjusted;
        Item."Allow Online Adjustment" := AllowOnlineAdjustment;
        Item."Vendor No." := VendorNo;
        Item."Vendor Item No." := VendorItemNo;
        Item."Lead Time Calculation" := LeadTimeCalculation;
        Item."Reorder Point" := ReorderPoint;
        Item."Maximum Inventory" := MaximumInventory;
        Item."Reorder Quantity" := ReorderQuantity;
        Item."Alternative Item No." := AlternativeItemNo;
        Item."Unit List Price" := UnitListPrice;
        Item."Duty Due %" := DutyDue;
        Item."Duty Code" := DutyCode;
        Item."Gross Weight" := GrossWeight;
        Item."Net Weight" := NetWeight;
        Item."Units per Parcel" := UnitsperParcel;
        Item."Unit Volume" := UnitVolume;
        Item."Durability" := Durability;
        Item."Freight Type" := FreightType;
        Item."Tariff No." := TariffNo;
        Item."Duty Unit Conversion" := DutyUnitConversion;
        Item."Country/Region Purchased Code" := CountryRegionPurchasedCode;
        Item."Budget Quantity" := BudgetQuantity;
        Item."Budgeted Amount" := BudgetedAmount;
        Item."Budget Profit" := BudgetProfit;
        Item."Blocked" := Blocked;
        Item."Block Reason" := BlockReason;
        Item."Last DateTime Modified" := LastDateTimeModified;
        Item."Last Date Modified" := LastDateModified;
        Item."Last Time Modified" := LastTimeModified;
        Item."Price Includes VAT" := PriceIncludesVAT;
        Item."VAT Bus. Posting Gr. (Price)" := VATBusPostingGrPrice;
        Item."Gen. Prod. Posting Group" := GenProdPostingGroup;
        Item."Country/Region of Origin Code" := CountryRegionofOriginCode;
        Item."Automatic Ext. Texts" := AutomaticExtTexts;
        Item."No. Series" := NoSeries;
        Item."Tax Group Code" := TaxGroupCode;
        Item."VAT Prod. Posting Group" := VATProdPostingGroup;
        Item."Reserve" := Reserve;
        Item."Global Dimension 1 Code" := GlobalDimensionOneCode;
        Item."Global Dimension 2 Code" := GlobalDimensionTwoCode;
        Item."Stockout Warning" := StockoutWarning;
        Item."Prevent Negative Inventory" := PreventNegativeInventory;
        Item."Variant Mandatory if Exists" := VariantMandatoryifExists;
        Item."Application Wksh. User ID" := ApplicationWkshUserID;
        Item."Coupled to CRM" := CoupledtoCRM;
        Item."Assembly Policy" := AssemblyPolicy;
        Item."GTIN" := GTIN;
        Item."Default Deferral Template Code" := DefaultDeferralTemplateCode;
        Item."Low-Level Code" := LowLevelCode;
        Item."Lot Size" := LotSize;
        Item."Serial Nos." := SerialNos;
        Item."Last Unit Cost Calc. Date" := LastUnitCostCalcDate;
        Item."Rolled-up Material Cost" := RolledupMaterialCost;
        Item."Rolled-up Capacity Cost" := RolledupCapacityCost;
        Item."Scrap %" := Scrap;
        Item."Inventory Value Zero" := InventoryValueZero;
        Item."Discrete Order Quantity" := DiscreteOrderQuantity;
        Item."Minimum Order Quantity" := MinimumOrderQuantity;
        Item."Maximum Order Quantity" := MaximumOrderQuantity;
        Item."Safety Stock Quantity" := SafetyStockQuantity;
        Item."Order Multiple" := OrderMultiple;
        Item."Safety Lead Time" := SafetyLeadTime;
        Item."Flushing Method" := FlushingMethod;
        Item."Replenishment System" := ReplenishmentSystem;
        Item."Rounding Precision" := RoundingPrecision;
        Item."Sales Unit of Measure" := SalesUnitofMeasure;
        Item."Purch. Unit of Measure" := PurchUnitofMeasure;
        Item."Time Bucket" := TimeBucket;
        Item."Reordering Policy" := ReorderingPolicy;
        Item."Include Inventory" := IncludeInventory;
        Item."Manufacturing Policy" := ManufacturingPolicy;
        Item."Rescheduling Period" := ReschedulingPeriod;
        Item."Lot Accumulation Period" := LotAccumulationPeriod;
        Item."Dampener Period" := DampenerPeriod;
        Item."Dampener Quantity" := DampenerQuantity;
        Item."Overflow Level" := OverflowLevel;
        Item."Manufacturer Code" := ManufacturerCode;
        Item."Item Category Code" := ItemCategoryCode;
        Item."Created From Nonstock Item" := CreatedFromNonstockItem;
        Item."Purchasing Code" := PurchasingCode;
        Item."Service Item Group" := ServiceItemGroup;
        Item."Item Tracking Code" := ItemTrackingCode;
        Item."Lot Nos." := LotNos;
        Item."Expiration Calculation" := ExpirationCalculation;
        Item."Warehouse Class Code" := WarehouseClassCode;
        Item."Special Equipment Code" := SpecialEquipmentCode;
        Item."Put-away Template Code" := PutawayTemplateCode;
        Item."Put-away Unit of Measure Code" := PutawayUnitofMeasureCode;
        Item."Phys Invt Counting Period Code" := PhysInvtCountingPeriodCode;
        Item."Last Counting Period Update" := LastCountingPeriodUpdate;
        Item."Use Cross-Docking" := UseCrossDocking;
        Item."Next Counting Start Date" := NextCountingStartDate;
        Item."Next Counting End Date" := NextCountingEndDate;
        Item."Unit of Measure Id" := UnitofMeasureId;
        Item."Tax Group Id" := TaxGroupId;
        Item."Sales Blocked" := SalesBlocked;
        Item."Purchasing Blocked" := PurchasingBlocked;
        Item."Item Category Id" := ItemCategoryId;
        Item."Inventory Posting Group Id" := InventoryPostingGroupId;
        Item."Gen. Prod. Posting Group Id" := GenProdPostingGroupId;
        Item."Over-Receipt Code" := OverReceiptCode;
        Item."Routing No." := RoutingNo;
        Item."Production BOM No." := ProductionBOMNo;
        Item."Single-Level Material Cost" := SingleLevelMaterialCost;
        Item."Single-Level Capacity Cost" := SingleLevelCapacityCost;
        Item."Single-Level Subcontrd. Cost" := SingleLevelSubcontrdCost;
        Item."Single-Level Cap. Ovhd Cost" := SingleLevelCapOvhdCost;
        Item."Single-Level Mfg. Ovhd Cost" := SingleLevelMfgOvhdCost;
        Item."Overhead Rate" := OverheadRate;
        Item."Rolled-up Subcontracted Cost" := RolledupSubcontractedCost;
        Item."Rolled-up Mfg. Ovhd Cost" := RolledupMfgOvhdCost;
        Item."Rolled-up Cap. Overhead Cost" := RolledupCapOverheadCost;
        Item."Order Tracking Policy" := OrderTrackingPolicy;
        Item."Critical" := Critical;
        Item."Common Item No." := CommonItemNo;
        Item.Insert(DoInsertTriggers);
    end;

    local procedure CreateUnitofMeasure(
        Code: Code[10];
        Description: Text[50];
        InternationalStandardCode: Code[10];
        Symbol: Text[10];
        LastModifiedDateTime: DateTime;
        CoupledtoCRM: Boolean
    )
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        UnitofMeasure.Init();
        UnitofMeasure."Code" := Code;
        UnitofMeasure."Description" := Description;
        UnitofMeasure."International Standard Code" := InternationalStandardCode;
        UnitofMeasure."Symbol" := Symbol;
        UnitofMeasure."Last Modified Date Time" := LastModifiedDateTime;
        UnitofMeasure."Coupled to CRM" := CoupledtoCRM;
        UnitofMeasure.Insert(DoInsertTriggers);
    end;

    local procedure CreateItemUnitofMeasure(
        ItemNo: Code[20];
        Code: Code[10];
        QtyperUnitofMeasure: Decimal;
        QtyRoundingPrecision: Decimal;
        Length: Decimal;
        Width: Decimal;
        Height: Decimal;
        Cubage: Decimal;
        Weight: Decimal
    )
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.Init();
        ItemUnitofMeasure."Item No." := ItemNo;
        ItemUnitofMeasure."Code" := Code;
        ItemUnitofMeasure."Qty. per Unit of Measure" := QtyperUnitofMeasure;
        ItemUnitofMeasure."Qty. Rounding Precision" := QtyRoundingPrecision;
        ItemUnitofMeasure."Length" := Length;
        ItemUnitofMeasure."Width" := Width;
        ItemUnitofMeasure."Height" := Height;
        ItemUnitofMeasure."Cubage" := Cubage;
        ItemUnitofMeasure."Weight" := Weight;
        ItemUnitofMeasure.Insert(DoInsertTriggers);
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreateItem('WRB-1000', '', 'Whole Roasted Beans, Arabica, Columbia', 'WHOLE ROASTED BEANS, ARABICA, COLUMBIA', '', 'PCS', 0, Enum::"Item Type"::Inventory, 'RESALE', '', '', true, 0, 0, 0, Enum::"Item Price Profit Calculation"::"Profit=Price-Cost", 0, Enum::"Costing Method"::FIFO, 0, 0, 0, 0, true, true, '', '', TextAsDateFormula(''), 0, 0, 0, '', 0, 0, '', 0, 0, 0, 0, '', '', '', 0, '', 0, 0, 0, false, '', CreateDateTime(20221018D, 114246T), 20221018D, 114246T, false, '', 'RETAIL', '', false, '', '', 'RETAIL', Enum::"Reserve Method"::Optional, '', '', 0, 0, 0, '', false, Enum::"Assembly Policy"::"Assemble-to-Stock", '', '', 0, 0, '', 0D, 0, 0, 0, false, 0, 0, 0, 0, 0, TextAsDateFormula(''), Enum::"Flushing Method"::Manual, Enum::"Replenishment System"::Purchase, 1, 'PCS', 'PCS', TextAsDateFormula(''), Enum::"Reordering Policy"::" ", false, Enum::"Manufacturing Policy"::"Make-to-Stock", TextAsDateFormula(''), TextAsDateFormula(''), TextAsDateFormula(''), 0, 0, '', 'BEANS', false, '', '', '', '', TextAsDateFormula(''), '', '', '', '', '', 0D, true, 0D, 0D, TextAsGuid('{A8DEB5DC-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{00000000-0000-0000-0000-000000000000}'), false, false, TextAsGuid('{00000000-0000-0000-0000-000000000000}'), TextAsGuid('{BBEDB5F4-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{64E0B5DC-D83A-ED11-BBAA-6045BD8E54CB}'), '', false, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, Enum::"Order Tracking Policy"::None, false, '');
        CreateItem('WRB-1001', '', 'Whole Roasted Beans, Arabica, Brazil', 'WHOLE ROASTED BEANS, ARABICA, BRAZIL', '', 'PCS', 0, Enum::"Item Type"::Inventory, 'RESALE', '', '', true, 0, 0, 0, Enum::"Item Price Profit Calculation"::"Profit=Price-Cost", 0, Enum::"Costing Method"::FIFO, 0, 0, 0, 0, true, true, '', '', TextAsDateFormula(''), 0, 0, 0, '', 0, 0, '', 0, 0, 0, 0, '', '', '', 0, '', 0, 0, 0, false, '', CreateDateTime(20221018D, 114251T), 20221018D, 114251T, false, '', 'RETAIL', '', false, '', '', 'RETAIL', Enum::"Reserve Method"::Optional, '', '', 0, 0, 0, '', false, Enum::"Assembly Policy"::"Assemble-to-Stock", '', '', 0, 0, '', 0D, 0, 0, 0, false, 0, 0, 0, 0, 0, TextAsDateFormula(''), Enum::"Flushing Method"::Manual, Enum::"Replenishment System"::Purchase, 1, 'PCS', 'PCS', TextAsDateFormula(''), Enum::"Reordering Policy"::" ", false, Enum::"Manufacturing Policy"::"Make-to-Stock", TextAsDateFormula(''), TextAsDateFormula(''), TextAsDateFormula(''), 0, 0, '', 'BEANS', false, '', '', '', '', TextAsDateFormula(''), '', '', '', '', '', 0D, true, 0D, 0D, TextAsGuid('{A8DEB5DC-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{00000000-0000-0000-0000-000000000000}'), false, false, TextAsGuid('{00000000-0000-0000-0000-000000000000}'), TextAsGuid('{BBEDB5F4-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{64E0B5DC-D83A-ED11-BBAA-6045BD8E54CB}'), '', false, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, Enum::"Order Tracking Policy"::None, false, '');
        CreateItem('WRB-1002', '', 'Whole Roasted Beans, Arabica, Indonesia', 'WHOLE ROASTED BEANS, ARABICA, INDONESIA', '', 'PCS', 0, Enum::"Item Type"::Inventory, 'RESALE', '', '', true, 0, 0, 0, Enum::"Item Price Profit Calculation"::"Profit=Price-Cost", 0, Enum::"Costing Method"::FIFO, 0, 0, 0, 0, true, true, '', '', TextAsDateFormula(''), 0, 0, 0, '', 0, 0, '', 0, 0, 0, 0, '', '', '', 0, '', 0, 0, 0, false, '', CreateDateTime(20221018D, 114253T), 20221018D, 114253T, false, '', 'RETAIL', '', false, '', '', 'RETAIL', Enum::"Reserve Method"::Optional, '', '', 0, 0, 0, '', false, Enum::"Assembly Policy"::"Assemble-to-Stock", '', '', 0, 0, '', 0D, 0, 0, 0, false, 0, 0, 0, 0, 0, TextAsDateFormula(''), Enum::"Flushing Method"::Manual, Enum::"Replenishment System"::Purchase, 1, 'PCS', 'PCS', TextAsDateFormula(''), Enum::"Reordering Policy"::" ", false, Enum::"Manufacturing Policy"::"Make-to-Stock", TextAsDateFormula(''), TextAsDateFormula(''), TextAsDateFormula(''), 0, 0, '', 'BEANS', false, '', '', '', '', TextAsDateFormula(''), '', '', '', '', '', 0D, true, 0D, 0D, TextAsGuid('{A8DEB5DC-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{00000000-0000-0000-0000-000000000000}'), false, false, TextAsGuid('{00000000-0000-0000-0000-000000000000}'), TextAsGuid('{BBEDB5F4-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{64E0B5DC-D83A-ED11-BBAA-6045BD8E54CB}'), '', false, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, Enum::"Order Tracking Policy"::None, false, '');
        CreateItem('WRB-1003', '', 'Whole Roasted Beans, Arabica/Robusta, Mixed', 'WHOLE ROASTED BEANS, ARABICA/ROBUSTA, MIXED', '', 'PCS', 0, Enum::"Item Type"::Inventory, 'RESALE', '', '', true, 0, 0, 0, Enum::"Item Price Profit Calculation"::"Profit=Price-Cost", 0, Enum::"Costing Method"::FIFO, 0, 0, 0, 0, true, true, '', '', TextAsDateFormula(''), 0, 0, 0, '', 0, 0, '', 0, 0, 0, 0, '', '', '', 0, '', 0, 0, 0, false, '', CreateDateTime(20221018D, 114258T), 20221018D, 114258T, false, '', 'RETAIL', '', false, '', '', 'RETAIL', Enum::"Reserve Method"::Optional, '', '', 0, 0, 0, '', false, Enum::"Assembly Policy"::"Assemble-to-Stock", '', '', 0, 0, '', 0D, 0, 0, 0, false, 0, 0, 0, 0, 0, TextAsDateFormula(''), Enum::"Flushing Method"::Manual, Enum::"Replenishment System"::Purchase, 1, 'PCS', 'PCS', TextAsDateFormula(''), Enum::"Reordering Policy"::" ", false, Enum::"Manufacturing Policy"::"Make-to-Stock", TextAsDateFormula(''), TextAsDateFormula(''), TextAsDateFormula(''), 0, 0, '', 'BEANS', false, '', '', '', '', TextAsDateFormula(''), '', '', '', '', '', 0D, true, 0D, 0D, TextAsGuid('{A8DEB5DC-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{00000000-0000-0000-0000-000000000000}'), false, false, TextAsGuid('{00000000-0000-0000-0000-000000000000}'), TextAsGuid('{BBEDB5F4-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{64E0B5DC-D83A-ED11-BBAA-6045BD8E54CB}'), '', false, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, Enum::"Order Tracking Policy"::None, false, '');
        CreateItem('WRB-1004', '', 'Whole Roasted Beans, Robusta, Vietnam', 'WHOLE ROASTED BEANS, ROBUSTA, VIETNAM', '', 'PCS', 0, Enum::"Item Type"::Inventory, 'RESALE', '', '', true, 0, 0, 0, Enum::"Item Price Profit Calculation"::"Profit=Price-Cost", 0, Enum::"Costing Method"::FIFO, 0, 0, 0, 0, true, true, '', '', TextAsDateFormula(''), 0, 0, 0, '', 0, 0, '', 0, 0, 0, 0, '', '', '', 0, '', 0, 0, 0, false, '', CreateDateTime(20221018D, 114302T), 20221018D, 114302T, false, '', 'RETAIL', '', false, '', '', 'RETAIL', Enum::"Reserve Method"::Optional, '', '', 0, 0, 0, '', false, Enum::"Assembly Policy"::"Assemble-to-Stock", '', '', 0, 0, '', 0D, 0, 0, 0, false, 0, 0, 0, 0, 0, TextAsDateFormula(''), Enum::"Flushing Method"::Manual, Enum::"Replenishment System"::Purchase, 1, 'PCS', 'PCS', TextAsDateFormula(''), Enum::"Reordering Policy"::" ", false, Enum::"Manufacturing Policy"::"Make-to-Stock", TextAsDateFormula(''), TextAsDateFormula(''), TextAsDateFormula(''), 0, 0, '', 'BEANS', false, '', '', '', '', TextAsDateFormula(''), '', '', '', '', '', 0D, true, 0D, 0D, TextAsGuid('{A8DEB5DC-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{00000000-0000-0000-0000-000000000000}'), false, false, TextAsGuid('{00000000-0000-0000-0000-000000000000}'), TextAsGuid('{BBEDB5F4-D83A-ED11-BBAA-6045BD8E54CB}'), TextAsGuid('{64E0B5DC-D83A-ED11-BBAA-6045BD8E54CB}'), '', false, '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, Enum::"Order Tracking Policy"::None, false, '');

        CreateUnitofMeasure('BAG', 'Large Bag', 'BAG', '', CreateDateTime(20221018D, 093256T), false);
        CreateUnitofMeasure('PALLET', 'Pallet', 'PF', '', 0DT, false);
        CreateUnitofMeasure('PCS', 'Piece', 'EA', '', 0DT, false);

        CreateItemUnitofMeasure('WRB-1000', 'BAG', 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1000', 'PALLET', 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1000', 'PCS', 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1001', 'BAG', 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1001', 'PALLET', 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1001', 'PCS', 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1002', 'BAG', 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1002', 'PALLET', 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1002', 'PCS', 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1003', 'BAG', 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1003', 'PALLET', 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1003', 'PCS', 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1004', 'BAG', 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1004', 'PALLET', 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1004', 'PCS', 1, 0, 8, 4, 5, 160, 0.75);
    end;
}
