codeunit 18005 "GST Tax Type Data"
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
        exit(GSTTaxTypeLbl);
    end;

    var
        GSTTaxTypeLbl: Label 'GST Tax Type place holder';
}