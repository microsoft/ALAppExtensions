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
                field(LineType; Rec."Line Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specified the line type.';
                    Caption = 'Line Type';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = LineTypeEmphasize;
                }
                field(TestCodeunit; Rec."Test Codeunit")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the ID of the test codeunit.';
                    BlankZero = true;
                    Caption = 'Codeunit ID';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TestCodeunitEmphasize;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                    ToolTip = 'Specifies the name of the test tool.';
                }
                field(Run; Rec.Run)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies whether the tests should be executed.';
                    Caption = 'Run';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Result; Rec.Result)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies whether the tests passed, failed or were skipped.';
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
                    ToolTip = 'Runs tests.';

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
                    ToolTip = 'Runs selected tests.';

                    trigger OnAction()
                    var
                        TestMethodLine: Record "Test Method Line";
                        TestSuiteMgt: Codeunit "Test Suite Mgt.";
                    begin
                        TestMethodLine.Copy(Rec);
                        CurrPage.SetSelectionFilter(TestMethodLine);
                        TestSuiteMgt.RunSelectedTests(TestMethodLine);
                    end;
                }
            }
            group("Manage Tests")
            {
                Caption = 'Manage Tests';
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
                        if GuiAllowed() then
                            if not Confirm(DeleteQst, false) then
                                exit;

                        CurrPage.SetSelectionFilter(TestMethodLine);
                        TestMethodLine.DeleteAll(true);
                        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
                    end;
                }
                action(InvertRun)
                {
                    ApplicationArea = All;
                    Caption = '&Invert Run Selection';
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Invert Run Selection on selected lines.';

                    trigger OnAction()
                    begin
                        InvertRunSelection();
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
        DeleteQst: Label 'Are you sure you want to delete the selected lines?';

    local procedure ChangeTestSuite()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        GlobalALTestSuite.Get(CurrentSuiteName);
        GlobalALTestSuite.CalcFields("Tests to Execute");

        CurrPage.SaveRecord();

        Rec.FilterGroup(2);
        Rec.SetRange("Test Suite", CurrentSuiteName);
        Rec.FilterGroup(0);

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

        Rec.FilterGroup(2);
        Rec.SetRange("Test Suite", CurrentSuiteName);
        Rec.FilterGroup(0);

        if Rec.Find('-') then;

        TestRunnerDisplayName := TestSuiteMgt.GetTestRunnerDisplayName(GlobalALTestSuite);
    end;

    local procedure UpdateDisplayPropertiesForLine()
    begin
        NameIndent := Rec."Line Type";
        LineTypeEmphasize := Rec."Line Type" = Rec."Line Type"::Codeunit;
        TestCodeunitEmphasize := Rec."Line Type" = Rec."Line Type"::Codeunit;
        ResultEmphasize := Rec.Result = Rec.Result::Success;
    end;

    local procedure UpdateCalculatedFields()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        RunDuration := Rec."Finish Time" - Rec."Start Time";
        ErrorMessageWithStackTraceTxt := TestSuiteMgt.GetErrorMessageWithStackTrace(Rec);
    end;

    local procedure InvertRunSelection()
    var
        TestMethodLine: Record "Test Method Line";
    begin
        CurrPage.SetSelectionFilter(TestMethodLine);

        if TestMethodLine.FindSet(true, false) then
            repeat
                TestMethodLine.Validate(Run, not TestMethodLine.Run);
                TestMethodLine.Modify(true);
            until TestMethodLine.Next() = 0;
    end;
}
