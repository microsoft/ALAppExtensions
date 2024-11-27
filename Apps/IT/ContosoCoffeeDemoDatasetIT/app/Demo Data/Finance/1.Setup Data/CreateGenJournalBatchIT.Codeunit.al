codeunit 12225 "Create Gen Journal Batch IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Batch", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalBatch(var Rec: Record "Gen. Journal Batch")
    var
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        if (Rec."Journal Template Name" = CreateGenJournalBatch.General()) and (Rec.Name = CreateGenJournalBatch.Default()) then
            Rec.Validate("No. Series", CreateNoSeries.GeneralJournal());
    end;
}