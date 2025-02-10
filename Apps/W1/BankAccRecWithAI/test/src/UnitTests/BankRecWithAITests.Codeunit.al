namespace Microsoft.Bank.Reconciliation.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Account;
using System.TestLibraries.Utilities;
using Microsoft.Finance.Dimension;

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
        CandidateLedgerEntryNos: List of [Integer];
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
        BankRecAIMatchingImpl.BuildBankRecLedgerEntries(BankRecLedgerEntriesTxt, TempLedgerEntryMatchingBuffer, CandidateLedgerEntryNos);

        // Assert
        BankAccountLedgerEntry.FindSet();
        repeat
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, '#Id: ' + Format(BankAccountLedgerEntry."Entry No.")) > 0, 'Expected ledger entry not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Description: ' + Format(BankAccountLedgerEntry.Description)) > 0, 'Expected ledger entry description not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Amount: ' + Format(BankAccountLedgerEntry."Remaining Amount", 0, 9)) > 0, 'Expected ledger entry amount not being sent to Copilot');
            Assert.IsTrue(StrPos(BankRecLedgerEntriesTxt, 'Date: ' + Format(BankAccountLedgerEntry."Posting Date", 0, 9)) > 0, 'Expected ledger entry date not being sent to Copilot');
        until BankAccountLedgerEntry.Next() = 0;
        Assert.AreEqual(CandidateLedgerEntryNos.Count(), BankAccountLedgerEntry.Count(), '');
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
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        Dimension1, Dimension2 : Record Dimension;
        DimensionValue11, DimensionValue12, DimensionValue21, DimensionValue22 : Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
        LastDimSetID: Integer;
    begin
        // [SCENARIO 546904] Bank Rec: Post Diff to G/L - missing ability to add dimension to suggested lines
        Initialize();

        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.DeleteAll();

        // [Given] G/L Accounts, Dimensions and a set of bank account reconciliation lines
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateDimension(Dimension1);
        LibraryERM.CreateDimensionValue(DimensionValue11, Dimension1.Code);
        LibraryERM.CreateDimensionValue(DimensionValue12, Dimension1.Code);
        LibraryERM.CreateDimension(Dimension2);
        LibraryERM.CreateDimensionValue(DimensionValue21, Dimension2.Code);
        LibraryERM.CreateDimensionValue(DimensionValue22, Dimension2.Code);
        Commit();
        LibraryUtility.CreateNoSeries(NoSeries, false, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'T0900000', 'T0999999');
        NoSeriesLine."Last No. Used" := 'T0900001';
        NoSeriesLine."Increment-by No." := 10;
        NoSeriesLine.Modify();
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch."No. Series" := NoSeries.Code;
        GenJournalBatch.Modify();
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));

        // [GIVEN] Copilot proposes to match Entries 1 and 2 to statement line 1, entry 3 to statement line 2, entry 4 to statement line 3
        // [GIVEN] user adds dimensions to the proposals
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Journal Template Name" := GenJournalTemplate.Name;
        TempBankAccRecAIProposal."Journal Batch Name" := GenJournalBatch.Name;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount + Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        if DimensionSetEntry.FindLast() then
            LastDimSetID := DimensionSetEntry."Dimension Set ID";
        LastDimSetID += 1;
        Clear(DimensionSetEntry);
        DimensionSetEntry."Dimension Set ID" := LastDimSetID;
        DimensionSetEntry."Dimension Code" := Dimension1.Code;
        DimensionSetEntry."Dimension Value Code" := DimensionValue12.Code;
        DimensionSetEntry."Dimension Value ID" := DimensionValue12."Dimension Value ID";
        DimensionSetEntry.Insert();
        DimensionSetEntry."Dimension Set ID" := LastDimSetID;
        DimensionSetEntry."Dimension Code" := Dimension2.Code;
        DimensionSetEntry."Dimension Value Code" := DimensionValue21.Code;
        DimensionSetEntry."Dimension Value ID" := DimensionValue21."Dimension Value ID";
        DimensionSetEntry.Insert();
        TempBankAccRecAIProposal."Dimension Set ID" := LastDimSetID;
        TempBankAccRecAIProposal.Description := DocumentNo;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        TransToGLAccJnlBatch.Init();
        TransToGLAccJnlBatch."Journal Template Name" := GenJournalTemplate.Name;
        TransToGLAccJnlBatch."Journal Batch Name" := GenJournalBatch.Name;
        TransToGLAccJnlBatch.Insert();

        // [WHEN] Accepting the proposal
        BankRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer, TransToGLAccJnlBatch);

        Commit();
        // [THEN] The proposed payments are posted, you get bank account ledger entries and dimension sets are transferred from the proposal lines to the ledger entries
        BankAccountLedgerEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(1));
        BankAccountLedgerEntry.SetRange("Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.IsTrue(BankAccountLedgerEntry.FindFirst(), 'Statement Line ' + Format(LineNos.Get(1)) + ' not applied.');
        Assert.AreEqual(0, BankAccountLedgerEntry."Dimension Set ID", 'Unexpected Dimension Set ID');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(2));
        Assert.IsTrue(BankAccountLedgerEntry.FindFirst(), 'Statement Line ' + Format(LineNos.Get(2)) + ' not applied.');
        Assert.AreEqual(0, BankAccountLedgerEntry."Dimension Set ID", 'Unexpected Dimension Set ID');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(3));
        Assert.IsTrue(BankAccountLedgerEntry.FindFirst(), 'Statement Line ' + Format(LineNos.Get(3)) + ' not applied.');
        DimensionSetEntry.SetRange("Dimension Set ID", BankAccountLedgerEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", Dimension1.Code);
        DimensionSetEntry.SetRange("Dimension Value ID", DimensionValue12."Dimension Value ID");
        Assert.IsFalse(DimensionSetEntry.IsEmpty(), 'Unexpected Dimension Set ID');
        DimensionSetEntry.SetRange("Dimension Code", Dimension2.Code);
        DimensionSetEntry.SetRange("Dimension Value ID", DimensionValue21."Dimension Value ID");
        Assert.IsFalse(DimensionSetEntry.IsEmpty(), 'Unexpected Dimension Set ID');
    end;

    [Test]
    procedure TestPostNewPaymentsToProposedGLAccountsCopyToPostedGenJnlLines()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
        PostedJournalLineCount: Integer;
    begin
        // [SCENARIO 544880] When using Post Difference to G/L Account, with a batch that uses 'Copy to Posted Journal lines' the posted payments must be copied to posted journal lines

        // [GIVEN] A Copilot proposal to post differences to G/L Accounts, that uses a journal batch with 'Copy to POsted Gen. Journal Lines'
        Initialize();
        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.DeleteAll();
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryUtility.CreateNoSeries(NoSeries, false, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'T0900000', 'T0999999');
        NoSeriesLine."Last No. Used" := 'T0900001';
        NoSeriesLine."Increment-by No." := 10;
        NoSeriesLine.Modify();
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch."No. Series" := NoSeries.Code;
        GenJournalBatch."Copy to Posted Jnl. Lines" := true;
        GenJournalBatch.Modify();
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));

        // [WHEN] You accept the proposal
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Journal Template Name" := GenJournalTemplate.Name;
        TempBankAccRecAIProposal."Journal Batch Name" := GenJournalBatch.Name;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount + Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := DocumentNo;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        TransToGLAccJnlBatch.Init();
        TransToGLAccJnlBatch."Journal Template Name" := GenJournalTemplate.Name;
        TransToGLAccJnlBatch."Journal Batch Name" := GenJournalBatch.Name;
        TransToGLAccJnlBatch.Insert();

        PostedGenJournalLine.SetRange("Journal Template Name", GenJournalTemplate.Name);
        PostedGenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        PostedJournalLineCount := PostedGenJournalLine.Count();
        BankRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer, TransToGLAccJnlBatch);

        // [THEN] New payments are posted, bank account ledger entries are matched with statement lines and posted general journal lines are copied]
        BankAccountLedgerEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(1));
        BankAccountLedgerEntry.SetRange("Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(1)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(2));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(2)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(3));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(3)) + ' not applied.');
        Assert.AreEqual(PostedJournalLineCount + 3, PostedGenJournalLine.Count(), 'Newly posted lines are not copied');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPostNewPaymentsToProposedGLAccountsDisallowedDatesOnTemplate()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
    begin
        // [SCENARIO 546902] When using Post Difference to G/L Account, no payments are posted for statement lines whose transaction date is outside of allowed posting date rage

        // [GIVEN] A bank account reconciliation with one line that has transaction date outside of allowed posting date range
        Initialize();
        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.DeleteAll();
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryUtility.CreateNoSeries(NoSeries, false, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'T0900000', 'T0999999');
        NoSeriesLine."Last No. Used" := 'T0900001';
        NoSeriesLine."Increment-by No." := 10;
        NoSeriesLine.Modify();
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        GenJournalTemplate.Validate("Allow Posting Date From", PostingDate);
        GenJournalTemplate.Validate("Allow Posting Date To", PostingDate);
        GenJournalTemplate.Modify();
        GenJournalBatch."No. Series" := NoSeries.Code;
        GenJournalBatch.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Journal Templ. Name Mandatory" := true;
        GeneralLedgerSetup.Modify();
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate - 1, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));

        // [WHEN] You choose to Post Differences to G/L Account
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Journal Template Name" := GenJournalTemplate.Name;
        TempBankAccRecAIProposal."Journal Batch Name" := GenJournalBatch.Name;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount + Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate - 1;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := DocumentNo;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        TransToGLAccJnlBatch.Init();
        TransToGLAccJnlBatch."Journal Template Name" := GenJournalTemplate.Name;
        TransToGLAccJnlBatch."Journal Batch Name" := GenJournalBatch.Name;
        TransToGLAccJnlBatch.Insert();

        BankRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer, TransToGLAccJnlBatch);

        // [THEN] No Payment is made for the line that had transaction date outside of allowed posting date range
        BankAccountLedgerEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(1));
        BankAccountLedgerEntry.SetRange("Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(1)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(2));
        Assert.IsTrue(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(2)) + ' applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(3));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(3)) + ' not applied.');
        GeneralLedgerSetup."Journal Templ. Name Mandatory" := false;
        GeneralLedgerSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPostNewPaymentsToProposedGLAccountsDisallowedDatesOnGLSetup()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        BankRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        PostingDate: Date;
        BankAccountNo: Code[20];
        StatementNo: Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        LineNos: List of [Integer];
    begin
        // [SCENARIO 546902] When using Post Difference to G/L Account, no payments are posted for statement lines whose transaction date is outside of allowed posting date rage

        // [GIVEN] A bank account reconciliation with one line that has transaction date outside of allowed posting date range
        Initialize();
        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.DeleteAll();
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryUtility.CreateNoSeries(NoSeries, false, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'T0900000', 'T0999999');
        NoSeriesLine."Last No. Used" := 'T0900001';
        NoSeriesLine."Increment-by No." := 10;
        NoSeriesLine.Modify();
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch."No. Series" := NoSeries.Code;
        GenJournalBatch.Modify();
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Allow Posting From" := PostingDate;
        GeneralLedgerSetup."Allow Posting To" := PostingDate;
        GeneralLedgerSetup.Modify();
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, Description, '', Amount + Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate - 1, Description, '', Amount));
        LineNos.Add(CreateBankAccRecLine(BankAccReconciliation, PostingDate, DocumentNo, '', Amount));

        // [WHEN] You choose to Post Differences to G/L Account
        TempBankAccRecAIProposal."Statement Type" := BankAccReconciliation."Statement Type";
        TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliation."Bank Account No.";
        TempBankAccRecAIProposal."Statement No." := BankAccReconciliation."Statement No.";
        TempBankAccRecAIProposal."Journal Template Name" := GenJournalTemplate.Name;
        TempBankAccRecAIProposal."Journal Batch Name" := GenJournalBatch.Name;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(1);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount + Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(2);
        TempBankAccRecAIProposal."Transaction Date" := PostingDate - 1;
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := Description;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal."Transaction Date" := PostingDate;
        TempBankAccRecAIProposal."Statement Line No." := LineNos.Get(3);
        TempBankAccRecAIProposal."G/L Account No." := GLAccount."No.";
        TempBankAccRecAIProposal.Description := DocumentNo;
        TempBankAccRecAIProposal.Difference := Amount;
        TempBankAccRecAIProposal.Insert();
        TempBankAccRecAIProposal.FindSet();
        TransToGLAccJnlBatch.Init();
        TransToGLAccJnlBatch."Journal Template Name" := GenJournalTemplate.Name;
        TransToGLAccJnlBatch."Journal Batch Name" := GenJournalBatch.Name;
        TransToGLAccJnlBatch.Insert();

        BankRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer, TransToGLAccJnlBatch);

        // [THEN] No Payment is made for the line that had transaction date outside of allowed posting date range
        BankAccountLedgerEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(1));
        BankAccountLedgerEntry.SetRange("Statement Status", BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(1)) + ' not applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(2));
        Assert.IsTrue(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(2)) + ' applied.');
        BankAccountLedgerEntry.SetRange("Statement Line No.", LineNos.Get(3));
        Assert.IsFalse(BankAccountLedgerEntry.IsEmpty(), 'Statement Line ' + Format(LineNos.Get(3)) + ' not applied.');
        GeneralLedgerSetup."Allow Posting From" := 0D;
        GeneralLedgerSetup."Allow Posting To" := 0D;
        GeneralLedgerSetup.Modify();
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

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}