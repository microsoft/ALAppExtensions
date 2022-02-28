// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 130455 "Command Line Test Tool"
{
    AccessByPermission = TableData "Test Method Line" = RIMD;
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Command Line Test Tool';
    DataCaptionExpression = CurrentSuiteName;
    DelayedInsert = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    PageType = Worksheet;
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
                ToolTip = 'Specifies the current Suite Name';

                trigger OnValidate()
                begin
                    ChangeTestSuite();
                end;
            }
            field(TestCodeunitRangeFilter; TestCodeunitRangeFilter)
            {
                ApplicationArea = All;
                Caption = 'Test Codeunit Range';
                ToolTip = 'Specifies the values that will update the current suite selection';

                trigger OnValidate()
                var
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestSuiteMgt.DeleteAllMethods(GlobalALTestSuite);
                    TestSuiteMgt.SelectTestMethodsByRange(GlobalALTestSuite, TestCodeunitRangeFilter);
                    IF Rec.FindFirst() THEN;
                end;
            }
            field(TestRunnerCodeunitId; TestRunnerCodeunitId)
            {
                ApplicationArea = All;
                Caption = 'Test Runner Codeunit ID';
                ToolTip = 'Specifies the currently selected test runner ID';

                trigger OnValidate()
                var
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestSuiteMgt.ChangeTestRunner(GlobalALTestSuite, TestRunnerCodeunitId);
                end;
            }
            field(ExtensionId; ExtensionId)
            {
                ApplicationArea = All;
                Caption = 'Extension ID';
                ToolTip = 'Specifies the values if set will update the current suite selection';

                trigger OnValidate()
                var
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestSuiteMgt.DeleteAllMethods(GlobalALTestSuite);
                    TestSuiteMgt.SelectTestMethodsByExtension(GlobalALTestSuite, ExtensionId);
                    IF Rec.FindFirst() THEN;
                end;
            }
            field(DisableTestMethod; RemoveTestMethod)
            {
                ApplicationArea = All;
                Caption = 'DisableTestMethod';
                ToolTip = 'Specifies the values that will update enabled property on the test method';

                trigger OnValidate()
                begin
                    FindAndDisableTestMethod();
                end;
            }

            field(TestResultJson; TestResultsJSONText)
            {
                ApplicationArea = All;
                Caption = 'Test Result JSON';
                Editable = false;
                ToolTip = 'Specifies the latest execution of the test as JSON';
            }

            repeater(Control1)
            {
                IndentationControls = Name;
                ShowCaption = false;
                field(LineType; LineTypeCode)
                {
                    ApplicationArea = All;
                    Caption = 'Line Type';
                    Editable = false;
                    ToolTip = 'Specifies a Non-Translatable value for console test runner.';
                }
                field(TestCodeunit; Rec."Test Codeunit")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the ID the test codeunit.';
                    Caption = 'Codeunit ID';
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the test tool.';
                }
                field(Run; Rec.Run)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies wether the tests should run.';
                    Caption = 'Run';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Result; ResultCode)
                {
                    ApplicationArea = All;
                    Caption = 'Result';
                    Editable = false;
                    ToolTip = 'Specifies a Non-Translatable value for console test runner.';
                }
                field(ErrorMessage; FullErrorMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies full error message with stack trace';
                }
                field(StackTrace; StackTrace)
                {
                    ApplicationArea = All;
                    Caption = 'Stack Trace';
                    ToolTip = 'Specifies stack trace';
                }
                field(FinishTime; Rec."Finish Time")
                {
                    ApplicationArea = All;
                    Caption = 'Finish Time';
                    ToolTip = 'Specifies the duration of the test run';
                }
                field(StartTime; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the time the test started.';
                    Caption = 'Start Time';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RunSelectedTests)
            {
                ApplicationArea = All;
                Tooltip = 'Runs the selected tests.';
                Caption = 'Run Se&lected Tests';
                Image = TestFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TestMethodLine: Record "Test Method Line";
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestMethodLine.Copy(Rec);
                    CurrPage.SetSelectionFilter(TestMethodLine);
                    TestSuiteMgt.RunSelectedTests(TestMethodLine);
                    Rec.Find();
                    CurrPage.Update(true);
                end;
            }

            action(RunNextTest)
            {
                ApplicationArea = All;
                Tooltip = 'Runs the next test.';
                Caption = 'Run N&ext Test';
                Image = TestReport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TestMethodLine: Record "Test Method Line";
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestMethodLine.Copy(Rec);
                    Clear(TestResultsJSONText);
                    if TestSuiteMgt.RunNextTest(TestMethodLine) then
                        TestResultsJSONText := TestSuiteMgt.TestResultsToJSON(TestMethodLine)
                    else
                        TestResultsJSONText := AllTestsExecutedTxt;

                    if Rec.Find() then;
                    CurrPage.Update(true);
                end;
            }

            action(ClearTestResults)
            {
                ApplicationArea = All;
                Tooltip = 'Clear the test results.';
                Caption = 'Clear Test R&esults';
                Image = ClearLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SetRange("Test Suite", CurrentSuiteName);
                    Rec.ModifyAll(Result, Rec.Result::" ", true);
                    Clear(TestResultsJSONText);
                    CurrPage.Update(true);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
        UpdateLine();
    end;

    trigger OnAfterGetRecord()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
        UpdateLine();
    end;

    trigger OnOpenPage()
    begin
        SetCurrentTestSuite();
    end;

    var
        GlobalALTestSuite: Record "AL Test Suite";
        CurrentSuiteName: Code[10];
        TestCodeunitRangeFilter: Text;
        TestRunnerCodeunitId: Integer;
        Skipped: Integer;
        Success: Integer;
        Failure: Integer;
        NotExecuted: Integer;
        ResultCode: Text;
        LineTypeCode: Text;
        FullErrorMessage: Text;
        StackTrace: Text;
        ExtensionId: Text;
        RemoveTestMethod: Text;
        TestResultsJSONText: Text;
        AllTestsExecutedTxt: Label 'All tests executed.', Locked = true;

    local procedure ChangeTestSuite()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        if not GlobalALTestSuite.Get(CurrentSuiteName) then begin
            TestSuiteMgt.CreateTestSuite(CurrentSuiteName);
            Commit();
        end;

        GlobalALTestSuite.CalcFields("Tests to Execute");

        CurrPage.SaveRecord();

        Rec.FilterGroup(2);
        Rec.SetRange("Test Suite", CurrentSuiteName);
        Rec.FilterGroup(0);

        CurrPage.Update(false);
    end;

    local procedure SetCurrentTestSuite()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        if not GlobalALTestSuite.Get(CurrentSuiteName) then
            if GlobalALTestSuite.FindFirst() then
                CurrentSuiteName := GlobalALTestSuite.Name
            else begin
                TestSuiteMgt.CreateTestSuite(CurrentSuiteName);
                Commit();
            end;

        Rec.FilterGroup(2);
        Rec.SetRange("Test Suite", CurrentSuiteName);
        Rec.FilterGroup(0);

        if Rec.Find('-') then;

        GlobalALTestSuite.Get(CurrentSuiteName);
        GlobalALTestSuite.CalcFields("Tests to Execute");
    end;

    local procedure UpdateLine()
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        ConvertToInteger: Integer;
    begin
        ConvertToInteger := Rec.Result;
        ResultCode := Format(ConvertToInteger);

        ConvertToInteger := Rec."Line Type";
        LineTypeCode := Format(ConvertToInteger);

        StackTrace := TestSuiteMgt.GetErrorCallStack(Rec);
        FullErrorMessage := TestSuiteMgt.GetFullErrorMessage(Rec);
    end;

    local procedure FindAndDisableTestMethod()
    var
        TestMethodLine: Record "Test Method Line";
        CodeunitTestMethodLine: Record "Test Method Line";
        CodeunitName: Text;
        TestMethodName: Text;
    begin
        if StrPos(RemoveTestMethod, ',') <= 0 then
            exit;

        CodeunitName := CopyStr(SelectStr(1, RemoveTestMethod), 1, MaxStrLen(CodeunitTestMethodLine.Name));
        TestMethodName := CopyStr(SelectStr(2, RemoveTestMethod), 1, MaxStrLen(CodeunitTestMethodLine.Name));

        if CodeunitName = '' then
            exit;

        if TestMethodName = '' then
            exit;

        CodeunitTestMethodLine.SetRange("Test Suite", GlobalALTestSuite.Name);
        CodeunitTestMethodLine.SetRange("Line Type", CodeunitTestMethodLine."Line Type"::Codeunit);
        CodeunitTestMethodLine.SetRange(Name, CodeunitName);
        if not CodeunitTestMethodLine.FindFirst() then
            exit;

        TestMethodLine.SetRange("Test Suite", GlobalALTestSuite.Name);
        TestMethodLine.SetRange("Line Type", Rec."Line Type"::"Function");
        TestMethodLine.SetRange("Test Codeunit", CodeunitTestMethodLine."Test Codeunit");
        TestMethodLine.SetFilter(Name, TestMethodName);
        TestMethodLine.ModifyAll(Run, false);


        TestMethodLine.SETRANGE(Name);
        TestMethodLine.SETRANGE(Run, TRUE);
        if TestMethodLine.IsEmpty() then begin
            CodeunitTestMethodLine.VALIDATE(Run, FALSE);
            CodeunitTestMethodLine.Modify(TRUE);
        end;

        CurrPage.Update();
    end;
}

