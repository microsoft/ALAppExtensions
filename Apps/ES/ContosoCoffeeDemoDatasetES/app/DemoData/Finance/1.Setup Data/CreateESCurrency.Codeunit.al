codeunit 10831 "Create ES Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
        CreateCurrency: Codeunit "Create Currency";
    begin
        UpdateCurrency(CreateCurrency.AED(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.AUD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.BGN(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.BND(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.BRL(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.CAD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.CHF(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.CZK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.DKK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.DZD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.EUR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.FJD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.GBP(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.HKD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.HRK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.HUF(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.IDR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.INR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.ISK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.JPY(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.KES(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.MAD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.MXN(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.MYR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.MZN(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.NGN(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.NOK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.NZD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.PHP(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.PLN(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.RON(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.RSD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.RUB(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.SAR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.SBD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.SEK(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.SGD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.SZL(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.THB(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.TND(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.TOP(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.TRY(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.UGX(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.USD(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.VUV(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.WST(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.XPF(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
        UpdateCurrency(CreateCurrency.ZAR(), CreateESGLAccount.ExchangeGainPosting(), CreateESGLAccount.RealizedLossesOnExchange());
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