codeunit 11522 "Create Currency Ex. Rate NL"
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
                ValidateCurrencyExchRate(Rec, 100, 100, 36.2037, 36.2037);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 53.1231, 53.1231);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 48.957, 48.957);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 60.8674, 60.8674);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 37.9763, 37.9763);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 66.8932, 66.8932);
        if Rec."Currency Code" = Currency.CHF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 84.1655, 84.1655);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 4.1226, 4.1226);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 18.09, 18.09);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.7373, 1.7373);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 64.8936, 64.8936);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 46.6812, 46.6812);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 13.5729, 13.5729);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 18.3015, 18.3015);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.5691, 0.5691);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.0149, 0.0149);
        if Rec."Currency Code" = Currency.INR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.2305, 2.2305);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.5413, 1.5413);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.8991, 0.8991);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.6768, 1.6768);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 12.7523, 12.7523);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 11.167, 11.167);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 27.9708, 27.9708);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.0576, 0.0576);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.0532, 1.0532);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 15.8921, 15.8921);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 44.9609, 44.9609);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.0749, 2.0749);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 25.7095, 25.7095);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1000, 1000, 0.0407, 0.0407);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.5835, 1.5835);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 3.6397, 3.6397);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 28.3127, 28.3127);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 19.6548, 19.6548);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 15.3277, 15.3277);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 61.2545, 61.2545);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 14.6119, 14.6119);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 2.3843, 2.3843);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 97.5918, 97.5918);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 1, 1, 0.5285, 0.5285);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 82.6123, 82.6123);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.0769, 0.0769);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 100.49, 100.49);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 0.7435, 0.7435);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 371.0006, 371.0006);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 1.1313, 1.1313);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = CurrentDate then
                ValidateCurrencyExchRate(Rec, 100, 100, 12.3754, 12.3754);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}