// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148086 "MTDTestOAuth"
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
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        ServiceConnectionSandboxSetupLbl: Label 'HMRC VAT Sandbox Setup';
        ServiceConnectionPRODSetupLbl: Label 'HMRC VAT Setup';
        ServiceURLPRODTxt: Label 'https://api.service.hmrc.gov.uk', Locked = true;
        ServiceURLSandboxTxt: Label 'https://test-api.service.hmrc.gov.uk', Locked = true;
        OAuthPRODSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns';
        OAuthSandboxSetupDescriptionLbl: Label 'HMRC Making Tax Digital VAT Returns Sandbox';
        OAuthNotConfiguredErr: Label 'OAuth setup is not enabled for HMRC Making Tax Digital.';
        OpenSetupMsg: Label 'Open service connections to setup.';
        OpenSetupQst: Label 'Do you want to open the setup?';

    [Test]
    [HandlerFunctions('OAuth20Setup_MPH')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
    end;

    [Test]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure OAuthSetupClientTokensVisibility_OnPrem()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [OnPrem]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" client tokens are visible in case of OnPrem
        Initialize();
        LibraryMakingTaxDigital.EnableSaaS(false);
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());

        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
        Assert.IsTrue(OAuth20SetupPage."HMRC VAT Client ID".Visible(), '"HMRC VAT Client ID".Visible');
        Assert.IsTrue(OAuth20SetupPage."HMRC VAT Client Secret".Visible(), '"HMRC VAT Client Secret".Visible');
        OAuth20SetupPage.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure OAuthSetupClientTokensVisibility_SaaS()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [SaaS]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" client tokens are hidden in case of SaaS
        Initialize();
        LibraryMakingTaxDigital.EnableSaaS(true);
        OAuth20Setup.Get(LibraryMakingTaxDigital.GetOAuthSandboxSetupCode());

        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
        Assert.IsFalse(OAuth20SetupPage."HMRC VAT Client ID".Visible(), '"HMRC VAT Client ID".Visible');
        Assert.IsFalse(OAuth20SetupPage."HMRC VAT Client Secret".Visible(), '"HMRC VAT Client Secret".Visible');
        OAuth20SetupPage.Close();
        LibraryMakingTaxDigital.EnableSaaS(false);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckOAuthConfigured_GetPayments_DenyOpenSetup()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (deny open)
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(false, '', '');

        LibraryVariableStorage.Enqueue(false); // deny open OAuth setup
        asserterror InvokeRetrievePayments(false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError('');
        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,OAuth20SetupSetStatus_MPH')]
    [Scope('OnPrem')]
    procedure CheckOAuthConfigured_GetPayments_AcceptOpenSetup_SetDisabled()
    var
        DummyOAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (accept open, leave Disabled setup)
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(false, '', '');

        LibraryVariableStorage.Enqueue(true); // accept open OAuth setup
        LibraryVariableStorage.Enqueue(DummyOAuth20Setup.Status::Disabled);
        asserterror InvokeRetrievePayments(false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError('');
        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckOAuthConfigured_SubmitVATReturn()
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".SubmitVATReturn() shows an error in case of Disabled OAuth 2.0 Setup
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(false, '', '');

        asserterror InvokeSubmitVATReturn();

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupMsg));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MTDConnection_IsError408Timeout()
    var
        MTDConnection: Codeunit "MTD Connection";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 312780] COD 10537 "MTD Connection".IsError408Timeout()
        Assert.IsFalse(MTDConnection.IsError408Timeout(''), '');
        Assert.IsFalse(MTDConnection.IsError408Timeout('{"Status":{"code":"401"}}'), '');
        Assert.IsTrue(MTDConnection.IsError408Timeout('{"Status":{"code":"408"}}'), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckOAuthSetupForConsistencyServiceURL()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDConnection: Codeunit "MTD Connection";
        ResponseJson: Text;
        HttpError: Text;
    begin
        // [SCENARIO 316966] OAuth 2.0 Setup is checked for consistency each http request (Service URL field)
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Enabled, '', 0DT);

        OAuth20Setup."Service URL" := 'test';
        OAuth20Setup.Modify();

        asserterror MTDConnection.InvokeRequest_RetrieveVATReturnPeriods(WorkDate(), WorkDate(), ResponseJson, HttpError, false);

        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(OAuth20Setup.FieldName("Service URL"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CheckOAuthSetupForConsistencyDailyLimit()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDConnection: Codeunit "MTD Connection";
        ResponseJson: Text;
        HttpError: Text;
    begin
        // [SCENARIO 316966] OAuth 2.0 Setup is checked for consistency each http request (Daily Limit field)
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Enabled, '', 0DT);

        OAuth20Setup."Daily Limit" := 0;
        OAuth20Setup.Modify();

        asserterror MTDConnection.InvokeRequest_RetrieveVATReturnPeriods(WorkDate(), WorkDate(), ResponseJson, HttpError, false);

        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(OAuth20Setup.FieldName("Daily Limit"));
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(false, '', '');
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

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;
}
