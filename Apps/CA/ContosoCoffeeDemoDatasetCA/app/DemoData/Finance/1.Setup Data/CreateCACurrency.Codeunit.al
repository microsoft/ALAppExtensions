codeunit 27047 "Create CA Currency"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCurrency.USD():
                ValidateRecordFields(Rec, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXLosses());
            CreateCurrency.EUR():
                ValidateRecordFields(Rec, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXLosses());
            CreateCurrency.MXN():
                ValidateRecordFields(Rec, CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXLosses());
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record "Currency"; UnrealizedGainsAcc: Code[20]; UnrealizedLossesAcc: Code[20])
    begin
        Currency.Validate("Unrealized Gains Acc.", UnrealizedGainsAcc);
        Currency.Validate("Unrealized Losses Acc.", UnrealizedLossesAcc);
    end;
}