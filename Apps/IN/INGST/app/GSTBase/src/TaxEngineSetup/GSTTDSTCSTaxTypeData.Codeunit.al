codeunit 18012 "GST TDS TCS Tax Type Data"
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
        exit(GSTTDSTCSTaxTypeLbl);
    end;

    var
        GSTTDSTCSTaxTypeLbl: Label 'GST TDS TCS Tax Type place holder';
}