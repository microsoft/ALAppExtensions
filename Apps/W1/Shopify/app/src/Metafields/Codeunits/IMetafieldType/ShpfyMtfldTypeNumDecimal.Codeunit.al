namespace Microsoft.Integration.Shopify;

using System.Utilities;

codeunit 30319 "Shpfy Mtfld Type Num Decimal" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Regex: Codeunit Regex;
    begin
        // +/-9999999999999.999999999
        exit(Regex.IsMatch(Value, '^[-+]?\d{1,13}(?:\.\d{1,9})?$'));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('123.45');
    end;
}