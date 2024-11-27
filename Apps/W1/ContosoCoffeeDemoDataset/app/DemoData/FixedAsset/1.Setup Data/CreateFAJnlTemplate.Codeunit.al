codeunit 5149 "Create FA Jnl. Template"
{

    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Source Code Setup" = r;

    trigger OnRun()
    begin
        CreateFAJournalTemplate();
        CreateGenJournalTemplate();
    end;

    local procedure CreateFAJournalTemplate()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        ContosoFixedAsset.InsertFAJournalTemplate(Assets(), FixedAssetGLJournalLbl, CreateFANoSeries.FixedAssetGLJournal(), false);
        ContosoFixedAsset.InsertFAJournalTemplate(Recurring(), RecurringFixedAssetGLJournalLbl, CreateFANoSeries.RecurringFixedAssetGLJournal(), true);

        ContosoFixedAsset.InsertFAJournalBatch(Assets(), Default(), DefaultJournalBatchLbl);
    end;

    local procedure CreateGenJournalTemplate()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        FANoSeries: Codeunit "Create FA No Series";
    begin
        SourceCodeSetup.Get();

        ContosoGeneralLedger.InsertGeneralJournalTemplate(Assets(), FixedAssetGLJournalLbl, Enum::"Gen. Journal Template Type"::Assets, false, FANoSeries.FixedAssetJournal(), SourceCodeSetup."Fixed Asset G/L Journal");

        ContosoGeneralLedger.InsertGeneralJournalBatch(Assets(), Default(), DefaultJournalBatchLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', FANoSeries.FixedAssetJournal(), false);
    end;

    procedure Assets(): Code[10]
    begin
        exit(AssetsTok);
    end;

    procedure Recurring(): Code[10]
    begin
        exit(RecurringTok);
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultTok);
    end;

    var
        AssetsTok: Label 'ASSETS', MaxLength = 10;
        FixedAssetGLJournalLbl: Label 'Fixed Asset G/L Journal', MaxLength = 50;
        RecurringTok: Label 'RECURRING', MaxLength = 10;
        RecurringFixedAssetGLJournalLbl: Label 'Recurring Fixed Asset G/L Jnl', MaxLength = 50;
        DefaultTok: Label 'DEFAULT', MaxLength = 10;
        DefaultJournalBatchLbl: Label 'Default Journal Batch', MaxLength = 50;
}