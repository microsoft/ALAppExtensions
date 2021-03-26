codeunit 18691 "TDS Tax Types"
{
    var
        TDSTaxTypeLbl: Label 'TDS Tax Type Place Holder';

    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(TDSTaxTypeLbl);
    end;
}