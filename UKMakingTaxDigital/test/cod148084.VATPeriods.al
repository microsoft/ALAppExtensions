codeunit 148084 "UK MTD Tests - VAT Periods"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Return Period]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetReturnPeriodsLbl: Label 'Get VAT Return Periods';
        RetrievePeriodsUpToDateMsg: Label 'Retrieve VAT return periods are up to date.';
        RetrievePeriodsErr: Label 'Not possible to retrieve VAT return periods.';
        RetrievePeriodsMsg: Label 'Retrieve VAT return periods successful';
        RetrieveVATReturnPeriodsTxt: Label 'Retrieve VAT Return Periods.', Locked = true;

    [Test]
    procedure GetVATPeriods_Negative_DisabledOutput()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of http error response and disabled message output
        InitGetOnePeriodScenario(DummyVATReturnPeriod, false, '', '');

        GetVATReturnPeriods(DummyVATReturnPeriod, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyVATReturnPeriod);
        VerifyLatestHttpLogFailure(RetrievePeriodsErr);
    end;

    [Test]
    procedure GetVATPeriods_Negative_NoReason()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of http error response without details
        InitGetOnePeriodScenario(DummyVATReturnPeriod, false, '', '');

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    procedure GetVATPeriods_Negative_Reason()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of http error response with details
        HttpError := LibraryUtility.GenerateGUID();
        InitGetOnePeriodScenario(DummyVATReturnPeriod, false, HttpError, '');

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrievePeriodsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure(HttpError);
    end;

    [Test]
    procedure GetVATPeriods_Negative_BlankedJsonResponse()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of blanked http json response
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', '');

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    procedure GetVATPeriods_Negative_WrongJsonResponse()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of wrong http json response
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', '{"wrongobligations":[]}');

        asserterror GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 0, 0, 0);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    procedure GetVATPeriods_OneNewPeriod_DisabledOutput()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one new return period and disabled message output
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);

        GetVATReturnPeriods(DummyVATReturnPeriod, false, true, 1, 1, 0);

        VerifyOnePeriod(DummyVATReturnPeriod);
        VerifyLatestHttpLogSucess(GetRetrievePeriodsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler')]
    procedure GetVATPeriods_OneNewPeriod_UI()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 737 "VAT Return Period List" action "Get VAT Return Periods" in case of a one new return period
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);

        GetVATReturnPeriodsAndShowResultViaPage(DummyVATReturnPeriod);

        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);
        VerifyOnePeriod(DummyVATReturnPeriod);
        VerifyLatestHttpLogSucess(GetRetrievePeriodsMsg(1, 0));
        Assert.ExpectedMessage(GetReturnPeriodsLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(GetRetrievePeriodsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_OneUpToDatePeriod()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one up to date return period
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod, DummyVATReturnPeriod."Due Date", DummyVATReturnPeriod."Period Key", DummyVATReturnPeriod.Status, DummyVATReturnPeriod."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 0);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, RetrievePeriodsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_OneModifiedPeriod_OrgAmt()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Due Date")
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod, DummyVATReturnPeriod."Due Date" + 1, DummyVATReturnPeriod."Period Key", DummyVATReturnPeriod.Status, DummyVATReturnPeriod."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_OneModifiedPeriod_PeriodKey()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Period Key")
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod, DummyVATReturnPeriod."Due Date", LibraryUtility.GenerateGUID(), DummyVATReturnPeriod.Status, DummyVATReturnPeriod."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_OneModifiedPeriod_Status()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Status")
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod, DummyVATReturnPeriod."Due Date", DummyVATReturnPeriod."Period Key", DummyVATReturnPeriod.Status::Closed, DummyVATReturnPeriod."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_OneModifiedPeriod_ReceivedDate()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a one modified return period ("Received Date")
        ResponseJson := CreateOnePeriodJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod.Status::Open);
        InitGetOnePeriodScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod, DummyVATReturnPeriod."Due Date", DummyVATReturnPeriod."Period Key", DummyVATReturnPeriod.Status, DummyVATReturnPeriod."Received Date" + 1);

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod, 1, 0, 1);

        VerifyGetOnePeriodScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoNewPeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two new return periods
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 2, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoUpToDatePeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two up to date return periods
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1]."Due Date", DummyVATReturnPeriod[1]."Period Key", DummyVATReturnPeriod[1].Status, DummyVATReturnPeriod[1]."Received Date");
        MockVATPeriod(DummyVATReturnPeriod[2], DummyVATReturnPeriod[2]."Due Date", DummyVATReturnPeriod[2]."Period Key", DummyVATReturnPeriod[2].Status, DummyVATReturnPeriod[2]."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, RetrievePeriodsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoModifiedPeriods()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two modified return periods
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1]."Due Date" + 1, DummyVATReturnPeriod[1]."Period Key", DummyVATReturnPeriod[1].Status, DummyVATReturnPeriod[1]."Received Date");
        MockVATPeriod(DummyVATReturnPeriod[2], DummyVATReturnPeriod[2]."Due Date", DummyVATReturnPeriod[2]."Period Key", DummyVATReturnPeriod[2].Status::Closed, DummyVATReturnPeriod[2]."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 2);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoPeriodsInclOneNew()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one new
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1]."Due Date", DummyVATReturnPeriod[1]."Period Key", DummyVATReturnPeriod[1].Status, DummyVATReturnPeriod[1]."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 1, 0);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoPeriodsInclOneModified()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one modified
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1]."Due Date", DummyVATReturnPeriod[1]."Period Key", DummyVATReturnPeriod[1].Status, DummyVATReturnPeriod[1]."Received Date");
        MockVATPeriod(DummyVATReturnPeriod[2], DummyVATReturnPeriod[2]."Due Date", DummyVATReturnPeriod[2]."Period Key", DummyVATReturnPeriod[2].Status::Closed, DummyVATReturnPeriod[2]."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 0, 1);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_TwoPeriodsInclOneNewAndOneModified()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturnPeriods() in case of a two return periods including one new and one modified
        ResponseJson := CreateTwoPeriodsJsonResponse(DummyVATReturnPeriod, DummyVATReturnPeriod[1].Status::Open, DummyVATReturnPeriod[2].Status::Open);
        InitGetTwoPeriodsScenario(DummyVATReturnPeriod, true, '', ResponseJson);
        MockVATPeriod(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1]."Due Date", DummyVATReturnPeriod[1]."Period Key", DummyVATReturnPeriod[1].Status::Closed, DummyVATReturnPeriod[1]."Received Date");

        GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod[1], 2, 1, 1);

        VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod, GetRetrievePeriodsMsg(1, 1));
    end;

    [Test]
    procedure GetVATPeriods_AutoReceiveJob_NegativeFirstResponse()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10535 "MTD Auto Receive Period" in case of negative response on the first request
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', '');

        asserterror GetVATReturnPeriodsAutoJob();

        DummyVATReturnPeriod."Start Date" := CalcDate('<-CY>', WorkDate());
        DummyVATReturnPeriod."End Date" := CalcDate('<CY>', WorkDate());
        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);

        VerifyGetPeriodsFailureScenario(RetrievePeriodsErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_AutoReceiveJob_NegativeSecondResponse()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10535 "MTD Auto Receive Period" in case of negative response on the second request
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', CreateOnePeriodJsonResponse(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1].Status::Open), '');
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', '');

        asserterror GetVATReturnPeriodsAutoJob();

        VerifyGetVATReturnPeriodsRequestJsonForAutoJob();

        VerifyOnePeriod(DummyVATReturnPeriod[1]);
        Assert.ExpectedMessage(RetrievePeriodsMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(RetrievePeriodsErr);
        VerifyLatestHttpLogFailure(RetrievePeriodsErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPeriods_AutoReceiveJob_Positive()
    var
        DummyVATReturnPeriod: array[2] of Record "VAT Return Period";
    begin
        // [SCENARIO 258181] COD 10535 "MTD Auto Receive Period" in case of positive response
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', CreateOnePeriodJsonResponse(DummyVATReturnPeriod[1], DummyVATReturnPeriod[1].Status::Open), '');
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', CreateOnePeriodJsonResponse(DummyVATReturnPeriod[2], DummyVATReturnPeriod[2].Status::Open), '');

        GetVATReturnPeriodsAutoJob();

        VerifyGetVATReturnPeriodsRequestJsonForAutoJob();

        VerifyTwoPeriods(DummyVATReturnPeriod);
        Assert.ExpectedMessage(GetRetrievePeriodsMsg(1, 0), LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(GetRetrievePeriodsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(GetRetrievePeriodsMsg(1, 0));
    end;

    [Test]
    procedure MarkAcceptedVATReturnAsClosed()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() updates linked VATReturn.Status from "Accepted" to "Closed"
        ResponseJson := CreateOnePeriodJsonResponse(VATReturnPeriod, VATReturnPeriod.Status::Closed);
        InitGetOnePeriodScenario(VATReturnPeriod, true, '', ResponseJson);
        with VATReturnPeriod do
            MockAndGetVATPeriod(VATReturnPeriod, "Start Date", "End Date", "Due Date", "Period Key", Status::Open, "Received Date");
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportHeader.Status::Accepted);

        GetVATReturnPeriods(VATReturnPeriod, false, true, 1, 0, 1);

        VATReportHeader.Find();
        VATReportHeader.TestField(Status, VATReportHeader.Status::Closed);
    end;

    local procedure Initialize()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        LibraryVariableStorage.Clear();
        ClearRecords();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.CreateEnabledOAuthSetup(OAuth20Setup);
        LibraryMakingTaxDigital.UpdateCompanyInformation();
        Commit();
    end;

    local procedure ClearRecords()
    var
        NameValueBuffer: Record "Name/Value Buffer";
        VATReturnPeriod: Record "VAT Return Period";
        MTDReturnDetails: Record "MTD Return Details";
    begin
        NameValueBuffer.DeleteAll();
        VATReturnPeriod.DeleteAll();
        MTDReturnDetails.DeleteAll();
    end;

    local procedure InitGetOnePeriodScenario(var DummyVATReturnPeriod: Record "VAT Return Period"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATPeriod(DummyVATReturnPeriod);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitGetTwoPeriodsScenario(var DummyVATReturnPeriod: array[2] of Record "VAT Return Period"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATPeriod(DummyVATReturnPeriod[1]);
        InitDummyVATPeriod(DummyVATReturnPeriod[2]);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitDummyVATPeriod(var DummyVATReturnPeriod: Record "VAT Return Period")
    begin
        with DummyVATReturnPeriod do begin
            if "Start Date" = 0D then
                "Start Date" := LibraryRandom.RandDate(10);
            if "End Date" = 0D then
                "End Date" := LibraryRandom.RandDateFrom("Start Date", 10);
        end;
    end;

    local procedure InitDummyVATPeriodValues(var DummyVATReturnPeriod: Record "VAT Return Period"; NewStatus: Option)
    begin
        InitDummyVATPeriod(DummyVATReturnPeriod);
        with DummyVATReturnPeriod do begin
            "Period Key" := LibraryUtility.GenerateGUID();
            "Due Date" := LibraryRandom.RandDate(10);
            Status := NewStatus;
            "Received Date" := LibraryRandom.RandDate(10);
        end;
    end;

    local procedure CreateOnePeriodJsonResponse(var DummyVATReturnPeriod: Record "VAT Return Period"; NewStatus: Option): Text
    begin
        InitDummyVATPeriodValues(DummyVATReturnPeriod, NewStatus);
        exit('{"obligations":[' + CreatePeriodJsonDetails(DummyVATReturnPeriod) + ']}');
    end;

    local procedure CreateTwoPeriodsJsonResponse(var DummyVATReturnPeriod: array[2] of Record "VAT Return Period"; NewStatus1: Option; NewStatus2: Option): Text
    begin
        InitDummyVATPeriodValues(DummyVATReturnPeriod[1], NewStatus1);
        InitDummyVATPeriodValues(DummyVATReturnPeriod[2], NewStatus2);
        exit('{"obligations":[' + CreatePeriodJsonDetails(DummyVATReturnPeriod[1]) + ',' + CreatePeriodJsonDetails(DummyVATReturnPeriod[2]) + ']}');
    end;

    local procedure CreatePeriodJsonDetails(var DummyVATReturnPeriod: Record "VAT Return Period"): Text
    var
        StatusTxt: Text;
    begin
        if DummyVATReturnPeriod.Status = DummyVATReturnPeriod.Status::Open then
            StatusTxt := 'O'
        else
            StatusTxt := 'F';
        with DummyVATReturnPeriod do
            exit(
                StrSubstNo(
                    '{"start":"%1","end":"%2","due":"%3","status":"%4","periodKey":"%5","received":"%6"}',
                    FormatValue("Start Date"), FormatValue("End Date"), FormatValue("Due Date"),
                    StatusTxt, FormatValue("Period Key"), FormatValue("Received Date")));
    end;

    local procedure MockAndGetVATPeriod(var VATReturnPeriod: Record "VAT Return Period"; StartDate: Date; EndDate: Date; DueDate: Date; PeriodKey: Code[10]; Status: Option; ReceivedDate: Date)
    begin
        LibraryMakingTaxDigital.MockVATReturnPeriod(VATReturnPeriod, StartDate, EndDate, DueDate, PeriodKey, Status, ReceivedDate);
    end;

    local procedure MockVATPeriod(DummyVATReturnPeriod: Record "VAT Return Period"; DueDate: Date; PeriodKey: Code[10]; Status: Option; ReceivedDate: Date)
    var
        VATReturnPeriod: Record "VAT Return Period";
    begin
        MockAndGetVATPeriod(VATReturnPeriod, DummyVATReturnPeriod."Start Date", DummyVATReturnPeriod."End Date", DueDate, PeriodKey, Status, ReceivedDate);
    end;

    local procedure GetVATReturnPeriodsAndShowResult(DummyVATReturnPeriod: Record "VAT Return Period"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATReturnPeriods(DummyVATReturnPeriod, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATReturnPeriods(DummyVATReturnPeriod: Record "VAT Return Period"; ShowMessage: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Assert.AreEqual(
            ExpectedResult,
            MTDMgt.RetrieveVATReturnPeriods(DummyVATReturnPeriod."Start Date", DummyVATReturnPeriod."End Date", TotalCount, NewCount, ModifiedCount, ShowMessage, false), 'MTDMgt.RetrieveVATReturnPeriods');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveVATReturnPeriods - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveVATReturnPeriods - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveVATReturnPeriods - ModifiedCount');
    end;

    local procedure GetVATReturnPeriodsAndShowResultViaPage(DummyVATReturnPeriod: Record "VAT Return Period")
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        VATReturnPeriodList: TestPage "VAT Return Period List";
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Commit();
        LibraryVariableStorage.Enqueue(DummyVATReturnPeriod."Start Date");
        LibraryVariableStorage.Enqueue(DummyVATReturnPeriod."End Date");

        VATReturnPeriodList.OpenEdit();
        VATReturnPeriodList."Get VAT Return Periods".Invoke();
        VATReturnPeriodList.Close();
    end;

    local procedure GetVATReturnPeriodsAutoJob()
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Codeunit.Run(Codeunit::"MTD Auto Receive Period");
    end;

    local procedure GetRetrievePeriodsMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrievePeriodsMsg, StrSubstNo(LibraryMakingTaxDigital.GetIncludingLbl(), NewCount, ModifiedCount)));
    end;

    procedure FormatValue(Value: Variant): Text
    begin
        EXIT(LibraryMakingTaxDigital.FormatValue(Value));
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

        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath);
    end;

    local procedure VerifyGetVATReturnPeriodsRequestJsonForAutoJob()
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
    begin
        DummyVATReturnPeriod."Start Date" := CalcDate('<-CY>', WorkDate());
        DummyVATReturnPeriod."End Date" := CalcDate('<CY>', WorkDate());
        VerifyGetVATReturnPeriodsRequestJson(DummyVATReturnPeriod);

        DummyVATReturnPeriod."Start Date" := CalcDate('<1Y>', DummyVATReturnPeriod."Start Date");
        DummyVATReturnPeriod."End Date" := CalcDate('<1Y>', DummyVATReturnPeriod."End Date");
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
    end;

    local procedure VerifyGetOnePeriodScenario(DummyVATReturnPeriod: Record "VAT Return Period"; ExpectedMessage: Text)
    begin
        VerifyOnePeriod(DummyVATReturnPeriod);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyGetTwoPeriodsScenario(DummyVATReturnPeriod: array[2] of Record "VAT Return Period"; ExpectedMessage: Text)
    begin
        VerifyTwoPeriods(DummyVATReturnPeriod);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
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
        VATReturnPeriod.FindFirst();
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
            ExpectedResult, LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATReturnPeriodsTxt, ExpectedActivityMessage, true);
    end;

    [RequestPageHandler]
    procedure GetMTDRecords_RPH(var GetMTDRecords: TestRequestPage "Get MTD Records")
    begin
        GetMTDRecords."Start Date".SetValue(LibraryVariableStorage.DequeueDate());
        GetMTDRecords."End Date".SetValue(LibraryVariableStorage.DequeueDate());
        LibraryVariableStorage.Enqueue(GetMTDRecords.Caption());
        GetMTDRecords.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}