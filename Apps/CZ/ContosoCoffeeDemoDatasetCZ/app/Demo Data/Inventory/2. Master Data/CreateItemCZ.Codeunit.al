codeunit 31338 "Create Item CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record Item)
    var
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
    begin
        ValidateRecordFields(Rec,
            Rec."Unit Cost" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor(),
            Rec."Unit Price" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor());
    end;

    local procedure ValidateRecordFields(var Item: Record Item; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        Item.Validate("Unit Cost", UnitCost);
        Item.Validate("Unit Price", UnitPrice);
    end;
}