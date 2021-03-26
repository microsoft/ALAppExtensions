codeunit 18690 "TDS Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxPeriod', '', false, false)]
    local procedure OnSetupTaxPeriod()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        TDSTaxTypes: Codeunit "TDS Tax Types";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportTaxTypes(TDSTaxTypes.GetText());
    end;
}