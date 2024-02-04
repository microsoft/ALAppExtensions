namespace Microsoft.Bank.Reconciliation.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Account;
using System.TestLibraries.Utilities;

codeunit 139777 "Bank Rec. With AI Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Account Reconciliation With AI]
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        isInitialized: Boolean;

    [Test]
    procedure TestBuildBankRecStatementLines()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
        BankRecStatementLinesTxt: Text;
    begin
        Initialize();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description);
        CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2), CopyStr(LibraryRandom.RandText(10), 1, 50));
        CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2), CopyStr(LibraryRandom.RandText(10), 1, 50));
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, WorkDate(), Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, WorkDate(), '', '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2)));

        // Execute
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankRecAIMatchingImpl.BuildBankRecStatementLines(BankRecStatementLinesTxt, BankAccReconciliationLine);

        // Assert
        BankAccReconciliationLine.FindSet();
        repeat
            Assert.IsTrue(StrPos(BankRecStatementLinesTxt, '#Id: ' + Format(BankAccReconciliationLine."Statement Line No.")) > 0, 'Expected statement line no not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecStatementLinesTxt, 'Description: ' + Format(BankAccReconciliationLine.Description)) > 0, 'Expected statement line description not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecStatementLinesTxt, 'Amount: ' + Format(BankAccReconciliationLine.Difference, 0, 9)) > 0, 'Expected statement line amount not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecStatementLinesTxt, 'Date: ' + Format(BankAccReconciliationLine."Transaction Date", 0, 9)) > 0, 'Expected statement line date not being sent to Copilot');
        until BankAccReconciliationLine.Next() = 0;
    end;

    [Test]
    procedure TestBuildBankAccountLedgerEntries()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        EntryNos: List of [Integer];
        BankRecLedgerEntriesTxt: Text;
    begin
        Initialize();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2), CopyStr(LibraryRandom.RandText(10), 1, 50)));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2), CopyStr(LibraryRandom.RandText(10), 1, 50)));
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount);
        CreateBankAccRecLine(BankAccReconciliation, WorkDate(), Description, '', Amount);
        CreateBankAccRecLine(BankAccReconciliation, WorkDate(), '', '', Amount);
        CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount - LibraryRandom.RandDec(100, 2));

        // Execute
        BankAccountLedgerEntry.SetFilter("Entry No.", Format(EntryNos.Get(1)) + '|' + Format(EntryNos.Get(2)) + '|' + Format(EntryNos.Get(3)));
        BankAccountLedgerEntry.FindSet();
        repeat
            InsertFromBankAccLedgerEntry(TempLedgerEntryMatchingBuffer, BankAccountLedgerEntry)
        until BankAccountLedgerEntry.Next() = 0;
        TempLedgerEntryMatchingBuffer.FindSet();
        BankRecAIMatchingImpl.BuildBankRecLedgerEntries(BankRecLedgerEntriesTxt, TempLedgerEntryMatchingBuffer);

        // Assert
        BankAccountLedgerEntry.FindSet();
        repeat
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, '#Id: ' + Format(BankAccountLedgerEntry."Entry No.")) > 0, 'Expected ledger entry not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Description: ' + Format(BankAccountLedgerEntry.Description)) > 0, 'Expected ledger entry description not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Amount: ' + Format(BankAccountLedgerEntry."Remaining Amount", 0, 9)) > 0, 'Expected ledger entry amount not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Date: ' + Format(BankAccountLedgerEntry."Posting Date", 0, 9)) > 0, 'Expected ledger entry date not being sent to Copilot');
        until BankAccountLedgerEntry.Next() = 0;
    end;

    [Test]
    procedure TestApplyAcceptedCopilotMatches()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        EntryNos: List of [Integer];
        LineNos: List of [Integer];
    begin
        Initialize();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));
        CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount);

        // Execute
        // Propose to match Entries 1 and 2 to statement line 1, entry 3 to statement line 2, entry 4 to statement line 3
        // Then apply the proposal
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Bank Account Ledger Entry No." := EntryNos.Get(1);
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Bank Account Ledger Entry No." := EntryNos.Get(2);
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Bank Account Ledger Entry No." := EntryNos.Get(3);
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."Bank Account Ledger Entry No." := EntryNos.Get(4);
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        BankRecAIMatchingImpl.ApplyToProposedLedgerEntries(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer);

        // Assert
        BankAccountLedgerEntry.Get(EntryNos.Get(1));
        Assert.AreEqual(BankAccountLedgerEntry."Statement No.", BankAccReconciliation."Statement No.", '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Line No.", LineNos.Get(1), '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied", '');
        BankAccountLedgerEntry.Get(EntryNos.Get(2));
        Assert.AreEqual(BankAccountLedgerEntry."Statement No.", BankAccReconciliation."Statement No.", '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Line No.", LineNos.Get(1), '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied", '');
        BankAccountLedgerEntry.Get(EntryNos.Get(3));
        Assert.AreEqual(BankAccountLedgerEntry."Statement No.", BankAccReconciliation."Statement No.", '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Line No.", LineNos.Get(2), '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied", '');
        BankAccountLedgerEntry.Get(EntryNos.Get(4));
        Assert.AreEqual(BankAccountLedgerEntry."Statement No.", BankAccReconciliation."Statement No.", '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Line No.", LineNos.Get(3), '');
        Assert.AreEqual(BankAccountLedgerEntry."Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied", '');
    end;

    [Test]
    procedure TestPostNewPaymentsToProposedGLAccounts()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GLAccount: Record "G/L Account";
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
    begin
        Initialize();

        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.DeleteAll();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));

        // Execute
        // Propose to match Entries 1 and 2 to statement line 1, entry 3 to statement line 2, entry 4 to statement line 3
        // Then apply the proposal
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Difference := Amount + Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        BankRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer);

        // Assert
        BankAccountLedgerEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(1));
        BankAccountLedgerEntry.SetRange("Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(1)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(2));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(2)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(3));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(3)) + ' not applied.');
    end;

    [Test]
    procedure ProcessCopilotAnswerTransferToGLAccountPositive()
    var
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        CompletionAnswerTxt: Text;
        Result: Dictionary of [Integer, Code[20]];
    begin
        CompletionAnswerTxt := 'blaabla(1000, Salaries), (2000, Gasoline)    blabla';
        BankRecTransToAcc.ProcessCompletionAnswer(CompletionAnswerTxt, Result);
        Assert.AreEqual(2, Result.Count(), '');
        Assert.AreEqual('GASOLINE', Result.Get(2000), '');
        Assert.AreEqual('SALARIES', Result.Get(1000), '');
    end;

    [Test]
    procedure ProcessCopilotAnswerTransferToGLAccountNegative()
    var
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        CompletionAnswerTxt: Text;
        Result: Dictionary of [Integer, Code[20]];
    begin
        CompletionAnswerTxt := 'No suitable G/L Account whose name has cosine similarity over 0.8 could be found.';
        BankRecTransToAcc.ProcessCompletionAnswer(CompletionAnswerTxt, Result);
        Assert.AreEqual(0, Result.Count(), '');
    end;

    [Test]
    procedure ProcessCopilotMatchingAnswerNegative()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        EntryNos: List of [Integer];
        LineNos: List of [Integer];
        NumberOfMatches: Integer;
        CompletionAnswerTxt: Text;
    begin
        NumberOfMatches := 0;
        Initialize();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));
        CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount);

        // Execute
        CompletionAnswerTxt := 'No match found';
        BankRecAIMatchingImpl.ProcessCompletionAnswer(CompletionAnswerTxt, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, NumberOfMatches);

        // Assert
        Assert.AreEqual(0, NumberOfMatches, '');
        Assert.AreEqual(0, TempBankStatementMatchingBuffer.Count(), '')
    end;

    [Test]
    procedure ProcessCopilotMatchingAnswerPositive()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        EntryNos: List of [Integer];
        LineNos: List of [Integer];
        NumberOfMatches: Integer;
        CompletionAnswerTxt: Text;
    begin
        NumberOfMatches := 0;
        Initialize();

        // Setup.
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        BankAccountLedgerEntry.Get(EntryNos.Get(1));
        InsertFromBankAccLedgerEntry(TempBankAccLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        BankAccountLedgerEntry.Get(EntryNos.Get(2));
        InsertFromBankAccLedgerEntry(TempBankAccLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        BankAccountLedgerEntry.Get(EntryNos.Get(3));
        InsertFromBankAccLedgerEntry(TempBankAccLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
        EntryNos.Add(CreateBankAccLedgerEntry(BankAccountNo, PostingDate, DocumentNo, '', Amount, Description));
        BankAccountLedgerEntry.Get(EntryNos.Get(4));
        InsertFromBankAccLedgerEntry(TempBankAccLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));
        CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount);
        BankAccReconciliationLine.Get(BankAccReconciliation."Statement Type", BankAccReconciliation."Bank Account No.", BankAccReconciliation."Statement No.", LineNos.Get(1));

        // Execute
        CompletionAnswerTxt := 'blablabla(' + Format(LineNos.Get(1)) + ', [' + Format(EntryNos.Get(1)) + ', ' + Format(EntryNos.Get(2)) + ']), (' + Format(LineNos.Get(2)) + ', [' + Format(EntryNos.Get(3)) + ']))  bla bla';
        BankRecAIMatchingImpl.ProcessCompletionAnswer(CompletionAnswerTxt, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, NumberOfMatches);

        // Assert
        Assert.AreEqual(3, NumberOfMatches, '');
        Assert.AreEqual(3, TempBankStatementMatchingBuffer.Count(), '');
        Assert.IsTrue(TempBankStatementMatchingBuffer.Get(LineNos.Get(1), EntryNos.Get(1)), '');
        Assert.IsTrue(TempBankStatementMatchingBuffer.Get(LineNos.Get(1), EntryNos.Get(2)), '');
        Assert.IsTrue(TempBankStatementMatchingBuffer.Get(LineNos.Get(2), EntryNos.Get(3)), '');
    end;

    local procedure Initialize()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Bank Rec. With AI Tests");
        LibraryApplicationArea.EnableFoundationSetup();
        BankAccReconciliationLine.DeleteAll();
        BankAccReconciliation.DeleteAll();

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Bank Rec. With AI Tests");

        LibraryERMCountryData.UpdateLocalData();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalPostingSetup();
        LibraryVariableStorage.Clear();

        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Bank Rec. With AI Tests");
    end;

    local procedure InsertFromBankAccLedgerEntry(var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    begin
        TempLedgerEntryMatchingBuffer."Entry No." := BankAccountLedgerEntry."Entry No.";
        TempLedgerEntryMatchingBuffer."Account Type" := TempLedgerEntryMatchingBuffer."Account Type"::"Bank Account";
        TempLedgerEntryMatchingBuffer."Account No." := BankAccountLedgerEntry."Bank Account No.";
        TempLedgerEntryMatchingBuffer."Bal. Account Type" := BankAccountLedgerEntry."Bal. Account Type";
        TempLedgerEntryMatchingBuffer."Bal. Account No." := BankAccountLedgerEntry."Bal. Account No.";
        TempLedgerEntryMatchingBuffer.Description := BankAccountLedgerEntry.Description;
        TempLedgerEntryMatchingBuffer."Posting Date" := BankAccountLedgerEntry."Posting Date";
        TempLedgerEntryMatchingBuffer."Document Type" := BankAccountLedgerEntry."Document Type";
        TempLedgerEntryMatchingBuffer."Document No." := BankAccountLedgerEntry."Document No.";
        TempLedgerEntryMatchingBuffer."External Document No." := BankAccountLedgerEntry."External Document No.";
        TempLedgerEntryMatchingBuffer."Remaining Amount" := BankAccountLedgerEntry."Remaining Amount";
        TempLedgerEntryMatchingBuffer."Remaining Amt. Incl. Discount" := BankAccountLedgerEntry."Remaining Amount";
        TempLedgerEntryMatchingBuffer.Insert(true);
    end;


    /*
        local procedure CreateBankAccountWithNo(var BankAccount: Record "Bank Account"; BankAccountNo: Code[20])
        var
            BankAccountPostingGroup: Record "Bank Account Posting Group";
            BankContUpdate: Codeunit "BankCont-Update";
            LibraryERM: Codeunit "Library - ERM";
        begin
            LibraryERM.FindBankAccountPostingGroup(BankAccountPostingGroup);
            BankAccount.Init();
            BankAccount.Validate("No.", BankAccountNo);
            BankAccount.Validate(Name, BankAccount."No.");  // Validating No. as Name because value is not important.
            BankAccount.Insert(true);
            BankAccount.Validate("Bank Acc. Posting Group", BankAccountPostingGroup.Code);
            BankAccount.Modify(true);
            BankContUpdate.OnModify(BankAccount);
        end;

        local procedure AddBankRecLinesToTemp(var TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; BankAccReconciliation: Record "Bank Acc. Reconciliation")
        var
            BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        begin
            TempBankAccReconciliationLine.Reset();
            TempBankAccReconciliationLine.DeleteAll();
            BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
            BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
            BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
            if BankAccReconciliationLine.FindSet() then
                repeat
                    TempBankAccReconciliationLine := BankAccReconciliationLine;
                    TempBankAccReconciliationLine.Insert();
                until BankAccReconciliationLine.Next() = 0;
        end;

        local procedure AddBankEntriesToTemp(var TempBankAccLedgerEntry: Record "Bank Account Ledger Entry" temporary; BankAccountNo: Code[20])
        var
            BankAccLedgerEntry: Record "Bank Account Ledger Entry";
        begin
            TempBankAccLedgerEntry.Reset();
            TempBankAccLedgerEntry.DeleteAll();
            BankAccLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
            if BankAccLedgerEntry.FindSet() then
                repeat
                    TempBankAccLedgerEntry := BankAccLedgerEntry;
                    TempBankAccLedgerEntry.Insert();
                until BankAccLedgerEntry.Next() = 0;
        end;
    */

    local procedure CreateInputData(var PostingDate: Date; var BankAccountNo: Code[20]; var StatementNo: Code[20]; var DocumentNo: Code[20]; var Description: Text[50]; var Amount: Decimal)
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankAccount: Record "Bank Account";
    begin
        Amount := -LibraryRandom.RandDec(1000, 2);
        PostingDate := WorkDate() - LibraryRandom.RandInt(10);
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccountNo := BankAccount."No.";
        StatementNo := LibraryUtility.GenerateRandomCode(BankAccReconciliationLine.FieldNo("Statement No."),
            DATABASE::"Bank Acc. Reconciliation Line");
        DocumentNo := LibraryUtility.GenerateRandomCode(BankAccReconciliationLine.FieldNo("Document No."),
            DATABASE::"Bank Acc. Reconciliation Line");
        Description := CopyStr(CreateGuid(), 1, 50);
    end;

    local procedure CreateBankAccRec(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankAccountNo: Code[20]; StatementNo: Code[20])
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation."Bank Account No." := BankAccountNo;
        BankAccReconciliation."Statement No." := StatementNo;
        BankAccReconciliation."Statement Date" := WorkDate();
        BankAccReconciliation.Insert();
    end;

    local procedure CreateBankAccRecLine(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; TransactionDate: Date; Description: Text[50]; PayerInfo: Text[50]; Amount: Decimal): Integer
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        if BankAccReconciliationLine.FindLast() then;

        BankAccReconciliationLine.Init();
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        BankAccReconciliationLine."Statement Line No." += 10000;
        BankAccReconciliationLine."Transaction Date" := TransactionDate;
        BankAccReconciliationLine.Description := Description;
        BankAccReconciliationLine."Related-Party Name" := PayerInfo;
        BankAccReconciliationLine."Statement Amount" := Amount;
        BankAccReconciliationLine.Difference := Amount;
        BankAccReconciliationLine.Insert();

        exit(BankAccReconciliationLine."Statement Line No.");
    end;

    local procedure CreateBankAccLedgerEntry(BankAccountNo: Code[20]; PostingDate: Date; DocumentNo: Code[20]; ExtDocNo: Code[35]; Amount: Decimal; Description: Text[50]): Integer
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        if BankAccountLedgerEntry.FindLast() then;

        BankAccountLedgerEntry.Init();
        BankAccountLedgerEntry."Entry No." += 1;
        BankAccountLedgerEntry."Bank Account No." := BankAccountNo;
        BankAccountLedgerEntry."Posting Date" := PostingDate;
        BankAccountLedgerEntry."Document No." := DocumentNo;
        BankAccountLedgerEntry.Amount := Amount;
        BankAccountLedgerEntry."Remaining Amount" := Amount;
        BankAccountLedgerEntry.Description := Description;
        BankAccountLedgerEntry."External Document No." := ExtDocNo;
        BankAccountLedgerEntry.Open := true;
        BankAccountLedgerEntry."Statement Status" := BankAccountLedgerEntry."Statement Status"::Open;
        BankAccountLedgerEntry.Insert();

        exit(BankAccountLedgerEntry."Entry No.");
    end;
}