namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.Currency;

codeunit 30317 "Shpfy Mtfld Type Money" implements "Shpfy IMetafield Type"
{
    var
        MoneyJsonTemplateTxt: Label '{"amount": "%1", "currency_code": "%2"}', Locked = true;

    procedure HasAssistEdit(): Boolean
    begin
        exit(true);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Amount: Decimal;
        CurrencyCode: Code[10];
    begin
        exit(TryExtractValues(Value, Amount, CurrencyCode));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    var
        MetafieldAssistEdit: Page "Shpfy Metafield Assist Edit";
        Amount: Decimal;
        CurrencyCode: Code[10];
    begin
        if Value <> '' then
            if not TryExtractValues(Value, Amount, CurrencyCode) then begin
                Clear(Amount);
                Clear(CurrencyCode);
            end;

        if MetafieldAssistEdit.OpenForMoney(Amount, CurrencyCode) then begin
            MetafieldAssistEdit.GetMoneyValue(Amount, CurrencyCode);
            Value := StrSubstNo(MoneyJsonTemplateTxt, Format(Amount, 0, 9), CurrencyCode);
            exit(true);
        end else
            exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit(StrSubstNo(MoneyJsonTemplateTxt, '5.99', 'CAD'));
    end;

    /// <summary>
    /// Tried to extract the amount and currency code from the JSON string.
    /// </summary>
    /// <param name="Value">JSON string with the following format: {"amount": "5.99", "currency_code": "CAD"}</param>
    /// <param name="Amount">Return value: the amount extracted from the JSON string.</param>
    /// <param name="CurrencyCode">Return value: the currency code extracted from the JSON string.</param>
    /// <returns>True if no errors occurred during the extraction.</returns>
    [TryFunction]
    internal procedure TryExtractValues(Value: Text; var Amount: Decimal; var CurrencyCode: Code[10])
    var
        Currency: Record Currency;
        JToken: JsonToken;
        JObject: JsonObject;
    begin
        JObject.ReadFrom(Value);
        JObject.SelectToken('amount', JToken);
        Amount := JToken.AsValue().AsDecimal();
        JObject.SelectToken('currency_code', JToken);
#pragma warning disable AA0139
        CurrencyCode := JToken.AsValue().AsText();
#pragma warning restore AA0139
        Currency.Get(CurrencyCode);

        if JObject.Keys.Count() <> 2 then
            Error('');
    end;
}