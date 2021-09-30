#pragma warning disable AL0432
codeunit 31013 "VAT LCY Correction-Post CZL"
{
    TableNo = "VAT LCY Correction Buffer CZL";

    trigger OnRun()
    begin
        Post(Rec);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCode: Record "Source Code";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
        DimensionManagement: Codeunit DimensionManagement;
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        WindowDialog: Dialog;
        PostingDescriptionTxt: Label 'VAT Correction in LCY';
        NothingToPostErr: Label 'There is nothing to post.';
        DialogMsg: Label 'Posting VAT correction lines #1######\', Comment = '%1 = Line Count';
        SuccessMsg: Label 'The VAT correction lines were successfully posted.';
        PostingDateOutRangeErr: Label 'is not within your range of allowed posting dates';
        VATRangeErr: Label ' %1 is not within your range of allowed VAT dates', Comment = '%1 = VAT Date';
        PreviewMode: Boolean;

    procedure Post(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    var
        LineNo: Integer;
    begin
        OnBeforePost(VATLCYCorrectionBufferCZL);

        VATLCYCorrectionBufferCZL.SetFilter("VAT Correction Amount", '<>0');
        if not VATLCYCorrectionBufferCZL.FindSet() then
            Error(NothingToPostErr);

        GeneralLedgerSetup.Get();
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("VAT LCY Correction CZL");
        SourceCode.Get(SourceCodeSetup."VAT LCY Correction CZL");

        GLEntry.LockTable();
        VATEntry.LockTable();

        WindowDialog.Open(DialogMsg);
        LineNo := 0;
        repeat
            LineNo += 1;
            WindowDialog.Update(1, LineNo);
            PostCorrectionAmount(VATLCYCorrectionBufferCZL);
        until VATLCYCorrectionBufferCZL.Next() = 0;
        WindowDialog.Close();

        if PreviewMode then
            GenJnlPostPreview.ThrowError();
        Commit();

        OnAfterPost(VATLCYCorrectionBufferCZL);
        Message(SuccessMsg);
    end;

    local procedure PostCorrectionAmount(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    var
        PurchVATAccount: Code[20];
        VATLCYCorrRoundingAccNo: Code[20];
    begin
        if VATLCYCorrectionBufferCZL."VAT Correction Amount" = 0 then
            exit;

        if GenJnlCheckLine.DateNotAllowed(VATLCYCorrectionBufferCZL."Posting Date") then
            VATLCYCorrectionBufferCZL.FieldError("Posting Date", PostingDateOutRangeErr);
        CheckVATDateCZL(VATLCYCorrectionBufferCZL);

        VATEntry.Get(VATLCYCorrectionBufferCZL."Entry No.");
        VATEntry.TestField(Type, VATEntry.Type::Purchase);
        VATPostingSetup.Get(VATLCYCorrectionBufferCZL."VAT Bus. Posting Group", VATLCYCorrectionBufferCZL."VAT Prod. Posting Group");
        PurchVATAccount := VATPostingSetup.GetPurchAccount(false);
        VATLCYCorrRoundingAccNo := VATPostingSetup.GetLCYCorrRoundingAccCZL();

        // Post to Purchase VAT Account
        SetGenJournalLine(GenJournalLine, VATLCYCorrectionBufferCZL, PurchVATAccount, VATLCYCorrectionBufferCZL."VAT Correction Amount", true);
        CopyFromVATEntry(GenJournalLine, VATEntry);
#if not CLEAN17
        SyncDeprecatedFields(GenJournalLine);
#endif
        SetDefaultDimensions(GenJournalLine);
        OnPostCorrectionAmountOnBeforePostVATAccountLine(GenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnPostCorrectionAmountOnAfterPostVATAccountLine(GenJournalLine, GenJnlPostLine);

        // Post to VAT LCY Correction Rounding Account
        SetGenJournalLine(GenJournalLine, VATLCYCorrectionBufferCZL, VATLCYCorrRoundingAccNo, -VATLCYCorrectionBufferCZL."VAT Correction Amount", false);
        CopyFromVATEntry(GenJournalLine, VATEntry);
#if not CLEAN17
        SyncDeprecatedFields(GenJournalLine);
#endif
        SetDefaultDimensions(GenJournalLine);
        OnPostCorrectionAmountOnBeforePostRoundingAccountLine(GenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnPostCorrectionAmountOnAfterPostRoundingAccountLine(GenJournalLine, GenJnlPostLine);
    end;

    local procedure SetGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL"; GLAccNo: Code[20]; Amount: Decimal; VATPosting: Boolean)
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := VATLCYCorrectionBufferCZL."Document Type";
        GenJournalLine."Document No." := VATLCYCorrectionBufferCZL."Document No.";
        GenJournalLine.Description := PostingDescriptionTxt;
        GenJournalLine."Posting Date" := VATLCYCorrectionBufferCZL."Posting Date";
        GenJournalLine."VAT Date CZL" := VATLCYCorrectionBufferCZL."VAT Date";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Source Code" := SourceCode.Code;
        GenJournalLine."Currency Code" := '';
        GenJournalLine."Account No." := GLAccNo;
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
        GenJournalLine."Bill-to/Pay-to No." := VATLCYCorrectionBufferCZL."Bill-to/Pay-to No.";
        GenJournalLine."Country/Region Code" := VATLCYCorrectionBufferCZL."Country/Region Code";
        GenJournalLine."VAT Registration No." := VATLCYCorrectionBufferCZL."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := VATLCYCorrectionBufferCZL."Registration No.";
        GenJournalLine."Tax Registration No. CZL" := VATLCYCorrectionBufferCZL."Tax Registration No.";

        if VATPosting then begin
            GenJournalLine."VAT Base Amount" := 0;
            GenJournalLine."VAT Base Amount (LCY)" := 0;
            GenJournalLine."VAT Amount" := GenJournalLine.Amount;
            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."Amount (LCY)";
            GenJournalLine."Gen. Posting Type" := VATLCYCorrectionBufferCZL.Type;
            GenJournalLine."VAT Calculation Type" := GenJournalLine."VAT Calculation Type"::"Full VAT";
            GenJournalLine."VAT Bus. Posting Group" := VATLCYCorrectionBufferCZL."VAT Bus. Posting Group";
            GenJournalLine."VAT Prod. Posting Group" := VATLCYCorrectionBufferCZL."VAT Prod. Posting Group";
        end;
    end;

    local procedure CopyFromVATEntry(var GenJournalLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry")
    begin
        GenJournalLine."External Document No." := VATEntry."External Document No.";
        GenJournalLine."Document Date" := VATEntry."Document Date";
        GenJournalLine."Original Doc. VAT Date CZL" := VATEntry."Original Doc. VAT Date CZL";
        GenJournalLine."Reason Code" := VATEntry."Reason Code";
        GenJournalLine."VAT Registration No." := VATEntry."VAT Registration No.";
    end;

    local procedure SetDefaultDimensions(var GenJournalLine: Record "Gen. Journal Line")
    var
        DefaultDimension: Record "Default Dimension";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account" then begin
            TableID[1] := DATABASE::"G/L Account";
            No[1] := GenJournalLine."Account No.";
            DefaultDimension.SetRange("Table ID", TableID[1]);
            DefaultDimension.SetRange("No.", No[1]);
            if not DefaultDimension.IsEmpty() then
                GenJournalLine."Dimension Set ID" := DimensionManagement.GetDefaultDimID(
                    TableID, No, GenJournalLine."Source Code", GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", 0);
        end;
    end;

    local procedure CheckVATDateCZL(VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    var
    begin
        if not GeneralLedgerSetup."Use VAT Date CZL" then
            VATLCYCorrectionBufferCZL.TestField("VAT Date", VATLCYCorrectionBufferCZL."Posting Date")
        else begin
            VATLCYCorrectionBufferCZL.TestField("VAT Date");
            if VATDateHandlerCZL.VATDateNotAllowed(VATLCYCorrectionBufferCZL."VAT Date") then
                VATLCYCorrectionBufferCZL.FieldError("VAT Date", StrSubstNo(VATRangeErr, VATLCYCorrectionBufferCZL."VAT Date"));
            VATDateHandlerCZL.VATPeriodCZLCheck(VATLCYCorrectionBufferCZL."VAT Date");
        end;
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

#if not CLEAN17
    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.5')]
    local procedure SyncDeprecatedFields(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date" := GenJournalLine."VAT Date CZL";
        GenJournalLine."Original Document VAT Date" := GenJournalLine."Original Doc. VAT Date CZL";
        GenJournalLine."Registration No." := GenJournalLine."Registration No. CZL";
    end;

#endif
    [IntegrationEvent(false, false)]
    local procedure OnPostCorrectionAmountOnBeforePostVATAccountLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostCorrectionAmountOnAfterPostVATAccountLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostCorrectionAmountOnBeforePostRoundingAccountLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostCorrectionAmountOnAfterPostRoundingAccountLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePost(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL")
    begin
    end;
}
