namespace Microsoft.Integration.Shopify;

using System.Utilities;

codeunit 30324 "Shpfy Mtfld Type Url" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Regex: Codeunit Regex;
    begin
        exit(Regex.IsMatch(Value, '^(http|https|mailto|sms|tel)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$'));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('https://www.shopify.com');
    end;
}