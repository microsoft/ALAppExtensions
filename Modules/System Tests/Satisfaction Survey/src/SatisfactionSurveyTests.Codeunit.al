// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138074 "Satisfaction Survey Tests"
{
    // [FEATURE] [Satisfaction Survey] [UT]

    Subtype = Test;
    Permissions = tabledata "User Property" = r;

    var
        LibraryAssert: Codeunit "Library Assert";
        SatisfactionSurveyMgt: Codeunit "Satisfaction Survey Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialized: Boolean;
        TestApiUrlTxt: Label 'https://localhost:8080/', Locked = true;
        DisplayDataTxt: Label 'display/%1/?puid=%2', Locked = true;
        FinancialsUriSegmentTxt: Label 'financials', Locked = true;
        ApiUrlTxt: Label 'NpsApiUrl', Locked = true;
        RequestTimeoutTxt: Label 'NpsRequestTimeout', Locked = true;
        CacheLifeTimeTxt: Label 'NpsCacheLifeTime', Locked = true;
        ParametersTxt: Label 'NpsParameters', Locked = true;
        AllowedApplicationSecretsTxt: Label 'AllowedApplicationSecrets', Locked = true;
        FinacialsTok: Label 'FIN', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestResetCache()
    var
        ApiUrlBefore: Text;
        ApiUrlAfter: Text;
        ExpectedCheckUrlBefore: Text;
        ExpectedCheckUrlAfter: Text;
        ActualCheckUrlBefore: Text;
        ActualCheckUrlAfter: Text;
        ResultBefore: Boolean;
        ResultAfter: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ApiUrlBefore := TestApiUrlTxt + 'before/';
        ApiUrlAfter := TestApiUrlTxt + 'after/';
        ExpectedCheckUrlBefore := ApiUrlBefore + StrSubstNo(DisplayDataTxt, FinancialsUriSegmentTxt, GetPuid());
        ExpectedCheckUrlAfter := ApiUrlAfter + StrSubstNo(DisplayDataTxt, FinancialsUriSegmentTxt, GetPuid());
        SetSurveyParameters(ApiUrlBefore, 1, 10000);
        ResultBefore := SatisfactionSurveyMgt.TryGetCheckUrl(ActualCheckUrlBefore);
        ResetCache();
        SetSurveyParameters(ApiUrlAfter, 1, 10000);
        ResultAfter := SatisfactionSurveyMgt.TryGetCheckUrl(ActualCheckUrlAfter);

        // Verify
        LibraryAssert.IsTrue(ResultBefore, 'Cannot get API URL before cache reset.');
        LibraryAssert.IsTrue(ResultAfter, 'Cannot get API URL after cache reset.');
        LibraryAssert.AreEqual(LowerCase(ExpectedCheckUrlBefore), LowerCase(ActualCheckUrlBefore), 'API URL before cache reset is invalid.');
        LibraryAssert.AreEqual(LowerCase(ExpectedCheckUrlAfter), LowerCase(ActualCheckUrlAfter), 'API URL after cache reset is invalid.');
        LibraryAssert.AreNotEqual(LowerCase(ActualCheckUrlBefore), LowerCase(ActualCheckUrlAfter), 'API URL is not updated after cache reset.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestResetState()
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        ResetState();

        // Verify
        VerifySurveyDeactivated();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetRequestTimeoutAsync()
    var
        Timeout: Integer;
    begin
        // Execute
        PermissionsMock.Set('Satisfaction View');
        Timeout := SatisfactionSurveyMgt.GetRequestTimeoutAsync();

        // Verify
        LibraryAssert.IsTrue((Timeout > 0) and (Timeout <= 60000), 'Request timeout is incorrect.');
    end;

    [Test]
    [HandlerFunctions('HandleSurveyPage')]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKDisplayTrue()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":true}');

        // Verify
        VerifySurveyPresented(IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKDisplayFalse()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":false}');

        // Verify
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKMissingDisplay()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(200, '{}');

        // Verify
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusOKInvalidJson()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(200, ':}invalid json{"');

        // Verify
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryShowSurveyStatusNotFound()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(404, '{"display":true}');

        // Verify
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsUrlEmpty()
    var
        Url: Text;
        Result: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

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
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        Result := SatisfactionSurveyMgt.TryGetCheckUrl(ActualUrl);
        ExpectedUrl := TestApiUrlTxt + StrSubstNo(DisplayDataTxt, FinancialsUriSegmentTxt, GetPuid());

        // Verify
        LibraryAssert.IsTrue(Result, 'API URL is not returned.');
        LibraryAssert.AreEqual(LowerCase(ExpectedUrl), LowerCase(ActualUrl), 'API URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledInSandbox()
    var
        IsActivated: Boolean;
    begin
        // Setup
        Initialize();
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(true);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        VerifySurveyDeactivated(not IsActivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledOnMobileDevice()
    var
        IsActivated: Boolean;
    begin
        // Setup
        Initialize();
        TestClientTypeSubscriber.SetClientType(CLIENTTYPE::Phone);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        VerifySurveyDeactivated(not IsActivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledOnPrem()
    var
        IsActivated: Boolean;
    begin
        // Setup
        Initialize();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        VerifySurveyDeactivated(not IsActivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDeactivated()
    var
        IsDeactivated: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsDeactivated := SatisfactionSurveyMgt.DeactivateSurvey();

        // Verify
        VerifySurveyDeactivated(IsDeactivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledWhenPuidEmpty()
    var
        IsActivated: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        VerifySurveyDeactivated(not IsActivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDisabledWhenApiUrlEmpty()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey();

        // Verify
        VerifyRequestNotSent();
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyEnabledWhenApiUrlNotEmpty()
    var
        IsActivated: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        IsActivated := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        VerifySurveyActivated(IsActivated);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyErrorWhenNoConnection()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey();

        // Verify
        VerifyRequestFailed();
        VerifySurveyNotPresented(not IsPresented);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDeactivatedAfterBasePresenting()
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        SatisfactionSurveyMgt.TryShowSurvey();

        // Verify
        VerifySurveyDeactivated();
    end;

    [Test]
    [HandlerFunctions('HandleSurveyPage')]
    [Scope('OnPrem')]
    procedure TestFinancialsSurveyDeactivatedAfterForcePresenting()
    var
        IsPresented: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        IsPresented := SatisfactionSurveyMgt.TryShowSurvey(200, '{"display":true}');

        // Verify
        VerifySurveyPresented(IsPresented);
        VerifySurveyDeactivated();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActivateSurveyTwice()
    var
        Result1: Boolean;
        Result2: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        Result1 := SatisfactionSurveyMgt.ActivateSurvey();
        Result2 := SatisfactionSurveyMgt.ActivateSurvey();

        // Verify
        LibraryAssert.IsTrue(Result1, 'Survey is not activated.');
        LibraryAssert.IsFalse(Result2, 'Survey is already activated.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeactivateSurveyTwice()
    var
        Result1: Boolean;
        Result2: Boolean;
    begin
        // Setup
        Initialize();
        SimulatePuidNotEmpty();
        SimulateApiUrlNotEmpty();
        PermissionsMock.Set('Satisfaction View');

        // Execute
        ActivateSurvey();
        Result1 := SatisfactionSurveyMgt.DeactivateSurvey();
        Result2 := SatisfactionSurveyMgt.DeactivateSurvey();

        // Verify
        LibraryAssert.IsTrue(Result1, 'Survey is not deactivated.');
        LibraryAssert.IsFalse(Result2, 'Survey is already deactivated.');
    end;

    local procedure Initialize()
    begin
        ClearLastError();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        SatisfactionSurveyMgt.ResetCache();
        TestClientTypeSubscriber.SetClientType(ClientType::Web);
        SatisfactionSurveyMgt.ResetState();
        EnvironmentInfoTestLibrary.SetAppId(FinacialsTok);

        if IsInitialized then
            exit;

        if BindSubscription(TestClientTypeSubscriber) then;
        if BindSubscription(EnvironmentInfoTestLibrary) then;
        GlobalLanguage := 1033; // mock service supports only this language
        IsInitialized := true;
    end;

    local procedure SetSurveyParameters(ApiUrl: Text; RequestTimeoutMilliseconds: Integer; CacheLifeTimeMinutes: Integer)
    var
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
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
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(MockAzureKeyVaultSecretProvider);
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
        LibraryAssert.IsTrue(IsActivated, 'Survey is not activated.');
    end;

    local procedure VerifySurveyDeactivated(IsDeactivated: Boolean)
    begin
        LibraryAssert.IsTrue(IsDeactivated, 'Survey is activated.');
    end;

    local procedure VerifySurveyDeactivated()
    var
        IsAlreadyDeactivated: Boolean;
    begin
        IsAlreadyDeactivated := not SatisfactionSurveyMgt.DeactivateSurvey();
        LibraryAssert.IsTrue(IsAlreadyDeactivated, 'Survey is activated.');
    end;

    local procedure VerifySurveyPresented(Presented: Boolean)
    begin
        LibraryAssert.IsTrue(Presented, 'Survey is not presented.');
    end;

    local procedure VerifySurveyNotPresented(IsNotPresented: Boolean)
    begin
        LibraryAssert.IsTrue(IsNotPresented, 'Survey is presented.');
    end;


    local procedure VerifyRequestFailed()
    begin
        LibraryAssert.ExpectedError('Request failed');
    end;

    local procedure VerifyRequestNotSent()
    begin
        LibraryAssert.IsFalse(StrPos(GetLastErrorText(), 'Request failed') > 0, 'Request is sent.');
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
        Result := SatisfactionSurveyMgt.DeactivateSurvey();
        VerifySurveyDeactivated(Result);
    end;

    local procedure ResetState()
    var
        Result: Boolean;
    begin
        Result := SatisfactionSurveyMgt.ResetState();
        LibraryAssert.IsTrue(Result, 'State is not reset.');
    end;

    local procedure ResetCache()
    var
        Result: Boolean;
    begin
        Result := SatisfactionSurveyMgt.ResetCache();
        LibraryAssert.IsTrue(Result, 'Cache is not reset.');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure HandleSurveyPage(var SatisfactionSurvey: TestPage "Satisfaction Survey")
    begin
        SatisfactionSurvey.OK().Invoke();
    end;
}

