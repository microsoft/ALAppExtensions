codeunit 130454 "Test Runner - Mgt"
{

    trigger OnRun()
    begin
    end;

    [Scope('OnPrem')]
    procedure RunTests(var NewTestMethodLine: Record "Test Method Line")
    var
        TestMethodLine: Record "Test Method Line";
    begin
        TestMethodLine.Copy(NewTestMethodLine);
        TestMethodLine.SetRange("Test Suite", TestMethodLine."Test Suite");
        TestMethodLine.ModifyAll(Result, TestMethodLine.Result::" ");
        TestMethodLine.ModifyAll("Error Message Preview", '');

        Commit();

        TestMethodLine.SetRange("Line Type", TestMethodLine."Line Type"::Codeunit);

        OnRunTestSuite(TestMethodLine);

        if TestMethodLine.FindSet() then
            repeat
                OnBeforeCodeunitRun(TestMethodLine);
                CODEUNIT.Run(TestMethodLine."Test Codeunit");
                TestMethodLine.Find();
                OnAfterCodeunitRun(TestMethodLine);
            until TestMethodLine.Next() = 0;

        OnAfterRunTestSuite(TestMethodLine);
    end;

    [Scope('OnPrem')]
    procedure GetDefautlTestRunner(): Integer
    begin
        exit(GetCodeIsolationTestRunner());
    end;

    [Scope('OnPrem')]
    procedure GetIsolationDisabledTestRunner(): Integer
    begin
        exit(CODEUNIT::"Test Runner - Isol. Disabled");
    end;

    [Scope('OnPrem')]
    procedure GetCodeIsolationTestRunner(): Integer
    begin
        exit(CODEUNIT::"Test Runner - Isol. Codeunit");
    end;

    [Scope('OnPrem')]
    procedure PlatformBeforeTestRun(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; TestSuite: Code[10]; LineNoTestFilter: Text): Boolean
    var
        TestMethodLineFunction: Record "Test Method Line";
    begin
        // Invoked by the platform before any codeunit is run
        if (FunctionName = '') or (FunctionName = 'OnRun') then
            exit(true);

        if not GetTestFunction(TestMethodLineFunction, FunctionName, TestSuite, CodeunitID, LineNoTestFilter) then
            exit(false);

        if not TestMethodLineFunction.Run then
            exit(false);

        OnBeforeTestMethodRun(TestMethodLineFunction, CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure PlatformAfterTestRun(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean; TestSuite: Code[10]; LineNoTestFilter: Text)
    var
        TestMethodLine: Record "Test Method Line";
        CodeunitTestMethodLine: Record "Test Method Line";
    begin
        // Invoked by platform after every test method is run
        if (FunctionName = '') or (FunctionName = 'OnRun') then
            exit;

        GetTestFunction(TestMethodLine, FunctionName, TestSuite, CodeunitID, LineNoTestFilter);
        UpdateTestFunctionLine(TestMethodLine, IsSuccess);

        if GetTestCodeunit(CodeunitTestMethodLine, TestMethodLine) then
            UpdateCodeunitLine(CodeunitTestMethodLine, TestMethodLine, IsSuccess);

        Commit();
        ClearLastError();

        OnAfterTestMethodRun(TestMethodLine, CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions, IsSuccess);
    end;

    local procedure UpdateCodeunitLine(var CodeunitTestMethodLine: Record "Test Method Line"; TestMethodLine: Record "Test Method Line"; IsSuccess: Boolean)
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
        FunctionTestMethodLine: Record "Test Method Line";
        DummyBlankDateTime: DateTime;
    begin
        if IsSuccess then begin
            FunctionTestMethodLine.SETRANGE("Test Suite", CodeunitTestMethodLine."Test Suite");
            FunctionTestMethodLine.SETRANGE("Test Codeunit", CodeunitTestMethodLine."Test Codeunit");
            FunctionTestMethodLine.SETRANGE("Line Type", FunctionTestMethodLine."Line Type"::"Function");
            FunctionTestMethodLine.SETRANGE(Result, FunctionTestMethodLine.Result::Failure);
            if not FunctionTestMethodLine.FindFirst() then begin
                CodeunitTestMethodLine.Result := CodeunitTestMethodLine.Result::Success;
                TestSuiteMgt.ClearErrorOnLine(CodeunitTestMethodLine);
            end;
        end else begin
            CodeunitTestMethodLine.Result := CodeunitTestMethodLine.Result::Failure;
            TestSuiteMgt.SetLastErrorOnLine(CodeunitTestMethodLine);
        end;

        if (TestMethodLine."Start Time" < CodeunitTestMethodLine."Start Time") or
           (CodeunitTestMethodLine."Start Time" = DummyBlankDateTime)
        then
            CodeunitTestMethodLine."Start Time" := TestMethodLine."Start Time";

        CodeunitTestMethodLine."Finish Time" := CurrentDateTime();
        CodeunitTestMethodLine.Modify();
    end;

    local procedure UpdateTestFunctionLine(var TestMethodLineFunction: Record "Test Method Line"; IsSuccess: Boolean)
    var
        TestSuiteMgt: Codeunit "Test Suite Mgt.";
    begin
        TestSuiteMgt.ClearErrorOnLine(TestMethodLineFunction);

        if IsSuccess then
            TestMethodLineFunction.Result := TestMethodLineFunction.Result::Success
        else begin
            TestMethodLineFunction.Result := TestMethodLineFunction.Result::Failure;
            TestSuiteMgt.SetLastErrorOnLine(TestMethodLineFunction);
        end;

        TestMethodLineFunction."Finish Time" := CurrentDateTime();
        TestMethodLineFunction.Modify();
    end;

    local procedure GetTestFunction(var TestMethodLineFunction: Record "Test Method Line"; FunctionName: Text[128]; TestSuite: Code[10]; TestCodeunit: Integer; LineNoTestFilter: Text): Boolean
    begin
        TestMethodLineFunction.Reset();
        TestMethodLineFunction.SetRange("Test Suite", TestSuite);
        TestMethodLineFunction.SetRange("Test Codeunit", TestCodeunit);
        TestMethodLineFunction.SetRange("Function", FunctionName);

        if LineNoTestFilter <> '' then
            TestMethodLineFunction.SetFilter("Line No.", LineNoTestFilter);

        if not TestMethodLineFunction.FindFirst() then
            exit(false);

        TestMethodLineFunction."Start Time" := CurrentDateTime();
        TestMethodLineFunction."Finish Time" := TestMethodLineFunction."Start Time";
        TestMethodLineFunction.Result := TestMethodLineFunction.Result::Skipped;
        TestMethodLineFunction.Modify();

        exit(true);
    end;

    local procedure GetTestCodeunit(var CodeunitTestMethodLineFunction: Record "Test Method Line"; var TestMethodLineFunction: Record "Test Method Line"): Boolean
    begin
        CodeunitTestMethodLineFunction.SetRange("Test Suite", TestMethodLineFunction."Test Suite");
        CodeunitTestMethodLineFunction.SetRange("Test Codeunit", TestMethodLineFunction."Test Codeunit");
        CodeunitTestMethodLineFunction.SetRange("Line Type", CodeunitTestMethodLineFunction."Line Type"::Codeunit);

        exit(CodeunitTestMethodLineFunction.FindFirst());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunTestSuite(var TestMethodLine: Record "Test Method Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunTestSuite(var TestMethodLine: Record "Test Method Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCodeunitRun(var TestMethodLine: Record "Test Method Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCodeunitRun(var TestMethodLine: Record "Test Method Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    begin
    end;
}

