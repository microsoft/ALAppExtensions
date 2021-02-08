report 31069 "Create Stockkeeping Unit CZL"
{
    AdditionalSearchTerms = 'create sku';
    ApplicationArea = Warehouse;
    Caption = 'Create Stockkeeping Unit';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Inventory Posting Group", "Location Filter", "Variant Filter";

            trigger OnAfterGetRecord()
            var
                ItemVariant: Record "Item Variant";
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeItemOnAfterGetRecord(Item, IsHandled);
                if IsHandled then
                    CurrReport.Skip();

                if SaveFilters then begin
                    LocationFilter := CopyStr(GetFilter("Location Filter"), 1, MaxStrLen(LocationFilter));
                    VariantFilter := CopyStr(GetFilter("Variant Filter"), 1, MaxStrLen(VariantFilter));
                    SaveFilters := false;
                end;
                SetFilter("Location Filter", LocationFilter);
                SetFilter("Variant Filter", VariantFilter);

                Location.SetFilter(Code, GetFilter("Location Filter"));

                OnItemOnAfterGetRecordOnAfterSetLocationFilter(Location, Item);

                if ReplacePreviousSKUs then begin
                    StockkeepingUnit.Reset();
                    StockkeepingUnit.SetRange("Item No.", "No.");
                    if GetFilter("Variant Filter") <> '' then
                        StockkeepingUnit.SetFilter("Variant Code", GetFilter("Variant Filter"));
                    if GetFilter("Location Filter") <> '' then
                        StockkeepingUnit.SetFilter("Location Code", GetFilter("Location Filter"));
                    StockkeepingUnit.DeleteAll();
                end;

                DialogWindow.Update(1, "No.");
                ItemVariant.SetRange("Item No.", "No.");
                ItemVariant.SetFilter(Code, GetFilter("Variant Filter"));
                case true of
                    (SKUCreationMethod = SKUCreationMethod::Location) or
                    ((SKUCreationMethod = SKUCreationMethod::"Location & Variant") and
                     (not ItemVariant.Find('-'))):
                        if Location.FindSet() then
                            repeat
                                DialogWindow.Update(2, Location.Code);
                                SetRange("Location Filter", Location.Code);
                                CreateSKUIfRequired(Item, Location.Code, '');
                            until Location.Next() = 0;
                    (SKUCreationMethod = SKUCreationMethod::Variant) or
                    ((SKUCreationMethod = SKUCreationMethod::"Location & Variant") and
                     (not Location.Find('-'))):
                        if ItemVariant.FindSet() then
                            repeat
                                DialogWindow.Update(3, ItemVariant.Code);
                                SetRange("Variant Filter", ItemVariant.Code);
                                CreateSKUIfRequired(Item, '', ItemVariant.Code);
                            until ItemVariant.Next() = 0;
                    (SKUCreationMethod = SKUCreationMethod::"Location & Variant"):
                        if Location.FindSet() then
                            repeat
                                DialogWindow.Update(2, Location.Code);
                                SetRange("Location Filter", Location.Code);
                                if ItemVariant.FindSet() then
                                    repeat
                                        DialogWindow.Update(3, ItemVariant.Code);
                                        SetRange("Variant Filter", ItemVariant.Code);
                                        CreateSKUIfRequired(Item, Location.Code, ItemVariant.Code);
                                    until ItemVariant.Next() = 0;
                            until Location.Next() = 0;
                end;
            end;

            trigger OnPostDataItem()
            begin
                DialogWindow.Close();
                Message(CreatedFromTemplateMsg, SKUCounter);
            end;

            trigger OnPreDataItem()
            begin
                OnBeforeItemOnPreDataItem(Item);

                Location.SetRange("Use As In-Transit", false);

                DialogWindow.Open(
                  ItemTxt +
                  LocationTxt +
                  VariantTxt);

                SaveFilters := true;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(OnlyForSKUTemplatesCZL; OnlyForSKUTemplates)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Only For SKU Templates';
                        ToolTip = 'Specifies if the stockkeeping unit will be created only for the stockkeeping unit templates.';
                    }
                    field(SKUCreationMethodCZL; SKUCreationMethod)
                    {
                        ApplicationArea = Location;
                        Caption = 'Create Per';
                        OptionCaption = 'Location,Variant,Location & Variant';
                        ToolTip = 'Specifies if you want to create stockkeeping units per location or per variant or per location combined with variant.';
                    }
                    field(ItemInInventoryOnlyCZL; ItemInInventoryOnly)
                    {
                        ApplicationArea = Location;
                        Caption = 'Item In Inventory Only';
                        ToolTip = 'Specifies if you only want the batch job to create stockkeeping units for items that are in your inventory (that is, for items where the value in the Inventory field is above 0).';
                    }
                    field(ReplacePreviousSKUsCZL; ReplacePreviousSKUs)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Replace Previous SKUs';
                        ToolTip = 'Specifies if you want the batch job to replace all previous created stockkeeping units on the items you have included in the batch job.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            ReplacePreviousSKUs := false;
            OnlyForSKUTemplates := true;
        end;
    }
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
        Location: Record Location;
        ItemTxt: Label 'Item No.       #1##################\', Comment = '%1 = Item No.';
        LocationTxt: Label 'Location Code  #2########\', Comment = '%1 = Location Code';
        VariantTxt: Label 'Variant Code   #3########\', Comment = '%1 = Variant Code';
        DialogWindow: Dialog;
        SKUCreationMethod: Option Location,Variant,"Location & Variant";
        ItemInInventoryOnly: Boolean;
        ReplacePreviousSKUs: Boolean;
        SaveFilters: Boolean;
        LocationFilter: Code[1024];
        VariantFilter: Code[1024];
        OnlyForSKUTemplates: Boolean;
        SKUCounter: Integer;
        CreatedFromTemplateMsg: Label '%1 Stockkeeping Units was created.', Comment = '%1 = Count of created SKUs';

    procedure CreateSKUIfRequired(var Item2: Record Item; LocationCode: Code[10]; VariantCode: Code[10])
    var
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        ConfigTemplateHeader: Record "Config. Template Header";
        TempSkipField: Record "Field" temporary;
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        StockkeepingUnitRecRef: RecordRef;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSKU(Item2, LocationCode, VariantCode, ItemInInventoryOnly, IsHandled);
        if IsHandled then
            exit;
        if OnlyForSKUTemplates and (not StockkeepingUnitTemplateCZL.Get(Item2."Item Category Code", LocationCode)) then
            exit;

        Item2.CalcFields(Inventory);
        if (ItemInInventoryOnly and (Item2.Inventory > 0)) or
           (not ItemInInventoryOnly)
        then
            if not StockkeepingUnit.Get(LocationCode, Item2."No.", VariantCode) then begin
                CreateSKU(Item2, LocationCode, VariantCode);

                // update created SKU according to the Configuration Template
                if StockkeepingUnitTemplateCZL.Get(Item2."Item Category Code", StockkeepingUnit."Location Code") then
                    if StockkeepingUnitTemplateCZL."Configuration Template Code" <> '' then begin
                        ConfigTemplateHeader.Get(StockkeepingUnitTemplateCZL."Configuration Template Code");
                        ConfigTemplateHeader.TestField("Table ID", Database::"Stockkeeping Unit");
                        ConfigTemplateHeader.TestField(Enabled, true);
                        StockkeepingUnitRecRef.GetTable(StockkeepingUnit);
                        ConfigTemplateManagement.InsertTemplate(StockkeepingUnitRecRef, ConfigTemplateHeader, false, TempSkipField);
                        StockkeepingUnitRecRef.Modify();
                    end;
                SKUCounter += 1;
            end;
    end;

    procedure InitializeRequest(CreatePerOption: Option Location,Variant,"Location & Variant"; NewItemInInventoryOnly: Boolean; NewReplacePreviousSKUs: Boolean)
    begin
        SKUCreationMethod := CreatePerOption;
        ItemInInventoryOnly := NewItemInInventoryOnly;
        ReplacePreviousSKUs := NewReplacePreviousSKUs;
    end;

    procedure InitializeRequest(CreatePerOption: Option Location,Variant,"Location & Variant"; NewItemInInventoryOnly: Boolean; NewReplacePreviousSKUs: Boolean; NewOnlyForSKUTemplates: Boolean)
    begin
        InitializeRequest(CreatePerOption, NewItemInInventoryOnly, NewReplacePreviousSKUs);
        OnlyForSKUTemplates := NewOnlyForSKUTemplates;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSKU(var Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; ItemInInventoryOnly: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStockkeepingUnitInsert(var StockkeepingUnit: Record "Stockkeeping Unit"; Item: Record Item)
    begin
    end;

    procedure CreateSKU(var Item2: Record Item; LocationCode: Code[10]; VariantCode: Code[10])
    begin
        StockkeepingUnit.Init();
        StockkeepingUnit."Item No." := Item2."No.";
        StockkeepingUnit."Location Code" := LocationCode;
        StockkeepingUnit."Variant Code" := VariantCode;
        StockkeepingUnit.CopyFromItem(Item2);
        StockkeepingUnit."Last Date Modified" := WorkDate();
        StockkeepingUnit."Special Equipment Code" := Item2."Special Equipment Code";
        StockkeepingUnit."Put-away Template Code" := Item2."Put-away Template Code";
        StockkeepingUnit.SetHideValidationDialog(true);
        StockkeepingUnit.Validate("Phys Invt Counting Period Code", Item2."Phys Invt Counting Period Code");
        StockkeepingUnit."Put-away Unit of Measure Code" := Item2."Put-away Unit of Measure Code";
        StockkeepingUnit."Use Cross-Docking" := Item2."Use Cross-Docking";
        OnBeforeStockkeepingUnitInsert(StockkeepingUnit, Item2);
        StockkeepingUnit.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemOnPreDataItem(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemOnAfterGetRecord(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemOnAfterGetRecordOnAfterSetLocationFilter(var Location: Record Location; var Item: Record Item)
    begin
    end;
}
