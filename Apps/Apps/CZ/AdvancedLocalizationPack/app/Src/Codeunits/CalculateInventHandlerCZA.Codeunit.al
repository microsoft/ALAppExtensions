// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Journal;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;

codeunit 31446 "Calculate Invent. Handler CZA"
{
    SingleInstance = true;

    var
        Location: Record Location;
        ItemsWithoutChange, UseItemDimensions, IsItemWithoutChange : Boolean;
        VariantCode: Code[10];

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnBeforeOnPreReportCZA', '', false, false)]
    local procedure GetRequestPageFieldsOnBeforeOnPreReportCZA(ItemsWithoutChangeCZA: Boolean; UseItemDimensionsCZA: Boolean)
    begin
        ItemsWithoutChange := ItemsWithoutChangeCZA;
        UseItemDimensions := UseItemDimensionsCZA;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnAfterItemOnPreDataItem', '', false, false)]
    local procedure CheckFiltersOnAfterItemOnPreDataItem(var Item: Record Item)
    var
        ItemFilterErr: Label 'When used %1 without change, %2 must be set to one value.', Comment = '%1 = TableCaption, %2 = FieldCaption';
    begin
        if not ItemsWithoutChange then
            exit;

        if Item.GetFilter("Location Filter") <> '' then begin
            Item.Copyfilter("Location Filter", Location.Code);
            if Location.Count() <> 1 then
                Error(ItemFilterErr, Item.TableCaption(), Item.FieldCaption("Location Filter"))
            else
                Location.FindFirst();
        end;
        if Item.GetFilter("Variant Filter") <> '' then
            if Item.GetRangeMin("Variant Filter") <> Item.GetRangeMax("Variant Filter") then
                Error(ItemFilterErr, Item.TableCaption(), Item.FieldCaption("Variant Filter"))
            else
                VariantCode := Item.GetRangeMin("Variant Filter");
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnBeforeItemOnAfterGetRecord', '', false, false)]
    local procedure CreateLineItemWithoutChangeOnBeforeItemOnAfterGetRecord(sender: Report "Calculate Inventory"; var Item: Record Item)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not ItemsWithoutChange then
            exit;

        ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", ItemLedgEntry."Variant Code");
        Item.CopyFilter("Location Filter", ItemLedgEntry."Location Code");
        Item.CopyFilter("Global Dimension 1 Filter", ItemLedgEntry."Global Dimension 1 Code");
        Item.CopyFilter("Global Dimension 2 Filter", ItemLedgEntry."Global Dimension 2 Code");
        if ItemLedgEntry.IsEmpty() then begin
            IsItemWithoutChange := true;
            sender.GetLocation(Location.Code);
            sender.InsertItemJnlLine(Item."No.", VariantCode, 0, '', 0, 0);
        end else
            IsItemWithoutChange := false;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnInsertItemJnlLineOnAfterCalcShouldInsertItemJnlLine', '', false, false)]
    local procedure CreateLineItemWithoutChangeOnInsertItemJnlLineOnAfterCalcShouldInsertItemJnlLine(var ShouldInsertItemJnlLine: Boolean)
    begin
        ShouldInsertItemJnlLine := ShouldInsertItemJnlLine or IsItemWithoutChange;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory", 'OnAfterFunctionInsertItemJnlLine', '', false, false)]
    local procedure UseItemDimensionsOnAfterFunctionInsertItemJnlLineMyProcedure(var ItemJournalLine: Record "Item Journal Line")
    begin
        if IsItemWithoutChange or UseItemDimensions then begin
            ItemJournalLine.CreateDimFromDefaultDim(ItemJournalLine.FieldNo("Item No."));
            ItemJournalLine.Modify();
        end;
    end;
}
