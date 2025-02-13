namespace Microsoft.Bank.Reconciliation.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Account;
using System.TestLibraries.Utilities;
using System.TestTools.AITestToolkit;
using System.Reflection;

codeunit 139791 "Bank Rec. With AI Match Acc."
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
    procedure TestAccuracyPostToGLAccount()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GLAccount: Record "G/L Account";
        BankAccRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        AITContext: Codeunit "AIT Test Context";
        TypeHelper: Codeunit "Type Helper";
        PostingDate: Date;
        BankAccountNo: Code[20];
        DataSetAccountNo, GLAccountNo, StatementNo : Code[20];
        DocumentNo: Code[20];
        Description: Text[50];
        Amount: Decimal;
        Lines, Attributes, LineSpecs : List of [Text];
        Line, Input, DataSetDescription, K, V, LineSpec, GLAccountName : Text;
        JsonContent: JSonObject;
        JSonToken: JSonToken;
        DataSetLineNo, LineNo : Integer;
        ExpectedTestOutputTxt, TestOutputTxt : Text;
        TestOutput: Dictionary of [Integer, Code[20]];
        LineNoMapping: Dictionary of [Integer, Integer];
        AccountNoMapping: Dictionary of [Code[20], Code[20]];
    begin
        // [SCENARIO 539150] Automate Red Team testing and happy path scenarios
        Initialize();

        // [GIVEN] a set of bank account reconciliation lines and G/L Account names (taken from input dataset)
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
                            end;
                        end;
                        LineNo := CreateBankAccRecLine(BankAccReconciliation, PostingDate, CopyStr(DataSetDescription, 1, MaxStrLen(Description)), '', Amount);
                        LineNoMapping.Add(DataSetLineNo, LineNo);
                    end;
                'A':
                    begin
                        LineSpecs := Line.Split(',');
                        foreach LineSpec in LineSpecs do begin
                            Attributes := LineSpec.Split(':');
                            Attributes.Get(1, K);
                            Attributes.Get(2, V);

                            case K.Trim() of
                                'AID':
                                    DataSetAccountNo := CopyStr(V.Trim(), 1, 20);
                                'Name':
                                    GLAccountName := V.Trim();
                            end;
                        end;
                        GLAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
                        GLAccount.Get(GLAccountNo);
                        GLAccount.Name := CopyStr(GLAccountName, 1, MaxStrLen(GLAccount.Name));
                        GLAccount.Modify();
                        AccountNoMapping.Add(DataSetAccountNo, GLAccountNo);
                    end;
            end;

        // [WHEN] You call Copilot to find the best suitable G/L Account
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        Assert.IsTrue(BankAccReconciliationLine.FindSet(), '');
        TestOutput := BankAccRecTransToAcc.GetMostAppropriateGLAccountNos(BankAccReconciliationLine, TempBankStatementMatchingBuffer);

        foreach LineNo in TestOutput.Keys() do
            TestOutputTxt += ('(' + Format(LineNo) + ',' + Format(TestOutput.Get(LineNo)) + ')');

        // [THEN] The expected G/L Accounts are matched (as per expected result in the dataset)
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
                        'AID':
                            DataSetAccountNo := CopyStr(V.Trim(), 1, 20);
                    end;
                end;
                Assert.AreEqual(TestOutput.Get(LineNoMapping.Get(DataSetLineNo)), AccountNoMapping.Get(DataSetAccountNo), '');
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

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}