namespace Microsoft.Integration.Shopify;

codeunit 30353 "Shpfy Mtfld Type Json" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        JsonObject: JsonObject;
    begin
        exit(JsonObject.ReadFrom(Value));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('{"ingredient": "flour", "amount": 0.3}');
    end;
}