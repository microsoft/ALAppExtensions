codeunit 11630 "Create CH Currency Ex. Rate"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCurrency: Codeunit "Contoso Currency";
        CreateCurrency: Codeunit "Create Currency";
        date: Date;
    begin
        date := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 196.9537, 196.9537);
        date := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 189.1657, 189.1657);
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 183.9897, 183.9897);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record "Currency Exchange Rate")
    var
        Currency: Codeunit "Create Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        if Rec."Currency Code" = Currency.AED() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 43.0082, 43.0082);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 63.1075, 63.1075);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 58.1584, 58.1584);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 72.3074, 72.3074);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 45.114, 45.114);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 79.4657, 79.4657);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4.8975, 4.8975);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 21.49, 21.49);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.0639, 2.0639);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.1882, 1.1882);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 55.4549, 55.4549);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 16.1239, 16.1239);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 21.7412, 21.7412);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.6761, 0.6761);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0178, 0.0178);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.6497, 2.6497);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.8309, 1.8309);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.0681, 1.0681);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.9919, 1.9919);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 15.1491, 15.1491);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 13.2658, 13.2658);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 33.2278, 33.2278);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0684, 0.0684);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.2512, 1.2512);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 18.879, 18.879);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 53.4112, 53.4112);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.4649, 2.4649);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 30.5416, 30.5416);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0483, 0.0483);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.8811, 1.8811);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4.3238, 4.3238);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 33.634, 33.634);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 23.3489, 23.3489);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 18.2085, 18.2085);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 72.7673, 72.7673);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 17.3583, 17.3583);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.8324, 2.8324);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 115.934, 115.934);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.6278, 0.6278);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 98.1392, 98.1392);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0913, 0.0913);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 119.377, 119.377);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.8832, 0.8832);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 440.7298, 440.7298);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.344, 1.344);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 14.7013, 14.7013);

        date := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 160.3197, 160.3197);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 18.707, 18.707);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 120.8855, 120.8855);

        date := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 160.2037, 160.2037);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 19.2765, 19.2765);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 124.7688, 124.7688);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}