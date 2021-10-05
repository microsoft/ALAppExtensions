codeunit 148084 "ERM G/L Account Where-Used CZB"
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
    procedure CheckBankAccount()
    var
        BankAccount: Record "Bank Account";
    begin
        // [SCENARIO] Bank Account should be shown on Where-Used page
        Initialize();

        // [GIVEN] Bank Account with "Non Assoc. Payment Account CZB" = "G"
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Non Assoc. Payment Account CZB", LibraryERM.CreateGLAccountNo());
        BankAccount.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(BankAccount."Non Assoc. Payment Account CZB");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          BankAccount.TableCaption,
          BankAccount.FieldCaption("Non Assoc. Payment Account CZB"),
          StrSubstNo('%1=%2', BankAccount.FieldCaption("No."), BankAccount."No."));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    procedure ShowDetailsWhereUsedBankAccount()
    var
        BankAccount: Record "Bank Account";
        BankAccountList: TestPage "Bank Account List";
    begin
        // [SCENARIO] Bank Accounts page should be open on Show Details action from Where-Used page
        Initialize();

        // [GIVEN] Bank Account "B" with "Non Assoc. Payment Account CZB" = "G"
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Non Assoc. Payment Account CZB", LibraryERM.CreateGLAccountNo());
        BankAccount.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G" and choose Show Details action
        BankAccountList.Trap();
        CalcGLAccWhereUsed.CheckGLAcc(BankAccount."Non Assoc. Payment Account CZB");

        // [THEN] Bank Accounts page opened with "No." = "B"
        BankAccountList."No.".AssertEquals(BankAccount."No.");
    end;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"ERM G/L Account Where-Used CZB");
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();
        MultipleTableIDFilter := '';
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZB");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZB");
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

