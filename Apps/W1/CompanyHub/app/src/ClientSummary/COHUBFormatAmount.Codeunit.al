codeunit 1165 "COHUB Format Amount"
{
    Access = Internal;

    procedure GetAmountFormat(CurrencySymbol: Text[10]): Text
    begin
        if StrLen(CurrencySymbol) = 1 then
            exit(CurrencySymbol + GetDefaultAmountFormat())
        else
            exit(CurrencySymbol + ' ' + GetDefaultAmountFormat())
    end;

    local procedure GetDefaultAmountFormat(): Text
    begin
        exit('<Precision,2:2><Standard Format,0>');
    end;

    procedure ParseAmount(AmountText: text; var DecimalValue: Decimal; var CurrencySymbol: text[10]): Boolean
    begin
        AmountText := AmountText.Trim();

        while (not (AmountText[1] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '+'])) do begin
            if StrLen(CurrencySymbol) = MaxStrLen(CurrencySymbol) then
                break;

            CurrencySymbol += AmountText[1];
            if (StrLen(AmountText) = 1) then
                break;

            AmountText := AmountText.Remove(1, 1);
        end;

        AmountText := AmountText.Replace(',', '');
        if Evaluate(DecimalValue, AmountText, 9) then
            exit(true);

        SendTraceTag('0000DIA', COHUBTelemetryCategoryLbl, Verbosity::Error, StrSubstNo(CouldNotParseStringTxt, AmountText), DataClassification::CustomerContent);
        exit(false);
    end;

    var

        CouldNotParseStringTxt: Label 'Could not parse amount %1', Locked = true;
        COHUBTelemetryCategoryLbl: Label 'CompanyHub', Locked = true;
}