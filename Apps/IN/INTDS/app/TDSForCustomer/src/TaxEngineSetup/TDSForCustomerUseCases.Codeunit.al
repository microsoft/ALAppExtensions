codeunit 18663 "TDS For Customer Use Cases"
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
        exit(TDSForCustomerUseCasesLbl);
    end;

    var
        TDSForCustomerUseCasesLbl: Label 'TDS For Customer Use Cases';
}