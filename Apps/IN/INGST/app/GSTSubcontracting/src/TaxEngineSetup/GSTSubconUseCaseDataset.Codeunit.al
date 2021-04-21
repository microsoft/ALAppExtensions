codeunit 18473 "GST Subcon UseCase Dataset"
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
        exit(GSTOnSubconUseCasesLbl);
    end;

    var
        GSTOnSubconUseCasesLbl: Label 'GST On Subcon Use Cases';
}