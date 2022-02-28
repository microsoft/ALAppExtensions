codeunit 31063 "Copy Gen. Jnl. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Gen. Journal Mgt.", 'OnAfterInsertGenJournalLine', '', false, false)]
    local procedure ReplaceVATDateOnAfterInsertGenJournalLine(PostedGenJournalLine: Record "Posted Gen. Journal Line"; CopyGenJournalParameters: Record "Copy Gen. Journal Parameters"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CopyGenJournalParameters."Replace VAT Date CZL" <> 0D then begin
            GenJournalLine."VAT Date CZL" := CopyGenJournalParameters."Replace VAT Date CZL";
            GenJournalLine.Modify();
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Gen. Journal Mgt.", 'OnAfterInsertGenJournalLine', '', false, false)]
    local procedure ReverseSignCorrectionOnAfterInsertGenJournalLine(CopyGenJournalParameters: Record "Copy Gen. Journal Parameters"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not CopyGenJournalParameters."Reverse Sign" then
            exit;

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Cr. Memos as Corrections" then begin
            GenJournalLine.Validate(Correction, true);
            GenJournalLine.Modify();
        end;
    end;
}