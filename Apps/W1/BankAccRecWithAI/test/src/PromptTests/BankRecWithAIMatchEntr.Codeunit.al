namespace Microsoft.Bank.Reconciliation.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Account;
using System.TestLibraries.Utilities;
using System.TestTools.AITestToolkit;
using System.Reflection;

codeunit 139790 "Bank Rec. With AI Match Entr."
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
    procedure TestAccuracyMatchLedgerEntries()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        AITContext: Codeunit "AIT Test Context";
        TypeHelper: Codeunit "Type Helper";
        DataSetDate, PostingDate : Date;
        BankAccountNo: Code[20];
        DataSetExtDocNo: Code[35];
        DataSetDocumentNo, StatementNo : Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        DataSetAmount, Amount : Decimal;
        Lines, Attributes, LineSpecs : List of [Text];
        Line, Input, DataSetDescription, K, V, LineSpec, TestOutputTxt, ExpectedTestOutputTxt, BankRecLedgerEntriesTxt, BankRecStatementLinesTxt : Text;
        JsonContent: JSonObject;
        JSonToken: JSonToken;
        DataSetEntryNo, DataSetLineNo, LineNo, EntryNo : Integer;
        LineNoMapping, EntryNoMapping : Dictionary of [Integer, Integer];
        CandidateEntryNos, EntryNos : List of [Integer];
        CompletionTaskTxt, CompletionPromptTxt : SecretText;
    begin
        // [SCENARIO 539150] Automate Red Team testing and happy path scenarios
        Initialize();

        // [GIVEN] a set of bank account reconciliation lines and ledger entries (taken from input dataset)
        CreateInputData(PostingDate, BankAccountNo, StatementNo, DocumentNo, Description, Amount);
        CreateBankAccRec(BankAccReconciliation, BankAccountNo, StatementNo);
        JsonContent.ReadFrom(AITContext.GetInput().ToText());
        JsonContent.Get('input', JsonToken);
        Input := JsonToken.AsValue().AsText();
        Lines := Input.Split(TypeHelper.LFSeparator(), TypeHelper.CRLFSeparator(), TypeHelper.NewLine());
        LineNo := 0;
        foreach Line in Lines do
            case Line[1] of
                'L':
                    begin
                        LineSpecs := Line.Split(',');
                        foreach LineSpec in LineSpecs do begin
                            Attributes := LineSpec.Split(':');
                            Attributes.Get(1, K);
                            Attributes.Get(2, V);

                            case K.Trim() of
                                'LID':
                                    Evaluate(DataSetLineNo, V.Trim());
                                'Description':
                                    DataSetDescription := V.Trim();
                                'Amount':
                                    Evaluate(DataSetAmount, V.Trim(), 9);
                                'Date':
                                    Evaluate(DataSetDate, V.Trim(), 9);
                            end;
                        end;
                        LineNo := CreateBankAccRecLine(BankAccReconciliation, DataSetDate, CopyStr(DataSetDescription, 1, MaxStrLen(Description)), '', DataSetAmount);
                        LineNoMapping.Add(DataSetLineNo, LineNo);
                    end;
                'E':
                    begin
                        LineSpecs := Line.Split(',');
                        foreach LineSpec in LineSpecs do begin
                            Attributes := LineSpec.Split(':');
                            Attributes.Get(1, K);
                            Attributes.Get(2, V);

                            case K.Trim() of
                                'EID':
                                    Evaluate(DataSetEntryNo, V.Trim());
                                'ExtDocNo':
                                    DataSetExtDocNo := CopyStr(V.Trim(), 1, MaxStrLen(DataSetExtDocNo));
                                'Description':
                                    DataSetDescription := V.Trim();
                                'DocumentNo':
                                    DataSetDocumentNo := CopyStr(V.Trim(), 1, MaxStrLen(DataSetDocumentNo));
                                'Date':
                                    Evaluate(DataSetDate, V.Trim(), 9);
                                'Amount':
                                    Evaluate(DataSetAmount, V.Trim(), 9);
                            end;
                        end;
                        EntryNo := CreateBankAccLedgerEntry(BankAccountNo, DataSetDate, DataSetDocumentNo, DataSetExtDocNo, DataSetAmount, CopyStr(DataSetDescription, 1, 50));
                        BankAccountLedgerEntry.Get(EntryNo);
                        InsertFromBankAccLedgerEntry(TempLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
                        EntryNoMapping.Add(DataSetEntryNo, EntryNo);
                        EntryNos.Add(EntryNo);
                    end;
            end;

        // [WHEN] You call Copilot to find the best suitable G/L Account
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        Assert.IsTrue(BankAccReconciliationLine.FindSet(), '');
        BankRecAIMatchingImpl.BuildBankRecStatementLines(BankRecStatementLinesTxt, BankAccReconciliationLine);
        TempLedgerEntryMatchingBuffer.FindSet();
        BankRecAIMatchingImpl.BuildBankRecLedgerEntries(BankRecLedgerEntriesTxt, TempLedgerEntryMatchingBuffer, CandidateEntryNos);
        CompletionTaskTxt := BankRecAIMatchingImpl.BuildBankRecCompletionTask(true);
        CompletionPromptTxt := BankRecAIMatchingImpl.BuildBankRecCompletionPrompt(CompletionTaskTxt, BankRecStatementLinesTxt, BankRecLedgerEntriesTxt);
        BankRecAIMatchingImpl.CreateCompletionAndMatch(CompletionPromptTxt, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, 1);

        // [THEN] The expected entries are matched (as defined in dataset expected results)
        TempBankStatementMatchingBuffer.Reset();
        if TempBankStatementMatchingBuffer.FindSet() then
            repeat
                TestOutputTxt += ('(' + Format(TempBankStatementMatchingBuffer."Line No.") + ', ' + Format(TempBankStatementMatchingBuffer."Entry No.") + ')');
            until TempBankStatementMatchingBuffer.Next() = 0;
        AITContext.SetTestOutput(TestOutputTxt);
        JsonContent.Get('expected_output', JsonToken);
        ExpectedTestOutputTxt := JsonToken.AsValue().AsText();
        Lines := ExpectedTestOutputTxt.Split(TypeHelper.LFSeparator(), TypeHelper.CRLFSeparator(), TypeHelper.NewLine());
        LineNo := 0;
        foreach Line in Lines do
            if Line <> '' then begin
                LineSpecs := Line.Split(',');
                foreach LineSpec in LineSpecs do begin
                    Attributes := LineSpec.Split(':');
                    Attributes.Get(1, K);
                    Attributes.Get(2, V);

                    case K.Trim() of
                        'LID':
                            Evaluate(DataSetLineNo, V.Trim());
                        'EID':
                            Evaluate(DataSetEntryNo, V.Trim());
                    end;
                end;
                Assert.IsTrue(StrPos(TestOutputTxt, '(' + Format(LineNoMapping.Get(DataSetLineNo)) + ', ' + Format(EntryNoMapping.Get(DataSetEntryNo)) + ')') > 0, '');
            end;
    end;

    local procedure Initialize()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        GLAccount: Record "G/L Account";
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Bank Rec. With AI Tests");
        LibraryApplicationArea.EnableFoundationSetup();
        BankAccReconciliationLine.DeleteAll();
        BankAccReconciliation.DeleteAll();
        GLAccount.ModifyAll("Direct Posting", false);

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
        Description := CopyStr('Desc' + Format(LibraryRandom.RandInt(99)), 1, 50);
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