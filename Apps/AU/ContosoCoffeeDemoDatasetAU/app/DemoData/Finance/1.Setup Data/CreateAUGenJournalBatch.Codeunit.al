codeunit 17161 "Create AU Gen. Journal Batch"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
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

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Batch", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertRecord(var Rec: Record "Gen. Journal Batch")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        if (Rec."Journal Template Name" = CreateGenJournalTemplate.General()) and (Rec.Name = CreateGenJournalBatch.Default()) then
            Rec.Validate("No. Series", CreateNoSeries.GeneralJournal());
    end;

    var
        DefaultLbl: Label 'Default Journal Batch', MaxLength = 100;
}