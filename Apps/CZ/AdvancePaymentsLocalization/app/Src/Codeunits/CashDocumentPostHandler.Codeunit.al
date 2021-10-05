codeunit 31065 "Cash Document-Post Handler CZZ"
{
    SingleInstance = true;
    Permissions = tabledata "EET Entry CZL" = rm;

    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        UseBuffer: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDocLine', '', false, false)]
    local procedure CashDocumentPostCZPOnBeforePostCashDocLine(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Advance Letter No. CZZ" := CashDocumentLineCZP."Advance Letter No. CZZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDoc', '', false, false)]
    local procedure CashDocumentPostOnBeforePostCashDoc()
    begin
        if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
            TempSalesAdvLetterEntryCZZ.DeleteAll();

        UseBuffer := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SalesAdvLetterManagement CZZ", 'OnAfterInsertAdvEntry', '', false, false)]
    local procedure SalesAdvLetterManagementCZZOnAfterInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        if (SalesAdvLetterEntryCZZ.IsTemporary()) or (not UseBuffer) then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" = SalesAdvLetterEntryCZZ."Entry Type"::Payment then begin
            TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
            TempSalesAdvLetterEntryCZZ.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterFinalizePosting', '', false, false)]
    local procedure CashDocumentPostOnAfterFinalizePosting(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
        AfterFinalizePosting(PostedCashDocumentHdrCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterFinalizePostingPreview', '', false, false)]
    local procedure CashDocumentPostOnAfterFinalizePostingPreview(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
        AfterFinalizePosting(PostedCashDocumentHdrCZP);
    end;

    local procedure AfterFinalizePosting(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        if TempSalesAdvLetterEntryCZZ.FindSet() then begin
            repeat
                SalesAdvLetterHeaderCZZ.Get(TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
                    SalesAdvLetterManagementCZZ.PostAdvancePaymentVAT(TempSalesAdvLetterEntryCZZ, 0D);
            until TempSalesAdvLetterEntryCZZ.Next() = 0;

            ModifyEETEntry(PostedCashDocumentHdrCZP."EET Entry No.");

            TempSalesAdvLetterEntryCZZ.DeleteAll();
        end;

        UseBuffer := false;
    end;

    local procedure ModifyEETEntry(EETEntryNo: Integer)
    var
        EETEntryCZL: Record "EET Entry CZL";
        TempVATEntry: Record "VAT Entry" temporary;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        if EETEntryNo = 0 then
            exit;

        if TempSalesAdvLetterEntryCZZ.FindSet() then
            repeat
                SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ.SetRange("Related Entry", TempSalesAdvLetterEntryCZZ."Entry No.");
                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
                if SalesAdvLetterEntryCZZ.FindSet() then
                    repeat
                        TempVATEntry.Init();
                        TempVATEntry."Entry No." += 1;
                        TempVATEntry."VAT Bus. Posting Group" := SalesAdvLetterEntryCZZ."VAT Bus. Posting Group";
                        TempVATEntry."VAT Prod. Posting Group" := SalesAdvLetterEntryCZZ."VAT Prod. Posting Group";
                        TempVATEntry.Base := SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)";
                        TempVATEntry.Amount := SalesAdvLetterEntryCZZ."VAT Amount (LCY)";
                        TempVATEntry.Insert();
                    until SalesAdvLetterEntryCZZ.Next() = 0;
            until TempSalesAdvLetterEntryCZZ.Next() = 0;

        if TempVATEntry.FindSet() then begin
            EETEntryCZL.Get(EETEntryNo);
            repeat
                EETEntryCZL.CalculateAmounts(TempVATEntry);
            until TempVATEntry.Next() = 0;

            EETEntryCZL.RoundAmounts();
#pragma warning disable AA0214
            EETEntryCZL.Modify();
#pragma warning restore AA0214
        end;
    end;
}
