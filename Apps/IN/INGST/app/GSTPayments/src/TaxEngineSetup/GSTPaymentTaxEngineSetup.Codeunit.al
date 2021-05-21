codeunit 18249 "GST Payment Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        GSTPaymentsUseCaseDataset: Codeunit "GST Payments UseCase Dataset";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(GSTPaymentsUseCaseDataset.GetText());
    end;
}