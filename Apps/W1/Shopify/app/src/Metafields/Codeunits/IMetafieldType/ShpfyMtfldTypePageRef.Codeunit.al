namespace Microsoft.Integration.Shopify;

using System.Utilities;

codeunit 30328 "Shpfy Mtfld Type Page Ref" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Regex: Codeunit Regex;
    begin
        exit(Regex.IsMatch(Value, '^gid:\/\/shopify\/OnlinePage\/\d+$'));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('gid://shopify/OnlinePage/1234567890');
    end;
}