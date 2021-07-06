codeunit 18083 "GST Purchase Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        GSTPurchaseUseCaseDataset: Codeunit "GST Purchase UseCase Dataset";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        TaxJsonDeserialization.ImportUseCases(GSTPurchaseUseCaseDataset.GetText());
    end;
}