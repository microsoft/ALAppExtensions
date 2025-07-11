namespace Microsoft.Integration.Shopify;

codeunit 30318 "Shpfy Mtfld Type Date" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        DummyDate: Date;
    begin
        exit(Evaluate(DummyDate, Value, 9));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('2022-02-02');
    end;
}