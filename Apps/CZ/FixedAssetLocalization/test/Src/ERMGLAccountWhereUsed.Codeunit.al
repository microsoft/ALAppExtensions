codeunit 148086 "ERM G/L Account Where-Used CZF"
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
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryFixedAssetCZF: Codeunit "Library - Fixed Asset CZF";
        Assert: Codeunit Assert;
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
        isInitialized: Boolean;
        InvalidTableCaptionErr: Label 'Invalid table caption.';
        InvalidFieldCaptionErr: Label 'Invalid field caption.';
        InvalidLineValueErr: Label 'Invalid Line value.';
        MultipleTableIDFilter: Text;

    [Test]
    [HandlerFunctions('WhereUsedHandler')]
    procedure CheckFAExtendedPostingGroup()
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        // [SCENARIO] FA Extended Posting Group should be shown on Where-Used page
        Initialize();
        MultipleTableIDFilter := Format(Database::"FA Extended Posting Group CZF");

        // [GIVEN] FA Extended Posting Group with "Maintenance Expense Account" = "G"
        CreateFAExtendedPostingGroup(FAExtendedPostingGroupCZF);

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(FAExtendedPostingGroupCZF."Maintenance Expense Account");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          FAExtendedPostingGroupCZF.TableCaption,
          FAExtendedPostingGroupCZF.FieldCaption("Maintenance Expense Account"),
          StrSubstNo(
            '%1=%2, %3=%4, %5=%6',
            FAExtendedPostingGroupCZF.FieldCaption("FA Posting Group Code"),
            FAExtendedPostingGroupCZF."FA Posting Group Code",
            FAExtendedPostingGroupCZF.FieldCaption("FA Posting Type"),
            FAExtendedPostingGroupCZF."FA Posting Type",
            FAExtendedPostingGroupCZF.FieldCaption(Code),
            FAExtendedPostingGroupCZF.Code));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    procedure ShowDetailsWhereUsedFAExtendedPostingGroup()
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        FAExtendedPostingGroupsCZF: TestPage "FA Extended Posting Groups CZF";
    begin
        // [SCENARIO] FA Extended Posting Groups page should be open on Show Details action from Where-Used page
        Initialize();
        MultipleTableIDFilter := Format(Database::"FA Extended Posting Group CZF");

        // [GIVEN] FA Extended Posting Group "FA Posting Group Code" = "FPGC", "FA Posting Type" = "Disposal", Code = "C" with "Maintenance Expense Account" = "G"
        CreateFAExtendedPostingGroup(FAExtendedPostingGroupCZF);

        // [WHEN] Run Where-Used function for G/L Accoun "G" and choose Show Details action
        FAExtendedPostingGroupsCZF.Trap();
        CalcGLAccWhereUsed.CheckGLAcc(FAExtendedPostingGroupCZF."Maintenance Expense Account");

        // [THEN] FA Extended Posting Groups page opened with "FA Posting Type" = "Disposal", Code = "C"
        FAExtendedPostingGroupsCZF."FA Posting Type".AssertEquals(FAExtendedPostingGroupCZF."FA Posting Type");
        FAExtendedPostingGroupsCZF.Code.AssertEquals(FAExtendedPostingGroupCZF.Code);
    end;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"ERM G/L Account Where-Used CZF");
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();
        MultipleTableIDFilter := '';
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZF");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"ERM G/L Account Where-Used CZF");
    end;

    local procedure CreateFAExtendedPostingGroup(var FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF")
    var
        ReasonCode: Record "Reason Code";
        FAPostingGroup: Record "FA Posting Group";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
        LibraryFixedAssetCZF.CreateFAExtendedPostingGroup(
          FAExtendedPostingGroupCZF, FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonCode.Code);
        FAExtendedPostingGroupCZF.Validate("Maintenance Expense Account", LibraryERM.CreateGLAccountNo());
        FAExtendedPostingGroupCZF.Modify();
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

