codeunit 17152 "Create NZ Gen. Journal Batch"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

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
}