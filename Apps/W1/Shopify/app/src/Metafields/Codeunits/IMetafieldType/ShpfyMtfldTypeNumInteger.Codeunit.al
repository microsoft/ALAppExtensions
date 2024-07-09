namespace Microsoft.Integration.Shopify;

codeunit 30320 "Shpfy Mtfld Type Num Integer" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        DummyInteger: BigInteger;
        MinInt: BigInteger;
        MaxInt: BigInteger;
    begin
        if not Evaluate(DummyInteger, Value, 9) then
            exit(false);

        Evaluate(MinInt, '-9007199254740991', 9);
        Evaluate(MaxInt, '9007199254740991', 9);
        if (DummyInteger < MinInt) or (DummyInteger > MaxInt) then
            exit(false);

        exit(true);
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('123');
    end;
}