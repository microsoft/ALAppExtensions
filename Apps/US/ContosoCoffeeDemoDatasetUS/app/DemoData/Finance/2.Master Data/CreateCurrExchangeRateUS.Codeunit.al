codeunit 11478 "Create Curr Exchange Rate US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Codeunit "Create Currency";
        ContosoCurrency: Codeunit "Contoso Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 2Y + 1D>', WorkDate());

        ContosoCurrency.SetOverwriteData(true);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.EUR(), date, 1, 1, 0.9952, 0.9952);
        ContosoCurrency.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Currency Exchange Rate")
    var
        Currency: Codeunit "Create Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 2Y + 1D>', WorkDate());

        case Rec."Currency Code" of
            Currency.CAD():
                if Rec."Starting Date" = date then
                    ValidateRecordFields(Rec, 100, 100, 66.5604, 66.5604);
            Currency.MXN():
                if Rec."Starting Date" = date then
                    ValidateRecordFields(Rec, 100, 100, 11.1114, 11.1114);
        end;
    end;

    local procedure ValidateRecordFields(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}