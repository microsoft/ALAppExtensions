// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148083 "MTDTestLiabilitiesWebService"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Liability] [Web Service]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetLiabilitiesLbl: Label 'Get VAT Liabilities';
        RetrieveLiabilitiesErr: Label 'Not possible to retrieve VAT liabilities.';
        RetrieveLiabilitiesUpToDateMsg: Label 'Retrieve VAT liabilities are up to date.';
        RetrieveVATLiabilitiesTxt: Label 'Retrieve VAT Liabilities.', Locked = true;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_Negative_DisabledOutput()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of HTTP error response and disabled message output
        // <parse key="Packet303" compare="333333303" response="MakingTaxDigital\400_blanked.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333303');

        GetVATLiabilities(DummyMTDLiability, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyMTDLiability);
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request)');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_Negative_Reason()
    var
        DummyMTDLiability: Record "MTD Liability";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of HTTP error response with details
        // <parse key="Packet310" compare="333333310" response="MakingTaxDigital\400_vrn_invalid.txt"/>
        HttpError := 'The provided VRN is invalid.';
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333310');

        asserterror GetVATLiabilitiesAndShowResult(DummyMTDLiability, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrieveLiabilitiesErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request). The provided VRN is invalid.');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_Negative_BlankedJsonResponse()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of blanked http json response
        // <parse key="Packet301" compare="333333301" response="MakingTaxDigital\200_blanked.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333301');

        asserterror GetVATLiabilitiesAndShowResult(DummyMTDLiability, 0, 0, 0);

        VerifyGetLblFailureScenario(RetrieveLiabilitiesErr);
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_Negative_WrongJsonResponse()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of wrong http json response
        // <parse key="Packet302" compare="333333302" response="MakingTaxDigital\200_dummyjson.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333302');

        asserterror GetVATLiabilitiesAndShowResult(DummyMTDLiability, 0, 0, 0);

        VerifyGetLblFailureScenario(RetrieveLiabilitiesErr);
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneNewLbl_DisabledOutput()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] PAG 10530 "MTD Liabilities" action "Get Liabilities" in case of a one new liability
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');

        GetVATLiabilities(DummyMTDLiability, false, true, 1, 1, 0);

        VerifyOneLiability(DummyMTDLiability);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 0));
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneNewLbl_UI()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 10530 "MTD Liabilities" action "Get Liabilities" in case of a one new liability
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');

        GetVATLiabilitiesAndShowResultViaPage(DummyMTDLiability);

        VerifyGetLiabilitiesRequestJson(DummyMTDLiability);
        VerifyOneLiability(DummyMTDLiability);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 0));
        Assert.ExpectedMessage(GetLiabilitiesLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneNew_ExpiredToken()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] PAG 10530 "MTD Liabilities" action "Get Liabilities" in case of a one new liability and expired access token
        // <parse key="Packet349" compare="MockServicePacket349" response="MakingTaxDigital\200_liability.txt"/>
        // <parse key="Packet350" compare="333333350" response="MakingTaxDigital\401_unauthorized.txt"/>
        // <parse key="Packet351" compare="MockServicePacket351" response="MakingTaxDigital\200_authorize_349.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket351', '333333350');
        InitDummyVATLiability(DummyMTDLiability);

        GetVATLiabilities(DummyMTDLiability, false, true, 1, 1, 0);

        VerifyOneLiability(DummyMTDLiability);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 0));
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneUpToDateLbl()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one up to date liability
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');
        with DummyMTDLiability do
            MockVATLiability(DummyMTDLiability, "Original Amount", "Outstanding Amount", "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability, 1, 0, 0);

        VerifyGetOneLblScenario(DummyMTDLiability, RetrieveLiabilitiesUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_OrgAmt()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Original Amount")
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');
        with DummyMTDLiability do
            MockVATLiability(DummyMTDLiability, "Original Amount" + 0.01, "Outstanding Amount", "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_OutstAmt()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Outstanding Amount")
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');
        with DummyMTDLiability do
            MockVATLiability(DummyMTDLiability, "Original Amount", "Outstanding Amount" + 0.01, "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_DueDate()
    var
        DummyMTDLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Due Date")
        // <parse key="Packet336" compare="333333336" response="MakingTaxDigital\200_liability.txt"/>
        InitGetOneLiabilityScenario(DummyMTDLiability, '333333336');
        with DummyMTDLiability do
            MockVATLiability(DummyMTDLiability, "Original Amount", "Outstanding Amount", "Due Date" + 1);

        GetVATLiabilitiesAndShowResult(DummyMTDLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoNewLbl()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two new liabilities
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 2, 0);

        VerifyGetTwoLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoUpToDateLbl()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two up to date liabilities
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');
        with DummyMTDLiability[1] do
            MockVATLiability(DummyMTDLiability[1], "Original Amount", "Outstanding Amount", "Due Date");
        with DummyMTDLiability[2] do
            MockVATLiability(DummyMTDLiability[2], "Original Amount", "Outstanding Amount", "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 0, 0);

        VerifyGetTwoLblScenario(DummyMTDLiability, RetrieveLiabilitiesUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoModifiedLbl()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two modified liabilities
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');
        with DummyMTDLiability[1] do
            MockVATLiability(DummyMTDLiability[1], "Original Amount" + 0.01, "Outstanding Amount", "Due Date");
        with DummyMTDLiability[2] do
            MockVATLiability(DummyMTDLiability[2], "Original Amount", "Outstanding Amount" + 0.01, "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 0, 2);

        VerifyGetTwoLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneNew()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one new
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');
        with DummyMTDLiability[1] do
            MockVATLiability(DummyMTDLiability[1], "Original Amount", "Outstanding Amount", "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 1, 0);

        VerifyGetTwoLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneModified()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one modified
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');
        with DummyMTDLiability[1] do
            MockVATLiability(DummyMTDLiability[1], "Original Amount", "Outstanding Amount", "Due Date");
        with DummyMTDLiability[2] do
            MockVATLiability(DummyMTDLiability[2], "Original Amount", "Outstanding Amount", "Due Date" + 1);

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 0, 1);

        VerifyGetTwoLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,MTDWebClientFPHeaders_MPH')]
    [Scope('OnPrem')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneNewAndOneModified()
    var
        DummyMTDLiability: array[2] of Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one new and one modified
        // <parse key="Packet337" compare="333333337" response="MakingTaxDigital\200_liabilities.txt"/>
        InitGetTwoLiabilitiesScenario(DummyMTDLiability, '333333337');
        with DummyMTDLiability[2] do
            MockVATLiability(DummyMTDLiability[2], "Original Amount", "Outstanding Amount" + 0.01, "Due Date");

        GetVATLiabilitiesAndShowResult(DummyMTDLiability[1], 2, 1, 1);

        VerifyGetTwoLblScenario(DummyMTDLiability, LibraryMakingTaxDigital.GetRetrieveLiabilitiesMsg(1, 1));
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
        MTDLiability: Record "MTD Liability";
    begin
        MTDLiability.DeleteAll();
    end;

    local procedure InitGetOneLiabilityScenario(var MTDLiability: Record "MTD Liability"; VATRegNo: Text)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);
        InitDummyVATLiability(MTDLiability);
    end;

    local procedure InitGetTwoLiabilitiesScenario(var MTDLiability: array[2] of Record "MTD Liability"; VATRegNo: Text)
    begin
        Initialize();
        InitDummyVATLiability(MTDLiability[1]);
        MTDLiability[2] := MTDLiability[1];
        with MTDLiability[2] DO begin
            "From Date" += 1;
            "To Date" += 1;
            "Original Amount" += 0.01;
            "Outstanding Amount" += 0.01;
            "Due Date" += 1;
        end;
        LibraryMakingTaxDigital.UpdateCompanyInformation(VATRegNo);
    end;

    local procedure InitDummyVATLiability(var MTDLiability: Record "MTD Liability")
    begin
        with MTDLiability DO begin
            "From Date" := LibraryMakingTaxDigital.HttpStartDate();
            "To Date" := LibraryMakingTaxDigital.HttpEndDate();
            "Original Amount" := LibraryMakingTaxDigital.HttpAmount1();
            "Outstanding Amount" := LibraryMakingTaxDigital.HttpAmount2();
            "Due Date" := LibraryMakingTaxDigital.HttpDueDate();
        end;
    end;

    local procedure MockAndGetVATLiability(var MTDLiability: Record "MTD Liability"; StartDate: Date; EndDate: Date; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    begin
        LibraryMakingTaxDigital.MockVATLiability(
          MTDLiability, StartDate, EndDate, MTDLiability.Type::"VAT Return Debit Charge", OriginalAmount, OutstandingAmount, DueDate);
    end;

    local procedure MockVATLiability(DummyMTDLiability: Record "MTD Liability"; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    var
        MTDLiability: Record "MTD Liability";
    begin
        MockAndGetVATLiability(
          MTDLiability, DummyMTDLiability."From Date", DummyMTDLiability."To Date", OriginalAmount, OutstandingAmount, DueDate);
    end;

    local procedure GetVATLiabilitiesAndShowResult(DummyMTDLiability: Record "MTD Liability"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATLiabilities(DummyMTDLiability, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATLiabilities(DummyMTDLiability: Record "MTD Liability"; ShowResult: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    var
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        Assert.AreEqual(
          ExpectedResult,
          MTDMgt.RetrieveLiabilities(
            DummyMTDLiability."From Date", DummyMTDLiability."To Date", TotalCount, NewCount, ModifiedCount, ShowResult),
            'MTDMgt.RetrieveLiabilities');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveLiabilities - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveLiabilities - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveLiabilities - ModifiedCount');
    end;

    local procedure GetVATLiabilitiesAndShowResultViaPage(DummyMTDLiability: Record "MTD Liability")
    var
        MTDLiabilities: TestPage "MTD Liabilities";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(DummyMTDLiability."From Date");
        LibraryVariableStorage.Enqueue(DummyMTDLiability."To Date");
        MTDLiabilities.OpenEdit();
        MTDLiabilities."Get VAT Liabilities".Invoke();
        MTDLiabilities.Close();
    end;

    local procedure FormatValue(VariantValue: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(VariantValue));
    end;

    local procedure VerifyGetLiabilitiesRequestJson(DummyMTDLiability: Record "MTD Liability")
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath :=
          StrSubstNo(
            '/organisations/vat/%1/liabilities?from=%2&to=%3',
            CompanyInformation."VAT Registration No.",
            FormatValue(DummyMTDLiability."From Date"), FormatValue(DummyMTDLiability."To Date"));
        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath, false);
    end;

    local procedure VerifyGetLblFailureScenario(ExpectedMessage: Text)
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordIsEmpty(MTDLiability);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(ExpectedMessage);
        VerifyLatestHttpLogFailure(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyGetOneLblScenario(DummyMTDLiability: Record "MTD Liability"; ExpectedMessage: Text)
    begin
        VerifyOneLiability(DummyMTDLiability);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyGetTwoLblScenario(DummyMTDLiability: array[2] of Record "MTD Liability"; ExpectedMessage: Text)
    begin
        VerifyTwoLiabilities(DummyMTDLiability);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyOneLiability(DummyMTDLiability: Record "MTD Liability")
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordCount(MTDLiability, 1);
        MTDLiability.FindFirst();
        VerifySingleLiabilityRecord(MTDLiability, DummyMTDLiability);
    end;

    local procedure VerifyTwoLiabilities(DummyMTDLiability: array[2] of Record "MTD Liability")
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordCount(MTDLiability, 2);
        MTDLiability.FindSet();
        VerifySingleLiabilityRecord(MTDLiability, DummyMTDLiability[1]);
        MTDLiability.Next();
        VerifySingleLiabilityRecord(MTDLiability, DummyMTDLiability[2]);
    end;

    local procedure VerifySingleLiabilityRecord(MTDLiability: Record "MTD Liability"; DummyMTDLiability: Record "MTD Liability")
    begin
        with MTDLiability do begin
            TestField("From Date", DummyMTDLiability."From Date");
            TestField("To Date", DummyMTDLiability."To Date");
            TestField("Original Amount", DummyMTDLiability."Original Amount");
            TestField("Outstanding Amount", DummyMTDLiability."Outstanding Amount");
            TestField("Due Date", DummyMTDLiability."Due Date");
            TestField(Type, Type::"VAT Return Debit Charge");
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
          LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATLiabilitiesTxt, ExpectedActivityMessage, true);
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

    [ModalPageHandler]
    procedure MTDWebClientFPHeaders_MPH(var MTDWebClientFPHeaders: TestPage "MTD Web Client FP Headers")
    begin
    end;
}
