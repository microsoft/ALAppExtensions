codeunit 148085 "ERM G/L Account Where-Used CZC"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [G/L Account Where-Used]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        Assert: Codeunit Assert;
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
        isInitialized: Boolean;
        InvalidTableCaptionErr: Label 'Invalid table caption.';
        InvalidFieldCaptionErr: Label 'Invalid field caption.';
        InvalidLineValueErr: Label 'Invalid Line value.';
        MultipleTableIDFilter: Text;

    [Test]
    [HandlerFunctions('WhereUsedHandler')]
    procedure CheckCompensationsSetup()
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
    begin
        // [SCENARIO] Compensations Setup should be shown on Where-Used page
        Initialize();
        MultipleTableIDFilter := Format(Database::"Compensations Setup CZC");

        // [GIVEN] Compensations Setup with "Compensation Bal. Account No." = "G"
        CompensationsSetupCZC.Get();
        CompensationsSetupCZC.Validate("Compensation Bal. Account No.", LibraryERM.CreateGLAccountNo());
        CompensationsSetupCZC.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(CompensationsSetupCZC."Compensation Bal. Account No.");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          CompensationsSetupCZC.TableCaption,
          CompensationsSetupCZC.FieldCaption("Compensation Bal. Account No."),
          StrSubstNo('%1=%2', CompensationsSetupCZC.FieldCaption("Primary Key"), CompensationsSetupCZC."Primary Key"));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    procedure ShowDetailsWhereUsedCompensationsSetup()
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        CompensationsSetupCZCPage: TestPage "Compensations Setup CZC";
    begin
        // [SCENARIO] Compensations Setups page should be open on Show Details action from Where-Used page
        Initialize();
        MultipleTableIDFilter := Format(Database::"Compensations Setup CZC");

        // [GIVEN] Compensations Setup with "Compensation Bal. Account No." = "G"
        CompensationsSetupCZC.Get();
        CompensationsSetupCZC.Validate("Compensation Bal. Account No.", LibraryERM.CreateGLAccountNo());
        CompensationsSetupCZC.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G" and choose Show Details action
        CompensationsSetupCZCPage.Trap();
        CalcGLAccWhereUsed.CheckGLAcc(CompensationsSetupCZC."Compensation Bal. Account No.");

        // [THEN] Compensations Setups page opened
        CompensationsSetupCZCPage.OK().Invoke();
    end;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"ERM G/L Account Where-Used CZC");
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();
        MultipleTableIDFilter := '';
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZC");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZC");
    end;

    local procedure ValidateWhereUsedRecord(ExpectedTableCaption: Text; ExpectedFieldCaption: Text; ExpectedLineValue: Text)
    begin
        Assert.AreEqual(ExpectedTableCaption, LibraryVariableStorage.DequeueText(), InvalidTableCaptionErr);
        Assert.AreEqual(ExpectedFieldCaption, LibraryVariableStorage.DequeueText(), InvalidFieldCaptionErr);
        Assert.AreEqual(ExpectedLineValue, LibraryVariableStorage.DequeueText(), InvalidLineValueErr);
    end;

    [ModalPageHandler]
    procedure WhereUsedHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        if MultipleTableIDFilter <> '' then
            GLAccountWhereUsedList.Filter.SetFilter("Table ID", MultipleTableIDFilter);
        GLAccountWhereUsedList.First();
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Table Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Field Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList.Line.Value);
        GLAccountWhereUsedList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure WhereUsedShowDetailsHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        if MultipleTableIDFilter <> '' then
            GLAccountWhereUsedList.Filter.SetFilter("Table ID", MultipleTableIDFilter);
        GLAccountWhereUsedList.First();
        GLAccountWhereUsedList.ShowDetails.Invoke();
    end;
}

