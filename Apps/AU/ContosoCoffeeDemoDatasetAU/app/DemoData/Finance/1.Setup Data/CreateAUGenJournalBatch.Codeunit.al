codeunit 17161 "Create AU Gen. Journal Batch"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAUGenJournTemplate: Codeunit "Create AU Gen. Journ. Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateAUNoSeries: Codeunit "Create AU No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateAUGenJournTemplate.Purchase(), CreateGenJournalBatch.Default(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateAUNoSeries.PurchaseJournal(), false);
    end;

    var
        DefaultLbl: Label 'Default Journal Batch', MaxLength = 100;
}