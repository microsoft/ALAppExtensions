codeunit 18771 "TDS Payments Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TDSOnPaymentUseCases: Codeunit "TDS On Payment Use Cases";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(TDSOnPaymentUseCases.GetText());
    end;
}