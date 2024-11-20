codeunit 27045 "Create CA Curr. Exch. Rate"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Currency Exchange Rate")
    var
        Currency: Codeunit "Create Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());

        case Rec."Currency Code" of
            Currency.EUR():
                if Rec."Starting Date" = date then
                    ValidateRecordFields(Rec, 1, 1, 1.495, 1.495);
            Currency.USD():
                if Rec."Starting Date" = date then
                    ValidateRecordFields(Rec, 100, 100, 150.2072, 150.2072);
            Currency.MXN():
                if Rec."Starting Date" = date then
                    ValidateRecordFields(Rec, 100, 100, 16.6918, 16.6918);
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