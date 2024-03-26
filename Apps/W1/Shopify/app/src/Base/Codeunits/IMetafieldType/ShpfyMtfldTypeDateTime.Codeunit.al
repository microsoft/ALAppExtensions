namespace Microsoft.Integration.Shopify;

codeunit 30315 "Shpfy Mtfld Type DateTime" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        DummyDateTime: DateTime;
    begin
        exit(Evaluate(DummyDateTime, Value, 9));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('2022-01-01T12:30:00');
    end;
}