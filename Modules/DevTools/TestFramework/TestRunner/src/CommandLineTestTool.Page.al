// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.TestRunner;

using System.TestTools.CodeCoverage;
using System.Tooling;

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
                    if Rec.FindFirst() then;
                end;
            }
            field(TestProcedureRangeFilter; TestProcedureRangeFilter)
            {
                ApplicationArea = All;
                Caption = 'Test Procedure Range';
                ToolTip = 'Specifies the test procedure range';

                trigger OnValidate()
                begin
                    if TestProcedureRangeFilter = '' then
                        exit;

                    TestSuiteMgt.SelectTestProceduresByName(GlobalALTestSuite.Name, TestProcedureRangeFilter);
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
                    if Rec.FindFirst() then;
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

            field(CCTrackingType; CCTrackingType)
            {
                ApplicationArea = All;
                Caption = 'Code Coverage Tracking Type';
                ToolTip = 'Specifies the Code Coverage tracking type';

                trigger OnValidate()
                begin
                    TestSuiteMgt.SetCCTrackingType(GlobalALTestSuite, CCTrackingType);
                end;
            }

            field(CCMap; CCMap)
            {
                ApplicationArea = All;
                Caption = 'Code Coverage Map';
                Tooltip = 'Specifies the Code Coverage Map';
                trigger OnValidate()
                begin
                    TestSuiteMgt.SetCCMap(GlobalALTestSuite, CCMap);
                end;
            }

            field(CCTrackAllSessions; CCTrackAllSessions)
            {
                ApplicationArea = All;
                Caption = 'Code Coverage Track All Sessions';
                ToolTip = 'Specifies if the Code Coverage should track all sessions';

                trigger OnValidate()
                begin
                    TestSuiteMgt.SetCCTrackAllSessions(GlobalALTestSuite, CCTrackAllSessions);
                end;
            }

            field(CCExporterID; CodeCoverageExporterID)
            {
                ApplicationArea = All;
                Caption = 'Code Coverage Exporter ID';
                ToolTip = 'Specifies the Code Coverage exporter ID';

                trigger OnValidate()
                begin
                    TestSuiteMgt.SetCodeCoverageExporterID(GlobalALTestSuite, CodeCoverageExporterID);
                end;
            }

            field(CCResultsCSVText; CCResultsCSVText)
            {
                ApplicationArea = All;
                Editable = false;
                MultiLine = true;
                Caption = 'Code Coverage Results CSV';
                ToolTip = 'Specifies the Code Coverage results as CSV';
            }

            field(CCMapCSVText; CCMapCSVText)
            {
                Caption = 'Code Coverage Map CSV Text';
                Tooltip = 'Specifies the Code Coverage Map CSV Text';
                ApplicationArea = All;
                Editable = false;
                MultiLine = true;
            }

            field(CCInfo; CCInfo)
            {
                ApplicationArea = All;
                Editable = false;
                MultiLine = true;
                Caption = 'Code Coverage Information';
                ToolTip = 'Specifies the Code Coverage information';
            }

            field(StabilityRun; StabilityRun)
            {
                ApplicationArea = All;
                Caption = 'Stability run';
                ToolTip = 'Specifies the latest execution of the test as JSON';

                trigger OnValidate()
                var
                    TestSuiteMgt: Codeunit "Test Suite Mgt.";
                begin
                    TestSuiteMgt.ChangeStabilityRun(GlobalALTestSuite, StabilityRun);
                end;
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
                end;
            }
            action(GetCodeCoverage)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update Code Coverage';
                Image = Action;

                trigger OnAction()
                var
                    ALCodeCoverageMgt: Codeunit "AL Code Coverage Mgt.";
                begin
                    Clear(CCResultsCSVText);
                    Clear(CCInfo);
                    if not ALCodeCoverageMgt.ConsumeCoverageResult(CCResultsCSVText, CCInfo) then
                        CCInfo := DoneLbl;
                    CurrPage.Update(true);
                end;
            }

            action(GetCodeCoverageMap)
            {
                ApplicationArea = All;
                Tooltip = 'Get Code Coverage Map';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Action;

                trigger OnAction()
                var
                    ALCodeCoverageMgt: Codeunit "AL Code Coverage Mgt.";
                begin
                    Clear(CCMapCSVText);
                    ALCodeCoverageMgt.GetCoveCoverageMap(CCMapCSVText);
                    CurrPage.Update(true);
                end;
            }
            action(ClearCodeCoverage)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Clear Code Coverage';
                Image = Action;

                trigger OnAction()
                var
                    TestCodeCoverageResult: Record "Test Code Coverage Result";
                    CodeCoverage: Record "Code Coverage";
                begin
                    TestCodeCoverageResult.DeleteAll();
                    CodeCoverage.DeleteAll();
                    System.CodeCoverageRefresh();
                    CCInfo := '';
                    CCResultsCSVText := '';
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TestSuiteMgt.CalcTestResults(Rec, Success, Failure, Skipped, NotExecuted);
        UpdateLine();
    end;

    trigger OnAfterGetRecord()
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
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        CurrentSuiteName: Code[10];
        TestCodeunitRangeFilter: Text;
        TestProcedureRangeFilter: Text;
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
        CCResultsCSVText: Text;
        CCMapCSVText: Text;
        CCInfo: Text;
        AllTestsExecutedTxt: Label 'All tests executed.', Locked = true;
        DoneLbl: Label 'Done.', Locked = true;
        CCTrackingType: Integer;
        CCMap: Integer;
        CCTrackAllSessions: Boolean;
        CodeCoverageExporterID: Integer;
        StabilityRun: Boolean;

    local procedure ChangeTestSuite()
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
        TestRunnerCodeunitId := GlobalALTestSuite."Test Runner Id";
        StabilityRun := GlobalALTestSuite."Stability Run";
        CCTrackAllSessions := GlobalALTestSuite."CC Track All Sessions";
        CCTrackingType := GlobalALTestSuite."CC Tracking Type";
        CodeCoverageExporterID := GlobalALTestSuite."CC Exporter ID";
        CCMap := GlobalALTestSuite."CC Coverage Map";
    end;

    local procedure UpdateLine()
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
        CodeunitTestMethodLine.SetFilter(Name, CodeunitName);
        if CodeunitTestMethodLine.IsEmpty() then
            CodeunitTestMethodLine.SetRange(Name, CodeunitName);
        if not CodeunitTestMethodLine.FindSet() then
            exit;
        repeat
            TestMethodLine.SetRange("Test Suite", GlobalALTestSuite.Name);
            TestMethodLine.SetRange("Line Type", Rec."Line Type"::"Function");
            TestMethodLine.SetRange("Test Codeunit", CodeunitTestMethodLine."Test Codeunit");
            TestMethodLine.SetFilter(Name, TestMethodName);
            TestMethodLine.ModifyAll(Run, false);

            TestMethodLine.SetRange(Name);
            TestMethodLine.SetRange(Run, true);
            if TestMethodLine.IsEmpty() then begin
                CodeunitTestMethodLine.Validate(Run, false);
                CodeunitTestMethodLine.Modify(true);
            end;
        until CodeunitTestMethodLine.Next() = 0;
        
        CurrPage.Update();
    end;
}
