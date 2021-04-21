codeunit 18901 "TCS Receipt Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TCSOnReceiptUseCases: Codeunit "TCS On Receipt Use Cases";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(TCSOnReceiptUseCases.GetText());
    end;
}