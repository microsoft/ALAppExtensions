codeunit 18718 "TDS On Purchase Use Cases"
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
        exit(TDSOnPurchaseUseCasesLbl);
    end;

    var
        TDSOnPurchaseUseCasesLbl: Label 'TDS On Purchase Use Cases';
}