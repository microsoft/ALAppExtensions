codeunit 17167 "Create Currency Ex. Rate AU"
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
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 291.524, 291.524);

        CurrentDate := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 312.0648, 312.0648);

        CurrentDate := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 299.7251, 299.7251);
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
                ValidateCurrencyExchRate(Rec, 100, 100, 68.1446, 68.1446);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 293.66, 293.66);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 92.1495, 92.1495);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 114.568, 114.568);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 71.4812, 71.4812);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 125.9101, 125.9101);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 158.421, 158.421);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 7.7599, 7.7599);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 34.05, 34.05);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3.2701, 3.2701);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 1.8826, 1.8826);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 87.866, 87.866);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 25.5477, 25.5477);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 34.448, 34.448);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.0712, 1.0712);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.0281, 0.0281);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.1984, 4.1984);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.9011, 2.9011);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.6923, 1.6923);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3.1561, 3.1561);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 24.0032, 24.0032);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 21.0191, 21.0191);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 52.6481, 52.6481);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.1084, 0.1084);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.9824, 1.9824);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 29.9129, 29.9129);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 84.6279, 84.6279);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3.9055, 3.9055);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 48.3919, 48.3919);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.0765, 0.0765);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.9805, 2.9805);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 6.8509, 6.8509);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 53.2917, 53.2917);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 36.9953, 36.9953);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 28.8506, 28.8506);

        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 115.2967, 115.2967);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 27.5034, 27.5034);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.4878, 4.4878);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 183.6926, 183.6926);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 0.9948, 0.9948);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 155.4975, 155.4975);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.1447, 0.1447);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 189.1478, 189.1478);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.3995, 1.3995);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 698.3178, 698.3178);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.1295, 2.1295);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 23.2936, 23.2936);

        CurrentDate := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 254.0198, 254.0198);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 29.6405, 29.6405);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 191.5381, 191.5381);

        CurrentDate := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 253.8359, 253.8359);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 30.5429, 30.5429);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 197.6909, 197.6909);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}