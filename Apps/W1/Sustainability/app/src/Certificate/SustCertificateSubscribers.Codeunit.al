namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;

codeunit 6250 "Sust. Certificate Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure OnAfterValidateItemTypeEvent(var Rec: Record Item; var xRec: Record Item)
    begin
        if (xRec.Type = xRec.Type::Inventory) and (Rec.Type <> Rec.Type::Inventory) then
            Rec.TestField("Sust. Cert. No.", '');
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
}