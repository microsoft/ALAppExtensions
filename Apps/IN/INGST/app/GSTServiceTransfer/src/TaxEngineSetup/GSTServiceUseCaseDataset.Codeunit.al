codeunit 18353 "GST Service UseCase Dataset"
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
        exit(GSTOnServiceTransferUseCasesLbl);
    end;

    var
        GSTOnServiceTransferUseCasesLbl: Label 'GST On Service Transfer Use Cases';
}