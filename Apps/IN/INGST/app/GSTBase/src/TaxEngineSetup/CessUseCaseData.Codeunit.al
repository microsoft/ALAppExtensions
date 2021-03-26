codeunit 18010 "Cess Use Case Data"
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
        exit(CessUseCaseLbl);
    end;

    var
        CessUseCaseLbl: Label 'Cess Use Cases place holder';
}