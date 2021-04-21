codeunit 18995 "Library Voucher Interface"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";

    procedure VerifyVoucherGLEntryCount(JnlBatchName: Code[10]; ExpectedCount: Integer): Code[20]
    var
        GLEntry: Record "G/L Entry";
        Assert: Codeunit Assert;
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        Assert.RecordCount(GLEntry, ExpectedCount);
        exit(GLEntry."Document No.");
    end;

    procedure AssignChequeNo(DocumentNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
        LibUtility: Codeunit "Library - Utility";
        ChequeNo: Code[20];
    begin
        ChequeNo := LibUtility.GenerateRandomCode(GenJnlLine.FieldNo("Cheque No."), DATABASE::"Gen. Journal Line");
        GenJnlLine.SetRange("Document No.", DocumentNo);
        if GenJnlLine.FindSet(true, false) then begin
            GenJnlLine.ModifyAll("Cheque No.", ChequeNo);
            GenJnlLine.ModifyAll("Cheque Date", CalcDate('< +1D>', WorkDate()), true);
        end;
    end;

    procedure AssignVoucherNarration(DocumentNo: Code[20])
    var
        LineNarration: Record "Gen. Journal Narration";
        GenJnlLine: Record "Gen. Journal Line";
        LibRandom: Codeunit "Library - Random";
    begin
        GenJnlLine.SetRange("Document No.", DocumentNo);
        if GenJnlLine.FindFirst() then begin
            LineNarration.Init();
            LineNarration.Validate("Journal Template Name", GenJnlLine."Journal Template Name");
            LineNarration.Validate("Journal Batch Name", GenJnlLine."Journal Batch Name");
            LineNarration.Validate("Document No.", GenJnlLine."Document No.");
            LineNarration.Validate("Line No.", GenJnlLine."Line No.");
            LineNarration.Validate(Narration, LibRandom.RandText(250));
            LineNarration.Insert(true);
        end;
    end;

    procedure AssignLineNarration(DocumentNo: Code[20])
    var
        LineNarration: Record "Gen. Journal Narration";
        GenJnlLine: Record "Gen. Journal Line";
        LibRandom: Codeunit "Library - Random";
        NarationText: Text;
    begin
        NarationText := LibRandom.RandText(250);
        GenJnlLine.SetRange("Document No.", DocumentNo);
        if GenJnlLine.FindSet() then
            repeat
                LineNarration.Init();
                LineNarration.Validate("Journal Template Name", GenJnlLine."Journal Template Name");
                LineNarration.Validate("Journal Batch Name", GenJnlLine."Journal Batch Name");
                LineNarration.Validate("Document No.", GenJnlLine."Document No.");
                LineNarration.Validate("Gen. Journal Line No.", GenJnlLine."Line No.");
                LineNarration.Validate("Line No.", GenJnlLine."Line No.");
                LineNarration.Validate(Narration, NarationText);
                LineNarration.Insert(true);
            until GenJnlLine.Next() = 0;
    end;

    procedure CreateGenJournalLineForGLToCustomer(
        var GenJournalLine: Record "Gen. Journal Line";
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        LineNarration: Boolean;
        GLAccNo: Code[20])
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"G/L Account", GLAccNo,
            GenJournalLine."Bal. Account Type"::Customer, Customer."No.",
            10000);
        if LineNarration then
            AssignLineNarration(GenJournalLine."Document No.");
    end;

    procedure CreateGenJournalLineForGLAccount(
        var GenJournalLine: Record "Gen. Journal Line";
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        LineNarration: Boolean;
        GLAccNo: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Bank Account", BankAccount."No.",
            GenJournalLine."Bal. Account Type"::"G/L Account", GLAccNo,
            10000);
        if LineNarration then
            AssignLineNarration(GenJournalLine."Document No.");
    end;

    procedure CreateGenJournalLineForBankToCustomer(
        var GenJournalLine: Record "Gen. Journal Line";
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        LineNarration: Boolean;
        BankAccNo: Code[20])
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Bank Account", BankAccNo,
            GenJournalLine."Bal. Account Type"::Customer, Customer."No.",
            10000);
        if LineNarration then
            AssignLineNarration(GenJournalLine."Document No.");
    end;

    procedure CreateGenJournalLineForVendorToBank(
        var GenJournalLine: Record "Gen. Journal Line";
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        LineNarration: Boolean;
        BankAccNo: Code[20])
    var
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Vendor, Vendor."No.",
            GenJournalLine."Account Type"::"Bank Account", BankAccNo,
            10000);
        if LineNarration then
            AssignLineNarration(GenJournalLine."Document No.");
    end;
}