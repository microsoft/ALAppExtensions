namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;

codeunit 6250 "Sust. Certificate Subscribers"
{
    var
        ConfirmationForClearEmissionInfoQst: Label 'Changing the Replenishment System to %1 will clear sustainability emission value. Do you want to continue?', Comment = '%1 = Replenishment System';

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnAfterValidateItemTypeEvent(var Rec: Record Item; var xRec: Record Item)
    begin
        if (xRec.Type = xRec.Type::Inventory) and (Rec.Type <> Rec.Type::Inventory) then
            Rec.TestField("Sust. Cert. No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterValidateItemCategoryCode', '', false, false)]
    local procedure OnAfterValidateItemCategoryCode(var Item: Record Item; xItem: Record Item)
    begin
        if Item."Replenishment System" = Item."Replenishment System"::Purchase then
            UpdateDefaultSustAccountOnItem(Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', "Replenishment System", false, false)]
    local procedure OnAfterValidateItemReplenishmentSystemEvent(var Rec: Record Item; var xRec: Record Item)
    begin
        ClearDefaultSustAccountForNonPurchaseItem(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidatePurchaseLineNoEvent(var Rec: Record "Purchase Line")
    var
        Item: Record Item;
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;

        if Item.Get(Rec."No.") then
            if Item."GHG Credit" then
                Item.TestField("Carbon Credit Per UOM");
    end;

    local procedure UpdateDefaultSustAccountOnItem(var Item: Record Item)
    var
        ItemCategory: Record "Item Category";
    begin
        if not ItemCategory.Get(Item."Item Category Code") then
            exit;

        if ItemCategory."Default Sust. Account" = '' then
            exit;

        Item.Validate("Default Sust. Account", ItemCategory."Default Sust. Account");
    end;

    local procedure ClearDefaultSustAccountForNonPurchaseItem(var Item: Record Item)
    begin
        if (Item."Replenishment System" = Item."Replenishment System"::Purchase) then
            exit;

        if (Item."Default Sust. Account" = '') then
            exit;

        if Confirm(StrSubstNo(ConfirmationForClearEmissionInfoQst, Item."Replenishment System"), false) then
            Item.Validate("Default Sust. Account", '')
        else
            Error('');
    end;
}