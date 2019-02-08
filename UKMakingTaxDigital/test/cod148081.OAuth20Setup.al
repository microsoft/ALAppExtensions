// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148081 "UK MTD Tests - OAuth 2.0 Setup"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [OAuth 2.0]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        ServiceConnectionSandboxSetupLbl: Label 'HMRC VAT Sandbox Setup';
        ServiceConnectionPRODSetupLbl: Label 'HMRC VAT Setup';
        ServiceURLPRODTxt: Label 'https://api.service.hmrc.gov.uk', Locked = true;
        ServiceURLSandboxTxt: Label 'https://test-api.service.hmrc.gov.uk', Locked = true;
        OAuthPRODSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns';
        OAuthSandboxSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns Sandbox';
        CheckCompanyVATNoAfterSuccessAuthorizationQst: Label 'Authorization successful.\Do you want to open the Company Information setup to verify the VAT registration number?';
        OAuthNotConfiguredErr: Label 'OAuth setup is not enabled for HMRC Making Tax Digital.';
        OpenSetupMsg: Label 'Open service connections to setup.';
        OpenSetupQst: Label 'Do you want to open the setup?';
        RetrievePaymentsErr: Label 'Not possible to retrieve VAT payments.';
        RetrieveVATPaymentsTxt: Label 'Retrieve VAT Payments.', Locked = true;
        InvokeRequestMsg: Label 'Invoke GET request.', Locked = true;
        Error_VRN_INVALID_Txt: Label 'The provided VRN is invalid.', Locked = true;
        Error_INVALID_DATE_FROM_Txt: Label 'Invalid date from.', Locked = true;
        Error_INVALID_DATE_TO_Txt: Label 'Invalid date to.', Locked = true;
        Error_INVALID_DATE_RANGE_Txt: Label 'Invalid date range.', Locked = true;
        Error_INVALID_STATUS_Txt: Label 'Invalid status.', Locked = true;
        Error_PERIOD_KEY_INVALID_Txt: Label 'Invalid period key.', Locked = true;
        Error_INVALID_REQUEST_Txt: Label 'Invalid request.', Locked = true;
        Error_VAT_TOTAL_VALUE_Txt: Label 'TotalVatDue should be equal to the sum of vatDueSales and vatDueAcquisitions.', Locked = true;
        Error_VAT_NET_VALUE_Txt: Label 'NetVatDue should be the difference between the largest and the smallest values among totalVatDue and vatReclaimedCurrPeriod.', Locked = true;
        Error_INVALID_NUMERIC_VALUE_Txt: Label 'Please provide a numeric field.', Locked = true;
        Error_DATE_RANGE_TOO_LARGE_Txt: Label 'The date of the requested return cannot be more than four years from the current date.', Locked = true;
        Error_NOT_FINALISED_Txt: Label 'User has not declared VAT return as final.', Locked = true;
        Error_DUPLICATE_SUBMISSION_Txt: Label 'User has has already submitted a VAT return for the given period.', Locked = true;
        Error_CLIENT_OR_AGENT_NOT_AUTHORISED_Txt: Label 'The client and/or agent is not authorised.', Locked = true;
        Error_NOT_FOUND_Txt: Label 'The remote endpoint has indicated that no associated data is found.', Locked = true;
        Error_TOO_MANY_REQ_Txt: Label 'The HMRC service is busy. Try again later.', Locked = true;

    [Test]
    [HandlerFunctions('OAuth20Setup_MPH')]
    procedure ServiceConnection_UI_Sandbox()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] Service Connections inits and shows "HMRC VAT Sandbox Setup" in case of VAT Report Setup "OAuth Setup" = "Sandbox"
        Initialize();
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        OAuth20Setup.Delete();

        OpenServiceConnectionSetup(ServiceConnectionSandboxSetupLbl);

        Assert.ExpectedMessage(ServiceURLSandboxTxt, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(OAuthSandboxSetupDescriptionLbl, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('OAuth20Setup_MPH')]
    procedure ServiceConnection_UI_Prod()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] Service Connections shows "HMRC VAT Setup" in case of VAT Report Setup "OAuth Setup" = "Production"
        Initialize();
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthProdSetupCode());
        OAuth20Setup.Delete();
        LibraryMakingTaxDigital.SetOAuthSetupSandbox(false);

        OpenServiceConnectionSetup(ServiceConnectionPRODSetupLbl);

        Assert.ExpectedMessage(ServiceURLPRODTxt, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(OAuthPRODSetupDescriptionLbl, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure MTDOAuth20Mgt_InitOAuthSetup_Sandbox()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
        OAuthSandboxSetupCode: Code[20];
    begin
        // [SCENARIO 258181] COD 10538 "MTD OAuth 2.0 Mgt".InitOAuthSetup() for "Sandbox"
        Initialize();
        OAuthSandboxSetupCode := LibraryMakingTaxDigital.GetOAuthSandboxSetupCode();
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        OAuth20Setup.Delete();

        MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, OAuthSandboxSetupCode);

        VerifyOAuth20Setup(OAuthSandboxSetupCode, ServiceURLSandboxTxt, OAuthSandboxSetupDescriptionLbl);
    end;

    [Test]
    procedure MTDOAuth20Mgt_InitOAuthSetup_Prod()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
        OAuthProdSetupCode: Code[20];
    begin
        // [SCENARIO 258181] COD 10538 "MTD OAuth 2.0 Mgt".InitOAuthSetup() for "Prod"
        Initialize();
        OAuthProdSetupCode := LibraryMakingTaxDigital.GetOAuthProdSetupCode();
        OAuth20Setup.Get(OAuthProdSetupCode);
        OAuth20Setup.Delete();

        MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, OAuthProdSetupCode);

        VerifyOAuth20Setup(OAuthProdSetupCode, ServiceURLPRODTxt, OAuthPRODSetupDescriptionLbl);
    end;

    [Test]
    procedure MTDOAuth20Mgt_IsMTDOAuthSetup_Sandbox()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        // [SCENARIO 258181] COD 10538 "MTD OAuth 2.0 Mgt".IsMTDOAuthSetup() for "Sandbox"
        Initialize();

        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        Assert.IsTrue(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthProdSetupCode());
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Code := '';
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Code := 'test';
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');
    end;

    [Test]
    procedure MTDOAuth20Mgt_IsMTDOAuthSetup_Prod()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        // [SCENARIO 258181] COD 10538 "MTD OAuth 2.0 Mgt".IsMTDOAuthSetup() for "Prod"
        Initialize();
        LibraryMakingTaxDigital.SetOAuthSetupSandbox(false);

        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthProdSetupCode());
        Assert.IsTrue(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Code := '';
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');

        OAuth20Setup.Code := 'test';
        Assert.IsFalse(MTDOAuth20Mgt.IsMTDOAuthSetup(OAuth20Setup), '');
    end;

    [Test]
    procedure OAuthSetupClientTokensVisibility_OnPrem()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [OnPrem]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" client tokens are visible in case of OnPrem
        Initialize();
        EnableSaaS(false);
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());

        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
        Assert.IsTrue(OAuth20SetupPage."HMRC VAT Client ID".Visible(), '"HMRC VAT Client ID".Visible');
        Assert.IsTrue(OAuth20SetupPage."HMRC VAT Client Secret".Visible(), '"HMRC VAT Client Secret".Visible');
        OAuth20SetupPage.Close();
    end;

    [Test]
    procedure OAuthSetupClientTokensVisibility_SaaS()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [SaaS]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" client tokens are hidden in case of SaaS
        Initialize();
        EnableSaaS(true);
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());

        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
        Assert.IsFalse(OAuth20SetupPage."HMRC VAT Client ID".Visible(), '"HMRC VAT Client ID".Visible');
        Assert.IsFalse(OAuth20SetupPage."HMRC VAT Client Secret".Visible(), '"HMRC VAT Client Secret".Visible');
        OAuth20SetupPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckVATRegNoAfterAuthorization_Deny()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [Authorization]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" confirm about check VAT Reg. No. is shown after success authorization (deny confirm)
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);
        LibraryMakingTaxDigital.PrepareResponseOnRequestAccessToken(true, '');
        OpenOAuthSetupPage(OAuth20SetupPage, OAuth20Setup);

        LibraryVariableStorage.Enqueue(false); // deny confirm
        BindSubscription(LibraryMakingTaxDigitalLcl);
        OAuth20SetupPage."Enter Authorization Code".SetValue('Test Authorization Code');
        OAuth20SetupPage.Close();

        Assert.ExpectedMessage(CheckCompanyVATNoAfterSuccessAuthorizationQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,CompanyInformation_MPH')]
    procedure CheckVATRegNoAfterAuthorization_Accept()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [Authorization]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" confirm about check VAT Reg. No. is shown after success authorization (accept confirm)
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);
        LibraryMakingTaxDigital.PrepareResponseOnRequestAccessToken(true, '');
        OpenOAuthSetupPage(OAuth20SetupPage, OAuth20Setup);

        LibraryVariableStorage.Enqueue(true); // accept confirm
        BindSubscription(LibraryMakingTaxDigitalLcl);
        OAuth20SetupPage."Enter Authorization Code".SetValue('Test Authorization Code');
        OAuth20SetupPage.Close();

        Assert.ExpectedMessage(CheckCompanyVATNoAfterSuccessAuthorizationQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure CheckOAuthConfigured_GetPayments_DenyOpenSetup()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (deny open)
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);

        LibraryVariableStorage.Enqueue(false); // deny open OAuth setup
        asserterror InvokeRetrievePayments(false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError('');
        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,OAuth20SetupSetStatus_MPH')]
    procedure CheckOAuthConfigured_GetPayments_AcceptOpenSetup_SetDisabled()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (accept open, leave Disabled setup)
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);

        LibraryVariableStorage.Enqueue(true); // accept open OAuth setup
        LibraryVariableStorage.Enqueue(OAuth20Setup.Status::Disabled);
        asserterror InvokeRetrievePayments(false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError('');
        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,OAuth20SetupSetStatus_MPH')]
    procedure CheckOAuthConfigured_GetPayments_AcceptOpenSetup_SetEnabled()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (accept open, set Enabled setup)
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '', '');

        LibraryVariableStorage.Enqueue(true); // accept open OAuth setup
        LibraryVariableStorage.Enqueue(OAuth20Setup.Status::Enabled);
        BindSubscription(LibraryMakingTaxDigitalLcl);
        InvokeRetrievePayments(false);

        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CheckOAuthConfigured_SubmitVATReturn()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".SubmitVATReturn() shows an error in case of Disabled OAuth 2.0 Setup
        Initialize();
        LibraryMakingTaxDigital.CreateDisbaledOAuthSetup(OAuth20Setup);

        asserterror InvokeSubmitVATReturn();

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupMsg));
    end;

    [Test]
    procedure ParseErrors_Basic()
    begin
        // [SCENARIO 258181] Parsing of basic HMRC json error response in case of error code = 400\403\404
        PerformParseErrorScenario('400', 'VRN_INVALID', Error_VRN_INVALID_Txt);
        PerformParseErrorScenario('400', 'INVALID_DATE_FROM', Error_INVALID_DATE_FROM_Txt);
        PerformParseErrorScenario('400', 'DATE_FROM_INVALID', Error_INVALID_DATE_FROM_Txt);
        PerformParseErrorScenario('400', 'INVALID_DATE_TO', Error_INVALID_DATE_TO_Txt);
        PerformParseErrorScenario('400', 'DATE_TO_INVALID', Error_INVALID_DATE_TO_Txt);
        PerformParseErrorScenario('400', 'INVALID_DATE_RANGE', Error_INVALID_DATE_RANGE_Txt);
        PerformParseErrorScenario('400', 'DATE_RANGE_INVALID', Error_INVALID_DATE_RANGE_Txt);
        PerformParseErrorScenario('400', 'INVALID_STATUS', Error_INVALID_STATUS_Txt);

        PerformParseErrorScenario('400', 'PERIOD_KEY_INVALID', Error_PERIOD_KEY_INVALID_Txt);
        PerformParseErrorScenario('400', 'INVALID_REQUEST', Error_INVALID_REQUEST_Txt);
        PerformParseErrorScenario('400', 'VAT_TOTAL_VALUE', Error_VAT_TOTAL_VALUE_Txt);
        PerformParseErrorScenario('400', 'VAT_NET_VALUE', Error_VAT_NET_VALUE_Txt);
        PerformParseErrorScenario('400', 'INVALID_NUMERIC_VALUE', Error_INVALID_NUMERIC_VALUE_Txt);

        PerformParseErrorScenario('403', 'DATE_RANGE_TOO_LARGE', Error_DATE_RANGE_TOO_LARGE_Txt);
        PerformParseErrorScenario('403', 'NOT_FINALISED', Error_NOT_FINALISED_Txt);
        PerformParseErrorScenario('403', 'DUPLICATE_SUBMISSION', Error_DUPLICATE_SUBMISSION_Txt);
        PerformParseErrorScenario('403', 'CLIENT_OR_AGENT_NOT_AUTHORISED', Error_CLIENT_OR_AGENT_NOT_AUTHORISED_Txt);

        PerformParseErrorScenario('404', 'NOT_FOUND', Error_NOT_FOUND_Txt);
    end;

    [Test]
    procedure ParseErrors_Advanced()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        Value: array[6] of Text;
        i: Integer;
    begin
        // [SCENARIO 258181] Parsing of custom HMRC json error response
        Initialize();
        LibraryMakingTaxDigital.CreateEnabledOAuthSetup(OAuth20Setup);
        for i := 1 to ArrayLen(Value) do
            Value[i] := LibraryUtility.GenerateGUID();

        LibraryMakingTaxDigital.PrepareCustomResponse(
            false, '',
            StrSubstNo('{"message":"%1","code":"dummy","errors":[{"message":"%2"},{"message":"%3","path":"%4"}]}', Value[1], Value[2], Value[3], Value[4]),
            StrSubstNo('{"code":"%1","name":"%2"}', Value[5], Value[6]));

        BindSubscription(LibraryMakingTaxDigitalLcl);
        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(StrSubstNo('%1\%2\%3 (path %4)', Value[1], Value[2], Value[3], Value[4]));
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            false,
            InvokeRequestMsg + ' ' + RetrieveVATPaymentsTxt,
            StrSubstNo('Http error %1 (%2). %3\%4\%5 (path %6)', Value[5], Value[6], Value[1], Value[2], Value[3], Value[4]),
            true);
    end;

    [Test]
    procedure ParseErrors_Error429_TooManyReq()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        Value: array[2] of Text;
        i: Integer;
    begin
        // [SCENARIO 258181] Parsing of http error 429 "Too Many Requests"
        Initialize();
        LibraryMakingTaxDigital.CreateEnabledOAuthSetup(OAuth20Setup);
        for i := 1 to ArrayLen(Value) do
            Value[i] := LibraryUtility.GenerateGUID();

        LibraryMakingTaxDigital.PrepareCustomResponse(
            false, '', StrSubstNo('{"message":"%1","code":"dummy"}', Value[1]), StrSubstNo('{"code":"429","name":"%1"}', Value[2]));

        BindSubscription(LibraryMakingTaxDigitalLcl);
        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(Error_TOO_MANY_REQ_Txt);
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            false,
            InvokeRequestMsg + ' ' + RetrieveVATPaymentsTxt,
            StrSubstNo('Http error %1 (%2). %3', 429, Value[2], Value[1]),
            true);
    end;

    local procedure Initialize()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        LibraryVariableStorage.Clear();
        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);

        if IsInitialized then
            exit;
        IsInitialized := true;

        MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        Commit();
    end;

    local procedure EnableSaaS(Enable: Boolean)
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        PermissionManager.SetTestabilitySoftwareAsAService(Enable);
    end;

    local procedure PerformParseErrorScenario(ErrorCode: Text; Message: Text; ExpectedMessage: Text)
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
    begin
        InitParseErrorScenario(ErrorCode, Message);

        BindSubscription(LibraryMakingTaxDigitalLcl);
        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(ExpectedMessage);
    end;

    local procedure InitParseErrorScenario(ErrorCode: Text; Message: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        Initialize();
        LibraryMakingTaxDigital.CreateEnabledOAuthSetup(OAuth20Setup);
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', StrSubstNo('{"message":"%1","statusCode":"dummy"}', Message), StrSubstNo('{"code":"%1"}', ErrorCode));
    end;

    local procedure InvokeRetrievePayments(ShowMessage: Boolean)
    var
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        MTDMgt.RetrievePayments(WorkDate(), WorkDate(), TotalCount, NewCount, ModifiedCount, ShowMessage);
    end;

    local procedure InvokeSubmitVATReturn()
    var
        MTDMgt: Codeunit "MTD Mgt.";
        RequestJson: Text;
        ResponseJson: Text;
    begin
        MTDMgt.SubmitVATReturn(RequestJson, ResponseJson);
    end;

    local procedure OpenServiceConnectionSetup(NameFilter: Text)
    var
        ServiceConnectionsPage: TestPage "Service Connections";
    begin
        ServiceConnectionsPage.OpenEdit();
        ServiceConnectionsPage.Filter.SetFilter(Name, NameFilter);
        ServiceConnectionsPage.Name.AssertEquals(NameFilter);
        ServiceConnectionsPage.Setup.Invoke();
        ServiceConnectionsPage.Close();
    end;

    local procedure OpenOAuthSetupPage(var OAuth20SetupPage: TestPage "OAuth 2.0 Setup"; OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
    end;

    local procedure VerifyOAuth20Setup(OAuth20SetupCode: Code[20]; ExpectedServiceURL: Text; ExpectedDescription: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        with OAuth20Setup do begin
            Get(OAuth20SetupCode);
            TestField("Service URL", ExpectedServiceURL);
            TestField(Description, ExpectedDescription);
            TestField("Redirect URL", 'urn:ietf:wg:oauth:2.0:oob');
            TestField(Scope, 'write:vat read:vat');
            TestField("Authorization URL Path", '/oauth/authorize');
            TestField("Access Token URL Path", '/oauth/token');
            TestField("Refresh Token URL Path", '/oauth/token');
            TestField("Authorization Response Type", 'code');
            TestField("Token DataScope", "Token DataScope"::Company);
            TestField(Status, Status::Disabled);
        end;
    end;

    local procedure VerifyParseErrorScenario(ExpectedMessage: Text)
    begin
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrievePaymentsErr, LibraryMakingTaxDigital.GetResonLbl(), ExpectedMessage));
    end;

    [ModalPageHandler]
    procedure OAuth20Setup_MPH(var OAuth20SetupPage: TestPage "OAuth 2.0 Setup")
    begin
        LibraryVariableStorage.Enqueue(OAuth20SetupPage."Service URL".Value());
        LibraryVariableStorage.Enqueue(OAuth20SetupPage.Description.Value());
        OAuth20SetupPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure OAuth20SetupSetStatus_MPH(var OAuth20SetupPage: TestPage "OAuth 2.0 Setup")
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());
        OAuth20Setup.Status := LibraryVariableStorage.DequeueInteger();
        OAuth20Setup.Modify();
        OAuth20SetupPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CompanyInformation_MPH(var OAuth20SetupPage: TestPage "Company Information")
    begin
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;
}