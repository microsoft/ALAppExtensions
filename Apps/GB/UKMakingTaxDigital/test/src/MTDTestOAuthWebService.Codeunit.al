// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148081 "MTDTestOAuthWebService"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [OAuth 2.0] [Web Service]
    end;

    var
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        CheckCompanyVATNoAfterSuccessAuthorizationQst: Label 'Authorization successful.\Do you want to open the Company Information setup to verify the VAT registration number?';
        OAuthNotConfiguredErr: Label 'OAuth setup is not enabled for HMRC Making Tax Digital.';
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
        RefreshSuccessfulTxt: Label 'Refresh token successful.';
        RefreshFailedTxt: Label 'Refresh token failed.';
        ReasonTxt: Label 'Reason: ';

    [Test]
    [HandlerFunctions('ConfirmHandler,HyperlinkHandler')]
    [Scope('OnPrem')]
    procedure CheckVATRegNoAfterAuthorization_Deny()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [Authorization]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" confirm about check VAT Reg. No. is shown after success authorization (deny confirm)
        // [SCENARIO 324828] New Access Token Due DateTime is 2 hours from now (previous value is a blanked datetime)
        // <parse key="Packet399" compare="MockServicePacket399" response="MakingTaxDigital\200_authorize.txt"/>
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Disabled, '', 0DT);
        LibraryMakingTaxDigital.MockAzureClientToken('MockServicePacket399');
        OpenOAuthSetupPage(OAuth20SetupPage, OAuth20Setup);

        LibraryVariableStorage.Enqueue(false); // deny confirm
        LibraryMakingTaxDigital.EnableSaaS(true);
        OAuth20SetupPage.RequestAuthorizationCode.Invoke(); // sync client tokens from azure
        OAuth20SetupPage."Enter Authorization Code".SetValue('Test Authorization Code');
        OAuth20SetupPage.Close();
        LibraryMakingTaxDigital.EnableSaaS(false);

        OAuth20Setup.Find();
        OAuth20Setup.TestField(Status, OAuth20Setup.Status::Enabled);
        Assert.ExpectedMessage(CheckCompanyVATNoAfterSuccessAuthorizationQst, LibraryVariableStorage.DequeueText());
        VerifyAccessTokenDueDateTime(OAuth20Setup, 2); // TFS 324828
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,CompanyInformation_MPH,HyperlinkHandler')]
    [Scope('OnPrem')]
    procedure CheckVATRegNoAfterAuthorization_Accept()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20SetupPage: TestPage "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI] [Authorization]
        // [SCENARIO 258181] PAG 1140 "OAuth 2.0 Setup" confirm about check VAT Reg. No. is shown after success authorization (accept confirm)
        // [SCENARIO 324828] New Access Token Due DateTime is 2 hours from now (previous value is 2+ hours old)
        // <parse key="Packet399" compare="MockServicePacket399" response="MakingTaxDigital\200_authorize.txt"/>
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Disabled, '', CreateDateTime(Today() - 1, Time()));
        LibraryMakingTaxDigital.MockAzureClientToken('MockServicePacket399');
        OpenOAuthSetupPage(OAuth20SetupPage, OAuth20Setup);

        LibraryVariableStorage.Enqueue(true); // accept confirm
        LibraryMakingTaxDigital.EnableSaaS(true);
        OAuth20SetupPage.RequestAuthorizationCode.Invoke(); // sync client tokens from azure
        OAuth20SetupPage."Enter Authorization Code".SetValue('Test Authorization Code');
        OAuth20SetupPage.Close();
        LibraryMakingTaxDigital.EnableSaaS(false);

        OAuth20Setup.Find();
        OAuth20Setup.TestField(Status, OAuth20Setup.Status::Enabled);
        Assert.ExpectedMessage(CheckCompanyVATNoAfterSuccessAuthorizationQst, LibraryVariableStorage.DequeueText());
        VerifyAccessTokenDueDateTime(OAuth20Setup, 2); // TFS 324828
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,OAuth20SetupSetStatus_MPH')]
    [Scope('OnPrem')]
    procedure CheckOAuthConfigured_GetPayments_AcceptOpenSetup_SetEnabled()
    var
        DummyOAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] COD 10530 "MTD Mgt.".RetrievePayments() confirms to open OAuth setup (accept open, set Enabled setup)
        // <parse key="Packet330" compare="MockServicePacket330" response="MakingTaxDigital\200_payment.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(false, '', 'MockServicePacket330');

        LibraryVariableStorage.Enqueue(true); // accept open OAuth setup
        LibraryVariableStorage.Enqueue(DummyOAuth20Setup.Status::Enabled);
        InvokeRetrievePayments(false);

        Assert.ExpectedMessage(StrSubstNo('%1\%2', OAuthNotConfiguredErr, OpenSetupQst), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseErrors_Basic()
    begin
        // [SCENARIO 258181] Parsing of basic HMRC json error response in case of error code = 400\403\404
        // MockServicePacket310..MockServicePacket327
        PerformParseErrorScenario('MockServicePacket310', Error_VRN_INVALID_Txt);
        PerformParseErrorScenario('MockServicePacket311', Error_INVALID_DATE_FROM_Txt);
        PerformParseErrorScenario('MockServicePacket312', Error_INVALID_DATE_FROM_Txt);
        PerformParseErrorScenario('MockServicePacket313', Error_INVALID_DATE_TO_Txt);
        PerformParseErrorScenario('MockServicePacket314', Error_INVALID_DATE_TO_Txt);
        PerformParseErrorScenario('MockServicePacket315', Error_INVALID_DATE_RANGE_Txt);
        PerformParseErrorScenario('MockServicePacket316', Error_INVALID_DATE_RANGE_Txt);
        PerformParseErrorScenario('MockServicePacket317', Error_INVALID_STATUS_Txt);
        PerformParseErrorScenario('MockServicePacket318', Error_PERIOD_KEY_INVALID_Txt);
        PerformParseErrorScenario('MockServicePacket319', Error_INVALID_REQUEST_Txt);
        PerformParseErrorScenario('MockServicePacket320', Error_VAT_TOTAL_VALUE_Txt);
        PerformParseErrorScenario('MockServicePacket321', Error_VAT_NET_VALUE_Txt);
        PerformParseErrorScenario('MockServicePacket322', Error_INVALID_NUMERIC_VALUE_Txt);

        PerformParseErrorScenario('MockServicePacket323', Error_DATE_RANGE_TOO_LARGE_Txt);
        PerformParseErrorScenario('MockServicePacket324', Error_NOT_FINALISED_Txt);
        PerformParseErrorScenario('MockServicePacket325', Error_DUPLICATE_SUBMISSION_Txt);
        PerformParseErrorScenario('MockServicePacket326', Error_CLIENT_OR_AGENT_NOT_AUTHORISED_Txt);

        PerformParseErrorScenario('MockServicePacket327', Error_NOT_FOUND_Txt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseErrors_Advanced()
    var
        Value: array[6] of Text;
    begin
        // [SCENARIO 258181] Parsing of custom HMRC json error response
        // <parse key="Packet328" compare="MockServicePacket328" response="MakingTaxDigital\400_custom.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket328');

        Value[1] := '400_custom_msg';
        Value[2] := '400_custom_err1_msg';
        Value[3] := '400_custom_err2_msg';
        Value[4] := '400_custom_err2_path';
        Value[5] := '400';
        Value[6] := 'Bad Request';

        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(StrSubstNo('%1\%2\%3 (path %4)', Value[1], Value[2], Value[3], Value[4]));
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            false,
            InvokeRequestMsg + ' ' + RetrieveVATPaymentsTxt,
            StrSubstNo('HTTP error %1 (%2). %3\%4\%5 (path %6)', Value[5], Value[6], Value[1], Value[2], Value[3], Value[4]),
            true);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ParseErrors_Error429_TooManyReq()
    var
        Value: array[2] of Text;
    begin
        // [SCENARIO 258181] Parsing of HTTP error 429 "Too Many Requests"
        // <parse key="Packet329" compare="MockServicePacket329" response="MakingTaxDigital\429_too_many_requests.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket329');
        Value[1] := 'The request for the API is throttled as you have exceeded your quota.';
        Value[2] := 'Too Many Requests';

        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(Error_TOO_MANY_REQ_Txt);
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            false,
            InvokeRequestMsg + ' ' + RetrieveVATPaymentsTxt,
            StrSubstNo('HTTP error %1 (%2). %3', 429, Value[2], Value[1]),
            true);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MTDConnection_InvokeRequest_RefreshAccessToken_Negative()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDConnection: Codeunit "MTD Connection";
        AccessTokenDueDateTime: DateTime;
        ActualMessage: Text;
        HttpError: Text;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 313380] COD 10537 "MTD Connection".InvokeRequest_RefreshAccessToken() in case of negative response
        // [SCENARIO 324828] Access Token Due DateTime is not changed in case of negative response
        // MockServicePacket304 MockService\MakingTaxDigital\401_unauthorized.txt
        Initialize();
        AccessTokenDueDateTime := CreateDateTime(LibraryRandom.RandDate(10), 0T);
        LibraryMakingTaxDigital.CreateOAuthSetup(
            OAuth20Setup, OAuth20Setup.Status::Enabled, '/MockServicePacket304', AccessTokenDueDateTime);

        HttpError := 'HTTP error 401 (Unauthorized)\invalid client id or secret';

        Assert.IsFalse(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage, true), '');
        Assert.AreEqual(STRSUBSTNO('%1\%2%3', RefreshFailedTxt, ReasonTxt, HttpError), ActualMessage, '');
        // TFS 324828: Access Token Due DateTime is not changed
        OAuth20Setup.Find();
        OAuth20Setup.TestField("Access Token Due DateTime", AccessTokenDueDateTime);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MTDConnection_InvokeRequest_RefreshAccessToken_Positive()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDConnection: Codeunit "MTD Connection";
        ActualMessage: Text;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 313380] COD 10537 "MTD Connection".InvokeRequest_RefreshAccessToken() in case of positive response
        // [SCENARIO 324828] New Access Token Due DateTime is 2 hours from now (previous value is 1 hour from now)
        // MockServicePacket399 MockService\MakingTaxDigital\200_authorize.txt
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(
            OAuth20Setup, OAuth20Setup.Status::Enabled, '/MockServicePacket399', CurrentDateTime() + 60 * 60 * 1000); // now + 1 hour
        Assert.IsTrue(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage, true), '');

        Assert.AreEqual(RefreshSuccessfulTxt, ActualMessage, '');
        VerifyAccessTokenDueDateTime(OAuth20Setup, 2); // TFS 324828
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MTDConnection_InvokeRequest_RefreshAccessToken_Positive_ExpireInSec()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDConnection: Codeunit "MTD Connection";
        ActualMessage: Text;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 313380] COD 10537 "MTD Connection".InvokeRequest_RefreshAccessToken() in case of positive response
        // [SCENARIO 324828] New Access Token Due DateTime is 4 hours from now (parsed from http response 4 hours from now)
        // MockServicePacket398 MockService\MakingTaxDigital\200_authorize_expiresinsec.txt
        Initialize();
        LibraryMakingTaxDigital.CreateOAuthSetup(
            OAuth20Setup, OAuth20Setup.Status::Enabled, '/MockServicePacket398', CurrentDateTime() + 60 * 60 * 1000); // now + 1 hour
        Assert.IsTrue(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage, true), '');

        Assert.AreEqual(RefreshSuccessfulTxt, ActualMessage, '');
        VerifyAccessTokenDueDateTime(OAuth20Setup, 4); // TFS 324828
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_WebClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Web Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Web);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_WinClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Win Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Windows);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_BatchClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Batch Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Background);
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.SetupDefaultFPHeaders();
        LibraryMakingTaxDigital.EnableFeatureConsent(true);
        LibrarySetupStorage.Save(Database::"VAT Report Setup");
    end;

    local procedure PerformParseErrorScenario(VATRegNo: Text; ExpectedMessage: Text)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);

        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure PerformFraudPreventionHeadersForGivenClientType(GivenClientType: ClientType)
    begin
        // MockServicePacket340 MockService\MakingTaxDigital\200_period_open.txt
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');

        RetrieveVATReturnPeriodsForGivenClientType(GivenClientType);

        VerifyDefaultFPHeadersInLatestHttpLog(GivenClientType);
        LibraryVariableStorage.AssertEmpty();
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

    local procedure RetrieveVATReturnPeriodsForGivenClientType(GivenClientType: ClientType)
    var
        TestClientTypeSubscriber: Codeunit "Test Client Type Subscriber";
        MTDConnection: Codeunit "MTD Connection";
        ResponseJson: Text;
        HttpError: Text;
    begin
        TestClientTypeSubscriber.SetClientType(GivenClientType);
        BindSubscription(TestClientTypeSubscriber);
        Assert.IsTrue(MTDConnection.InvokeRequest_RetrieveVATReturnPeriods(WorkDate(), WorkDate(), ResponseJson, HttpError, false), '');
    end;

    local procedure OpenOAuthSetupPage(var OAuth20SetupPage: TestPage "OAuth 2.0 Setup"; OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        OAuth20SetupPage.Trap();
        Page.Run(Page::"OAuth 2.0 Setup", OAuth20Setup);
    end;

    local procedure VerifyParseErrorScenario(ExpectedMessage: Text)
    begin
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrievePaymentsErr, LibraryMakingTaxDigital.GetResonLbl(), ExpectedMessage));
    end;

    local procedure VerifyAccessTokenDueDateTime(OAuth20Setup: Record "OAuth 2.0 Setup"; Hours: Integer)
    begin
        OAuth20Setup.Find();
        // +- 1 minute for test delay
        Assert.IsTrue(
            Abs(OAuth20Setup."Access Token Due DateTime" - CurrentDateTime() - Hours * 60 * 60 * 1000) < 60 * 1000,
            'Access Token Due DateTime should be 2 hours from now');
    end;

    local procedure VerifyDefaultFPHeadersInLatestHttpLog(GivenClientType: ClientType)
    var
        JToken: JsonToken;
    begin
        JToken.ReadFrom(LibraryMakingTaxDigital.GetLatestHttpLogText());
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-CONNECTION-METHOD'), 'Gov-Client-Connection-Method');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-VENDOR-VERSION'), 'Gov-Vendor-Version');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-VENDOR-PRODUCT-NAME'), 'Gov-Vendor-Product-Name');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-TIMEZONE'), 'Gov-Client-Timezone');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-DEVICE-ID'), 'Gov-Client-Device-ID');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-VENDOR-LICENSE-IDS'), 'Gov-Vendor-License-IDs');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-PUBLIC-IP'), 'Gov-Client-Public-IP');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-PUBLIC-IP-TIMESTAMP'), 'Gov-Client-Public-IP-Timestamp');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-USER-IDS'), 'Gov-Client-User-IDs');

        if GivenClientType = ClientType::Background then begin
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-PUBLIC-PORT');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-LOCAL-IPS');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-LOCAL-IPS-TIMESTAMP');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-SCREENS');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-WINDOW-SIZE');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-MULTI-FACTOR');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-VENDOR-PUBLIC-IP');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-VENDOR-FORWARDED');
        end else begin
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-PUBLIC-PORT'), 'Gov-Client-Public-Port');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-LOCAL-IPS'), 'Gov-Client-Local-IPs');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-LOCAL-IPS-TIMESTAMP'), 'Gov-Client-Local-IPs-Timestamp');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-SCREENS'), 'Gov-Client-Screens');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-WINDOW-SIZE'), 'Gov-Client-Window-Size');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-MULTI-FACTOR'), 'Gov-Client-Multi-Factor');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-VENDOR-PUBLIC-IP'), 'Gov-Vendor-Public-IP');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-VENDOR-FORWARDED'), 'Gov-Vendor-Forwarded');
        end;

        if GivenClientType = ClientType::Web then begin
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-PLUGINS'), 'Gov-Client-Browser-Plugins');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-JS-USER-AGENT'), 'Gov-Client-Browser-JS-User-Agent');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-DO-NOT-TRACK'), 'Gov-Client-Browser-Do-Not-Track');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-MAC-ADDRESSES');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-USER-AGENT');
        end else begin
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-PLUGINS');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-JS-USER-AGENT');
            AssertBlankedJsonValue(JToken, 'Request.Header.GOV-CLIENT-BROWSER-DO-NOT-TRACK');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-MAC-ADDRESSES'), 'Gov-Client-MAC-Addresses');
            Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.GOV-CLIENT-USER-AGENT'), 'Gov-Client-User-Agent');
        end;
    end;

    local procedure AssertBlankedJsonValue(JToken: JsonToken; Path: Text)
    begin
        LibraryMakingTaxDigital.AssertBlankedJsonValue(JToken, Path);
    end;

    local procedure ReadJsonValue(JToken: JsonToken; Path: Text): Text
    begin
        exit(LibraryMakingTaxDigital.ReadJsonValue(JToken, Path));
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

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [HyperlinkHandler]
    procedure HyperlinkHandler(Message: Text[1024])
    begin
    end;
}
