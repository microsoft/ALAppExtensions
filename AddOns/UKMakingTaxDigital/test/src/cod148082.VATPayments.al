// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148082 "UK MTD Tests - VAT Payments"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Payment]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetPaymentsLbl: Label 'Get VAT Payments';
        RetrievePaymentsMsg: Label 'Retrieve VAT payments successful';
        RetrievePaymentsErr: Label 'Not possible to retrieve VAT payments.';
        RetrievePaymentsUpToDateMsg: Label 'Retrieve VAT payments are up to date.';
        RetrieveVATPaymentsTxt: Label 'Retrieve VAT Payments.', Locked = true;

    [Test]
    procedure MTDPayment_DiffersFromPayment()
    var
        MTDPayment: array[2] of Record "MTD Payment";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 258181] TAB 10531 MTDPayment.DiffersFromPayment()
        MockAndgetVATPayment(MTDPayment[1], WorkDate(), WorkDate(), 1, WorkDate(), 1);

        MTDPayment[2] := MTDPayment[1];
        Assert.Isfalse(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');

        MTDPayment[2]."Received Date" += 1;
        Assert.IsTrue(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');

        MTDPayment[2] := MTDPayment[1];
        MTDPayment[2].Amount += 0.01;
        Assert.IsTrue(MTDPayment[1].DiffersFromPayment(MTDPayment[2]), '');
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_Negative_DisabledOutput()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of http error response and disabled message output
        InitGetOnePaymentScenario(DummyMTDPayment, false, '', '');

        GetVATPayments(DummyMTDPayment, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyMTDPayment);
        VerifyLatestHttpLogFailure(RetrievePaymentsErr);
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_Negative_NoReason()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of http error response without details
        InitGetOnePaymentScenario(DummyMTDPayment, false, '', '');

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        VerifyGetPmtFailureScenario(RetrievePaymentsErr);
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_Negative_Reason()
    var
        DummyMTDPayment: Record "MTD Payment";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of http error response with details
        HttpError := LibraryUtility.GenerateGUID();
        InitGetOnePaymentScenario(DummyMTDPayment, false, HttpError, '');

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrievePaymentsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure(HttpError);
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_Negative_BlankedJsonResponse()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of blanked http json response
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', '');

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        VerifyGetPmtFailureScenario(RetrievePaymentsErr);
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_Negative_WrongJsonResponse()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of wrong http json response
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', '{"wrongpayments":[]}');

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        VerifyGetPmtFailureScenario(RetrievePaymentsErr);
    end;

    [Test]
    procedure GetVATPaymentsAndShowResult_OneNew_DisabledOutput()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one new payment with disabled message output
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithDateJsonResponse(DummyMTDPayment));

        GetVATPayments(DummyMTDPayment, false, true, 1, 1, 0);

        VerifyOnePayment(DummyMTDPayment);
        VerifyLatestHttpLogSucess(GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneNewPmtWithDate_UI()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 10531 "MTD Payments" action "Get Payments" in case of a one new payment with date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResultViaPage(DummyMTDPayment);

        VerifyGetPaymentRequestJson(DummyMTDPayment);
        VerifyOnePayment(DummyMTDPayment);
        VerifyLatestHttpLogSucess(GetRetrievePaymentsMsg(1, 0));
        Assert.ExpectedMessage(GetPaymentsLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(GetRetrievePaymentsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneNewPmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one new payment without date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithoutDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 1, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneUpToDatePmtWithDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one up to date payment with date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneUpToDatePmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one up to date payment without date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithoutDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneModifiedPmtWithDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one modified payment with date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date" + 1, DummyMTDPayment.Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 1);

        VerifyGetOnePmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_OneModifiedPmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one modified payment without date
        InitGetOnePaymentScenario(DummyMTDPayment, true, '', CreateOnePmtWithoutDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 1);

        VerifyGetOnePmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithDates()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with dates
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithoutDates()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments without dates
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithoutDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithOnlyFirstDate()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with only first date
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithOnlyFirstDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithOnlySecondDate()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with only second date
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithOnlySecondDateJsonResponse(DummyMTDPayment));

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoUpToDatePmt()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two up to date payments with dates
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[2]."Received Date", DummyMTDPayment[2].Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoModifiedPmt()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two modified payments with dates
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date" + 1, DummyMTDPayment[1].Amount + 0.01);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[2]."Received Date" - 1, DummyMTDPayment[2].Amount - 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 2);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneNew()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one new
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 1, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneModified()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one modified
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[1]."Received Date" + 1, DummyMTDPayment[1].Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 1);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneNewAndOneModified()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one new and one modified
        InitGetTwoPaymentsScenario(DummyMTDPayment, true, '', CreateTwoPmtWithDateJsonResponse(DummyMTDPayment));
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 1, 1);

        VerifyGetTwoPmtScenario(DummyMTDPayment, GetRetrievePaymentsMsg(1, 1));
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
        MTDPayment: Record "MTD Payment";
    begin
        NameValueBuffer.DeleteAll();
        MTDPayment.DeleteAll();
    end;

    local procedure InitGetOnePaymentScenario(var MTDPayment: Record "MTD Payment"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATPayment(MTDPayment);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitGetTwoPaymentsScenario(var MTDPayment: array[2] of Record "MTD Payment"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitTwoDummyVATPayments(MTDPayment);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitDummyVATPayment(var MTDPayment: Record "MTD Payment")
    begin
        with MTDPayment do begin
            "Start Date" := LibraryRandom.RandDate(10);
            "End Date" := LibraryRandom.RandDateFrom("Start Date", 10);
            "Entry No." := 1;
        end;
    end;

    local procedure InitTwoDummyVATPayments(var MTDPayment: array[2] of Record "MTD Payment")
    begin
        InitDummyVATPayment(MTDPayment[1]);
        MTDPayment[2]."Start Date" := MTDPayment[1]."Start Date";
        MTDPayment[2]."End Date" := MTDPayment[1]."End Date";
        MTDPayment[2]."Entry No." := MTDPayment[1]."Entry No." + 1;
    end;

    local procedure InitDummyVATPaymentWithDateValues(var MTDPayment: Record "MTD Payment")
    begin
        InitDummyVATPaymentValues(MTDPayment, LibraryRandom.RandDecInRange(10000, 20000, 2), LibraryRandom.RandDate(10));
    end;

    local procedure InitDummyVATPaymentWithoutDateValues(var MTDPayment: Record "MTD Payment")
    begin
        InitDummyVATPaymentValues(MTDPayment, LibraryRandom.RandDecInRange(10000, 20000, 2), 0D);
    end;

    local procedure InitDummyVATPaymentValues(var MTDPayment: Record "MTD Payment"; NewAmount: Decimal; NewRecevivedDate: Date)
    begin
        with MTDPayment do begin
            Amount := NewAmount;
            "Received Date" := NewRecevivedDate;
        end;
    end;

    local procedure CreateOnePmtWithDateJsonResponse(var MTDPayment: Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithDateValues(MTDPayment);
        exit(StrSubstNo('{"payments":[{"received":"%1","amount":"%2"}]}', FormatValue(MTDPayment."Received Date"), FormatValue(MTDPayment.Amount)));
    end;

    local procedure CreateOnePmtWithoutDateJsonResponse(var MTDPayment: Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithoutDateValues(MTDPayment);
        exit(StrSubstNo('{"payments":[{"amount":"%1"}]}', FormatValue(MTDPayment.Amount)));
    end;

    local procedure CreateTwoPmtWithDateJsonResponse(var MTDPayment: array[2] of Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithDateValues(MTDPayment[1]);
        InitDummyVATPaymentWithDateValues(MTDPayment[2]);
        exit(
            StrSubstNo(
                '{"payments":[{"received":"%1","amount":"%2"},{"received":"%3","amount":"%4"}]}',
                FormatValue(MTDPayment[1]."Received Date"), FormatValue(MTDPayment[1].Amount),
                FormatValue(MTDPayment[2]."Received Date"), FormatValue(MTDPayment[2].Amount)));
    end;

    local procedure CreateTwoPmtWithoutDateJsonResponse(var MTDPayment: array[2] of Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithoutDateValues(MTDPayment[1]);
        InitDummyVATPaymentWithoutDateValues(MTDPayment[2]);
        exit(StrSubstNo('{"payments":[{"amount":"%1"},{"amount":"%2"}]}', FormatValue(MTDPayment[1].Amount), FormatValue(MTDPayment[2].Amount)));
    end;

    local procedure CreateTwoPmtWithOnlyFirstDateJsonResponse(var MTDPayment: array[2] of Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithDateValues(MTDPayment[1]);
        InitDummyVATPaymentWithoutDateValues(MTDPayment[2]);
        exit(
            StrSubstNo(
                '{"payments":[{"received":"%1","amount":"%2"},{"amount":"%3"}]}',
                FormatValue(MTDPayment[1]."Received Date"), FormatValue(MTDPayment[1].Amount), FormatValue(MTDPayment[2].Amount)));
    end;

    local procedure CreateTwoPmtWithOnlySecondDateJsonResponse(var MTDPayment: array[2] of Record "MTD Payment"): Text
    begin
        InitDummyVATPaymentWithoutDateValues(MTDPayment[1]);
        InitDummyVATPaymentWithDateValues(MTDPayment[2]);
        exit(
            StrSubstNo(
                '{"payments":[{"amount":"%1"},{"received":"%2","amount":"%3"}]}',
                FormatValue(MTDPayment[1].Amount), FormatValue(MTDPayment[2]."Received Date"), FormatValue(MTDPayment[2].Amount)));
    end;

    local procedure MockAndGetVATPayment(var MTDPayment: Record "MTD Payment"; StartDate: Date; EndDate: Date; EntryNo: Integer; ReceivedDate: Date; NewAmount: Decimal)
    begin
        LibraryMakingTaxDigital.MockVATPayment(MTDPayment, StartDate, EndDate, EntryNo, ReceivedDate, NewAmount);
    end;

    local procedure MockVATPayment(DummyMTDPayment: Record "MTD Payment"; ReceivedDate: Date; Amount: Decimal)
    var
        MTDPayment: Record "MTD Payment";
    begin
        MockAndGetVATPayment(MTDPayment, DummyMTDPayment."Start Date", DummyMTDPayment."End Date", DummyMTDPayment."Entry No.", ReceivedDate, Amount);
    end;

    local procedure GetVATPaymentsAndShowResult(DummyMTDPayment: Record "MTD Payment"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATPayments(DummyMTDPayment, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATPayments(DummyMTDPayment: Record "MTD Payment"; ShowResult: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
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
            MTDMgt.RetrievePayments(DummyMTDPayment."Start Date", DummyMTDPayment."End Date", TotalCount, NewCount, ModifiedCount, ShowResult), 'MTDMgt.RetrievePayments');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrievePayments - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrievePayments - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrievePayments - ModifiedCount');
    end;

    local procedure GetVATPaymentsAndShowResultViaPage(DummyMTDPayment: Record "MTD Payment")
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDPayments: TestPage "MTD Payments";
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Commit();
        LibraryVariableStorage.Enqueue(DummyMTDPayment."Start Date");
        LibraryVariableStorage.Enqueue(DummyMTDPayment."End Date");
        MTDPayments.OpenEdit();
        MTDPayments."Get VAT Payments".Invoke();
        MTDPayments.Close();
    end;

    local procedure GetRetrievePaymentsMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrievePaymentsMsg, StrSubstNo(LibraryMakingTaxDigital.GetIncludingLbl(), NewCount, ModifiedCount)));
    end;

    procedure FormatValue(Value: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(Value));
    end;

    local procedure VerifyGetPaymentRequestJson(DummyMTDPayment: Record "MTD Payment")
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath :=
            StrSubstNo(
                '/organisations/vat/%1/payments?from=%2&to=%3',
                CompanyInformation."VAT Registration No.",
                FormatValue(DummyMTDPayment."Start Date"), FormatValue(DummyMTDPayment."End Date"));
        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath);
    end;

    local procedure VerifyGetPmtFailureScenario(ExpectedMessage: Text)
    var
        MTDPayment: Record "MTD Payment";
    begin
        Assert.RecordIsEmpty(MTDPayment);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(ExpectedMessage);
        VerifyLatestHttpLogFailure(ExpectedMessage);
    end;

    local procedure VerifyGetOnePmtScenario(DummyMTDPayment: Record "MTD Payment"; ExpectedMessage: Text)
    begin
        VerifyOnePayment(DummyMTDPayment);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyGetTwoPmtScenario(DummyMTDPayment: array[2] of Record "MTD Payment"; ExpectedMessage: Text)
    begin
        VerifyTwoPayments(DummyMTDPayment);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyOnePayment(DummyMTDPayment: Record "MTD Payment")
    var
        MTDPayment: Record "MTD Payment";
    begin
        Assert.RecordCount(MTDPayment, 1);
        MTDPayment.FindFirst();
        VerifySinglePaymentRecord(MTDPayment, DummyMTDPayment);
    end;

    local procedure VerifyTwoPayments(DummyMTDPayment: array[2] of Record "MTD Payment")
    var
        MTDPayment: Record "MTD Payment";
    begin
        Assert.RecordCount(MTDPayment, 2);
        MTDPayment.FindFirst();
        VerifySinglePaymentRecord(MTDPayment, DummyMTDPayment[1]);
        MTDPayment.Next();
        VerifySinglePaymentRecord(MTDPayment, DummyMTDPayment[2]);
    end;

    local procedure VerifySinglePaymentRecord(MTDPayment: Record "MTD Payment"; DummyMTDPayment: Record "MTD Payment")
    begin
        with MTDPayment do begin
            TestField("Start Date", DummyMTDPayment."Start Date");
            TestField("End Date", DummyMTDPayment."End Date");
            TestField("Entry No.", DummyMTDPayment."Entry No.");
            TestField("Received Date", DummyMTDPayment."Received Date");
            TestField(Amount, DummyMTDPayment.Amount);
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
            ExpectedResult, LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATPaymentsTxt, ExpectedActivityMessage, true);
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