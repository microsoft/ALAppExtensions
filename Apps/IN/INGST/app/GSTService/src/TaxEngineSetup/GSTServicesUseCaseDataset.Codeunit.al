codeunit 18445 "GST Services UseCase Dataset"
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
        exit(GSTOnServicesUseCasesLbl);
    end;

    var
        GSTOnServicesUseCasesLbl: Label 'GST On Services Use Cases';
}