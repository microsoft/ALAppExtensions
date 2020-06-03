// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130455 "Test Runner - Progress Dialog"
{
    EventSubscriberInstance = Manual;
    Permissions = TableData "AL Test Suite" = rimd, TableData "Test Method Line" = rimd;

    trigger OnRun()
    begin
    end;

    var
        Window: Dialog;
        ExecutingTestsMsg: Label 'Executing Tests...\', Locked = true;
        TestSuiteMsg: Label 'Test Suite    #1###################\', Locked = true;
        TestCodeunitMsg: Label 'Test Codeunit #2################### @3@@@@@@@@@@@@@\', Locked = true;
        TestFunctionMsg: Label 'Test Function #4################### @5@@@@@@@@@@@@@\', Locked = true;
        NoOfResultsMsg: Label 'No. of Results with:\', Locked = true;
        WindowUpdateDateTime: DateTime;
        WindowTestSuccess: Integer;
        WindowTestFailure: Integer;
        WindowTestSkip: Integer;
        SuccessMsg: Label '    Success   #6######\', Locked = true;
        FailureMsg: Label '    Failure   #7######\', Locked = true;
        SkipMsg: Label '    Skip      #8######\', Locked = true;
        WindowNoOfTestCodeunitTotal: Integer;
        WindowNoOfFunctionTotal: Integer;
        WindowNoOfTestCodeunit: Integer;
        WindowNoOfFunction: Integer;
        CurrentCodeunitNumber: Integer;

    [EventSubscriber(ObjectType::Codeunit, 130454, 'OnRunTestSuite', '', false, false)]
    local procedure OpenWindow(var TestMethodLine: Record "Test Method Line")
    var
        CopyTestMethodLine: Record "Test Method Line";
    begin
        if not GuiAllowed() then
            exit;

        CopyTestMethodLine.Copy(TestMethodLine);
        WindowNoOfTestCodeunitTotal := CopyTestMethodLine.Count();
        CopyTestMethodLine.Reset();
        CopyTestMethodLine.SetRange("Test Suite", TestMethodLine."Test Suite");
        CopyTestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::"Function");

        WindowNoOfFunctionTotal := CopyTestMethodLine.Count();

        Window.HideSubsequentDialogs(true);
        Window.Open(
          ExecutingTestsMsg +
          TestSuiteMsg +
          TestCodeunitMsg +
          TestFunctionMsg +
          NoOfResultsMsg +
          SuccessMsg +
          FailureMsg +
          SkipMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, 130454, 'OnAfterRunTestSuite', '', false, false)]
    local procedure CloseWindow(var TestMethodLine: Record "Test Method Line")
    begin
        if not GuiAllowed() then
            exit;

        Window.Close();
    end;

    [EventSubscriber(ObjectType::Codeunit, 130454, 'OnAfterTestMethodRun', '', false, false)]
    local procedure UpDateWindow(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
        if not GuiAllowed() then
            exit;

        case CurrentTestMethodLine.Result of
            CurrentTestMethodLine.Result::Failure:
                WindowTestFailure += 1;
            CurrentTestMethodLine.Result::Success:
                WindowTestSuccess += 1;
            else
                WindowTestSkip += 1;
        end;

        WindowNoOfFunction += 1;

        if CurrentCodeunitNumber <> CurrentTestMethodLine."Test Codeunit" then begin
            if CurrentCodeunitNumber <> 0 then
                WindowNoOfTestCodeunit += 1;
            CurrentCodeunitNumber := CurrentTestMethodLine."Test Codeunit";
        end;

        if IsTimeForUpdate() then begin
            Window.Update(1, CurrentTestMethodLine."Test Suite");
            Window.Update(2, CurrentTestMethodLine."Test Codeunit");
            Window.Update(4, FunctionName);
            Window.Update(6, WindowTestSuccess);
            Window.Update(7, WindowTestFailure);
            Window.Update(8, WindowTestSkip);

            if WindowNoOfTestCodeunitTotal <> 0 then
                Window.Update(3, Round(WindowNoOfTestCodeunit / WindowNoOfTestCodeunitTotal * 10000, 1));
            if WindowNoOfFunctionTotal <> 0 then
                Window.Update(5, Round(WindowNoOfFunction / WindowNoOfFunctionTotal * 10000, 1));
        end;
    end;

    local procedure IsTimeForUpdate(): Boolean
    begin
        if true in [WindowUpdateDateTime = 0DT, CurrentDateTime() - WindowUpdateDateTime >= 1000] then begin
            WindowUpdateDateTime := CurrentDateTime();
            exit(true);
        end;

        exit(false);
    end;
}

