// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148082 "MTDTestPaymentsWebService"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Payment] [Web Service]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetPaymentsLbl: Label 'Get VAT Payments';
        RetrievePaymentsErr: Label 'Not possible to retrieve VAT payments.';
        RetrievePaymentsUpToDateMsg: Label 'Retrieve VAT payments are up to date.';
        RetrieveVATPaymentsTxt: Label 'Retrieve VAT Payments.', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_Negative_DisabledOutput()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of HTTP error response and disabled message output
        // <parse key="Packet303" compare="MockServicePacket303" response="MakingTaxDigital\400_blanked.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket303', false);

        GetVATPayments(DummyMTDPayment, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyMTDPayment);
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request)');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_Negative_Reason()
    var
        DummyMTDPayment: Record "MTD Payment";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of HTTP error response with details
        // <parse key="Packet310" compare="MockServicePacket310" response="MakingTaxDigital\400_vrn_invalid.txt"/>
        HttpError := 'The provided VRN is invalid.';
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket310', false);

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(
            StrSubstNo('%1\%2%3', RetrievePaymentsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request). The provided VRN is invalid.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_Negative_BlankedJsonResponse()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of blanked http json response
        // <parse key="Packet301" compare="MockServicePacket301" response="MakingTaxDigital\200_blanked.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket301', false);

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        VerifyGetPmtFailureScenario(RetrievePaymentsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_Negative_WrongJsonResponse()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of wrong http json response
        // <parse key="Packet302" compare="MockServicePacket302" response="MakingTaxDigital\200_dummyjson.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket302', false);

        asserterror GetVATPaymentsAndShowResult(DummyMTDPayment, 0, 0, 0);

        VerifyGetPmtFailureScenario(RetrievePaymentsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneNew_DisabledOutput()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one new payment with disabled message output
        // <parse key="Packet330" compare="MockServicePacket330" response="MakingTaxDigital\200_payment.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket330', false);

        GetVATPayments(DummyMTDPayment, false, true, 1, 1, 0);

        VerifyOnePayment(DummyMTDPayment);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneNew_ExpiredToken()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one new payment and  expired access token
        // <parse key="Packet346" compare="MockServicePacket346" response="MakingTaxDigital\200_payment.txt"/>
        // <parse key="Packet347" compare="MockServicePacket347" response="MakingTaxDigital\401_unauthorized.txt"/>
        // <parse key="Packet348" compare="MockServicePacket348" response="MakingTaxDigital\200_authorize_346.txt"/> 
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket348', 'MockServicePacket347');
        InitDummyVATPayment(DummyMTDPayment);

        GetVATPayments(DummyMTDPayment, false, true, 1, 1, 0);

        VerifyOnePayment(DummyMTDPayment);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneNewPmtWithDate_UI()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] PAG 10531 "MTD Payments" action "Get Payments" in case of a one new payment with date
        // <parse key="Packet330" compare="MockServicePacket330" response="MakingTaxDigital\200_payment.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket330', false);

        GetVATPaymentsAndShowResultViaPage(DummyMTDPayment);

        VerifyGetPaymentRequestJson(DummyMTDPayment);
        VerifyOnePayment(DummyMTDPayment);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0));
        Assert.ExpectedMessage(GetPaymentsLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneNewPmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one new payment without date
        // <parse key="Packet331" compare="MockServicePacket331" response="MakingTaxDigital\200_payment_nodate.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket331', true);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 1, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneUpToDatePmtWithDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one up to date payment with date
        // <parse key="Packet330" compare="MockServicePacket330" response="MakingTaxDigital\200_payment.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket330', false);
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneUpToDatePmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one up to date payment without date
        // <parse key="Packet331" compare="MockServicePacket331" response="MakingTaxDigital\200_payment_nodate.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket331', true);
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 0);

        VerifyGetOnePmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneModifiedPmtWithDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one modified payment with date
        // <parse key="Packet330" compare="MockServicePacket330" response="MakingTaxDigital\200_payment.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket330', false);
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date" + 1, DummyMTDPayment.Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 1);

        VerifyGetOnePmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_OneModifiedPmtWithoutDate()
    var
        DummyMTDPayment: Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a one modified payment without date
        // <parse key="Packet331" compare="MockServicePacket331" response="MakingTaxDigital\200_payment_nodate.txt"/>
        InitGetOnePaymentScenario(DummyMTDPayment, 'MockServicePacket331', true);
        MockVATPayment(DummyMTDPayment, DummyMTDPayment."Received Date", DummyMTDPayment.Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment, 1, 0, 1);

        VerifyGetOnePmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithDates()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with dates
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithoutDates()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments without dates
        // <parse key="Packet333" compare="MockServicePacket333" response="MakingTaxDigital\200_payments_nodates.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket333', true, true);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithOnlyFirstDate()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with only first date
        //<parse key="Packet334" compare="MockServicePacket334" response="MakingTaxDigital\200_payments_firstdate.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket334', false, true);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoNewPmtWithOnlySecondDate()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two new payments with only second date
        // <parse key="Packet335" compare="MockServicePacket335" response="MakingTaxDigital\200_payments_seconddate.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket335', true, false);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 2, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoUpToDatePmt()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two up to date payments with dates
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[2]."Received Date", DummyMTDPayment[2].Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, RetrievePaymentsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoModifiedPmt()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two modified payments with dates
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date" + 1, DummyMTDPayment[1].Amount + 0.01);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[2]."Received Date" - 1, DummyMTDPayment[2].Amount - 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 2);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneNew()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one new
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 1, 0);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneModified()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one modified
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);
        MockVATPayment(DummyMTDPayment[1], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[2]."Received Date" + 1, DummyMTDPayment[2].Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 0, 1);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATPaymentsAndShowResult_TwoPmtInclOneNewAndOneModified()
    var
        DummyMTDPayment: array[2] of Record "MTD Payment";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrievePayments() in case of a two payments including one new and one modified
        // <parse key="Packet332" compare="MockServicePacket332" response="MakingTaxDigital\200_payments.txt"/>
        InitGetTwoPaymentsScenario(DummyMTDPayment, 'MockServicePacket332', false, false);
        MockVATPayment(DummyMTDPayment[2], DummyMTDPayment[1]."Received Date", DummyMTDPayment[1].Amount + 0.01);

        GetVATPaymentsAndShowResult(DummyMTDPayment[1], 2, 1, 1);

        VerifyGetTwoPmtScenario(DummyMTDPayment, LibraryMakingTaxDigital.GetRetrievePaymentsMsg(1, 1));
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        ClearRecords();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.DisableFraudPreventionHeaders(true);
    end;

    local procedure ClearRecords()
    var
        MTDPayment: Record "MTD Payment";
    begin
        MTDPayment.DeleteAll();
    end;

    local procedure InitGetOnePaymentScenario(var MTDPayment: Record "MTD Payment"; VATRegNo: Text; BlankedReceivedDate: Boolean)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);
        InitDummyVATPayment(MTDPayment);
        IF BlankedReceivedDate THEN
            MTDPayment."Received Date" := 0D;
    end;

    local procedure InitGetTwoPaymentsScenario(var MTDPayment: array[2] of Record "MTD Payment"; VATRegNo: Text; BlankedReceivedDate1: Boolean; BlankedReceivedDate2: Boolean)
    begin
        Initialize();
        LibraryMakingTaxDigital.UpdateCompanyInformation(VATRegNo);
        InitTwoDummyVATPayments(MTDPayment);
        IF BlankedReceivedDate1 THEN
            MTDPayment[1]."Received Date" := 0D;
        IF BlankedReceivedDate2 THEN
            MTDPayment[2]."Received Date" := 0D;
    end;

    local procedure InitDummyVATPayment(var MTDPayment: Record "MTD Payment")
    begin
        WITH MTDPayment DO BEGIN
            "Start Date" := LibraryMakingTaxDigital.HttpStartDate();
            "End Date" := LibraryMakingTaxDigital.HttpEndDate();
            "Entry No." := 1;
            "Received Date" := LibraryMakingTaxDigital.HttpReceivedDate();
            Amount := LibraryMakingTaxDigital.HttpAmount1();
        END;
    end;

    local procedure InitTwoDummyVATPayments(var MTDPayment: array[2] of Record "MTD Payment")
    begin
        InitDummyVATPayment(MTDPayment[1]);
        MTDPayment[2] := MTDPayment[1];
        MTDPayment[2]."Entry No." += 1;
        MTDPayment[2].Amount += 0.01;
        MTDPayment[2]."Received Date" += 1;
    end;

    local procedure MockAndGetVATPayment(var MTDPayment: Record "MTD Payment"; StartDate: Date; EndDate: Date; EntryNo: Integer; ReceivedDate: Date; NewAmount: Decimal)
    begin
        LibraryMakingTaxDigital.MockVATPayment(MTDPayment, StartDate, EndDate, EntryNo, ReceivedDate, NewAmount);
    end;

    local procedure MockVATPayment(DummyMTDPayment: Record "MTD Payment"; ReceivedDate: Date; Amount: Decimal)
    var
        MTDPayment: Record "MTD Payment";
    begin
        MockAndGetVATPayment(
            MTDPayment, DummyMTDPayment."Start Date", DummyMTDPayment."End Date", DummyMTDPayment."Entry No.", ReceivedDate, Amount);
    end;

    local procedure GetVATPaymentsAndShowResult(DummyMTDPayment: Record "MTD Payment"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATPayments(DummyMTDPayment, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATPayments(DummyMTDPayment: Record "MTD Payment"; ShowResult: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    var
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        Assert.AreEqual(
            ExpectedResult,
            MTDMgt.RetrievePayments(DummyMTDPayment."Start Date", DummyMTDPayment."End Date", TotalCount, NewCount, ModifiedCount, ShowResult),
            'MTDMgt.RetrievePayments');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrievePayments - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrievePayments - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrievePayments - ModifiedCount');
    end;

    local procedure GetVATPaymentsAndShowResultViaPage(DummyMTDPayment: Record "MTD Payment")
    var
        MTDPayments: TestPage "MTD Payments";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(DummyMTDPayment."Start Date");
        LibraryVariableStorage.Enqueue(DummyMTDPayment."End Date");
        MTDPayments.OpenEdit();
        MTDPayments."Get VAT Payments".Invoke();
        MTDPayments.Close();
    end;

    local procedure FormatValue(Value: Variant): Text
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
        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath, false);
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
            ExpectedResult,
            LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATPaymentsTxt, ExpectedActivityMessage, true);
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
}
