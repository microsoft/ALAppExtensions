codeunit 18004 "GST Base Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupTaxTypes', '', false, false)]
    local procedure OnSetupTaxTypes()
    var
        GSTTaxTypeData: Codeunit "GST Tax Type Data";
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportTaxTypes(GSTTaxTypeData.GetText());
    end;
}