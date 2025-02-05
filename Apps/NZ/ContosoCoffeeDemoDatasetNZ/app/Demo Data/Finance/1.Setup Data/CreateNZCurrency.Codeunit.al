codeunit 17145 "Create NZ Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrency(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        if Rec.Code = CreateCurrency.GBP() then
            Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
    end;
}