namespace Microsoft.Integration.Shopify;

using System.Utilities;

codeunit 30354 "Shpfy Mtfld Type Color" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        Regex: Codeunit Regex;
    begin
        exit(Regex.IsMatch(Value, '^#[0-9A-Fa-f]{6}$'));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('#fff123');
    end;
}