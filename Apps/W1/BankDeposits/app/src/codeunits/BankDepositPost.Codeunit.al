namespace Microsoft.Bank.Deposit;

using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Payables;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Analysis;
using System.Telemetry;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.AuditCodes;
using System.Utilities;

codeunit 1690 "Bank Deposit-Post"
{
    Permissions = TableData "Cust. Ledger Entry" = r,
                  TableData "Vendor Ledger Entry" = r,
                  TableData "Bank Account Ledger Entry" = r,
                  TableData "Bank Acc. Comment Line" = rimd,
                  TableData "Bank Deposit Header" = rd,
                  TableData "Posted Bank Deposit Header" = rim,
                  TableData "Posted Bank Deposit Line" = rim;
    TableNo = "Bank Deposit Header";
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLEntry: Record "G/L Entry";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        BankDepositPost: Codeunit "Bank Deposit-Post";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        PostingDate: Date;
        DocumentType: Enum "Gen. Journal Document Type";
        TotalAmountLCY: Decimal;
    begin
        FeatureTelemetry.LogUptake('0000IG4', 'Bank Deposit', Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000IG5', 'Bank Deposit', 'Bank deposit posted');
        OnBeforeBankDepositPost(Rec);

        GLSetup.GetRecordOnce();
        // Check deposit
        Rec.TestField("Posting Date");
        Rec.TestField("Total Deposit Amount");
        Rec.TestField("Document Date");
        Rec.TestField("Bank Account No.");
        BankAccount.Get(Rec."Bank Account No.");
        BankAccount.TestField(Blocked, false);
        Rec.CalcFields("Total Deposit Lines");
        if Rec."Total Deposit Lines" <> Rec."Total Deposit Amount" then
            Error(TotalAmountsMustMatchErr, Rec.FieldCaption("Total Deposit Amount"), Rec.FieldCaption("Total Deposit Lines"));

        OnAfterCheckBankDeposit(Rec);

        if Rec."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(Rec."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        SourceCodeSetup.Get();

        TotalAmountLCY := 0;
        ProgressDialog.Open(
          StrSubstNo(PostingDepositTxt, Rec."No.") +
          StatusTxt +
          BankDepositLineTxt +
          DividerTxt);

        ProgressDialog.Update(4, MovingToHistoryTxt);

        PostedBankDepositHeader.LockTable();
        PostedBankDepositLine.LockTable();
        Rec.LockTable();
        GenJournalLine.LockTable();

        InsertPostedBankDepositHeader(Rec);
        CopyBankComments(Rec);

        GenJournalTemplate.Get(Rec."Journal Template Name");
        DocumentType := Enum::"Gen. Journal Document Type"::" ";
        PostingDate := Rec."Posting Date";
        if Rec."Post as Lump Sum" and GenJournalTemplate."Force Doc. Balance" then
            ValidateLinesInSameTransaction(Rec, DocumentType, PostingDate);

        // Post to General, and other, Ledgers
        ProgressDialog.Update(4, PostingLinesToLedgersTxt);

        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");

        if GenJournalLine.Count() = 0 then
            Error(EmptyDepositErr);
        if Rec."Post as Lump Sum" and (GenJournalLine.Count() = 1) then
            Rec."Post as Lump Sum" := false;

        TotalAmountLCY := ModifyGenJournalLinesForBankDepositPosting(Rec, GenJournalTemplate."Force Doc. Balance");
        if Rec."Post as Lump Sum" then
            InsertLumpSumGenJournalLine(Rec, DocumentType, PostingDate, TotalAmountLCY);
        GenJournalLine.FindSet();
        repeat
            GenJnlCheckLine.RunCheck(GenJournalLine);
        until GenJournalLine.Next() = 0;

        Commit();
        BankDepositPost.SetCurrentDeposit(Rec);
        BindSubscription(BankDepositPost);
        GenJnlPostBatch.Run(GenJournalLine);
        UnbindSubscription(BankDepositPost);
        if Rec."Post as Lump Sum" then begin
            BankDepositPost.GetLumpSumBalanceEntry(GLEntry);
            SetBalancingEntryToPostedDepositLines(Rec, GLEntry);
        end;


        DeleteBankComments(Rec);

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        OnRunOnBeforeGenJournalLineDeleteAll(Rec, PostedBankDepositLine, GenJournalLine);
        GenJournalLine.DeleteAll();
        Rec.Delete();
        Commit();

        UpdateAnalysisView.UpdateAll(0, true);

        OnAfterBankDepositPost(Rec, PostedBankDepositHeader);

        Page.Run(Page::"Posted Bank Deposit", PostedBankDepositHeader);
    end;

    local procedure InsertLumpSumGenJournalLine(BankDepositHeader: Record "Bank Deposit Header"; DocumentType: Enum "Gen. Journal Document Type"; DocumentDate: Date; TotalAmountLCY: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine."Line No." := GetLastLineNo(BankDepositHeader) + 10000;
        GenJournalLine."Journal Template Name" := BankDepositHeader."Journal Template Name";
        GenJournalLine."Journal Batch Name" := BankDepositHeader."Journal Batch Name";
        SetSourceFields(GenJournalLine, BankDepositHeader, BankDepositHeader."Total Deposit Amount");
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
        GenJournalLine."Account No." := BankDepositHeader."Bank Account No.";
        GenJournalLine."Posting Date" := BankDepositHeader."Posting Date";
        GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(BankDepositHeader."Posting Date", BankDepositHeader."Document Date");
        GenJournalLine."Document No." := BankDepositHeader."No.";
        GenJournalLine."Document Type" := DocumentType;
        GenJournalLine."Document Date" := DocumentDate;
        GenJournalLine."Currency Code" := BankDepositHeader."Currency Code";
        GenJournalLine."Currency Factor" := BankDepositHeader."Currency Factor";
        GenJournalLine."Posting Group" := BankDepositHeader."Bank Acc. Posting Group";
        GenJournalLine."Shortcut Dimension 1 Code" := BankDepositHeader."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := BankDepositHeader."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := BankDepositHeader."Dimension Set ID";
        GenJournalLine."Document Date" := BankDepositHeader."Document Date";
        GenJournalLine."External Document No." := BankDepositHeader."No.";
        GenJournalLine.Description := BankDepositHeader."Posting Description";
        GenJournalLine.Amount := BankDepositHeader."Total Deposit Amount";
        GenJournalLine."Journal Template Name" := BankDepositHeader."Journal Template Name";
        GenJournalLine."Journal Batch Name" := BankDepositHeader."Journal Batch Name";
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Amount (LCY)" := -TotalAmountLCY;
        GenJournalLine.Insert();
    end;

    local procedure GetLastLineNo(BankDepositHeader: Record "Bank Deposit Header"): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.SetCurrentKey("Line No.");
        GenJournalLine.SetAscending("Line No.", false);
        GenJournalLine.FindFirst();
        exit(GenJournalLine."Line No.");
    end;

    local procedure ModifyGenJournalLinesForBankDepositPosting(BankDepositHeader: Record "Bank Deposit Header"; ForceDocumentNo: Boolean) TotalAmountLCY: Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        if not GenJournalLine.FindSet() then
            exit;
        repeat
            SetSourceFields(GenJournalLine, BankDepositHeader, GenJournalLine.Amount);
            if BankDepositHeader."Post as Lump Sum" then begin
                if ForceDocumentNo then
                    GenJournalLine."Document No." := BankDepositHeader."No.";
                GenJournalLine."Bal. Account No." := '';
            end else begin
                GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"Bank Account";
                GenJournalLine."Bal. Account No." := BankDepositHeader."Bank Account No.";
            end;
            GenJournalLine.Validate(Amount);
            AssignVATDateIfEmpty(GenJournalLine);
            TotalAmountLCY += GenJournalLine."Amount (LCY)";
            GenJournalLine.Modify();
        until GenJournalLine.Next() = 0;
    end;

    local procedure SetSourceFields(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header"; SourceCurrencyAmount: Decimal)
    begin
        GenJournalLine."Source Code" := SourceCodeSetup."Bank Deposit";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::"Bank Account";
        GenJournalLine."Source No." := BankDepositHeader."Bank Account No.";
        GenJournalLine."Source Currency Code" := BankDepositHeader."Currency Code";
        GenJournalLine."Reason Code" := BankDepositHeader."Reason Code";
        GenJournalLine."Source Currency Amount" := SourceCurrencyAmount;
    end;

    local procedure ValidateLinesInSameTransaction(BankDepositHeader: Record "Bank Deposit Header"; var DocumentType: Enum "Gen. Journal Document Type"; var PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LastPostingDate: Date;
        LastDocumentType: Enum "Gen. Journal Document Type";
        LastDocumentNo: Code[20];
    begin
        LastPostingDate := 0D;
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.FindSet();
        repeat
            if LastPostingDate = 0D then begin
                LastPostingDate := GenJournalLine."Posting Date";
                LastDocumentType := GenJournalLine."Document Type";
                LastDocumentNo := GenJournalLine."Document No.";
            end else begin
                if LastDocumentNo <> GenJournalLine."Document No." then
                    Error(LinesInSameTransactionForLumpSumErr, GenJournalLine.FieldCaption("Posting Date"), GenJournalLine.FieldCaption("Document Type"), GenJournalLine.FieldCaption("Document No."));
                if LastDocumentType <> GenJournalLine."Document Type" then
                    Error(LinesInSameTransactionForLumpSumErr, GenJournalLine.FieldCaption("Posting Date"), GenJournalLine.FieldCaption("Document Type"), GenJournalLine.FieldCaption("Document No."));
                if LastPostingDate <> GenJournalLine."Posting Date" then
                    Error(LinesInSameTransactionForLumpSumErr, GenJournalLine.FieldCaption("Posting Date"), GenJournalLine.FieldCaption("Document Type"), GenJournalLine.FieldCaption("Document No."));
            end;
        until GenJournalLine.Next() = 0;
        PostingDate := LastPostingDate;
        DocumentType := LastDocumentType;
    end;

    internal procedure CombineDimensionSets(var BankDepositHeader: Record "Bank Deposit Header"; var GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        DefaultDimensionPriority: Record "Default Dimension Priority";
        LocalSourceCodeSetup: Record "Source Code Setup";
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
        DefaultDimensionPriorityHeader: Integer;
        DefaultDimensionPriorityLine: Integer;
    begin
        if LocalSourceCodeSetup.Get() then
            if LocalSourceCodeSetup."Bank Deposit" <> '' then
                if DefaultDimensionPriority.Get(LocalSourceCodeSetup."Bank Deposit", Database::"Bank Deposit Header") then begin
                    DefaultDimensionPriorityHeader := DefaultDimensionPriority.Priority;
                    if DefaultDimensionPriority.Get(LocalSourceCodeSetup."Bank Deposit", Database::"Gen. Journal Line") then
                        DefaultDimensionPriorityLine := DefaultDimensionPriority.Priority;
                end;
        if DefaultDimensionPriorityHeader < DefaultDimensionPriorityLine then begin
            DimensionSetIDArr[1] := GenJournalLine."Dimension Set ID";
            DimensionSetIDArr[2] := BankDepositHeader."Dimension Set ID";
        end else begin
            DimensionSetIDArr[1] := BankDepositHeader."Dimension Set ID";
            DimensionSetIDArr[2] := GenJournalLine."Dimension Set ID";
        end;

        exit(DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code"));
    end;

    internal procedure CombineDimensionSetsHeaderPriority(var BankDepositHeader: Record "Bank Deposit Header"; var GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimensionSetIDArr[1] := GenJournalLine."Dimension Set ID";
        DimensionSetIDArr[2] := BankDepositHeader."Dimension Set ID";
        exit(DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code"));
    end;

    local procedure SetLumpSumBalanceEntry(GenJournalLine: Record "Gen. Journal Line")
    begin
        if not LumpBalanceGLEntry.FindLast() then
            exit;
        if GenJournalLine.Amount * LumpBalanceGLEntry.Amount < 0 then
            if LumpBalanceGLEntry.Get(LumpBalanceGLEntry."Entry No." - 1) then;
    end;

    internal procedure GetLumpSumBalanceEntry(var GLEntry: Record "G/L Entry")
    begin
        GLEntry.Copy(LumpBalanceGLEntry);
    end;

    local procedure SetBalancingEntryToPostedDepositLines(BankDepositHeader: Record "Bank Deposit Header"; GLEntry: Record "G/L Entry")
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
#if not CLEAN24
        GenJournalLine: Record "Gen. Journal Line";
#endif
    begin
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        PostedBankDepositLine.FindSet();
        repeat
            PostedBankDepositLine."Bank Account Ledger Entry No." := GLEntry."Entry No.";
#if not CLEAN24
            OnBeforePostedBankDepositLineModify(PostedBankDepositLine, GenJournalLine);
#endif
            PostedBankDepositLine.Modify();
        until PostedBankDepositLine.Next() = 0;
    end;

    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        SourceCodeSetup: Record "Source Code Setup";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        LumpBalanceGLEntry: Record "G/L Entry";
        CurrentBankDepositHeader: Record "Bank Deposit Header";
        LineNo: Integer;
        ProgressDialog: Dialog;
        EmptyDepositErr: Label 'The deposit must have lines.';
        TotalAmountsMustMatchErr: Label 'The %1 must match the %2.', Comment = '%1 - total amount, %2 - total amount on the lines';
        LinesInSameTransactionForLumpSumErr: Label 'The lines of the deposit must belong to the same transaction when posting as lump sum. Please verify that %1, %2 and %3 are the same for every line or modify the template used to allow unbalanced documents.', Comment = '%1 - posting date field caption, %2 - document type field caption, %3 - document number field caption';
        PostingDepositTxt: Label 'Posting Bank Deposit No. %1...\\', Comment = '%1 - bank deposit number';
        BankDepositLineTxt: Label 'Bank Deposit Line  #2########\', Comment = '#2- a number (progress indicator)';
        DividerTxt: Label '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', Locked = true;
        StatusTxt: Label 'Status        #4###################\', Comment = '#4 - a number (progress indicator)';
        MovingToHistoryTxt: Label 'Moving Bank Deposit to History';
        PostingLinesToLedgersTxt: Label 'Posting Lines to Ledgers';

    local procedure CopyBankComments(BankDepositHeader: Record "Bank Deposit Header")
    var
        BankAccCommentLine: Record "Bank Acc. Comment Line";
        BankAccCommentLine2: Record "Bank Acc. Comment Line";
    begin
        BankAccCommentLine.Reset();
        BankAccCommentLine.SetRange("Table Name", BankAccCommentLine."Table Name"::"Bank Deposit Header");
        BankAccCommentLine.SetRange("Bank Account No.", BankDepositHeader."Bank Account No.");
        BankAccCommentLine.SetRange("No.", BankDepositHeader."No.");
        if BankAccCommentLine.FindSet() then
            repeat
                BankAccCommentLine2 := BankAccCommentLine;
                BankAccCommentLine2."Table Name" := BankAccCommentLine2."Table Name"::"Posted Bank Deposit Header";
                BankAccCommentLine2.Insert();
            until BankAccCommentLine.Next() = 0;
    end;

    local procedure DeleteBankComments(BankDepositHeader: Record "Bank Deposit Header")
    var
        BankAccCommentLine: Record "Bank Acc. Comment Line";
    begin
        BankAccCommentLine.Reset();
        BankAccCommentLine.SetRange("Table Name", BankAccCommentLine."Table Name"::"Bank Deposit Header");
        BankAccCommentLine.SetRange("Bank Account No.", BankDepositHeader."Bank Account No.");
        BankAccCommentLine.SetRange("No.", BankDepositHeader."No.");
        BankAccCommentLine.DeleteAll();
    end;

    local procedure InsertPostedBankDepositHeader(var BankDepositHeader: Record "Bank Deposit Header")
    var
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        PostedBankDepositHeader.Reset();
        PostedBankDepositHeader.TransferFields(BankDepositHeader, true);
        PostedBankDepositHeader."No. Printed" := 0;
        OnBeforePostedBankDepositHeaderInsert(PostedBankDepositHeader, BankDepositHeader);
        PostedBankDepositHeader.Insert();
        RecordLinkManagement.CopyLinks(BankDepositHeader, PostedBankDepositHeader);
    end;

    internal procedure SetCurrentDeposit(BankDepositHeader: Record "Bank Deposit Header")
    begin
        LineNo := 0;
        CurrentBankDepositHeader.Copy(BankDepositHeader);
    end;

    local procedure AssignVATDateIfEmpty(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."VAT Reporting Date" = 0D then begin
            GLSetup.GetRecordOnce();
            if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
                GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
            else
                GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean; var Posted: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var PostingGenJournalLine: Record "Gen. Journal Line")
    begin
        if (CurrentBankDepositHeader."Post as Lump Sum") and (GenJournalLine.Amount = CurrentBankDepositHeader."Total Deposit Amount") then begin
            OnBeforePostBalancingEntry(PostingGenJournalLine, CurrentBankDepositHeader, GenJnlPostLine);
            exit;
        end;
        OnBeforePostGenJournalLine(PostingGenJournalLine, CurrentBankDepositHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterPostGenJnlLine', '', false, false)]
    local procedure InsertPostedBankDepositLineAfterPostingGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; IsPosted: Boolean; var PostingGenJournalLine: Record "Gen. Journal Line")
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GLEntry: Record "G/L Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        if (CurrentBankDepositHeader."Post as Lump Sum") and (GenJournalLine.Amount = CurrentBankDepositHeader."Total Deposit Amount") then begin
            OnAfterPostBalancingEntry(PostingGenJournalLine);
            OnRunOnAfterPostBalancingEntry(PostingGenJournalLine);
            SetLumpSumBalanceEntry(PostingGenJournalLine);
            exit;
        end;
        LineNo += 1;
        PostedBankDepositLine."Bank Deposit No." := CurrentBankDepositHeader."No.";
        PostedBankDepositLine."Line No." := LineNo;
        PostedBankDepositLine."Account Type" := PostingGenJournalLine."Account Type";
        PostedBankDepositLine."Account No." := PostingGenJournalLine."Account No.";
        PostedBankDepositLine."Document Date" := PostingGenJournalLine."Document Date";
        PostedBankDepositLine."Document Type" := PostingGenJournalLine."Document Type";
        PostedBankDepositLine."Document No." := PostingGenJournalLine."Document No.";
        PostedBankDepositLine.Description := PostingGenJournalLine.Description;
        PostedBankDepositLine."Currency Code" := PostingGenJournalLine."Currency Code";
        PostedBankDepositLine.Amount := PostingGenJournalLine."Credit Amount";
        PostedBankDepositLine."Posting Group" := PostingGenJournalLine."Posting Group";
        PostedBankDepositLine."Shortcut Dimension 1 Code" := PostingGenJournalLine."Shortcut Dimension 1 Code";
        PostedBankDepositLine."Shortcut Dimension 2 Code" := PostingGenJournalLine."Shortcut Dimension 2 Code";
        PostedBankDepositLine."Dimension Set ID" := PostingGenJournalLine."Dimension Set ID";
        PostedBankDepositLine."Posting Date" := CurrentBankDepositHeader."Posting Date";
        case PostingGenJournalLine."Account Type" of
            PostingGenJournalLine."Account Type"::"G/L Account",
            PostingGenJournalLine."Account Type"::"Bank Account":
                if GLEntry.FindLast() then begin
                    PostedBankDepositLine."Entry No." := GLEntry."Entry No.";
                    if (not CurrentBankDepositHeader."Post as Lump Sum") and (PostingGenJournalLine.Amount * GLEntry.Amount < 0) then
                        PostedBankDepositLine."Entry No." -= 1;
                end;
            PostingGenJournalLine."Account Type"::Customer:
                if CustLedgerEntry.FindLast() then
                    PostedBankDepositLine."Entry No." := CustLedgerEntry."Entry No.";
            PostingGenJournalLine."Account Type"::Vendor:
                if VendorLedgerEntry.FindLast() then
                    PostedBankDepositLine."Entry No." := VendorLedgerEntry."Entry No.";
        end;
        if not CurrentBankDepositHeader."Post as Lump Sum" then
            if BankAccountLedgerEntry.FindLast() then begin
                PostedBankDepositLine."Bank Account Ledger Entry No." := BankAccountLedgerEntry."Entry No.";
                if (PostingGenJournalLine."Account Type" = PostingGenJournalLine."Account Type"::"Bank Account") and (PostingGenJournalLine.Amount * BankAccountLedgerEntry.Amount > 0) then
                    PostedBankDepositLine."Bank Account Ledger Entry No." -= 1;
            end;
        OnBeforePostedBankDepositLineInsert(PostedBankDepositLine, PostingGenJournalLine);
        PostedBankDepositLine.Insert();
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckBankDeposit(BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBankDepositPost(BankDepositHeader: Record "Bank Deposit Header"; var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostBalancingEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBankDepositPost(var BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostBalancingEntry(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedBankDepositHeaderInsert(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; BankDepositHeader: Record "Bank Deposit Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedBankDepositLineInsert(var PostedBankDepositLine: Record "Posted Bank Deposit Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

#if not CLEAN24
    [Obsolete('Posted Bank Deposit Lines are not modified after created anymore, they are created with the required information. Adapt the logic to use OnBeforePostedBankDepositLineInsert. This procedure is only called when setting the balancing entries to all the posted deposit lines and GenJournalLine is meaningless.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedBankDepositLineModify(var PostedBankDepositLine: Record "Posted Bank Deposit Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterPostBalancingEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeGenJournalLineDeleteAll(var BankDepositHeader: Record "Bank Deposit Header"; var PostedBankDepositLine: Record "Posted Bank Deposit Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}



