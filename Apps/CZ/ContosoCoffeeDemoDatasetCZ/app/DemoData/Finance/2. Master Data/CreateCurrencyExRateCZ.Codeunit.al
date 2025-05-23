codeunit 31337 "Create Currency Ex. Rate CZ"
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
        ContosoCurrency.SetOverwriteData(true);
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.GBP(), date, 1, 1, 1, 1);
        ContosoCurrency.SetOverwriteData(false);
    end;

    procedure DeleteLocalCurrencyExchangeRate()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        CurrencyExchangeRate.SetRange("Currency Code", GeneralLedgerSetup."LCY Code");
        CurrencyExchangeRate.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record "Currency Exchange Rate")
    begin
        Rec."Relational Exch. Rate Amount" := (Rec."Relational Exch. Rate Amount" / GetLocalCurrencyFactor()) / Rec."Exchange Rate Amount";
        Rec."Relational Adjmt Exch Rate Amt" := (Rec."Relational Adjmt Exch Rate Amt" / GetLocalCurrencyFactor()) / Rec."Exchange Rate Amount";
        Rec."Exchange Rate Amount" := 1;
        Rec."Adjustment Exch. Rate Amount" := 1;
        if Rec."Relational Exch. Rate Amount" / Rec."Exchange Rate Amount" < 1 then begin
            Rec."Exchange Rate Amount" := 100;
            Rec."Relational Exch. Rate Amount" := Rec."Relational Exch. Rate Amount" * 100;
        end;
        if Rec."Relational Adjmt Exch Rate Amt" / Rec."Adjustment Exch. Rate Amount" < 1 then begin
            Rec."Adjustment Exch. Rate Amount" := 100;
            Rec."Relational Adjmt Exch Rate Amt" := Rec."Relational Adjmt Exch Rate Amt" * 100;
        end;

        ValidateCurrencyExchRate(
            Rec, Rec."Exchange Rate Amount", Rec."Adjustment Exch. Rate Amount",
            Rec."Relational Exch. Rate Amount", Rec."Relational Adjmt Exch Rate Amt");
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;

    internal procedure GetLocalCurrencyFactor(): Decimal
    begin
        exit(0.026618);
    end;
}