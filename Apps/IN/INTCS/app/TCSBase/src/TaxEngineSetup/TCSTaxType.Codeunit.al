codeunit 18811 "TCS Tax Type"
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
        exit(TCSTaxTypeLbl);
    end;

    var
        TCSTaxTypeLbl: Label 'TCS Tax Type place holder';
}