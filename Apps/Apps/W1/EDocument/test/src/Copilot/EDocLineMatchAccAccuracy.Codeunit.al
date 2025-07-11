namespace Microsoft.Sales.Document.Test;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Finance.GeneralLedger.Account;
using System.TestLibraries.Utilities;
using System.TestTools.AITestToolkit;
using System.Reflection;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

codeunit 133509 "EDoc. Line Match Acc. Accuracy"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [E-Document Invoice Intelligence Assist]
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        isInitialized: Boolean;

    [Test]
    procedure TestAccuracyProposeGLAccount()
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocument: Record "E-Document";
        GLAccount: Record "G/L Account";
        LineToAccountLLMMatching: Codeunit "Line To Account LLM Matching";
        AITContext: Codeunit "AIT Test Context";
        TypeHelper: Codeunit "Type Helper";
        DataSetAccountNo, GLAccountNo : Code[20];
        Description: Text[100];
        Lines, Attributes, LineSpecs : List of [Text];
        Line, Input, DataSetDescription, K, V, LineSpec, GLAccountName : Text;
        JsonContent: JSonObject;
        JSonToken: JSonToken;
        DataSetLineNo, LineNo : Integer;
        ExpectedTestOutputTxt, TestOutputTxt : Text;
        TestOutput: Dictionary of [Integer, Code[20]];
        LineNoMapping: Dictionary of [Integer, Integer];
        AccountNoMapping: Dictionary of [Code[20], Code[20]];
        MatchedLines: Integer;
    begin
        // [SCENARIO 572271] Automate Red Team testing and happy path scenarios
        Initialize();

        // [GIVEN] an e-document and G/L Account names (taken from input dataset)
        EDocument.Insert(true);
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
                        LineNo := CreateEDocumentPurchaseLine(EDocument, CopyStr(DataSetDescription, 1, MaxStrLen(Description)));
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
                        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
                        GLAccount.Modify();
                        AccountNoMapping.Add(DataSetAccountNo, GLAccountNo);
                    end;
            end;

        // [WHEN] You call Copilot to find the best suitable G/L Account
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        Assert.IsTrue(EDocumentPurchaseLine.FindSet(), '');
        TestOutput := LineToAccountLLMMatching.GetPurchaseLineAccountsWithCopilot(EDocumentPurchaseLine);

        foreach LineNo in TestOutput.Keys() do begin
            if not (Format(TestOutput.Get(LineNo)) in ['XPIA', '0', '', 'NONE']) then
                MatchedLines += 1;
            TestOutputTxt += ('(' + Format(LineNo) + ',' + Format(TestOutput.Get(LineNo)) + ')');
        end;

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
        if ExpectedTestOutputTxt = '' then
            Assert.AreEqual(0, MatchedLines, '')
        else
            Assert.IsTrue(Lines.Count() <= TestOutput.Count(), '');
    end;

    local procedure Initialize()
    var
        GLAccount: Record "G/L Account";
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"EDoc. Line Match Acc. Accuracy");
        LibraryApplicationArea.EnableFoundationSetup();
        GLAccount.ModifyAll("Direct Posting", false);

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"EDoc. Line Match Acc. Accuracy");

        LibraryVariableStorage.Clear();

        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"EDoc. Line Match Acc. Accuracy");
    end;

    local procedure CreateEDocumentPurchaseLine(var EDocument: Record "E-Document"; Description: Text[100]): Integer
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseLine.Init();
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocumentPurchaseLine.FindLast() then
            EDocumentPurchaseLine."E-Document Entry No." := EDocument."Entry No";

        EDocumentPurchaseLine.Description := Description;
        EDocumentPurchaseLine."Line No." += 10000;
        EDocumentPurchaseLine.Insert();

        exit(EDocumentPurchaseLine."Line No.");
    end;

}