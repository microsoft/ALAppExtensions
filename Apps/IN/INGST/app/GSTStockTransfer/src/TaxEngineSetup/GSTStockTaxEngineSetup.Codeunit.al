codeunit 18394 "GST Stock Tax Engine Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCases', '', false, false)]
    local procedure OnSetupUseCases()
    var
        TaxJsonDeserialization: Codeunit "Tax Json Deserialization";
        GSTStockUseCaseDataset: Codeunit "GST Stock UseCase Dataset";
    begin
        TaxJsonDeserialization.HideDialog(true);
        TaxJsonDeserialization.ImportUseCases(GSTStockUseCaseDataset.GetText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCaseTree', '', false, false)]
    local procedure OnSetupUseCaseTree()
    var
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
        GSTStockUseCaseDataset: Codeunit "GST Stock UseCase Dataset";
    begin
        UseCaseTreeIndent.ReadUseCaseTree(GSTStockUseCaseDataset.GetTreeText());
    end;
}