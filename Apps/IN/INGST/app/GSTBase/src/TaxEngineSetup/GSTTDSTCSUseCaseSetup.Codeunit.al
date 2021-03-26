codeunit 18014 "GST TDS TCS Use Case Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        GSTTDSTCSUseCaseData: Codeunit "GST TDS TCS Use Case Data";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(GSTTDSTCSUseCaseData.GetText());
    end;
}