codeunit 18145 "GST Sales UseCase Dataset"
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
        exit(GSTOnSalesUseCasesLbl);
    end;

    var
        GSTOnSalesUseCasesLbl: Label 'GST On Sales Use Cases';
}