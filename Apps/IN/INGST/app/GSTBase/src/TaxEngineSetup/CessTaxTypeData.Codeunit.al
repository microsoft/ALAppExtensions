codeunit 18008 "Cess Tax Type Data"
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
        exit(CessTaxTypeLbl);
    end;

    var
        CessTaxTypeLbl: Label 'Cess Tax Type place holder';
}