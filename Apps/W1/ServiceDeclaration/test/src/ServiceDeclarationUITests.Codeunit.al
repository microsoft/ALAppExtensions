codeunit 139902 "Service Declaration UI Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [UI]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryServiceDeclaration: Codeunit "Library - Service Declaration";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        FeatureNotEnabledMessageTxt: Label 'The %1 page is part of the new Service Declaration feature, which is not yet enabled in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';
        ServDeclAlreadyExistErr: Label 'The service declaration %1 already exists.', Comment = '%1 = service declaration number.';

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ShowErorMessageOnServDeclSetupPageWhenFeatureIsDisabled()
    var
        ServDeclSetupPage: Page "Service Declaration Setup";
        ServDeclSetupTestPage: TestPage "Service Declaration Setup";
    begin
        // [SCENARIO 437878] A message "feature is not enabled" thrown when a "Service Declaration Setup" page opened and a service declaration feature is not enabled

        Initialize();
        LibraryServiceDeclaration.DisableFeature();
        LibraryVariableStorage.Enqueue(StrSubstNo(FeatureNotEnabledMessageTxt, ServDeclSetupPage.Caption()));
        asserterror ServDeclSetupTestPage.OpenEdit();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ShowErorMessageOnServTransTypesPageWhenFeatureIsDisabled()
    var
        ServTransactionTypesPage: Page "Service Transaction Types";
        ServTransactionTypesTestPage: TestPage "Service Transaction Types";
    begin
        // [SCENARIO 437878] A message "feature is not enabled" thrown when a "Service Transaction Types" page opened and a service declaration feature is not enabled

        Initialize();
        LibraryServiceDeclaration.DisableFeature();
        LibraryVariableStorage.Enqueue(StrSubstNo(FeatureNotEnabledMessageTxt, ServTransactionTypesPage.Caption()));
        asserterror ServTransactionTypesTestPage.OpenEdit();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ShowErorMessageOnServDeclarationsPageWhenFeatureIsDisabled()
    var
        ServDeclarationsPage: Page "Service Declarations";
        ServDeclarationsTestPage: TestPage "Service Declarations";
    begin
        // [SCENARIO 437878] A message "feature is not enabled" thrown when a "Service Declarations" page opened and a service declaration feature is not enabled

        Initialize();
        LibraryServiceDeclaration.DisableFeature();
        LibraryVariableStorage.Enqueue(StrSubstNo(FeatureNotEnabledMessageTxt, ServDeclarationsPage.Caption()));
        asserterror ServDeclarationsTestPage.OpenEdit();
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NoSeriesListVerifyTwoNosModalPageHandler')]
    procedure ServDeclPageNoHasAssistEditShowingListOfNoSeries()
    var
        NoSeries: Record "No. Series";
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclPage: TestPage "Service Declaration";
    begin
        // [SCENARIO 457814] A "No." field in service declaration page has the "AssistEdit" button that shows list of No. Series
        Initialize();

        // [GIVEN] No. Series "X"
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryVariableStorage.Enqueue(NoSeries.Code);
        // [GIVEN] "Declaration No. Series" is "X" in "Service Declaration Setup"
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Declaration No. Series", NoSeries.Code);
        ServDeclSetup.Modify(true);
        // [GIVEN] No. Series "Y"
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryVariableStorage.Enqueue(NoSeries.Code);
        // [GIVEN] No. Series Relationship "X" -> "Y" 
        LibraryUtility.CreateNoSeriesRelationship(ServDeclSetup."Declaration No. Series", NoSeries.Code);
        // [GIVEN] Service Declaration page is opened for adding new record
        ServDeclPage.OpenNew();
        // [WHEN] Stan click "Assist Edit" on "No." field
        ServDeclPage."No.".AssistEdit();
        // [THEN] No. Series page is opened
        // [THEN] First No. series is "X"
        // [THEN] Second No. series is "Y"
        // Verification done in NoSeriesListModalPageHandler
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NoSeriesSelectFirstModalPageHandler')]
    procedure CannotSetServDeclManuallyIfItThisNumberAlreadyExists()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclHeader: Record "Service Declaration Header";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        // [SCENARIO 457814] Stan cannot set service declaration number manually if this number already exists
        Initialize();
        // [GIVEN] No. Series "X" with the "Manual Nos." option is enabled
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
        LibraryVariableStorage.Enqueue(NoSeries.Code);
        // [GIVEN] "Declaration No. Series" is "X" in "Service Declaration Setup"
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Declaration No. Series", NoSeries.Code);
        ServDeclSetup.Modify(true);
        // [GIVEN] Service declaration with number "SERVDECL-001" from No. Series inserted manually
        ServDeclHeader.Validate("No.", NoSeriesMgt.GetNextNo(ServDeclSetup."Declaration No. Series", WorkDate(), false));
        ServDeclHeader.Insert(true);
        // [WHEN] Call AssistEdit and select No. Series "X"
        Asserterror ServDeclHeader.AssistEdit(ServDeclHeader);
        // [THE] The error message "Service Declaration with number SERVDECL-001 already exists" is thrown
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(ServDeclAlreadyExistErr, ServDeclHeader."No."));
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Declaration UI Tests");
        LibraryServiceDeclaration.InitServDeclSetup();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Declaration UI Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Service Declaration UI Tests");
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Msg, 'Message is not expected');
    end;

    [ModalPageHandler]
    procedure NoSeriesListVerifyTwoNosModalPageHandler(var NoSeriesPage: TestPage "No. Series")
    begin
        NoSeriesPage.Code.AssertEquals(LibraryVariableStorage.DequeueText());
        Assert.IsTrue(NoSeriesPage.Next(), '');
        NoSeriesPage.Code.AssertEquals(LibraryVariableStorage.DequeueText());
        Assert.IsFalse(NoSeriesPage.Next(), '');
    end;

    [ModalPageHandler]
    procedure NoSeriesSelectFirstModalPageHandler(var NoSeriesPage: TestPage "No. Series")
    begin
        NoSeriesPage.Ok().Invoke();
    end;
}
