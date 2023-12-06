// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Inventory.Item;
using System.IO;
using System.Reflection;

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
            DataItemTableView = sorting("No.");
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

                WindowDialog.Update(1, "No.");
                ItemVariant.SetRange("Item No.", "No.");
                ItemVariant.SetFilter(Code, GetFilter("Variant Filter"));
                case true of
                    (SKUCreationMethod = SKUCreationMethod::Location) or
                    ((SKUCreationMethod = SKUCreationMethod::"Location & Variant") and
                     (not ItemVariant.Find('-'))):
                        if Location.FindSet() then
                            repeat
                                WindowDialog.Update(2, Location.Code);
                                SetRange("Location Filter", Location.Code);
                                CreateSKUIfRequired(Item, Location.Code, '');
                            until Location.Next() = 0;
                    (SKUCreationMethod = SKUCreationMethod::Variant) or
                    ((SKUCreationMethod = SKUCreationMethod::"Location & Variant") and
                     (not Location.Find('-'))):
                        if ItemVariant.FindSet() then
                            repeat
                                WindowDialog.Update(3, ItemVariant.Code);
                                SetRange("Variant Filter", ItemVariant.Code);
                                CreateSKUIfRequired(Item, '', ItemVariant.Code);
                            until ItemVariant.Next() = 0;
                    (SKUCreationMethod = SKUCreationMethod::"Location & Variant"):
                        if Location.FindSet() then
                            repeat
                                WindowDialog.Update(2, Location.Code);
                                SetRange("Location Filter", Location.Code);
                                if ItemVariant.FindSet() then
                                    repeat
                                        WindowDialog.Update(3, ItemVariant.Code);
                                        SetRange("Variant Filter", ItemVariant.Code);
                                        CreateSKUIfRequired(Item, Location.Code, ItemVariant.Code);
                                    until ItemVariant.Next() = 0;
                            until Location.Next() = 0;
                end;
            end;

            trigger OnPostDataItem()
            begin
                WindowDialog.Close();
                Message(CreatedFromTemplateMsg, SKUCounter);
            end;

            trigger OnPreDataItem()
            begin
                OnBeforeItemOnPreDataItem(Item);

                Location.SetRange("Use As In-Transit", false);

                WindowDialog.Open(
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
        WindowDialog: Dialog;
        SKUCreationMethod: Option Location,Variant,"Location & Variant";
        ItemInInventoryOnly: Boolean;
        ReplacePreviousSKUs: Boolean;
        SaveFilters: Boolean;
        LocationFilter: Code[1024];
        VariantFilter: Code[1024];
        OnlyForSKUTemplates: Boolean;
        SKUCounter: Integer;
        CreatedFromTemplateMsg: Label '%1 Stockkeeping Units was created.', Comment = '%1 = Count of created SKUs';

    procedure CreateSKUIfRequired(var StockkeepingUnitItem: Record Item; LocationCode: Code[10]; VariantCode: Code[10])
    var
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        ConfigTemplateHeader: Record "Config. Template Header";
        TempSkipField: Record "Field" temporary;
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        StockkeepingUnitRecordRef: RecordRef;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSKU(StockkeepingUnitItem, LocationCode, VariantCode, ItemInInventoryOnly, IsHandled);
        if IsHandled then
            exit;
        if OnlyForSKUTemplates and (not StockkeepingUnitTemplateCZL.Get(StockkeepingUnitItem."Item Category Code", LocationCode)) then
            exit;

        StockkeepingUnitItem.CalcFields(Inventory);
        if (ItemInInventoryOnly and (StockkeepingUnitItem.Inventory > 0)) or
           (not ItemInInventoryOnly)
        then
            if not StockkeepingUnit.Get(LocationCode, StockkeepingUnitItem."No.", VariantCode) then begin
                CreateSKU(StockkeepingUnitItem, LocationCode, VariantCode);

                // update created SKU according to the Configuration Template
                if StockkeepingUnitTemplateCZL.Get(StockkeepingUnitItem."Item Category Code", StockkeepingUnit."Location Code") then
                    if StockkeepingUnitTemplateCZL."Configuration Template Code" <> '' then begin
                        ConfigTemplateHeader.Get(StockkeepingUnitTemplateCZL."Configuration Template Code");
                        ConfigTemplateHeader.TestField("Table ID", Database::"Stockkeeping Unit");
                        ConfigTemplateHeader.TestField(Enabled, true);
                        StockkeepingUnitRecordRef.GetTable(StockkeepingUnit);
                        ConfigTemplateManagement.InsertTemplate(StockkeepingUnitRecordRef, ConfigTemplateHeader, false, TempSkipField);
                        StockkeepingUnitRecordRef.Modify();
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

    procedure CreateSKU(var StockkeepingUnitItem: Record Item; LocationCode: Code[10]; VariantCode: Code[10])
    begin
        StockkeepingUnit.Init();
        StockkeepingUnit."Item No." := StockkeepingUnitItem."No.";
        StockkeepingUnit."Location Code" := LocationCode;
        StockkeepingUnit."Variant Code" := VariantCode;
        StockkeepingUnit.CopyFromItem(StockkeepingUnitItem);
        StockkeepingUnit."Last Date Modified" := WorkDate();
        StockkeepingUnit."Special Equipment Code" := StockkeepingUnitItem."Special Equipment Code";
        StockkeepingUnit."Put-away Template Code" := StockkeepingUnitItem."Put-away Template Code";
        StockkeepingUnit.SetHideValidationDialog(true);
        StockkeepingUnit.Validate("Phys Invt Counting Period Code", StockkeepingUnitItem."Phys Invt Counting Period Code");
        StockkeepingUnit."Put-away Unit of Measure Code" := StockkeepingUnitItem."Put-away Unit of Measure Code";
        StockkeepingUnit."Use Cross-Docking" := StockkeepingUnitItem."Use Cross-Docking";
        OnBeforeStockkeepingUnitInsert(StockkeepingUnit, StockkeepingUnitItem);
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
