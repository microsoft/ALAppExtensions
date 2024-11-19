codeunit 14608 "Create Currency Ex. Rate IS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoCurrency: Codeunit "Contoso Currency";
        CreateCurrency: Codeunit "Create Currency";
        CurrentDate: Date;
    begin
        CurrentDate := CalcDate('<CY - 3Y + 1D>', WorkDate());
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 10048.8869, 10048.8869);

        CurrentDate := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 10756.9348, 10756.9348);

        CurrentDate := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 10331.5823, 10331.5823);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record "Currency Exchange Rate")
    var
        Currency: Codeunit "Create Currency";
        CurrentDate: Date;
    begin
        CurrentDate := CalcDate('<CY - 3Y + 1D>', WorkDate());
        if Rec."Currency Code" = Currency.AED() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2348.9576, 2348.9576);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3446.7168, 3446.7168);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3176.4114, 3176.4114);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3949.182, 3949.182);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2463.9694, 2463.9694);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4340.1448, 4340.1448);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 5460.8031, 5460.8031);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 267.4838, 267.4838);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1173.71, 1173.71);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 112.7213, 112.7213);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 64.8936, 64.8936);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3028.7587, 3028.7587);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 880.6346, 880.6346);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1187.4307, 1187.4307);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 36.9237, 36.9237);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.97, 0.97);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 144.7184, 144.7184);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 58.3334, 58.3334);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 108.7924, 108.7924);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 827.3941, 827.3941);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 724.5312, 724.5312);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1814.7904, 1814.7904);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 3.7373, 3.7373);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 68.3346, 68.3346);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1031.1042, 1031.1042);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2917.1388, 2917.1388);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 134.6245, 134.6245);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1668.0767, 1668.0767);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 2.6385, 2.6385);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 102.738, 102.738);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 236.1505, 236.1505);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1836.9735, 1836.9735);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1275.2359, 1275.2359);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 994.4845, 994.4845);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3974.2994, 3974.2994);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 948.0482, 948.0482);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 154.695, 154.695);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6331.919, 6331.919);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 34.2908, 34.2908);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 5360.0284, 5360.0284);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.9869, 4.9869);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6519.9591, 6519.9591);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 48.2395, 48.2395);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 24071.1489, 24071.1489);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 73.4038, 73.4038);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 802.935, 802.935);

        CurrentDate := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 8756.1113, 8756.1113);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1021.7146, 1021.7146);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6602.3535, 6602.3535);

        CurrentDate := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 8749.7733, 8749.7733);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1052.8179, 1052.8179);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6814.4429, 6814.4429);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}