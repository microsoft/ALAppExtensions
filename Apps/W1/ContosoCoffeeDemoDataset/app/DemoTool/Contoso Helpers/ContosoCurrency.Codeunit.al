codeunit 5587 "Contoso Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Currency = rim,
                tabledata "Currency Exchange Rate" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCurrency(Code: Code[10]; ISONumericCode: Code[3]; Description: Text[30]; UnrealizedGainsAcc: Code[20]; RealizedGainsAcc: Code[20]; UnrealizedLossesAcc: Code[20]; RealizedLossesAcc: Code[20]; InvoiceRoundingPrecision: Decimal; InvoiceRoundingType: Option Nearest,Up,Down; AmountRoundingPrecision: Decimal; UnitAmountRoundingPrecision: Decimal; EMUCurrency: Boolean; AmountDecimalPlaces: Text[5]; UnitAmountDecimalPlaces: Text[5])
    var
        Currency: Record "Currency";
        Exists: Boolean;
    begin
        if Currency.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Currency.Validate(Code, Code);
        Currency.Validate("ISO Code", CopyStr(Code, 1, 3));
        Currency.Validate("ISO Numeric Code", ISONumericCode);
        Currency.Validate(Description, Description);

        Currency.Validate("Unrealized Gains Acc.", UnrealizedGainsAcc);
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Unrealized Losses Acc.", UnrealizedLossesAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);

        Currency.Validate("Invoice Rounding Precision", InvoiceRoundingPrecision);
        Currency.Validate("Invoice Rounding Type", InvoiceRoundingType);
        Currency.Validate("Amount Rounding Precision", AmountRoundingPrecision);
        Currency.Validate("Unit-Amount Rounding Precision", UnitAmountRoundingPrecision);

        Currency.Validate("Amount Decimal Places", AmountDecimalPlaces);
        Currency.Validate("Unit-Amount Decimal Places", UnitAmountDecimalPlaces);
        Currency.Validate("EMU Currency", EMUCurrency);

        if Exists then
            Currency.Modify(true)
        else
            Currency.Insert(true);
    end;

    procedure InsertCurrencyExchangeRate(CurrencyCode: Code[10]; StartingDate: Date; ExchangeRateAmount: Decimal; AdjustmentExchRateAmount: Decimal; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Exists: Boolean;
    begin
        if CurrencyExchangeRate.Get(CurrencyCode, StartingDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
        CurrencyExchangeRate.Validate("Starting Date", StartingDate);
        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);

        if Exists then
            CurrencyExchangeRate.Modify(true)
        else
            CurrencyExchangeRate.Insert(true);
    end;
}