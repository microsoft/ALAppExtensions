codeunit 14101 "Create Currency Ex. Rate MX"
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
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 1484.7138, 1484.7138);
        date := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 1426.005, 1426.005);
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 1386.9863, 1386.9863);
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
                ValidateCurrencyExchRate(Rec, 100, 100, 324.2122, 324.2122);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 475.7292, 475.7292);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 438.4206, 438.4206);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 545.0814, 545.0814);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 340.0866, 340.0866);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 599.0436, 599.0436);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 753.7212, 753.7212);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 36.9192, 36.9192);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 162, 162);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 15.5582, 15.5582);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 8.9569, 8.9569);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 418.041, 418.041);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 121.5486, 121.5486);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 163.8938, 163.8938);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 5.0964, 5.0964);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.1339, 0.1339);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 19.9746, 19.9746);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 13.8024, 13.8024);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 8.0514, 8.0514);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 15.0159, 15.0159);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 114.2001, 114.2001);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 250.4844, 250.4844);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.5158, 0.5158);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 9.4318, 9.4318);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 142.317, 142.317);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 402.6348, 402.6348);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 18.5814, 18.5814);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 230.2344, 230.2344);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.3642, 0.3642);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 14.1803, 14.1803);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 32.5944, 32.5944);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 253.5462, 253.5462);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 176.013, 176.013);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 137.2626, 137.2626);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 548.5482, 548.5482);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 130.8533, 130.8533);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 21.3516, 21.3516);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 873.956, 873.956);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 4.7329, 4.7329);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 739.8119, 739.8119);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.6883, 0.6883);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 899.91, 899.91);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6.6582, 6.6582);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3322.3932, 3322.3932);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 10.1315, 10.1315);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 110.8242, 110.8242);

        CurrentDate := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 141.021, 141.021);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 911.2824, 911.2824);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1208.5524, 1208.5524);

        CurrentDate := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 145.314, 145.314);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 940.5558, 940.5558);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1207.6776, 1207.6776);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}