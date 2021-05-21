codeunit 18840 "TCS On Sales Use Cases"
{
    var
        TCSOnSalesUseCasesLbl: Label 'TCS on Sales Use Cases';

    procedure GetJObject(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.ReadFrom(GetText());
        exit(JObject);
    end;

    procedure GetText(): Text
    begin
        exit(TCSOnSalesUseCasesLbl);
    end;
}