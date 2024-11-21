codeunit 11486 "Create Currency US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        case Rec.Code of
            CreateCurrency.CAD():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
            CreateCurrency.EUR():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
            CreateCurrency.MXN():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record "Currency"; RealizedGainsAcc: Code[20]; RealizedLossesAcc: Code[20])
    begin
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
    end;
}