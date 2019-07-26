// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138074 "Satisfaction Survey Tests"
{
    // [FEATURE] [Satisfaction Survey] [UT]

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryAssert: Codeunit "Library Assert";
        SatisfactionSurveyMgt: Codeunit "Satisfaction Survey Mgt.";
        EnvironmentInfo: Codeunit "Environment Information";
        SatisfactionSurveyEvents: Codeunit "Satisfaction Survey Events";
        MillisecondsPerDay: BigInteger;
        IsInitialized: Boolean;
        TestApiUrlTxt: Label 'https://localhost:8080/', Locked = true;
        DisplayDataTxt: Label 'display/%1/?puid=%2', Locked = true;
        FinancialsUriSegmentTxt: Label 'financials', Locked = true;
        InvoicingUriSegmentTxt: Label 'invoicing', Locked = true;
        ApiUrlTxt: Label 'NpsApiUrl', Locked = true;
        RequestTimeoutTxt: Label 'NpsRequestTimeout', Locked = true;
        CacheLifeTimeTxt: Label 'NpsCacheLifeTime', Locked = true;
        ParametersTxt: Label 'NpsParameters', Locked = true;
        AllowedApplicationSecretsTxt: Label 'AllowedApplicationSecrets', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestResetCache()
    var
        ExpectedUrlBefore: Text;
        ExpectedUrlAfter: Text;
        ActualUrlBefore: Text;
        ActualUrlAfter: Text;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();

        // Execute
        ExpectedUrlBefore := TestApiUrlTxt + 'before';
        ExpectedUrlAfter := TestApiUrlTxt + 'after';
        SetSurveyParameters(ExpectedUrlBefore, 1, 10000);
        SatisfactionSurveyMgt.TryGetCheckUrl(ActualUrlBefore);
        ResetCache();
        SetSurveyParameters(ExpectedUrlAfter, 1, 10000);
        SatisfactionSurveyMgt.TryGetCheckUrl(ActualUrlAfter);

        // Verify
        LibraryAssert.AreEqual(ExpectedUrlBefore, ActualUrlBefore, 'API URL before cache reset is invalid.');
        LibraryAssert.AreEqual(ExpectedUrlAfter, ActualUrlAfter, 'API URL after cache reset is invalid.');
        LibraryAssert.AreNotEqual(ActualUrlBefore, ActualUrlAfter, 'API URL is not updated after cache reset.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestResetState()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        ResetState();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetRequestTimeoutAsync()
    var
        Timeout: Integer;
    begin
        // Execute
        Timeout := SatisfactionSurveyMgt.GetRequestTimeoutAsync();

        // Verify
        LibraryAssert.IsTrue((Timeout > 0) and (Timeout <= 60000), 'Request timeout is incorrect.');
    end;

    [Test]
    [HandlerFunctions('HandleSurveyPage')]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKDisplayTrue()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":true}');

        // Verify
        VerifySurveyEnabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKDisplayFalse()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":false}');

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKMissingDisplay()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(200, '{}');

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKInvalidJson()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(200, ':}invalid json{"');

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusNotFound()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(404, '{"display":true}');

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsUrlEmpty()
    var
        Url: Text;
        Result: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        Result := SatisfactionSurveyMgt.TryGetCheckUrl(Url);

        // Verify
        LibraryAssert.IsFalse(Result, 'API URL is returned.');
        LibraryAssert.AreEqual('', Url, 'API URL is not empty.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingUrlEmpty()
    var
        Url: Text;
        Result: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        Result := SatisfactionSurveyMgt.TryGetCheckUrl(Url);

        // Verify
        LibraryAssert.IsFalse(Result, 'API URL is returned.');
        LibraryAssert.AreEqual('', Url, 'API URL is not empty.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsUrlNotEmpty()
    var
        ActualUrl: Text;
        ExpectedUrl: Text;
        Result: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        Result := SatisfactionSurveyMgt.TryGetCheckUrl(ActualUrl);
        ExpectedUrl := LowerCase(TestApiUrlTxt + StrSubstNo(DisplayDataTxt, FinancialsUriSegmentTxt, GetPuid()));

        // Verify
        LibraryAssert.IsTrue(Result, 'API URL is not returned.');
        LibraryAssert.AreEqual(ExpectedUrl, ActualUrl, 'API URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingUrlNotEmpty()
    var
        ActualUrl: Text;
        ExpectedUrl: Text;
        Result: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        Result := SatisfactionSurveyMgt.TryGetCheckUrl(ActualUrl);
        ExpectedUrl := LowerCase(TestApiUrlTxt + StrSubstNo(DisplayDataTxt, InvoicingUriSegmentTxt, GetPuid()));

        // Verify
        LibraryAssert.IsTrue(Result, 'API URL is not returned.');
        LibraryAssert.AreEqual(ExpectedUrl, ActualUrl, 'API URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledInSandbox()
    var
        IsActivated: Boolean;
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        EnvironmentInfo.SetTestabilitySandbox(true);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDeactivated(IsActivated);
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledInSandbox()
    var
        IsActivated: Boolean;
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        EnvironmentInfo.SetTestabilitySandbox(true);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDeactivated(IsActivated);
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledOnMobileDevice()
    var
        IsActivated: Boolean;
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SatisfactionSurveyEvents.SetPhoneClientType();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDeactivated(IsActivated);
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledOnPrem()
    var
        IsActivated: Boolean;
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        EnvironmentInfo.SetTestabilitySoftwareAsAService(false);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDeactivated(IsActivated);
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledOnPrem()
    var
        IsActivated: Boolean;
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        EnvironmentInfo.SetTestabilitySoftwareAsAService(false);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDeactivated(IsActivated);
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledWhenDeactivated()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        DeactivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledWhenDeactivated()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        DeactivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledWhenPuidEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledWhenPuidEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledWhenApiUrlEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledWhenApiUrlEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyEnabledWhenApiUrlNotEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyEnabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyEnabledWhenApiUrlNotEmpty()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyEnabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyErrorWhenNoConnection()
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        SatisfactionSurveyMgt.TryShowSurvey();

        // Verify
        LibraryAssert.AreNotEqual('', GetLastErrorText(), 'Error is expected.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyErrorWhenNoConnection()
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        SatisfactionSurveyMgt.TryShowSurvey();

        // Verify
        LibraryAssert.AreNotEqual('', GetLastErrorText(), 'Error is expected.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledAfterPresenting()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        SatisfactionSurveyMgt.TryShowSurvey();
        ClearLastError();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInvocingSurveyDisabledAfterPresenting()
    var
        IsEnabled: Boolean;
    begin
        // Setup
        InitializeInvoicing();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        SatisfactionSurveyMgt.TryShowSurvey();
        ClearLastError();
        IsEnabled := IsSurveyEnabled();

        // Verify
        VerifySurveyDisabled(IsEnabled);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActivateSurveyTwice()
    var
        Result1: Boolean;
        Result2: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        Result1 := SatisfactionSurveyMgt.ActivateSurvey();
        Result2 := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        LibraryAssert.IsTrue(Result1, 'Survey is not activated.');
        LibraryAssert.IsFalse(Result2, 'Survey is already activated.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeractivateSurveyTwice()
    var
        Result1: Boolean;
        Result2: Boolean;
    begin
        // Setup
        InitializeFinancials();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();

        // Execute
        ActivateSurvey();
        Result1 := SatisfactionSurveyMgt.DeactivateSurvey();
        Result2 := SatisfactionSurveyMgt.DeactivateSurvey();

        // Verify
        LibraryAssert.IsTrue(Result1, 'Survey is not deactivated.');
        LibraryAssert.IsFalse(Result2, 'Survey is already deactivated.');
    end;

    local procedure InitializeFinancials()
    begin
        Initialize(false);
    end;

    local procedure InitializeInvoicing()
    begin
        Initialize(true);
    end;

    local procedure Initialize(IsInvoicing: Boolean)
    begin
        ClearLastError();
        EnvironmentInfo.SetTestabilitySoftwareAsAService(true);
        EnvironmentInfo.SetTestabilitySandbox(false);
        SatisfactionSurveyMgt.ResetCache();
        SatisfactionSurveyEvents.SetWebClientType();
        if IsInvoicing then
            SatisfactionSurveyEvents.SetInvoicingAppId()
        else
            SatisfactionSurveyEvents.SetFinancialsAppId();

        if IsInitialized then
            exit;

        BindSubscription(SatisfactionSurveyEvents);
        GlobalLanguage := 1033; // mock service supports only this language
        MillisecondsPerDay := 86400000;
        IsInitialized := true;
    end;

    local procedure SetSurveyParameters(ApiUrl: Text; RequestTimeoutMilliseconds: Integer; CacheLifeTimeMinutes: Integer)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        JObject: JsonObject;
        MockAzureKeyVaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        ParametersValue: Text;
    begin
        JObject.Add(ApiUrlTxt, ApiUrl);
        JObject.Add(RequestTimeoutTxt, RequestTimeoutMilliseconds);
        JObject.Add(CacheLifeTimeTxt, CacheLifeTimeMinutes);
        JObject.WriteTo(ParametersValue);
        MockAzureKeyvaultSecretProvider := MockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        MockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsTxt, ParametersTxt);
        MockAzureKeyvaultSecretProvider.AddSecretMapping(ParametersTxt, ParametersValue);
        AzureKeyVault.SetAzureKeyVaultSecretProvider(MockAzureKeyVaultSecretProvider);
    end;

    local procedure SimulatePuidEmpty()
    var
        UserProperty: Record "User Property";
    begin
        if UserProperty.Get(UserSecurityId()) then
            UserProperty.Delete();
    end;

    local procedure SimulatePuidNotEmpty()
    var
        UserProperty: Record "User Property";
    begin
        if UserProperty.Get(UserSecurityId()) then
            UserProperty.Delete();
        UserProperty.Init();
        UserProperty."User Security ID" := UserSecurityId();
        UserProperty."Authentication Object ID" := CopyStr(Format(CreateGuid()), 2, 36);
        UserProperty.Insert();
    end;

    local procedure SimulateApiUrlEmpty()
    begin
        SetSurveyParameters('', 10, 10000);
    end;

    local procedure SimulateApiUrlNotEmpty()
    begin
        SetSurveyParameters(TestApiUrlTxt, 10, 10000);
    end;

    local procedure VerifySurveyActivated(IsActivated: Boolean)
    begin
        LibraryAssert.IsTrue(IsActivated, 'Survey is deactivated.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    local procedure VerifySurveyDisabled(IsEnabled: Boolean)
    begin
        LibraryAssert.IsFalse(IsEnabled, 'Survey is enabled.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    local procedure VerifySurveyDeactivated(IsActivated: Boolean)
    begin
        LibraryAssert.IsFalse(IsActivated, 'Survey is activated.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    local procedure IsSurveyEnabled(): Boolean
    var
        IsEnabled: Boolean;
    begin
        IsEnabled := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":true}');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
        exit(IsEnabled);
    end;

    local procedure GetPuid(): Text
    var
        UserProperty: Record "User Property";
    begin
        if UserProperty.Get(UserSecurityId()) then
            exit(UserProperty."Authentication Object ID");

        exit('');
    end;

    local procedure ActivateSurvey()
    var
        Result: Boolean;
    begin
        Result := SatisfactionSurveyMgt.ActivateSurvey();
        VerifySurveyActivated(Result);
    end;

    local procedure DeactivateSurvey()
    var
        Result: Boolean;
    begin
        Result := not SatisfactionSurveyMgt.DeactivateSurvey();
        VerifySurveyDeactivated(Result);
    end;

    local procedure ResetState()
    var
        Result: Boolean;
    begin
        Result := SatisfactionSurveyMgt.ResetState();
        LibraryAssert.IsTrue(Result, 'State is not reset.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    local procedure ResetCache()
    var
        Result: Boolean;
    begin
        Result := SatisfactionSurveyMgt.ResetCache();
        LibraryAssert.IsTrue(Result, 'Cache is not reset.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    local procedure VerifySurveyEnabled(IsEnabled: Boolean)
    begin
        LibraryAssert.IsTrue(IsEnabled, 'Survey is disabled.');
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Unexpected error.');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure HandleSurveyPage(var SatisfactionSurvey: TestPage "Satisfaction Survey")
    begin
        SatisfactionSurvey.OK().Invoke();
    end;
}

