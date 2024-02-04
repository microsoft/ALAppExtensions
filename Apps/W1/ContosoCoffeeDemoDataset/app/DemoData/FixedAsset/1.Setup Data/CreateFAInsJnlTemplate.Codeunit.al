codeunit 5170 "Create FA Ins Jnl. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        ContosoFixedAsset.InsertInsuranceJournalTemplate(Insurance(), InsuranceJournalLbl, CreateFANoSeries.FixedAssetGLJournal());
        ContosoFixedAsset.InsertInsuranceJournalBatch(Insurance(), Default(), DefaultJournalBatchLbl);
    end;

    procedure Insurance(): Code[10]
    begin
        exit(InsuranceTok);
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultTok);
    end;

    var
        InsuranceTok: Label 'INSURANCE', MaxLength = 10;
        InsuranceJournalLbl: Label 'Insurance Journal', MaxLength = 50;
        DefaultTok: Label 'DEFAULT', MaxLength = 10;
        DefaultJournalBatchLbl: Label 'Default Journal Batch', MaxLength = 50;
}