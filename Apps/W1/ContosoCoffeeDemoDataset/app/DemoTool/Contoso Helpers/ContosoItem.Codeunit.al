codeunit 5143 "Contoso Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Item" = rim,
        tabledata "Item Category" = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Item Tracking Code" = rim,
        tabledata "Item Variant" = rim,
        tabledata "Item Journal Batch" = rim,
        tabledata "Item Journal Line" = rim,
        tabledata "Item Reference" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertItem(ItemNo: Code[20]; Type: Enum "Item Type"; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: code[10]; ItemCategoryCode: Code[20]; ItemTrackingCode: Code[10]; NetWeight: Decimal; PutAwayTemplateCode: Code[10]; ServiceItemGroupCode: Code[10];
        CostingLotSize: Decimal; ReplenishmentSystem: Enum "Replenishment System"; RoundPrecision: Decimal; VendorNo: Code[20]; VendorItemNo: Text[20]; FlushingMethod: Enum "Flushing Method"; ReorderingPolicy: Enum "Reordering Policy"; IncludeInventory: Boolean; TimeBucket: Code[20]; Picture: Codeunit "Temp Blob"; GTIN: Code[14])
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
        Item.Validate(Type, Type);

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

    procedure InsertServiceItem(ItemNo: Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGroup: Code[20]; TaxGroup: Code[20]; BaseUnitOfMeasure: Code[10]; ItemCategoryCode: Code[20]; Picture: Codeunit "Temp Blob")
    begin
        InsertItem(ItemNo, Enum::"Item Type"::Service, Description, UnitPrice, LastDirectCost, GenProdPostingGroup, TaxGroup, '', Enum::"Costing Method"::FIFO, BaseUnitOfMeasure, ItemCategoryCode, '', 0, '', '', 0, Enum::"Replenishment System"::Purchase, 0, '', '', Enum::"Flushing Method"::Manual, Enum::"Reordering Policy"::" ", false, '', Picture, '');
    end;

    procedure InsertItemCategory(ItemCategoryCode: Code[20]; Description: Text[100]; ParentCategory: Code[20])
    var
        ItemCategory: Record "Item Category";
        Exists: Boolean;
    begin
        if ItemCategory.Get(ItemCategoryCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemCategory.Validate(Code, ItemCategoryCode);
        ItemCategory.Validate(Description, Description);
        ItemCategory.Validate("Parent Category", ParentCategory);

        if Exists then
            ItemCategory.Modify(true)
        else
            ItemCategory.Insert(true);
    end;

    procedure InsertItemTrackingCode(TrackingCode: Code[10]; Description: Text[50]; SNSpecificTracking: Boolean; LotSpecificTracking: Boolean; ManWarrantyDateEntryReqd: Boolean; ManExpirDateEntryReqd: Boolean)
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

    procedure InsertItemJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Item Journal Template Type"; Recurring: Boolean; SourceCode: Code[10])
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
        ItemJournalTemplate.Validate(Type, Type);
        ItemJournalTemplate.Validate(Recurring, Recurring);

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

        if Exists then
            ItemReference.Modify(true)
        else
            ItemReference.Insert(true);
    end;
}