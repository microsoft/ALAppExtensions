// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148084 "MTDTestPeriodsWebService"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Return Period] [Web Service]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetReturnPeriodsLbl: Label 'Get VAT Return Periods';
        RetrievePeriodsUpToDateMsg: Label 'Retrieve VAT return periods are up to date.';
        RetrievePeriodsErr: Label 'Not possible to retrieve VAT return periods.';
        RetrieveVATReturnPeriodsTxt: Label 'Retrieve VAT Return Periods.', Locked = true;
        FeatureConsentErr: Label 'The Making Tax Digital feature is not enabled. To enable it, on the VAT Report Setup page, on the Making Tax Digital FastTab, turn on the Enabled toggle.';

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_Negative_DisabledOutput()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of HTTP error response and disabled message output
        // <parse key="Packet303" compare="333333303" response="MakingTaxDigital\400_blanked.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333303', false);

        GetVATReturnPeriods(DummyVATReturnPeriod, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyVATReturnPeriod);
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request)');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_Negative_Reason()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of HTTP error response with details
        // <parse key="Packet310" compare="333333310" response="MakingTaxDigital\400_vrn_invalid.txt"/>
        HttpError := 'The provided VRN is invalid.';
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333310', false);

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrievePeriodsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request). The provided VRN is invalid.');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_Negative_BlankedJsonResponse()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of blanked http json response
        // <parse key="Packet301" compare="333333301" response="MakingTaxDigital\200_blanked.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333301', false);

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_Negative_WrongJsonResponse()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of wrong http json response
        // <parse key="Packet302" compare="333333302" response="MakingTaxDigital\200_dummyjson.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333302', false);

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneNewPeriod_DisabledOutput()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one new return period and disabled message output
        // <parse key="Packet340" compare="333333340" response="MakingTaxDigital\200_period_open.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333340', false);

        GetVATReturnPeriods(DummyVATReturnPeriod, false, true, 1, 1, 0);

        VerifyOnePeriod(DummyVATReturnPeriod);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0));
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler,SendNotificationHandler,RecallNotificationHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneNewPeriod_UI()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 737 "VAT Return Period List" action "Get VAT Return Periods" in case of a one new return period
        // <parse key="Packet341" compare="333333341" response="MakingTaxDigital\200_period_closed.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333341', true);

        GetVATReturnPeriodsAndShowResultViaPage(DummyVATReturnPeriod);

        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);
        VerifyOnePeriod(DummyVATReturnPeriod);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0));
        Assert.ExpectedMessage(GetReturnPeriodsLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneNewPeriod_ExpiredToken()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one new return period and expired access token
        // <parse key="Packet352" compare="MockServicePacket352" response="MakingTaxDigital\200_period_open.txt"/>
        // <parse key="Packet353" compare="333333353" response="MakingTaxDigital\401_unauthorized.txt"/>
        // <parse key="Packet354" compare="MockServicePacket354" response="MakingTaxDigital\200_authorize_352.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket354', '333333353');
        InitDummyVATPeriod(DummyVATReturnPeriod, false);

        GetVATReturnPeriods(DummyVATReturnPeriod, false, true, 1, 1, 0);

        VerifyOnePeriod(DummyVATReturnPeriod);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0));
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneUpToDatePeriod()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one up to date return period
        // <parse key="Packet340" compare="333333340" response="MakingTaxDigital\200_period_open.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333340', false);
        with DummyVATReturnPeriod do
            MockVATPeriod(DummyVATReturnPeriod, "Due Date", "Period Key", Status, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 0);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, RetrievePeriodsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneModifiedPeriod_OrgAmt()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Due Date")
        // <parse key="Packet340" compare="333333340" response="MakingTaxDigital\200_period_open.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333340', false);
        with DummyVATReturnPeriod do
            MockVATPeriod(DummyVATReturnPeriod, "Due Date" + 1, "Period Key", Status, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneModifiedPeriod_PeriodKey()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Period Key")
        // <parse key="Packet340" compare="333333340" response="MakingTaxDigital\200_period_open.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333340', false);
        with DummyVATReturnPeriod do
            MockVATPeriod(DummyVATReturnPeriod, "Due Date", LibraryUtility.GenerateGUID(), Status, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneModifiedPeriod_Status()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Status")
        // <parse key="Packet341" compare="333333341" response="MakingTaxDigital\200_period_closed.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333341', true);
        with DummyVATReturnPeriod do
            MockVATPeriod(DummyVATReturnPeriod, "Due Date", "Period Key", Status::Open, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_OneModifiedPeriod_ReceivedDate()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Received Date")
        // <parse key="Packet341" compare="333333341" response="MakingTaxDigital\200_period_closed.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333341', true);
        with DummyVATReturnPeriod do
            MockVATPeriod(DummyVATReturnPeriod, "Due Date", "Period Key", Status, "Received Date" + 1);

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoNewPeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two new return periods
        // <parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 2, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoUpToDatePeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two up to date return periods
        // <parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');
        with DummyVATReturnPeriod[1] do
            MockVATPeriod(DummyVATReturnPeriod[1], "Due Date", "Period Key", Status, "Received Date");
        with DummyVATReturnPeriod[2] do
            MockVATPeriod(DummyVATReturnPeriod[2], "Due Date", "Period Key", Status, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, RetrievePeriodsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoModifiedPeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two modified return periods
        //<parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');
        with DummyVATReturnPeriod[1] do
            MockVATPeriod(DummyVATReturnPeriod[1], "Due Date" + 1, "Period Key", Status, "Received Date");
        with DummyVATReturnPeriod[2] do
            MockVATPeriod(DummyVATReturnPeriod[2], "Due Date", "Period Key", Status::Closed, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 2);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoPeriodsInclOneNew()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one new
        // <parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');
        with DummyVATReturnPeriod[1] do
            MockVATPeriod(DummyVATReturnPeriod[1], "Due Date", "Period Key", Status, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 1, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoPeriodsInclOneModified()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one modified
        // <parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');
        with DummyVATReturnPeriod[1] do
            MockVATPeriod(DummyVATReturnPeriod[1], "Due Date", "Period Key", Status, "Received Date");
        with DummyVATReturnPeriod[2] do
            MockVATPeriod(DummyVATReturnPeriod[2], "Due Date", "Period Key", Status::Closed, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 1);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_TwoPeriodsInclOneNewAndOneModified()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one new and one modified
        // <parse key="Packet342" compare="333333342" response="MakingTaxDigital\200_periods.txt"/>
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, '333333342');
        with DummyVATReturnPeriod[1] do
            MockVATPeriod(DummyVATReturnPeriod[1], "Due Date", "Period Key", Status::Open, "Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 1, 1);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 1));
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_AutoReceiveJob_Negative()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10535 "MTD Auto Receive Period" in case of negative response on the first request
        // <parse key="Packet301" compare="333333301" response="MakingTaxDigital\200_blanked.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333301', false);

        asserterror GetVATReturnPeriodsAutoJob();

        DummyVATReturnPeriod."Start Date" := CalcDate('<-CY>', WorkDate());
        DummyVATReturnPeriod."End Date" := CalcDate('<CY>', WorkDate());

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATPeriods_AutoReceiveJob_Positive()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10535 "MTD Auto Receive Period" in case of positive response
        //  <parse key="Packet340" compare="333333340" response="MakingTaxDigital\200_period_open.txt"/>
        InitGetOnePeriodScenario(DummyVATReturnPeriod, '333333340', false);

        GetVATReturnPeriodsAutoJob();

        VerifyGetVATReturnPeriodsRequestJsonForAutoJob();

        VerifyOnePeriod(DummyVATReturnPeriod);
        Assert.ExpectedMessage(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePeriodsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure MarkAcceptedVATReturnAsClosed()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() updates linked VATReturn.Status from "Accepted" to "Closed"
        // <parse key="Packet341" compare="333333341" response="MakingTaxDigital\200_period_closed.txt"/>
        InitGetOnePeriodScenario(VATReturnPeriod, '333333341', false);
        with VATReturnPeriod do
            MockAndGetVATPeriod(VATReturnPeriod, "Start Date", "End Date", "Due Date", "Period Key", Status::Open, "Received Date");
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportHeader.Status::Accepted);

        GetVATReturnPeriods(VATReturnPeriod, false, true, 1, 0, 1);

        VATReportHeader.Find();
        VATReportHeader.TestField(Status, VATReportHeader.Status::Closed);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure FeatureConsentErrorTryingToGetPeriods()
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        // [FEATURE] [Customer Consent]
        // [SCENARIO 407087] An error occurs trying to get VAT Return Periods with disabled feature consent checkbox on VAT Report Setup
        InitGetOnePeriodScenario(VATReturnPeriod, '333333341', false);
        LibraryMakingTaxDigital.EnableFeatureConsent(false);

        asserterror GetVATReturnPeriods(VATReturnPeriod, false, true, 1, 0, 1);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(FeatureConsentErr);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        ClearRecords();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.SetupDefaultFPHeaders();
        LibraryMakingTaxDigital.EnableFeatureConsent(true);
    end;

    local procedure ClearRecords()
    var
        VATReturnPeriod: Record "VAT Return Period";
        MTDReturnDetails: Record "MTD Return Details";
    begin
        VATReturnPeriod.DeleteAll();
        MTDReturnDetails.DeleteAll();
    end;

    local procedure InitGetOnePeriodScenario(var DummyVATReturnPeriod: Record "VAT Return Period"; VATRegNo: Text; ClosedPeriod: Boolean)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);
        InitDummyVATPeriod(DummyVATReturnPeriod, ClosedPeriod);
    end;

    local procedure InitGetTwoPeriodsScenario(var DummyVATReturnPeriod: array[2] of Record "VAT Return Period"; VATRegNo: Text)
    begin
        Initialize();
        LibraryMakingTaxDigital.UpdateCompanyInformation(VATRegNo);
        InitDummyVATPeriod(DummyVATReturnPeriod[1], true);
        DummyVATReturnPeriod[2] := DummyVATReturnPeriod[1];
        with DummyVATReturnPeriod[2] do begin
            "Period Key" := IncStr("Period Key");
            "Start Date" += 1;
            "End Date" += 1;
            "Due Date" += 1;
            Status := Status::Open;
            "Received Date" := 0D;
        end;
    end;

    local procedure InitDummyVATPeriod(var DummyVATReturnPeriod: Record "VAT Return Period"; ClosedPeriod: Boolean)
    begin
        with DummyVATReturnPeriod do begin
            "Start Date" := LibraryMakingTaxDigital.HttpStartDate();
            "End Date" := LibraryMakingTaxDigital.HttpEndDate();
            "Due Date" := LibraryMakingTaxDigital.HttpDueDate();
            "Period Key" := LibraryMakingTaxDigital.HttpPeriodKey();
            IF ClosedPeriod THEN begin
                Status := Status::Closed;
                "Received Date" := LibraryMakingTaxDigital.HttpReceivedDate();
            end ELSE
                Status := Status::Open;
        end;
    end;

    local procedure MockAndGetVATPeriod(var VATReturnPeriod: Record "VAT Return Period"; StartDate: Date; EndDate: Date; DueDate: Date; PeriodKey: Code[10]; Status: Option; ReceivedDate: Date)
    begin
        LibraryMakingTaxDigital.MockVATReturnPeriod(
          VATReturnPeriod, StartDate, EndDate, DueDate, PeriodKey, Status, ReceivedDate);
    end;

    local procedure MockVATPeriod(DummyVATReturnPeriod: Record "VAT Return Period"; DueDate: Date; PeriodKey: Code[10]; Status: Option; ReceivedDate: Date)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        MockAndGetVATPeriod(
          VATReturnPeriod, DummyVATReturnPeriod."Start Date", DummyVATReturnPeriod."End Date", DueDate, PeriodKey, Status, ReceivedDate);
    end;

    local procedure GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod: Record "VAT Return Period"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATReturnPeriods(DummyVATReturnPeriod, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATReturnPeriods(DummyVATReturnPeriod: Record "VAT Return Period"; ShowMessage: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    var
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        Assert.AreEqual(
          ExpectedResult,
          MTDMgt.RetrieveVATReturnPeriods(
            DummyVATReturnPeriod."Start Date", DummyVATReturnPeriod."End Date",
            TotalCount, NewCount, ModifiedCount, ShowMessage, false),
            'MTDMgt.RetrieveVATReturnPeriods');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveVATReturnPeriods - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveVATReturnPeriods - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveVATReturnPeriods - ModifiedCount');
    end;

    local procedure GetVATReturnPeriodsAndShowResultViaPage(DummyVATReturnPeriod: Record "VAT Return Period")
    var
        VATReturnPeriodList: TestPage "VAT Return Period List";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(DummyVATReturnPeriod."Start Date");
        LibraryVariableStorage.Enqueue(DummyVATReturnPeriod."End Date");

        VATReturnPeriodList.OpenEdit();
        VATReturnPeriodList."Get VAT Return Periods".Invoke();
        VATReturnPeriodList.Close();
    end;

    local procedure GetVATReturnPeriodsAutoJob()
    begin
        Codeunit.Run(Codeunit::"MTD Auto Receive Period");
    end;

    local procedure FormatValue(VariantValue: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(VariantValue));
    end;

    local procedure VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod: Record "VAT Return Period")
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath :=
          StrSubstNo(
            '/organisations/vat/%1/obligations?from=%2&to=%3',
            CompanyInformation."VAT Registration No.",
            FormatValue(DummyVATReturnPeriod."Start Date"), FormatValue(DummyVATReturnPeriod."End Date"));

        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath, false);
    end;

    local procedure VerifyGetVATReturnPeriodsRequestJsonForAutoJob()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        DummyVATReturnPeriod."Start Date" := CalcDate('<-CY>', WorkDate());
        DummyVATReturnPeriod."End Date" := CalcDate('<CY>', WorkDate());
        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);
    end;

    local procedure VerifyGetPeriodsFailureScenario(ExpectedMessage: Text)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        Assert.RecordIsEmpty(VATReturnPeriod);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(ExpectedMessage);
        VerifyLatestHttpLogFailure(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyGetOnePeriodScenario(DummyVATReturnPeriod: Record "VAT Return Period"; ExpectedMessage: Text)
    begin
        VerifyOnePeriod(DummyVATReturnPeriod);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod: array[2] of Record "VAT Return Period"; ExpectedMessage: Text)
    begin
        VerifyTwoPeriods(DummyVATReturnPeriod);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyOnePeriod(DummyVATReturnPeriod: Record "VAT Return Period")
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        Assert.RecordCount(VATReturnPeriod, 1);
        VATReturnPeriod.FindFirst();
        VerifySingleVATPeriodRecord(VATReturnPeriod, DummyVATReturnPeriod);
    end;

    local procedure VerifyTwoPeriods(DummyVATReturnPeriod: array[2] of Record "VAT Return Period")
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        Assert.RecordCount(VATReturnPeriod, 2);
        VATReturnPeriod.FindSet();
        VerifySingleVATPeriodRecord(VATReturnPeriod, DummyVATReturnPeriod[1]);
        VATReturnPeriod.Next();
        VerifySingleVATPeriodRecord(VATReturnPeriod, DummyVATReturnPeriod[2]);
    end;

    local procedure VerifySingleVATPeriodRecord(VATReturnPeriod: Record "VAT Return Period"; DummyVATReturnPeriod: Record "VAT Return Period")
    begin
        with VATReturnPeriod do begin
            TestField("Start Date", DummyVATReturnPeriod."Start Date");
            TestField("End Date", DummyVATReturnPeriod."End Date");
            TestField("Due Date", DummyVATReturnPeriod."Due Date");
            TestField(Status, DummyVATReturnPeriod.Status);
            TestField("Period Key", DummyVATReturnPeriod."Period Key");
            TestField("Received Date", DummyVATReturnPeriod."Received Date");
        end;
    end;

    local procedure VerifyLatestHttpLogSucess(ExpectedActivityMessage: Text)
    begin
        VerifyLatestHttpLog(true, ExpectedActivityMessage);
    end;

    local procedure VerifyLatestHttpLogFailure(ExpectedActivityMessage: Text)
    begin
        VerifyLatestHttpLog(false, ExpectedActivityMessage);
    end;

    local procedure VerifyLatestHttpLog(ExpectedResult: Boolean; ExpectedActivityMessage: Text)
    begin
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          ExpectedResult,
          LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATReturnPeriodsTxt, ExpectedActivityMessage, true);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure GetMTDRecords_RPH(var GetMTDRecords: TestRequestPage "Get MTD Records")
    begin
        GetMTDRecords."Start Date".SetValue(LibraryVariableStorage.DequeueDate());
        GetMTDRecords."End Date".SetValue(LibraryVariableStorage.DequeueDate());
        LibraryVariableStorage.Enqueue(GetMTDRecords.Caption());
        GetMTDRecords.OK().Invoke();
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure SendNotificationHandler(var TheNotification: Notification): Boolean
    begin
    end;

    [RecallNotificationHandler]
    [Scope('OnPrem')]
    procedure RecallNotificationHandler(var TheNotification: Notification): Boolean
    begin
    end;

    [ModalPageHandler]
    procedure MTDWebClientFPHeaders_MPH(var MTDWebClientFPHeaders: TestPage "MTD Web Client FP Headers")
    begin
    end;
}
