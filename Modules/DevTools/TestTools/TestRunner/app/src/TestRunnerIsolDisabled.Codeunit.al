codeunit 130451 "Test Runner - Isol. Disabled"
{
    Subtype = TestRunner;
    TableNo = "Test Method Line";
    TestIsolation = Disabled;

    trigger OnRun()
    begin
        ALTestSuite.Get("Test Suite");
        CurrentTestMethodLine.Copy(Rec);
        TestRunnerMgt.RunTests(Rec);
    end;

    var
        ALTestSuite: Record "AL Test Suite";
        CurrentTestMethodLine: Record "Test Method Line";
        TestRunnerMgt: Codeunit "Test Runner - Mgt";

    trigger OnBeforeTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;FunctionTestPermissions: TestPermissions): Boolean
    begin
        exit(
          TestRunnerMgt.PlatformBeforeTestRun(
            CodeunitID,CodeunitName,FunctionName,FunctionTestPermissions,ALTestSuite.Name,CurrentTestMethodLine.GetFilter("Line No.")));
    end;

    trigger OnAfterTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;FunctionTestPermissions: TestPermissions;IsSuccess: Boolean)
    begin
        TestRunnerMgt.PlatformAfterTestRun(
          CodeunitID,CodeunitName,FunctionName,FunctionTestPermissions,IsSuccess,ALTestSuite.Name,
          CurrentTestMethodLine.GetFilter("Line No."));
    end;
}

