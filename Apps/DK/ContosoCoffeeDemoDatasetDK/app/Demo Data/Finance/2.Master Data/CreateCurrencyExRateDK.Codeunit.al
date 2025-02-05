codeunit 13743 "Create Currency Ex. Rate DK"
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
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 856.1644, 856.1644);

        CurrentDate := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 916.49, 916.49);

        CurrentDate := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 880.25, 880.25);
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
                ValidateCurrencyExchRate(Rec, 100, 100, 200.131, 200.131);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 293.66, 293.66);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 270.63, 270.63);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 336.47, 336.47);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 209.93, 209.93);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 369.78, 369.78);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 465.26, 465.26);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 22.7896, 22.7896);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 9.6039, 9.6039);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 9.6039, 9.6039);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 5.5289, 5.5289);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 258.05, 258.05);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 75.03, 75.03);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 101.169, 101.169);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3.1459, 3.1459);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.0826, 0.0826);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 12.33, 12.33);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 8.52, 8.52);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.97, 4.97);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 9.2691, 9.2691);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 70.4939, 70.4939);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 61.73, 61.73);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 154.62, 154.62);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.3184, 0.3184);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 5.8221, 5.8221);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 87.85, 87.85);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 248.54, 248.54);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 11.47, 11.47);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 142.12, 142.12);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.2248, 0.2248);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 8.7533, 8.7533);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 20.12, 20.12);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 156.51, 156.51);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 108.65, 108.65);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 87.05, 87.05);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 89.7, 89.7);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 84.73, 84.73);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 338.61, 338.61);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 80.7736, 80.7736);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 13.18, 13.18);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 539.479, 539.479);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 2.9216, 2.9216);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 456.674, 456.674);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.4249, 0.4249);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 555.5, 555.5);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.11, 4.11);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2050.86, 2050.86);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6.254, 6.254);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 68.41, 68.41);

        CurrentDate := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 746.02, 746.02);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 87.05, 87.05);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 562.52, 562.52);

        CurrentDate := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 745.48, 745.48);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 89.7, 89.7);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 580.59, 580.59);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}