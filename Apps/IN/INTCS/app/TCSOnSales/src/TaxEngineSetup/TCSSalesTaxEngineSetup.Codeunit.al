codeunit 18839 "TCS Sales Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TCSOnSalesUseCases: Codeunit "TCS On Sales Use Cases";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.SkipVersionCheck(true);
        TaxJsonDeserialization.SkipUseCaseIndentation(true);
        TaxJsonDeserialization.ImportUseCases(TCSOnSalesUseCases.GetText());
    end;
}