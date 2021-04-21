codeunit 18009 "Cess Use Case Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        CessUseCaseData: Codeunit "Cess Use Case Data";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(CessUseCaseData.GetText());
    end;
}