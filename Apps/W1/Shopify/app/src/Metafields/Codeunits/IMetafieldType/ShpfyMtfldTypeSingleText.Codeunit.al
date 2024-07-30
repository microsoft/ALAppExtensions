namespace Microsoft.Integration.Shopify;

codeunit 30323 "Shpfy Mtfld Type Single Text" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    begin
        exit(true);
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('VIP shipping method');
    end;
}