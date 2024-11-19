codeunit 27029 "Create CA Gen Journal Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", OnBeforeInsertEvent, '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Gen. Journal Template")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateFAGenJnlTemplate: Codeunit "Create FA Jnl. Template";
    begin
        case Rec.Name of
            CreateFAGenJnlTemplate.Assets():
                ValidateRecords(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.CashReceipts():
                ValidateRecords(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.General():
                ValidateRecords(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.InterCompanyGenJnl():
                ValidateRecords(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.PaymentJournal():
                ValidateRecords(Rec, Report::"Payment Journal - Test", Report::"G/L Register");
        end;
    end;

    local procedure ValidateRecords(var GenJournalTemplate: Record "Gen. Journal Template"; TestReporID: Integer; PostingReportID: Integer)
    begin
        GenJournalTemplate.Validate("Test Report ID", TestReporID);
        GenJournalTemplate.Validate("Posting Report ID", PostingReportID);
    end;
}