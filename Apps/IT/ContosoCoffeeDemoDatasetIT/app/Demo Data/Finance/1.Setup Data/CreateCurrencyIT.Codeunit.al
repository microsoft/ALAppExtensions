codeunit 12242 "Create Currency IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Record Currency;
        CreateGLAccount: Codeunit "Create G/L Account";
        ContosoCurrency: Codeunit "Contoso Currency";
        CreateCurrency: Codeunit "Create Currency";
    begin
        ContosoCurrency.SetOverwriteData(true);
        ContosoCurrency.InsertCurrency(CreateCurrency.GBP(), '826', BritishPoundLbl, '', CreateGLAccount.RealizedFXGains(), '', CreateGLAccount.RealizedFXLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.00001, false, '2:2', '2:5');
        ContosoCurrency.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record Currency)
    begin
        ValidateRecordFields(Rec);
    end;

    local procedure ValidateRecordFields(var Currency: Record Currency)
    begin
        Currency.Validate("Unrealized Gains Acc.", '');
        Currency.Validate("Unrealized Losses Acc.", '');
    end;

    var
        BritishpoundLbl: Label 'Pound Sterling';
}