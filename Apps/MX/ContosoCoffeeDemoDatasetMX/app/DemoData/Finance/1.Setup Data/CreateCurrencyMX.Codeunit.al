codeunit 14109 "Create Currency MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        if Rec.Code = CreateCurrency.GBP() then
            Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
    end;
}