codeunit 11377 "Create DE Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Record Currency;
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
        CreateCurrency: Codeunit "Create Currency";
        ContosoCurrency: Codeunit "Contoso Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        UpdateCurrency(CreateCurrency.AED(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.AUD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.BGN(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.BND(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.BRL(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.CAD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.CHF(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.CZK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.DKK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.DZD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.EUR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.FJD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.HKD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.HRK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.HUF(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.IDR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.INR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.ISK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.JPY(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.KES(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.MAD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.MXN(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.MYR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.MZN(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.NGN(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.NOK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.NZD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.PHP(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.PLN(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.RON(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.RSD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.RUB(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.SAR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.SBD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.SEK(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.SGD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.SZL(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.THB(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.TND(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.TOP(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.TRY(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.UGX(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.USD(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.VUV(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.WST(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.XPF(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        UpdateCurrency(CreateCurrency.ZAR(), CreateDEGLAccount.CurrencyGains(), CreateDEGLAccount.CurrencyLosses());
        ContosoCurrency.SetOverwriteData(true);
        ContosoCurrency.InsertCurrency(CreateCurrency.GBP(), '826', BritishPoundLbl, CreateGLAccount.UnrealizedFXGains(), CreateDEGLAccount.CurrencyGains(), CreateGLAccount.UnrealizedFXLosses(), CreateDEGLAccount.CurrencyLosses(), 0.01, Currency."Invoice Rounding Type"::Nearest, 0.01, 0.00001, false, '2:2', '2:5');
        ContosoCurrency.SetOverwriteData(false);
    end;

    local procedure UpdateCurrency(CurrecnyCode: Code[10]; RealizedGainsAcc: Code[20]; RealizedLossesAcc: Code[20])
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrecnyCode);
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
        Currency.Modify(true);
    end;

    var
        BritishpoundLbl: Label 'Pound Sterling', MaxLength = 30;
}