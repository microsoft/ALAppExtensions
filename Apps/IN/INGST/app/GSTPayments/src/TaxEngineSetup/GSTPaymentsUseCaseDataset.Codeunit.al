codeunit 18250 "GST Payments UseCase Dataset"
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
        exit(GSTOnPaymentUseCasesLbl);
    end;

    var
        GSTOnPaymentUseCasesLbl: Label 'GST On Payment Use Cases';
}