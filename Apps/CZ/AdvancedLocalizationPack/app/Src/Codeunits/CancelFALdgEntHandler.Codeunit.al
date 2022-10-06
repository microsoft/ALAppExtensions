codeunit 31439 "Cancel FA Ldg.Ent. Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cancel FA Ledger Entries", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure OnBeforeGenJnlLineInsert(var GenJournalLine: Record "Gen. Journal Line"; FALedgerEntry: Record "FA Ledger Entry")
    begin
        GenJournalLine."Reason Code" := FALedgerEntry."Reason Code";
    end;
}