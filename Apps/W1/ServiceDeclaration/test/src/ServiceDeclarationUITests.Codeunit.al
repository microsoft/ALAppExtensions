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
        IsInitialized: Boolean;
        FeatureNotEnabledMessageTxt: Label 'The %1 page is part of the new Service Declaration feature, which is not yet enabled in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';

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

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Declaration UI Tests");

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
}