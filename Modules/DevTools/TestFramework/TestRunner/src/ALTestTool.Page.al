// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 130451 "AL Test Tool"
{
    AccessByPermission = TableData "Test Method Line" = RIMD;
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'AL Test Tool';
    DataCaptionExpression = CurrentSuiteName;
    DelayedInsert = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Test Method Line";
    UsageCategory = Administration;
    Permissions = TableData "AL Test Suite" = rimd, TableData "Test Method Line" = rimd;

    layout
    {
        area(content)
        {
            field(CurrentSuiteName; CurrentSuiteName)
            {
                ApplicationArea = All;
                Caption = 'Suite Name';
                ToolTip = 'Specifies the currently selected Test Suite';

                trigger OnLookup(var Text: Text): Boolean
                var
                    ALTestSuite: Record "AL Test Suite";
                begin
                    ALTestSuite.Name := CurrentSuiteName;
                    if PAGE.RunModal(0, ALTestSuite) <> ACTION::LookupOK then
                        exit(false);

                    Text := ALTestSuite.Name;
                    CurrPage.Update(false);
                    exit(true);
                end;

                trigger OnValidate()
                begin
                    ChangeTestSuite();
                end;
            }
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowAsTree = true;
                ShowCaption = false;
                field(LineType; "Line Type")
                {
                    ApplicationArea = All;
                    Caption = 'Line Type';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = LineTypeEmphasize;
                }
                field(TestCodeunit; "Test Codeunit")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Codeunit ID';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TestCodeunitEmphasize;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                    ToolTip = 'Specifies the name of the test tool.';
                }
                field(Run; Run)
                {
                    ApplicationArea = All;
                    Caption = 'Run';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Result; Result)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Result';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = ResultEmphasize;
                }
                field("Error Message"; ErrorMessageWithStackTraceTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    DrillDown = true;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies full error message with stack trace';

                    trigger OnDrillDown()
                    begin
                        Message(ErrorMessageWithStackTraceTxt);
                    end;
                }
                field(Duration; RunDuration)
                {
                    ApplicationArea = All;
                    Caption = 'Duration';
                    Editable = false;
                    ToolTip = 'Specifies the duration of the test run';
                }
            }
            group(Control14)
            {
                ShowCaption = false;
                field(SuccessfulTests; Success)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Caption = 'Successful Tests';
                    Editable = false;
                    ToolTip = 'Specifies the number of Successful Tests';
                }
                field(FailedTests; Failure)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Caption = 'Failed Tests';
                    Editable = false;
                    ToolTip = 'Specifies the number of Failed Tests';
                }
                field(SkippedTests; Skipped)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Caption = 'Skipped Tests';
                    Editable = false;
                    ToolTip = 'Specifies the number of Skipped Tests';
                }
                field(NotExecutedTests; NotExecuted)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Caption = 'Tests not Executed';
                    Editable = false;
                    ToolTip = 'Specifies the number of Tests Not Executed';
                }
            }
            group(Control13)
            {
                ShowCaption = false;
                field(TestRunner; TestRunnerDisplayName)
                {
                    ApplicationArea = All;
                    Caption = 'Test Runner Codeunit';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies currently selected test runner';

                    trigger OnDrillDown()
                    begin
                        // Used to fix the rendering - don't show as a box
                        Error('');
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Manage Tests")
            {
                Caption = 'Manage Tests';
                action(DeleteLines)
                {
                    ApplicationArea = All;
                    Caption = '&Delete Lines';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Delete the selected lines.';

                    trigger OnAction()
                    var
                        TestMethodLine: Record "Test Method Line";
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(TestMethodLine);
                        TestMethodLine.DeleteAll(true);
                        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
                    end;
                }
                action(GetTestCodeunits)
                {
                    ApplicationArea = All;
                    Caption = 'Get &Test Codeunits';
                    Image = ChangeToLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Prompts a dialog to add test codeunits.';

                    trigger OnAction()
                    var
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestSuiteMgt.SelectTestMethods(GlobalALTestSuite);
                        CurrPage.Update(false);
                    end;
                }
                action(GetTestsByRange)
                {
                    ApplicationArea = All;
                    Caption = 'Get Test Codeunits by Ra&nge';
                    Image = GetLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Add test codeunits by using a range string.';

                    trigger OnAction()
                    var
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestSuiteMgt.LookupTestMethodsByRange(GlobalALTestSuite);
                        CurrPage.Update(false);
                    end;
                }
                action(UpdateTests)
                {
                    ApplicationArea = All;
                    Caption = 'Update Test Methods';
                    Image = RefreshLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Updates the test methods for the entire test suite.';

                    trigger OnAction()
                    var
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestSuiteMgt.UpdateTestMethods(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
            group("Run Tests")
            {
                Caption = 'Run Tests';
                action(RunTests)
                {
                    ApplicationArea = All;
                    Caption = '&Run Tests';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Runs selected tests.';

                    trigger OnAction()
                    var
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                        TestRunnerProgessDialog: Codeunit "Test Runner - Progress Dialog";
                    begin
                        BindSubscription(TestRunnerProgessDialog);
                        TestSuiteMgt.RunTestSuiteSelection(Rec);
                        CurrPage.Update(true);
                    end;
                }
                action(RunSelectedTests)
                {
                    ApplicationArea = All;
                    Caption = 'Run Se&lected Tests';
                    Image = TestFile;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        TestMethodLine: Record "Test Method Line";
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestMethodLine.Copy(Rec);
                        CurrPage.SetSelectionFilter(TestMethodLine);
                        TestSuiteMgt.RunSelectedTests(TestMethodLine);
                        CurrPage.Update(true);
                    end;
                }
            }
            group("Test Suite")
            {
                Caption = 'Test Suite';
                action(SelectTestRunner)
                {
                    ApplicationArea = All;
                    Caption = 'Select Test R&unner';
                    Image = SetupList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Specifies the action to select a test runner';

                    trigger OnAction()
                    var
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestSuiteMgt.LookupTestRunner(GlobalALTestSuite);
                        TestRunnerDisplayName := TestSuiteMgt.GetTestRunnerDisplayName(GlobalALTestSuite);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
        UpdateDisplayPropertiesForLine();
        UpdateCalculatedFields();
    end;

    trigger OnOpenPage()
    begin
        SetCurrentTestSuite();
    end;

    var
        GlobalALTestSuite: Record "AL Test Suite";
        CurrentSuiteName: Code[10];
        Skipped: Integer;
        Success: Integer;
        Failure: Integer;
        NotExecuted: Integer;
        [InDataSet]
        NameIndent: Integer;
        [InDataSet]
        LineTypeEmphasize: Boolean;
        NameEmphasize: Boolean;
        [InDataSet]
        TestCodeunitEmphasize: Boolean;
        [InDataSet]
        ResultEmphasize: Boolean;
        RunDuration: Duration;
        TestRunnerDisplayName: Text;
        ErrorMessageWithStackTraceTxt: Text;

    local procedure ChangeTestSuite()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        GlobalALTestSuite.Get(CurrentSuiteName);
        GlobalALTestSuite.CalcFields("Tests to Execute");

        CurrPage.SaveRecord();

        FilterGroup(2);
        SetRange("Test Suite", CurrentSuiteName);
        FilterGroup(0);

        CurrPage.Update(false);

        TestRunnerDisplayName := TestSuiteMgt.GetTestRunnerDisplayName(GlobalALTestSuite);
    end;

    local procedure SetCurrentTestSuite()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        GlobalALTestSuite.SetAutoCalcFields("Tests to Execute");

        if not GlobalALTestSuite.Get(CurrentSuiteName) then
            if (CurrentSuiteName = '') and GlobalALTestSuite.FindFirst() then
                CurrentSuiteName := GlobalALTestSuite.Name
            else begin
                TestSuiteMgt.CreateTestSuite(CurrentSuiteName);
                Commit();
                GlobalALTestSuite.Get(CurrentSuiteName);
            end;

        FilterGroup(2);
        SetRange("Test Suite", CurrentSuiteName);
        FilterGroup(0);

        if Find('-') then;

        TestRunnerDisplayName := TestSuiteMgt.GetTestRunnerDisplayName(GlobalALTestSuite);
    end;

    local procedure UpdateDisplayPropertiesForLine()
    begin
        NameIndent := "Line Type";
        LineTypeEmphasize := "Line Type" = "Line Type"::Codeunit;
        TestCodeunitEmphasize := "Line Type" = "Line Type"::Codeunit;
        ResultEmphasize := Result = Result::Success;
    end;

    local procedure UpdateCalculatedFields()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        RunDuration := "Finish Time" - "Start Time";
        ErrorMessageWithStackTraceTxt := TestSuiteMgt.GetErrorMessageWithStackTrace(Rec);
    end;
}
