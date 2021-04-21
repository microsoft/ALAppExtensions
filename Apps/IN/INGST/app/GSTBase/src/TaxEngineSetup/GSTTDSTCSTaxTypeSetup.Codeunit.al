codeunit 18011 "GST TDS TCS Tax Type Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        GSTTDSTCSTaxTypeData: Codeunit "GST TDS TCS Tax Type Data";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportTaxTypes(GSTTDSTCSTaxTypeData.GetText());
    end;
}