codeunit 14613 "Create FA Ins Jnl. Template IS"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFANoSeries: Codeunit "Create FA No Series";
        CreateFAInsJnlTemplate: Codeunit "Create FA Ins Jnl. Template";
    begin
        ContosoFixedAsset.SetOverwriteData(true);
        ContosoFixedAsset.InsertInsuranceJournalTemplate(CreateFAInsJnlTemplate.Insurance(), InsuranceJournalLbl, CreateFANoSeries.InsuranceJournal());
        ContosoFixedAsset.InsertInsuranceJournalBatch(CreateFAInsJnlTemplate.Insurance(), CreateFAInsJnlTemplate.Default(), DefaultJournalBatchLbl);
        ContosoFixedAsset.SetOverwriteData(false);
    end;

    var
        InsuranceJournalLbl: Label 'Insurance Journal', MaxLength = 50;
        DefaultJournalBatchLbl: Label 'Default Journal Batch', MaxLength = 50;
}