codeunit 11180 "Create Currency AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreateCurrency: Codeunit "Create Currency";
    begin
        UpdateCurrency(CreateCurrency.AED(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.AUD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.BGN(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.BND(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.BRL(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.CAD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.CHF(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.CZK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.DKK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.DZD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.EUR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.FJD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.GBP(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.HKD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.HRK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.HUF(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.IDR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.INR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.ISK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.JPY(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.KES(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.MAD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.MXN(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.MYR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.MZN(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.NGN(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.NOK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.NZD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.PHP(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.PLN(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.RON(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.RSD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.RUB(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.SAR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.SBD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.SEK(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.SGD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.SZL(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.THB(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.TND(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.TOP(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.TRY(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.UGX(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.USD(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.VUV(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.WST(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.XPF(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
        UpdateCurrency(CreateCurrency.ZAR(), CreateATGLAccount.FCYRealizedExchangeGains(), CreateATGLAccount.FCYRealizedExchangeLosses());
    end;

    local procedure UpdateCurrency(CurrecnyCode: Code[10]; RealizedGainsAcc: Code[20]; RealizedLossesAcc: Code[20])
    var
        Currency: Record Currency;
        CreateCurrency: Codeunit "Create Currency";
    begin
        Currency.Get(CurrecnyCode);
        if Currency.Code = CreateCurrency.GBP() then
            Currency.Validate("Unit-Amount Rounding Precision", 0.00001);

        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
        Currency.Modify(true);
    end;
}