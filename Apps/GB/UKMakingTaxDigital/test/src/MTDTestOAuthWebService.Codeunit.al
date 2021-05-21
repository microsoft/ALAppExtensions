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

        Assert.IsFalse(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage), '');
        Assert.AreEqual(STRSUBSTNO('%1\%2%3', RefreshFailedTxt, ReasonTxt, HttpError), ActualMessage, '');
        // TFS 324828: Access Token Due DateTime is not changed
        OAuth20Setup.Find();
        OAuth20Setup.TestField("Access Token Due DateTime", AccessTokenDueDateTime);
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
        Assert.IsTrue(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage), '');

        Assert.AreEqual(RefreshSuccessfulTxt, ActualMessage, '');
        VerifyAccessTokenDueDateTime(OAuth20Setup, 2); // TFS 324828
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
        Assert.IsTrue(MTDConnection.InvokeRequest_RefreshAccessToken(ActualMessage), '');

        Assert.AreEqual(RefreshSuccessfulTxt, ActualMessage, '');
        VerifyAccessTokenDueDateTime(OAuth20Setup, 4); // TFS 324828
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_WebClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Web Client type)
        // [SCENARIO 324828] Fraud Prevention Headers are stored (Web Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Web);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_WinClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Win Client type)
        // [SCENARIO 324828] Fraud Prevention Headers are stored (Win Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Windows);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeaders_BatchClient()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are sent each http request (Batch Client type)
        // [SCENARIO 324828] Fraud Prevention Headers are stored (Batch Client type)
        PerformFraudPreventionHeadersForGivenClientType(ClientType::Background);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FraudPreventionHeadersDisabled()
    var
        VATReportSetup: Record "VAT Report Setup";
        JToken: JsonToken;
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 316966] Fraud Prevention Headers are not sent in case of VAT Report Setup "Disable Fraud Prevention Headers" = true
        // [SCENARIO 324828] Fraud Prevention Headers are not stored
        // <parse key="Packet340" compare="MockServicePacket340" response="MakingTaxDigital\200_period_open.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');
        ClearFraudPreventionHeaders();

        RetrieveVATReturnPeriodsForGivenClientType(ClientType::Web);

        JToken.ReadFrom(LibraryMakingTaxDigital.GetLatestHttpLogText());
        AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Connection-Method');
        AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Vendor-Version');
        VerifyCommonBlankedCustomFPHeaders(ReadJsonValue(JToken, 'Request.Header'));

        // TFS 324828: Fraud Prevention Headers are not stored
        VATReportSetup.Get();
        Assert.IsFalse(VATReportSetup."MTD FP WebClient Json".HasValue(), 'Fraud Prevention Headers should not be stored');
        VATReportSetup.TestField("MTD FP WebClient Due DateTime", 0DT);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure NotExpiredBlankedFraudPreventionHeaders()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 324828] Not expired but blanked Fraud Prevention Headers (system invokes WMI and stores the result)
        // <parse key="Packet340" compare="MockServicePacket340" response="MakingTaxDigital\200_period_open.txt"/>
        Initialize();
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(false);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');
        ClearFraudPreventionHeaders();
        SetDummyFPHeaders(CreateDateTime(Today() + 1, Time()), '');

        RetrieveVATReturnPeriodsForGivenClientType(ClientType::Web);

        VerifyDefaultFPHeadersInLatestHttpLog(ClientType::Web);
        VerifyDefaultStoredFPHeaders(ClientType::Web, CurrentDateTime() + 12 * 60 * 60 * 1000);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure NotExpiredFraudPreventionHeaders()
    var
        HeadersDateTime: DateTime;
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 324828] Not expired Fraud Prevention Headers (system loads headers)
        // <parse key="Packet340" compare="MockServicePacket340" response="MakingTaxDigital\200_period_open.txt"/>
        Initialize();
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(false);
        HeadersDateTime := CreateDateTime(LibraryRandom.RandDate(10), 0T);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');
        ClearFraudPreventionHeaders();
        SetDummyFPHeaders(HeadersDateTime, 'dummy');

        RetrieveVATReturnPeriodsForGivenClientType(ClientType::Web);

        VerifyCustomFPHeadersInLatestHttpLog();
        VerifyCustomStoredFPHeaders(ClientType::Web, HeadersDateTime);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExpiredFraudPreventionHeaders()
    begin
        // [FEATURE] [Fraud Prevention]
        // [SCENARIO 324828] Expired Fraud Prevention Headers (system invokes WMI and stores the result)
        // <parse key="Packet340" compare="MockServicePacket340" response="MakingTaxDigital\200_period_open.txt"/>
        Initialize();
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(false);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');
        ClearFraudPreventionHeaders();
        SetDummyFPHeaders(CreateDateTime(Today() - 1, Time()), 'dummy');

        RetrieveVATReturnPeriodsForGivenClientType(ClientType::Web);

        VerifyDefaultFPHeadersInLatestHttpLog(ClientType::Web);
        VerifyDefaultStoredFPHeaders(ClientType::Web, CurrentDateTime() + 12 * 60 * 60 * 1000);
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(true);
        LibrarySetupStorage.Save(Database::"VAT Report Setup");
    end;

    local procedure ClearFraudPreventionHeaders()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        with VATReportSetup do begin
            Get();
            "MTD FP WebClient Due DateTime" := 0DT;
            "MTD FP WinClient Due DateTime" := 0DT;
            "MTD FP Batch Due DateTime" := 0DT;
            Clear("MTD FP WebClient Json");
            Clear("MTD FP WinClient Json");
            Clear("MTD FP Batch Json");
            Modify();
        end;
    end;

    local procedure PerformParseErrorScenario(VATRegNo: Text; ExpectedMessage: Text)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);

        asserterror InvokeRetrievePayments(true);

        VerifyParseErrorScenario(ExpectedMessage);
    end;

    procedure PerformFraudPreventionHeadersForGivenClientType(GivenClientType: ClientType)
    begin
        // MockServicePacket340 MockService\MakingTaxDigital\200_period_open.txt
        Initialize();
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(false);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket340');
        ClearFraudPreventionHeaders();

        RetrieveVATReturnPeriodsForGivenClientType(GivenClientType);

        VerifyDefaultFPHeadersInLatestHttpLog(GivenClientType);
        // TFS 324828: Fraud Prevention Headers are stored with Due DateTime 12 hours from now
        VerifyDefaultStoredFPHeaders(GivenClientType, CurrentDateTime() + 12 * 60 * 60 * 1000);
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

    local procedure SetDummyFPHeaders(DueDateTime: DateTime; GovClientPublicIP: text)
    var
        VATReportSetup: Record "VAT Report Setup";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        JObject: JsonObject;
        OutStream: OutStream;
    begin
        VATReportSetup.Get();
        VATReportSetup."MTD FP WebClient Due DateTime" := DueDateTime;
        if GovClientPublicIP <> '' then begin
            JObject.Add('Gov-Client-Public-IP', GovClientPublicIP);
            TempBlob.CreateOutStream(OutStream);
            JObject.WriteTo(OutStream);
            RecordRef.GetTable(VATReportSetup);
            TempBlob.ToRecordRef(RecordRef, VATReportSetup.FieldNo("MTD FP WebClient Json"));
            RecordRef.SetTable(VATReportSetup);
        end;
        VATReportSetup.Modify();
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
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Connection-Method'), 'Gov-Client-Connection-Method');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Vendor-Version'), 'Gov-Vendor-Version');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Vendor-License-IDs'), 'Gov-Vendor-License-IDs');
        AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Public-IP');

        case GivenClientType of
            ClientType::Windows:
                begin
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Timezone');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-MAC-Addresses');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Screens');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-User-IDs'), 'Gov-Client-User-IDs');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-User-Agent'), 'Gov-Client-User-Agent');
                end;
            ClientType::Web:
                begin
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Timezone'), 'Gov-Client-Timezone');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Device-ID'), 'Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-MAC-Addresses');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Screens'), 'Gov-Client-Screens');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-User-IDs');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-User-Agent');
                end;
            ClientType::Background:
                begin
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Timezone'), 'Gov-Client-Timezone');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Device-ID'), 'Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-MAC-Addresses');
                    AssertBlankedJsonValue(JToken, 'Request.Header.Gov-Client-Screens');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-User-IDs'), 'Gov-Client-User-IDs');
                    Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-User-Agent'), 'Gov-Client-User-Agent');
                end;
        end;
    end;

    local procedure VerifyDefaultStoredFPHeaders(GivenClientType: ClientType; ExpectedDueDateTime: DateTime)
    var
        JToken: JsonToken;
        JsonText: Text;
    begin
        VerifyStoredFPHeadersDateTimeAndReadJson(JsonText, GivenClientType, ExpectedDueDateTime);
        JToken.ReadFrom(JsonText);
        AssertBlankedJsonValue(JToken, 'Gov-Client-Connection-Method');
        AssertBlankedJsonValue(JToken, 'Gov-Vendor-Version');
        Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Vendor-License-IDs') <> '', 'Gov-Vendor-License-IDs');
        AssertBlankedJsonValue(JToken, 'Gov-Client-Public-IP');

        case GivenClientType of
            ClientType::Windows:
                begin
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Timezone');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-MAC-Addresses');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Screens');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-User-IDs') <> '', 'Gov-Client-User-IDs');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-User-Agent') <> '', 'Gov-Client-User-Agent');
                end;
            ClientType::Web:
                begin
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Timezone') <> '', 'Gov-Client-Timezone');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Device-ID') <> '', 'Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-MAC-Addresses');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Screens') <> '', 'Gov-Client-Screens');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-User-IDs');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-User-Agent');
                end;
            ClientType::Background:
                begin
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Timezone') <> '', 'Gov-Client-Timezone');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Device-ID') <> '', 'Gov-Client-Device-ID');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Local-IPs');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-MAC-Addresses');
                    AssertBlankedJsonValue(JToken, 'Gov-Client-Screens');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-User-IDs') <> '', 'Gov-Client-User-IDs');
                    Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-User-Agent') <> '', 'Gov-Client-User-Agent');
                end;
        end;
    end;

    local procedure VerifyCustomFPHeadersInLatestHttpLog()
    var
        JToken: JsonToken;
    begin
        JToken.ReadFrom(LibraryMakingTaxDigital.GetLatestHttpLogText());
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Connection-Method'), 'Gov-Client-Connection-Method');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Vendor-Version'), 'Gov-Vendor-Version');
        Assert.AreEqual('***', ReadJsonValue(JToken, 'Request.Header.Gov-Client-Public-IP'), 'Gov-Client-Public-IP');
        VerifyCommonBlankedCustomFPHeaders(ReadJsonValue(JToken, 'Request.Header'));
    end;

    local procedure VerifyCustomStoredFPHeaders(GivenClientType: ClientType; ExpectedDueDateTime: DateTime)
    var
        JToken: JsonToken;
        JsonText: Text;
    begin
        VerifyStoredFPHeadersDateTimeAndReadJson(JsonText, GivenClientType, ExpectedDueDateTime);
        JToken.ReadFrom(JsonText);
        Assert.IsTrue(ReadJsonValue(JToken, 'Gov-Client-Public-IP') <> '', 'Gov-Client-Public-IP');
        AssertBlankedJsonValue(JToken, 'Gov-Client-Connection-Method');
        AssertBlankedJsonValue(JToken, 'Gov-Vendor-Version');
        VerifyCommonBlankedCustomFPHeaders(JsonText);
    end;

    local procedure VerifyCommonBlankedCustomFPHeaders(JsonText: Text)
    var
        JToken: JsonToken;
    begin
        JToken.ReadFrom(JsonText);
        AssertBlankedJsonValue(JToken, 'Gov-Client-User-IDs');
        AssertBlankedJsonValue(JToken, 'Gov-Client-User-IDs');
        AssertBlankedJsonValue(JToken, 'Gov-Client-Timezone');
        AssertBlankedJsonValue(JToken, 'Gov-Client-User-Agent');
        AssertBlankedJsonValue(JToken, 'Gov-Vendor-License-IDs');
        AssertBlankedJsonValue(JToken, 'Gov-Client-Local-IPs');
        AssertBlankedJsonValue(JToken, 'Gov-Client-MAC-Addresses');
        AssertBlankedJsonValue(JToken, 'Gov-Client-Screens');
    end;

    local procedure VerifyStoredFPHeadersDateTimeAndReadJson(var JsonText: Text; GivenClientType: ClientType; ExpectedDueDateTime: DateTime)
    var
        VATReportSetup: Record "VAT Report Setup";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FieldNo: Integer;
    begin
        // Verify Due DateTime with +- 1 minute for test delay
        VATReportSetup.Get();
        case GivenClientType of
            ClientType::Windows:
                begin
                    Assert.IsTrue(VATReportSetup."MTD FP WinClient Json".HasValue(), 'Fraud Prevention Headers for WinClient should be stored');
                    Assert.IsFalse(VATReportSetup."MTD FP WebClient Json".HasValue(), 'Fraud Prevention Headers for WebClient should not be stored');
                    Assert.IsFalse(VATReportSetup."MTD FP Batch Json".HasValue(), 'Fraud Prevention Headers for BatchClient should not be stored');
                    Assert.IsTrue(
                        Abs(VATReportSetup."MTD FP WinClient Due DateTime" - ExpectedDueDateTime) < 60 * 1000,
                        'Fraud Prevention Headers WinClient Due DateTime');
                    VATReportSetup.TestField("MTD FP WebClient Due DateTime", 0DT);
                    VATReportSetup.TestField("MTD FP Batch Due DateTime", 0DT);
                    FieldNo := VATReportSetup.FieldNo("MTD FP WinClient Json");
                end;
            ClientType::Web:
                begin
                    Assert.IsFalse(VATReportSetup."MTD FP WinClient Json".HasValue(), 'Fraud Prevention Headers for WinClient should not be stored');
                    Assert.IsTrue(VATReportSetup."MTD FP WebClient Json".HasValue(), 'Fraud Prevention Headers for WebClient should be stored');
                    Assert.IsFalse(VATReportSetup."MTD FP Batch Json".HasValue(), 'Fraud Prevention Headers for BatchClient should not be stored');
                    VATReportSetup.TestField("MTD FP WinClient Due DateTime", 0DT);
                    Assert.IsTrue(
                        Abs(VATReportSetup."MTD FP WebClient Due DateTime" - ExpectedDueDateTime) < 60 * 1000,
                        'Fraud Prevention Headers WebClient Due DateTime');
                    VATReportSetup.TestField("MTD FP Batch Due DateTime", 0DT);
                    FieldNo := VATReportSetup.FieldNo("MTD FP WebClient Json");
                end;
            ClientType::Background:
                begin
                    Assert.IsFalse(VATReportSetup."MTD FP WinClient Json".HasValue(), 'Fraud Prevention Headers for WinClient should not be stored');
                    Assert.IsFalse(VATReportSetup."MTD FP WebClient Json".HasValue(), 'Fraud Prevention Headers for WebClient should not be stored');
                    Assert.IsTrue(VATReportSetup."MTD FP Batch Json".HasValue(), 'Fraud Prevention Headers for BatchClient should be stored');
                    VATReportSetup.TestField("MTD FP WinClient Due DateTime", 0DT);
                    VATReportSetup.TestField("MTD FP WebClient Due DateTime", 0DT);
                    Assert.IsTrue(
                        Abs(VATReportSetup."MTD FP Batch Due DateTime" - ExpectedDueDateTime) < 60 * 1000,
                        'Fraud Prevention Headers BatchClient Due DateTime');
                    FieldNo := VATReportSetup.FieldNo("MTD FP Batch Json");
                end;
        end;
        TempBlob.FromRecord(VATReportSetup, FieldNo);
        TempBlob.CreateInStream(InStream);
        InStream.Read(JsonText);
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
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [HyperlinkHandler]
    procedure HyperlinkHandler(Message: Text[1024])
    begin
    end;
}
