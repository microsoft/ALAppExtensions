codeunit 18013 "GST TDS TCS Use Case Data"
{
    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(GSTTDSTCSUseCaseLbl);
    end;

    var
        GSTTDSTCSUseCaseLbl: Label 'GST TDS TCS Use Cases place holder';
}