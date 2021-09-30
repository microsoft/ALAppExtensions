codeunit 31367 "FA Ledger Entry Handler CZF"
{
    [EventSubscriber(ObjectType::Table, Database::"FA Ledger Entry", 'OnAfterMoveToGenJnlLine', '', false, false)]
    local procedure OnAfterMoveToGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; FALedgerEntry: Record "FA Ledger Entry")
    begin
        GenJournalLine."VAT Date CZL" := FALedgerEntry."Posting Date";
    end;
}
