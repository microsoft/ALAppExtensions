#if not CLEAN19
#pragma warning disable AL0432
codeunit 31328 "Purch. Post Adv. Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostLetter_SetInvHeaderOnBeforeInsertPurchInvHeader', '', false, false)]
    local procedure CopyFieldsOnPostLetter_SetInvHeaderOnBeforeInsertPurchInvHeader(var PurchInvHeader: Record "Purch. Inv. Header"; PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; VATDate: Date)
    begin
        PurchInvHeader."VAT Date CZL" := VATDate;
        PurchInvHeader."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
        PurchInvHeader."Registration No. CZL" := PurchAdvanceLetterHeader."Registration No.";
        PurchInvHeader."Tax Registration No. CZL" := PurchAdvanceLetterHeader."Tax Registration No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostLetter_SetCrMemoHeaderOnBeforeInsertPurchCrMemoHeader', '', false, false)]
    local procedure CopyFieldsOnPostLetter_SetCrMemoHeaderOnBeforeInsertPurchCrMemoHeader(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header")
    begin
        PurchCrMemoHdr."VAT Date CZL" := PurchAdvanceLetterHeader."VAT Date";
        if PurchCrMemoHdr."VAT Date CZL" = 0D then
            PurchCrMemoHdr."VAT Date CZL" := PurchCrMemoHdr."Posting Date";
        PurchCrMemoHdr."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostVATCrMemoHeaderOnBeforeInsertPostVATPurchCrMemoHdr', '', false, false)]
    local procedure CopyFieldsOnPostVATCrMemoHeaderOnBeforeInsertPostVATPurchCrMemoHdr(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; VATDate: Date)
    begin
        PurchCrMemoHdr."VAT Date CZL" := VATDate;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnBeforeModifyTempPurchAdvanceLetterEntryOnFillVATFieldsOfDeductionEntry', '', false, false)]
    local procedure CopyFieldsOnBeforeModifyTempPurchAdvanceLetterEntryOnFillVATFieldsOfDeductionEntry(var TempPurchAdvanceLetterEntry: Record "Purch. Advance Letter Entry"; VATEntry: Record "VAT Entry")
    begin
        TempPurchAdvanceLetterEntry."VAT Identifier" := VATEntry."VAT Identifier CZL";
        TempPurchAdvanceLetterEntry."VAT Date" := VATEntry."VAT Date CZL";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnAfterPostLetterPostToGL', '', false, false)]
    local procedure CopyFieldsOnAfterPostLetterPostToGL(PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; var GenJournalLine: Record "Gen. Journal Line"; VATDate: Date)
    begin
        GenJournalLine."VAT Date CZL" := VATDate;
        GenJournalLine."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnAfterPrepareGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterPrepareGenJnlLine(PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."VAT Date CZL" := PurchInvHeader."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := PurchInvHeader."Original Doc. VAT Date CZL";
        if PurchInvHeader."Original Doc. VAT Date CZL" = 0D then
            GenJnlLine."Original Doc. VAT Date CZL" := GenJnlLine."VAT Date CZL";
        GenJnlLine."EU 3-Party Trade" := PurchInvHeader."EU 3-Party Trade CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnAfterPostVATCrMemoPrepareGL', '', false, false)]
    local procedure CopyFieldsOnAfterPostVATCrMemoPrepareGL(var GenJournalLine: Record "Gen. Journal Line"; PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; VATDate: Date)
    begin
        GenJournalLine."VAT Date CZL" := VATDate;
        GenJournalLine."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
        GenJournalLine."EU 3-Party Trade" := PurchCrMemoHdr."EU 3-Party Trade CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostRefundCorrToGLOnFillAdvanceRefundGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnPostRefundCorrToGLOnFillAdvanceRefundGenJnlLine(PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; var GenJnlLine: Record "Gen. Journal Line"; VATDate: Date)
    begin
        GenJnlLine."VAT Date CZL" := VATDate;
        GenJnlLine."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnPostRefundCorrToGLOnFillAdvanceRefundGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnPostRefundCorrToGLOnBeforePostAdvancePaymentGenJnlLine(PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; var GenJnlLine: Record "Gen. Journal Line"; VATDate: Date)
    begin
        GenJnlLine."VAT Date CZL" := VATDate;
        GenJnlLine."Original Doc. VAT Date CZL" := PurchAdvanceLetterHeader."Original Document VAT Date";
        GenJnlLine."Variable Symbol CZL" := PurchAdvanceLetterHeader."Variable Symbol";
        GenJnlLine."Constant Symbol CZL" := PurchAdvanceLetterHeader."Constant Symbol";
        GenJnlLine."Specific Symbol CZL" := PurchAdvanceLetterHeader."Specific Symbol";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnUnapplyCustLedgEntryOnBeforeUnapply', '', false, false)]
    local procedure CopyFieldsOnUnapplyCustLedgEntryOnBeforeUnapply(VendLedgEntry: Record "Vendor Ledger Entry"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."VAT Date CZL" := GenJnlLine."Posting Date";
        GenJnlLine."Original Doc. VAT Date CZL" := GenJnlLine."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Advances", 'OnCreateBlankCrMemoOnBeforeInsertPurchCrMemoHdr', '', false, false)]
    local procedure CopyFieldsOnCreateBlankCrMemoOnBeforeInsertPurchCrMemoHdr(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; VATDate: Date)
    begin
        PurchCrMemoHdr."VAT Date CZL" := VATDate;
    end;
}
#endif