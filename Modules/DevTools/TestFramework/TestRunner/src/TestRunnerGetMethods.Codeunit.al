// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130452 "Test Runner - Get Methods"
{
    Subtype = TestRunner;
    TableNo = "Test Method Line";
    Permissions = TableData "AL Test Suite" = rimd, TableData "Test Method Line" = rimd;

    trigger OnRun()
    var
        ALTestSuite: Record "AL Test Suite";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        CurrentTestMethodLine.Copy(Rec);
        ALTestSuite.Get(Rec."Test Suite");

        if UpdateTests then
            MaxLineNo := TestSuiteMgt.GetNextMethodNumber(Rec)
        else
            MaxLineNo := TestSuiteMgt.GetLastTestLineNo(ALTestSuite);

        CODEUNIT.Run(CurrentTestMethodLine."Test Codeunit");
    end;

    var
        CurrentTestMethodLine: Record "Test Method Line";
        MaxLineNo: Integer;
        UpdateTests: Boolean;

    trigger OnBeforeTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions): Boolean
    begin
        if (FunctionName = 'OnRun') or (FunctionName = '') then
            exit(true);

        OnGetTestMethods(CodeunitID, COPYSTR(CodeunitName, 1, 30), COPYSTR(FunctionName, 1, 128), FunctionTestPermissions);
        AddTestMethod(CodeunitID, COPYSTR(FunctionName, 1, 128));

        // Do not run the tests
        exit(false);
    end;

    trigger OnAfterTestRun(CodeunitID: Integer; CodeunitName: Text; FunctionName: Text; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
        // This method is invoked by platform
        // It is not used to discover individual test methods
    end;

    procedure SetUpdateTests(NewUpdateTests: Boolean)
    begin
        UpdateTests := NewUpdateTests;
    end;

    local procedure AddTestMethod(CodeunitID: Integer; FunctionName: Text[128])
    var
        TestMethodLine: Record "Test Method Line";
    begin
        if UpdateTests then
            MaxLineNo += 100
        else
            MaxLineNo += 10000;

        TestMethodLine."Line No." := MaxLineNo;
        TestMethodLine.Validate("Test Codeunit", CodeunitID);
        TestMethodLine.Validate("Test Suite", CurrentTestMethodLine."Test Suite");
        TestMethodLine.Validate("Line Type", TestMethodLine."Line Type"::"Function");
        TestMethodLine.Validate("Function", FunctionName);
        TestMethodLine.Validate(Run, CurrentTestMethodLine.Run);
        TestMethodLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTestMethods(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions)
    begin
    end;
}

