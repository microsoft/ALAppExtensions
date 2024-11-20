codeunit 11154 "Create Currency Ex. Rate AT"
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
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 154.8801, 154.8801);

        CurrentDate := DMY2Date(2, 1, 2013);
        ContosoCurrency.SetOverwriteData(true);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 165.793, 165.793);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.SEK(), CurrentDate, 100, 100, 15.7473, 15.7473);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.USD(), CurrentDate, 100, 100, 101.7599, 101.7599);

        CurrentDate := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), CurrentDate, 100, 100, 159.2372, 159.2372);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.SEK(), CurrentDate, 100, 100, 16.2267, 16.2267);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.USD(), CurrentDate, 100, 100, 105.0287, 105.0287);
        ContosoCurrency.SetOverwriteData(false);
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
                ValidateCurrencyExchRate(Rec, 36.2037, 36.2037);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 53.1231, 53.1231);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 48.957, 48.957);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 60.8674, 60.8674);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 37.9763, 37.9763);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 66.8932, 66.8932);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 84.1655, 84.1655);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4.1226, 4.1226);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 18.09, 18.09);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.7373, 1.7373);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 46.6812, 46.6812);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 13.5729, 13.5729);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 18.3015, 18.3015);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.5691, 0.5691);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0149, 0.0149);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.2305, 2.2305);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.5413, 1.5413);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.8991, 0.8991);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.6768, 1.6768);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 12.7523, 12.7523);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 11.167, 11.167);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 27.9708, 27.9708);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0576, 0.0576);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.0532, 1.0532);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 15.8921, 15.8921);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 44.9609, 44.9609);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.0749, 2.0749);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 25.7095, 25.7095);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0407, 0.0407);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.5835, 1.5835);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 3.6397, 3.6397);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 28.3127, 28.3127);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 19.6548, 19.6548);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 15.3277, 15.3277);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 61.2545, 61.2545);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 14.6119, 14.6119);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.3843, 2.3843);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 97.5918, 97.5918);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.5285, 0.5285);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 82.6123, 82.6123);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.0769, 0.0769);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 100.49, 100.49);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.7435, 0.7435);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 371.0006, 371.0006);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.1313, 1.1313);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 12.3754, 12.3754);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}