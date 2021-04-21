codeunit 18084 "GST Purchase UseCase Dataset"
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
        exit(GSTOnPurchaseUseCasesLbl);
    end;

    var
        GSTOnPurchaseUseCasesLbl: Label 'GST On Purchase Use Cases.';
}