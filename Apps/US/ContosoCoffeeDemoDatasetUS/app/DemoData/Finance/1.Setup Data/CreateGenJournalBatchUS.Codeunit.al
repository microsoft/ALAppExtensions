codeunit 11484 "Create Gen. Journal Batch US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Batch", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Gen. Journal Batch")
    var
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        if (Rec."Journal Template Name" = CreateGenJournalTemplate.General()) then
            case Rec.Name of
                CreateGenJournalBatch.General():
                    ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
                CreateGenJournalBatch.Monthly():
                    ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
            end;
        if (Rec."Journal Template Name" = CreateGenJournalTemplate.PaymentJournal()) then
            case Rec.Name of
                CreateGenJournalBatch.Cash():
                    ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
                CreateGenJournalBatch.General():
                    ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
            end;
        if Rec."Journal Template Name" = CreateGenJournalTemplate.CashReceipts() then
            if Rec.Name = CreateGenJournalBatch.General() then
                ValidateRecordFields(Rec, CreateUSGLAccounts.BusinessAccountOperatingDomestic());
    end;

    local procedure ValidateRecordFields(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountNo: Code[20])
    begin
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
    end;
}