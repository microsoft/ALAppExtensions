codeunit 18770 "TDS On Payment Use Cases"
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
        exit(TDSOnPaymentsUseCasesLbl);
    end;

    var
        TDSOnPaymentsUseCasesLbl: Label 'TDS on Payment Use Cases';
}