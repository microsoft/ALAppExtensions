codeunit 1690 "Bank Deposit-Post"
{
    Permissions = TableData "Cust. Ledger Entry" = r,
                  TableData "Vendor Ledger Entry" = r,
                  TableData "Bank Account Ledger Entry" = r,
                  TableData "Bank Acc. Comment Line" = rimd,
                  TableData "Bank Deposit Header" = r,
                  TableData "Posted Bank Deposit Header" = rim,
                  TableData "Posted Bank Deposit Line" = rim;
    TableNo = "Bank Deposit Header";

    trigger OnRun()
    var
        GLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        TotalAmountLCY: Decimal;
        NextLineNo: Integer;
        CurrLineNo: Integer;
    begin
        OnBeforeBankDepositPost(Rec);

        // Check deposit
        TestField("Posting Date");
        TestField("Total Deposit Amount");
        TestField("Document Date");
        TestField("Bank Account No.");
        BankAccount.Get("Bank Account No.");
        BankAccount.TestField(Blocked, false);
        CalcFields("Total Deposit Lines");
        if "Total Deposit Lines" <> "Total Deposit Amount" then
            Error(TotalAmountsMustMatchErr, FieldCaption("Total Deposit Amount"), FieldCaption("Total Deposit Lines"));

        OnAfterCheckBankDeposit(Rec);

        if "Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get("Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        SourceCodeSetup.Get();

        NextLineNo := 0;
        TotalAmountLCY := 0;
        CurrLineNo := 0;
        ProgressDialog.Open(
          StrSubstNo(PostingDepositTxt, "No.") +
          StatusTxt +
          BankDepositLineTxt +
          DividerTxt);

        ProgressDialog.Update(4, MovingToHistoryTxt);

        PostedBankDepositHeader.LockTable();
        PostedBankDepositLine.LockTable();
        LockTable();
        GenJournalLine.LockTable();

        InsertPostedBankDepositHeader(Rec);

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if GenJournalLine.Find('-') then
            repeat
                NextLineNo := NextLineNo + 1;
                ProgressDialog.Update(2, NextLineNo);

                InsertPostedBankDepositLine(Rec, GenJournalLine, NextLineNo);

                if not "Post as Lump Sum" then
                    AddBalancingAccount(GenJournalLine, Rec)
                else
                    GenJournalLine."Bal. Account No." := '';
                GenJnlCheckLine.RunCheck(GenJournalLine);
            until GenJournalLine.Next() = 0;

        CopyBankComments(Rec);

        // Post to General, and other, Ledgers
        ProgressDialog.Update(4, PostingLinesToLedgersTxt);
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if GenJournalLine.Find('-') then
            repeat
                CurrLineNo := CurrLineNo + 1;
                ProgressDialog.Update(2, CurrLineNo);
                ProgressDialog.Update(3, Round(CurrLineNo / NextLineNo * 10000, 1));
                if not "Post as Lump Sum" then
                    AddBalancingAccount(GenJournalLine, Rec)
                else begin
                    TotalAmountLCY += GenJournalLine."Amount (LCY)";
                    GenJournalLine."Bal. Account No." := '';
                end;
                GenJournalLine."Source Code" := SourceCodeSetup."Bank Deposit";
                GenJournalLine."Source Type" := GenJournalLine."Source Type"::"Bank Account";
                GenJournalLine."Source No." := "Bank Account No.";
                GenJournalLine."Source Currency Code" := "Currency Code";
                GenJournalLine."Source Currency Amount" := GenJournalLine.Amount;
                OnBeforePostGenJournalLine(GenJournalLine, Rec, GenJnlPostLine);
                GenJnlPostLine.RunWithoutCheck(GenJournalLine);

                PostedBankDepositLine.Get("No.", CurrLineNo);
                case GenJournalLine."Account Type" of
                    GenJournalLine."Account Type"::"G/L Account",
                    GenJournalLine."Account Type"::"Bank Account":
                        begin
                            GLEntry.FindLast();
                            PostedBankDepositLine."Entry No." := GLEntry."Entry No.";
                            if (not "Post as Lump Sum") and (GenJournalLine.Amount * GLEntry.Amount < 0) then
                                PostedBankDepositLine."Entry No." := PostedBankDepositLine."Entry No." - 1;
                        end;
                    GenJournalLine."Account Type"::Customer:
                        begin
                            CustLedgerEntry.FindLast();
                            PostedBankDepositLine."Entry No." := CustLedgerEntry."Entry No.";
                        end;
                    GenJournalLine."Account Type"::Vendor:
                        begin
                            VendorLedgerEntry.FindLast();
                            PostedBankDepositLine."Entry No." := VendorLedgerEntry."Entry No.";
                        end;
                end;
                if not "Post as Lump Sum" then begin
                    BankAccountLedgerEntry.FindLast();
                    PostedBankDepositLine."Bank Account Ledger Entry No." := BankAccountLedgerEntry."Entry No.";
                    if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and
                       (GenJournalLine.Amount * BankAccountLedgerEntry.Amount > 0)
                    then
                        PostedBankDepositLine."Entry No." := PostedBankDepositLine."Entry No." - 1;
                end;
                OnBeforePostedBankDepositLineModify(PostedBankDepositLine, GenJournalLine);
                PostedBankDepositLine.Modify();
            until GenJournalLine.Next() = 0;

        ProgressDialog.Update(4, PostingBankEntryTxt);
        if "Post as Lump Sum" then begin
            PostBalancingEntry(Rec, TotalAmountLCY);
            OnRunOnAfterPostBalancingEntry(GenJournalLine);

            BankAccountLedgerEntry.FindLast();
            PostedBankDepositLine.Reset();
            PostedBankDepositLine.SetRange("Bank Deposit No.", "No.");
            if PostedBankDepositLine.FindSet(true) then
                repeat
                    PostedBankDepositLine."Bank Account Ledger Entry No." := BankAccountLedgerEntry."Entry No.";
                    PostedBankDepositLine.Modify();
                until PostedBankDepositLine.Next() = 0;
        end;

        ProgressDialog.Update(4, RemovingBankDepositTxt);
        DeleteBankComments(Rec);

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        OnRunOnBeforeGenJournalLineDeleteAll(Rec, PostedBankDepositLine, GenJournalLine);
        GenJournalLine.DeleteAll();
        GenJournalBatch.Get("Journal Template Name", "Journal Batch Name");
        if IncStr("Journal Batch Name") <> '' then begin
            GenJournalBatch.Get("Journal Template Name", "Journal Batch Name");
            GenJournalBatch.Delete();
            GenJournalBatch.Name := IncStr("Journal Batch Name");
            if GenJournalBatch.Insert() then;
        end;

        Delete();
        Commit();

        UpdateAnalysisView.UpdateAll(0, true);

        OnAfterBankDepositPost(Rec, PostedBankDepositHeader);

        Page.Run(Page::"Posted Bank Deposit", PostedBankDepositHeader);
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

    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        SourceCodeSetup: Record "Source Code Setup";
        Currency: Record Currency;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ProgressDialog: Dialog;
        TotalAmountsMustMatchErr: Label 'The %1 must match the %2.', Comment = '%1 - total amount, %2 - total amount on the lines';
        PostingDepositTxt: Label 'Posting Bank Deposit No. %1...\\', Comment = '%1 - bank deposit number';
        BankDepositLineTxt: Label 'Bank Deposit Line  #2########\';
        DividerTxt: Label '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', Locked = true;
        StatusTxt: Label 'Status        #4###################\';
        MovingToHistoryTxt: Label 'Moving Bank Deposit to History';
        PostingLinesToLedgersTxt: Label 'Posting Lines to Ledgers';
        PostingBankEntryTxt: Label 'Posting Bank Account Ledger Entry';
        RemovingBankDepositTxt: Label 'Removing Bank Deposit';

    local procedure AddBalancingAccount(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header")
    begin
        with GenJournalLine do begin
            "Bal. Account Type" := "Bal. Account Type"::"Bank Account";
            "Bal. Account No." := BankDepositHeader."Bank Account No.";
            "Balance (LCY)" := 0;
        end;
    end;

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

    local procedure InsertPostedBankDepositLine(BankDepositHeader: Record "Bank Deposit Header"; GenJournalLine: Record "Gen. Journal Line"; LineNo: Integer)
    begin
        with PostedBankDepositLine do begin
            "Bank Deposit No." := BankDepositHeader."No.";
            "Line No." := LineNo;
            "Account Type" := GenJournalLine."Account Type";
            "Account No." := GenJournalLine."Account No.";
            "Document Date" := GenJournalLine."Document Date";
            "Document Type" := GenJournalLine."Document Type";
            "Document No." := GenJournalLine."Document No.";
            Description := GenJournalLine.Description;
            "Currency Code" := GenJournalLine."Currency Code";
            Amount := -GenJournalLine.Amount;
            "Posting Group" := GenJournalLine."Posting Group";
            "Shortcut Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
            "Dimension Set ID" := GenJournalLine."Dimension Set ID";
            "Posting Date" := BankDepositHeader."Posting Date";
            OnBeforePostedBankDepositLineInsert(PostedBankDepositLine, GenJournalLine);
            Insert();
        end;
    end;

    local procedure PostBalancingEntry(BankDepositHeader: Record "Bank Deposit Header"; TotalAmountLCY: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        with GenJournalLine do begin
            Init();
            "Account Type" := "Account Type"::"Bank Account";
            "Account No." := BankDepositHeader."Bank Account No.";
            "Posting Date" := BankDepositHeader."Posting Date";
            "Document No." := BankDepositHeader."No.";
            "Currency Code" := BankDepositHeader."Currency Code";
            "Currency Factor" := BankDepositHeader."Currency Factor";
            "Posting Group" := BankDepositHeader."Bank Acc. Posting Group";
            "Shortcut Dimension 1 Code" := BankDepositHeader."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := BankDepositHeader."Shortcut Dimension 2 Code";
            "Dimension Set ID" := BankDepositHeader."Dimension Set ID";
            "Source Code" := SourceCodeSetup."Bank Deposit";
            "Reason Code" := BankDepositHeader."Reason Code";
            "Document Date" := BankDepositHeader."Document Date";
            "External Document No." := BankDepositHeader."No.";
            "Source Type" := "Source Type"::"Bank Account";
            "Source No." := BankDepositHeader."Bank Account No.";
            "Source Currency Code" := BankDepositHeader."Currency Code";
            Description := BankDepositHeader."Posting Description";
            Amount := BankDepositHeader."Total Deposit Amount";
            "Source Currency Amount" := BankDepositHeader."Total Deposit Amount";
            "Journal Template Name" := BankDepositHeader."Journal Template Name";
            Validate(Amount);
            "Amount (LCY)" := -TotalAmountLCY;
            OnBeforePostBalancingEntry(GenJournalLine, BankDepositHeader, GenJnlPostLine);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            OnAfterPostBalancingEntry(GenJournalLine);
        end;
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedBankDepositLineModify(var PostedBankDepositLine: Record "Posted Bank Deposit Line"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterPostBalancingEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeGenJournalLineDeleteAll(var BankDepositHeader: Record "Bank Deposit Header"; var PostedBankDepositLine: Record "Posted Bank Deposit Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}

