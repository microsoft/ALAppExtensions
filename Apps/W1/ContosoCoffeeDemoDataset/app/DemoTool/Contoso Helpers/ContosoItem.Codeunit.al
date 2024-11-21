codeunit 5143 "Contoso Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Item" = rim,
        tabledata "Item Category" = rim,
        tabledata "Item Charge" = rim,
        tabledata "Item Unit of Measure" = r,
        tabledata "Item Tracking Code" = rim,
        tabledata "Item Variant" = rim,
        tabledata "Assembly Setup" = rim,
        tabledata "Item Journal Template" = rim,
        tabledata "Item Journal Batch" = rim,
        tabledata "Item Journal Line" = rim,
        tabledata "Item Reference" = rim,
        tabledata "Inventory Setup" = rim,
        tabledata "Item Substitution" = rim,
        tabledata "Item Attribute" = rim,
        tabledata "Item Attribute Value" = rim,
        tabledata "Item Attribute Value Mapping" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertItem(ItemNo: Code[20]; ItemType: Enum "Item Type"; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: code[10]; ItemCategoryCode: Code[20]; ItemTrackingCode: Code[10]; NetWeight: Decimal; PutAwayTemplateCode: Code[10]; ServiceItemGroupCode: Code[10];
        CostingLotSize: Decimal; ReplenishmentSystem: Enum "Replenishment System"; RoundPrecision: Decimal; VendorNo: Code[20]; VendorItemNo: Text[20]; FlushingMethod: Enum "Flushing Method"; ReorderingPolicy: Enum "Reordering Policy"; IncludeInventory: Boolean; TimeBucket: Code[20]; Picture: Codeunit "Temp Blob"; GTIN: Code[14])
    begin
        InsertItem(ItemNo, ItemType, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, CostingMethod, BaseUnitOfMeasure, ItemCategoryCode, ItemTrackingCode, NetWeight, PutAwayTemplateCode, ServiceItemGroupCode, CostingLotSize, ReplenishmentSystem, RoundPrecision, VendorNo, VendorItemNo, FlushingMethod, ReorderingPolicy, IncludeInventory, TimeBucket, Picture, GTIN, 0, 0, 0, 0, '');
    end;

    procedure InsertItem(ItemNo: Code[20]; ItemType: Enum "Item Type"; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: code[10]; ItemCategoryCode: Code[20]; ItemTrackingCode: Code[10]; NetWeight: Decimal; PutAwayTemplateCode: Code[10]; ServiceItemGroupCode: Code[10];
        CostingLotSize: Decimal; ReplenishmentSystem: Enum "Replenishment System"; RoundPrecision: Decimal; VendorNo: Code[20]; VendorItemNo: Text[20]; FlushingMethod: Enum "Flushing Method"; ReorderingPolicy: Enum "Reordering Policy"; IncludeInventory: Boolean; TimeBucket: Code[20]; Picture: Codeunit "Temp Blob"; GTIN: Code[14]; UnitCost: Decimal; ReorderPoint: Decimal; GrossWeight: Decimal; UnitVolume: Decimal; TariffNo: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Item: Record Item;
        Exists: Boolean;
        ObjInStream: InStream;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if Item.Get(ItemNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Item.Validate("No.", ItemNo);
        Item.Validate(Description, Description);

        if not Exists then
            Item.Validate(Type, ItemType);

        Item.Validate("Inventory Posting Group", InventoryPostingGroup);
        Item.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            if GenProdPostingGroup <> '' then
                Item.Validate("Tax Group Code", TaxGroup);

        Item.Validate("Last Direct Cost", LastDirectCost);
        if Item."Costing Method" = "Costing Method"::Standard then
            Item.Validate("Standard Cost", Item."Last Direct Cost");
        Item.Validate("Unit Cost", Item."Last Direct Cost");

        Item.Validate("Unit Price", UnitPrice);

        Item.Validate("Item Category Code", ItemCategoryCode);
        if ItemTrackingCode <> '' then begin
            Item.Validate("Item Tracking Code", ItemTrackingCode);
            Item.Validate("Costing Method", CostingMethod);
        end;

        Item.Validate("Lot Size", CostingLotSize);
        Item.Validate("Replenishment System", ReplenishmentSystem);
        if RoundPrecision <> 0 then
            Item.Validate("Rounding Precision", RoundPrecision);

        Item.Validate("Vendor No.", VendorNo);
        Item.Validate("Vendor Item No.", VendorItemNo);
        Item.Validate("Flushing Method", FlushingMethod);

        Item.Validate("Safety Lead Time");
        Item.Validate("Reordering Policy", ReorderingPolicy);
        Item.Validate("Include Inventory", IncludeInventory);
        if TimeBucket <> '' then begin
            Evaluate(Item."Time Bucket", TimeBucket);
            Item.Validate("Time Bucket");
        end;

        Item.Validate("Net Weight", NetWeight);
        Item.Validate("Put-away Template Code", PutAwayTemplateCode);
        Item.Validate("Service Item Group", ServiceItemGroupCode);
        Item.Validate(GTIN, GTIN);
        Item.Validate("Unit Cost", UnitCost);
        Item.validate("Reorder Point", ReorderPoint);
        Item.Validate("Gross Weight", GrossWeight);
        Item.Validate("Unit Volume", UnitVolume);
        Item.Validate("Tariff No.", TariffNo);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, Description);
        end;

        if Exists then
            Item.Modify(true)
        else
            Item.Insert(true);

        // this needs to be done after the item is inserted
        // when validate, we create the default Item Unit of Measure which requires the item to be inserted
        if BaseUnitOfMeasure <> '' then begin
            Item.Validate("Base Unit of Measure", BaseUnitOfMeasure);
            Item.Validate("Sales Unit of Measure", BaseUnitOfMeasure);
            Item.Validate("Purch. Unit of Measure", BaseUnitOfMeasure);
            Item.Modify(true);
        end;
    end;

    procedure InsertInventoryItem(ItemNo: Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: Code[10]; ItemCategoryCode: Code[20]; ItemTrackingCode: Code[10]; NetWeight: Decimal; PutAwayTemplateCode: Code[10]; Picture: Codeunit "Temp Blob"; GTIN: Code[14])
    begin
        InsertItem(ItemNo, Enum::"Item Type"::Inventory, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, CostingMethod, BaseUnitOfMeasure, ItemCategoryCode, ItemTrackingCode, NetWeight, PutAwayTemplateCode, '', 0, Enum::"Replenishment System"::Purchase, 0, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::" ", false, '', Picture, GTIN);
    end;

    procedure InsertInventoryItem(ItemNo: Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: Code[10]; ItemCategoryCode: Code[20]; NetWeight: Decimal; ServiceItemGroupCode: Code[10]; Picture: Codeunit "Temp Blob")
    begin
        InsertItem(ItemNo, Enum::"Item Type"::Inventory, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, CostingMethod, BaseUnitOfMeasure, ItemCategoryCode, '', NetWeight, '', ServiceItemGroupCode, 0, Enum::"Replenishment System"::Purchase, 0, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::" ", false, '', Picture, '');
    end;

    procedure InsertInventoryItem(ItemNo: Code[20]; Description: Text[100]; BaseUnitofMeasure: Code[10]; InventoryPostingGroup: Code[20]; UnitPrice: Decimal; UnitCost: Decimal; VendorNo: Code[20]; ReorderPoint: Decimal; GrossWeight: Decimal; NetWeight: Decimal; UnitVolume: Decimal; TariffNo: Code[20]; GenProdPostingGroup: Code[20]; Picture: Codeunit "Temp Blob"; TaxGroupCode: Code[20]; VATProdPostingGroup: Code[20]; SalesUnitofMeasure: Code[10]; PurchUnitofMeasure: Code[10]; ItemCategoryCode: Code[20])
    begin
        InsertItem(ItemNo, Enum::"Item Type"::Inventory, Description, UnitPrice, 0, GenProdPostingGroup, TaxGroupCode, InventoryPostingGroup, Enum::"Costing Method"::"FIFO", BaseUnitOfMeasure, ItemCategoryCode, '', NetWeight, '', '', 0, Enum::"Replenishment System"::Purchase, 0, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::" ", false, '', Picture, '', UnitCost, ReorderPoint, GrossWeight, UnitVolume, TariffNo);
    end;

    procedure InsertServiceItem(ItemNo: Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; BaseUnitOfMeasure: Code[10]; ItemCategoryCode: Code[20]; Picture: Codeunit "Temp Blob")
    begin
        InsertItem(ItemNo, Enum::"Item Type"::Service, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, '', Enum::"Costing Method"::FIFO, BaseUnitOfMeasure, ItemCategoryCode, '', 0, '', '', 0, Enum::"Replenishment System"::Purchase, 0, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::" ", false, '', Picture, '');
    end;

    procedure InsertItemCategory(ItemCategoryCode: Code[20]; Description: Text[100]; ParentCategory: Code[20])
    begin
        InsertItemCategory(ItemCategoryCode, ParentCategory, Description, 0, 0);
    end;

    procedure InsertItemCategory(Code: Code[20]; ParentCategory: Code[20]; Description: Text[100]; Indentation: Integer; PresentationOrder: Integer)
    var
        ItemCategory: Record "Item Category";
        Exists: Boolean;
    begin
        if ItemCategory.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemCategory.Validate(Code, Code);
        ItemCategory.Validate("Parent Category", ParentCategory);
        ItemCategory.Validate(Description, Description);
        ItemCategory.Validate(Indentation, Indentation);
        ItemCategory.Validate("Presentation Order", PresentationOrder);

        if Exists then
            ItemCategory.Modify(true)
        else
            ItemCategory.Insert(true);
    end;

    procedure InsertItemTrackingCode(TrackingCode: Code[10]; Description: Text[50]; SNSpecificTracking: Boolean; LotSpecificTracking: Boolean; ManWarrantyDateEntryReqd: Boolean; ManExpirDateEntryReqd: Boolean)
    begin
        InsertItemTrackingCode(TrackingCode, Description, SNSpecificTracking, LotSpecificTracking, ManWarrantyDateEntryReqd, ManExpirDateEntryReqd, false, false);
    end;

    procedure InsertItemTrackingCode(TrackingCode: Code[10]; Description: Text[50]; SNSpecificTracking: Boolean; LotSpecificTracking: Boolean; ManWarrantyDateEntryReqd: Boolean; ManExpirDateEntryReqd: Boolean; SNSalesInboundTracking: Boolean; SNSalesOutboundTracking: Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
        Exists: Boolean;
    begin
        if ItemTrackingCode.Get(TrackingCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemTrackingCode.Validate(Code, TrackingCode);
        ItemTrackingCode.Validate(Description, Description);
        ItemTrackingCode.Validate("SN Specific Tracking", SNSpecificTracking);
        ItemTrackingCode.Validate("Lot Specific Tracking", LotSpecificTracking);
        ItemTrackingCode.Validate("Use Expiration Dates", true);
        ItemTrackingCode.Validate("Man. Warranty Date Entry Reqd.", ManWarrantyDateEntryReqd);
        ItemTrackingCode.Validate("Man. Expir. Date Entry Reqd.", ManExpirDateEntryReqd);

        if not SNSpecificTracking then begin
            ItemTrackingCode.Validate("SN Sales Inbound Tracking", SNSalesInboundTracking);
            ItemTrackingCode.Validate("SN Sales Outbound Tracking", SNSalesOutboundTracking);
        end;

        if Exists then
            ItemTrackingCode.Modify(true)
        else
            ItemTrackingCode.Insert(true);
    end;

    procedure InsertItemVariant(ItemNo: Code[20]; VariantCode: Code[10]; Description: Text[30])
    var
        ItemVariant: Record "Item Variant";
        Exists: Boolean;
    begin
        if ItemVariant.Get(ItemNo, VariantCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemVariant.Validate(Code, VariantCode);
        ItemVariant.Validate("Item No.", ItemNo);
        ItemVariant.Validate(Description, Description);

        if Exists then
            ItemVariant.Modify(true)
        else
            ItemVariant.Insert(true);
    end;

    procedure InsertItemJournalBatch(TemplateName: Code[10]; Name: Text[30]; Description: Text[100])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        Exists: Boolean;
    begin
        if ItemJournalBatch.Get(TemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemJournalBatch.Validate("Journal Template Name", TemplateName);
        ItemJournalBatch.Validate(Name, Name);
        ItemJournalBatch.Validate(Description, Description);

        if Exists then
            ItemJournalBatch.Modify(true)
        else
            ItemJournalBatch.Insert(true);
    end;

    procedure InsertItemJournalTemplate(Name: Code[10]; Description: Text[80]; ItemJournalTemplateType: Enum "Item Journal Template Type"; Recurring: Boolean; SourceCode: Code[10])
    begin
        InsertItemJournalTemplate(Name, Description, ItemJournalTemplateType, Recurring, SourceCode, 0, 0, 0, '', 0);
    end;

    procedure InsertItemJournalTemplate(Name: Code[10]; Description: Text[80]; ItemJournalTemplateType: Enum "Item Journal Template Type"; Recurring: Boolean; SourceCode: Code[10]; TestReportID: Integer; PageID: Integer; PostingReportID: Integer; NoSeries: Code[20]; WhseRegisterReportID: Integer)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        Exists: Boolean;
    begin
        if ItemJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemJournalTemplate.Validate(Name, Name);
        ItemJournalTemplate.Validate(Description, Description);
        ItemJournalTemplate.Validate(Type, ItemJournalTemplateType);
        ItemJournalTemplate.Validate(Recurring, Recurring);
        ItemJournalTemplate.Validate("Test Report ID", TestReportID);
        ItemJournalTemplate.Validate("Page ID", PageID);
        ItemJournalTemplate.Validate("Posting Report ID", PostingReportID);
        ItemJournalTemplate.Validate("No. Series", NoSeries);
        ItemJournalTemplate.Validate("Whse. Register Report ID", WhseRegisterReportID);

        if Exists then
            ItemJournalTemplate.Modify(true)
        else
            ItemJournalTemplate.Insert(true);

        if SourceCode <> '' then begin
            ItemJournalTemplate.Validate("Source Code", SourceCode);
            ItemJournalTemplate.Modify(true);
        end;
    end;

    procedure InsertItemJournalLine(TemplateName: Code[10]; BatchName: Code[10]; ItemNo: Code[20]; DocumentNo: Code[20]; EntryType: Enum "Item Ledger Entry Type"; Quantity: Decimal; LocationCode: Code[10]; PostingDate: Date)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeries: Codeunit "No. Series";
    begin
        ItemJournalLine.Validate("Journal Template Name", TemplateName);
        ItemJournalLine.Validate("Journal Batch Name", BatchName);
        ItemJournalLine.Validate("Line No.", GetNextItemJournalLineNo(TemplateName, BatchName));
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate("Entry Type", EntryType);
        if DocumentNo = '' then begin
            ItemJnlBatch.Get(TemplateName, BatchName);
            if ItemJnlBatch."No. Series" <> '' then
                DocumentNo := NoSeries.PeekNextNo(ItemJnlBatch."No. Series", PostingDate)
            else
                DocumentNo := ItemJnlBatch.Name;
        end;
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Validate(Quantity, Quantity);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Validate("Posting Date", PostingDate);
        ItemJournalLine.Insert(true);
    end;

    local procedure GetNextItemJournalLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        ItemJournalLine.SetCurrentKey("Line No.");

        if ItemJournalLine.FindLast() then
            exit(ItemJournalLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertItemReference(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[50])
    begin
        InsertItemReference(ItemNo, VariantCode, UnitOfMeasureCode, ReferenceType, ReferenceTypeNo, ReferenceNo, '');
    end;

    procedure InsertItemReference(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[50]; Description: Text[100])
    var
        ItemReference: Record "Item Reference";
        Exists: Boolean;
    begin
        if ItemReference.Get(ItemNo, VariantCode, UnitOfMeasureCode, ReferenceType, ReferenceTypeNo, ReferenceNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemReference.Validate("Item No.", ItemNo);
        ItemReference.Validate("Variant Code", VariantCode);
        ItemReference.Validate("Unit of Measure", UnitOfMeasureCode);
        ItemReference.Validate("Reference Type", ReferenceType);
        ItemReference.Validate("Reference Type No.", ReferenceTypeNo);
        ItemReference.Validate("Reference No.", ReferenceNo);
        ItemReference.Validate(Description, Description);

        if Exists then
            ItemReference.Modify(true)
        else
            ItemReference.Insert(true);
    end;

    procedure InsertAssemblySetup(StockoutWarning: Boolean; AssemblyOrderNos: Code[20]; AssemblyQuoteNos: Code[20]; BlanketAssemblyOrderNos: Code[20]; PostedAssemblyOrderNos: Code[20]; CopyCommentswhenPosting: Boolean; CreateMovementsAutomatically: Boolean)
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        if not AssemblySetup.Get() then
            AssemblySetup.Insert();

        AssemblySetup.Validate("Stockout Warning", StockoutWarning);
        AssemblySetup.Validate("Assembly Order Nos.", AssemblyOrderNos);
        AssemblySetup.Validate("Assembly Quote Nos.", AssemblyQuoteNos);
        AssemblySetup.Validate("Blanket Assembly Order Nos.", BlanketAssemblyOrderNos);
        AssemblySetup.Validate("Posted Assembly Order Nos.", PostedAssemblyOrderNos);
        AssemblySetup.Validate("Copy Comments when Posting", CopyCommentswhenPosting);
        AssemblySetup.Validate("Create Movements Automatically", CreateMovementsAutomatically);
        AssemblySetup.Modify(true);
    end;

    procedure InsertInventorySetup(AutomaticCostPosting: Boolean; ItemNos: Code[20]; AutomaticCostAdjustment: Enum "Automatic Cost Adjustment Type"; TransferOrderNos: Code[20]; PostedTransferShptNos: Code[20]; PostedTransferRcptNos: Code[20]; NonstockItemNos: Code[20];
        InvtReceiptNos: Code[20]; PostedInvtReceiptNos: Code[20]; InvtShipmentNos: Code[20]; PostedInvtShipmentNos: Code[20]; PostedDirectTransNos: Code[20]; PhysInvtOrderNos: Code[20]; PostedPhysInvtOrderNos: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if not InventorySetup.Get() then
            InventorySetup.Insert();

        InventorySetup.Validate("Automatic Cost Posting", AutomaticCostPosting);
        InventorySetup.Validate("Item Nos.", ItemNos);
        InventorySetup.Validate("Automatic Cost Adjustment", AutomaticCostAdjustment);
        InventorySetup.Validate("Transfer Order Nos.", TransferOrderNos);
        InventorySetup.Validate("Posted Transfer Shpt. Nos.", PostedTransferShptNos);
        InventorySetup.Validate("Posted Transfer Rcpt. Nos.", PostedTransferRcptNos);
        InventorySetup.Validate("Nonstock Item Nos.", NonstockItemNos);
        InventorySetup.Validate("Invt. Receipt Nos.", InvtReceiptNos);
        InventorySetup.Validate("Posted Invt. Receipt Nos.", PostedInvtReceiptNos);
        InventorySetup.Validate("Invt. Shipment Nos.", InvtShipmentNos);
        InventorySetup.Validate("Posted Invt. Shipment Nos.", PostedInvtShipmentNos);
        InventorySetup.Validate("Posted Direct Trans. Nos.", PostedDirectTransNos);
        InventorySetup.Validate("Phys. Invt. Order Nos.", PhysInvtOrderNos);
        InventorySetup.Validate("Posted Phys. Invt. Order Nos.", PostedPhysInvtOrderNos);
        InventorySetup.Modify(true)
    end;

    procedure InsertItemAttribute(Name: Text[250]; Blocked: Boolean; AttributeType: Option; UnitofMeasure: Text[30]): Record "Item Attribute"
    var
        ItemAttribute: Record "Item Attribute";
    begin
        ItemAttribute.Validate(Name, Name);
        ItemAttribute.Insert(true);

        ItemAttribute.Validate(Blocked, Blocked);
        ItemAttribute.Validate(Type, AttributeType);
        ItemAttribute.Validate("Unit of Measure", UnitofMeasure);
        ItemAttribute.Modify(true);

        exit(ItemAttribute);
    end;

    procedure InsertItemAttributeValue(ItemAttribute: Record "Item Attribute"; Value: Text[250]; NumericValue: Decimal): Record "Item Attribute Value"
    var
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        ItemAttributeValue.Validate("Attribute ID", ItemAttribute.ID);
        ItemAttributeValue.Validate(Value, Value);
        ItemAttributeValue.Insert(true);

        ItemAttributeValue.Validate("Numeric Value", NumericValue);
        ItemAttributeValue.Modify(true);

        exit(ItemAttributeValue);
    end;

    procedure InsertItemAttributeValueMapping(TableID: Integer; No: Code[20]; ItemAttributeID: Integer; ItemAttributeValueID: Integer)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        Exists: Boolean;
    begin
        if ItemAttributeValueMapping.Get(TableID, No, ItemAttributeID) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemAttributeValueMapping.Validate("Table ID", TableID);
        ItemAttributeValueMapping.Validate("No.", No);
        ItemAttributeValueMapping.Validate("Item Attribute ID", ItemAttributeID);
        ItemAttributeValueMapping.Validate("Item Attribute Value ID", ItemAttributeValueID);


        if Exists then
            ItemAttributeValueMapping.Modify(true)
        else
            ItemAttributeValueMapping.Insert(true);
    end;

    procedure InsertItemCharge(No: Code[20]; Description: Text[100]; GenProdPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; SearchDescription: Code[100])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ItemCharge: Record "Item Charge";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ItemCharge.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemCharge.Validate("No.", No);
        ItemCharge.Validate(Description, Description);
        ItemCharge.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        ItemCharge.Validate("Search Description", SearchDescription);

        if Exists then
            ItemCharge.Modify(true)
        else
            ItemCharge.Insert(true);
    end;

    procedure InsertItemSubstitution(ItemSubsitutionType: Enum "Item Substitution Type"; No: Code[20]; VariantCode: Code[10]; SubstituteType: Enum "Item Substitute Type"; SubstituteNo: Code[20]; SubstituteVariantCode: Code[10]; Description: Text[100]; Interchangeable: Boolean)
    var
        ItemSubstitution: Record "Item Substitution";
        Exists: Boolean;
    begin
        if ItemSubstitution.Get(ItemSubsitutionType, No, VariantCode, SubstituteType, SubstituteNo, SubstituteVariantCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;
        ItemSubstitution.Validate(Type, ItemSubsitutionType);
        ItemSubstitution.Validate("No.", No);
        ItemSubstitution.Validate("Variant Code", VariantCode);
        ItemSubstitution.Validate("Substitute Type", SubstituteType);
        ItemSubstitution.Validate("Substitute No.", SubstituteNo);
        ItemSubstitution.Validate("Substitute Variant Code", SubstituteVariantCode);
        ItemSubstitution.Validate(Description, Description);
        ItemSubstitution.Validate(Interchangeable, Interchangeable);

        if Exists then
            ItemSubstitution.Modify(true)
        else
            ItemSubstitution.Insert(true);
    end;
}