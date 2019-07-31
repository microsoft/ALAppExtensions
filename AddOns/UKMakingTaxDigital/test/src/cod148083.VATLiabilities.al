// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148083 "UK MTD Tests - VAT Liabilities"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Liability]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetLiabilitiesLbl: Label 'Get VAT Liabilities';
        RetrieveLiabilitiesErr: Label 'Not possible to retrieve VAT liabilities.';
        RetrieveLiabilitiesMsg: Label 'Retrieve VAT liabilities successful';
        RetrieveLiabilitiesUpToDateMsg: Label 'Retrieve VAT liabilities are up to date.';
        RetrieveVATLiabilitiesTxt: Label 'Retrieve VAT Liabilities.', Locked = true;

    [Test]
    procedure MTDLiability_DiffersFromLiability()
    var
        MTDLiability: array[2] of Record "MTD Liability";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 258181] TAB 10530 MTDLiability.DiffersFromLiability()
        MockAndGetVATLiability(MTDLiability[1], WorkDate(), WorkDate(), 1, 1, WorkDate());

        MTDLiability[2] := MTDLiability[1];
        Assert.Isfalse(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2]."Original Amount" += 0.01;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2] := MTDLiability[1];
        MTDLiability[2]."Outstanding Amount" += 0.01;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');

        MTDLiability[2] := MTDLiability[1];
        MTDLiability[2]."Due Date" += 1;
        Assert.IsTrue(MTDLiability[1].DiffersFromLiability(MTDLiability[2]), '');
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_Negative_DisabledOutput()
    var
        DummyVATLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of http error response and disabled message output
        InitGetOneLiabilityScenario(DummyVATLiability, false, '', '');

        GetVATLiabilities(DummyVATLiability, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyVATLiability);
        VerifyLatestHttpLogFailure(RetrieveLiabilitiesErr);
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_Negative_NoReason()
    var
        DummyVATLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of http error response without details
        InitGetOneLiabilityScenario(DummyVATLiability, false, '', '');

        asserterror GetVATLiabilitiesAndShowResult(DummyVATLiability, 0, 0, 0);

        VerifyGetLblFailureScenario(RetrieveLiabilitiesErr);
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_Negative_Reason()
    var
        DummyVATLiability: Record "MTD Liability";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of http error response with details
        HttpError := LibraryUtility.GenerateGUID();
        InitGetOneLiabilityScenario(DummyVATLiability, false, HttpError, '');

        asserterror GetVATLiabilitiesAndShowResult(DummyVATLiability, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrieveLiabilitiesErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure(HttpError);
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_Negative_BlankedJsonResponse()
    var
        DummyVATLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of blanked http json response
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', '');

        asserterror GetVATLiabilitiesAndShowResult(DummyVATLiability, 0, 0, 0);

        VerifyGetLblFailureScenario(RetrieveLiabilitiesErr);
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_Negative_WrongJsonResponse()
    var
        DummyVATLiability: Record "MTD Liability";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of wrong http json response
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', '{"wrongliabilities":[]}');

        asserterror GetVATLiabilitiesAndShowResult(DummyVATLiability, 0, 0, 0);

        VerifyGetLblFailureScenario(RetrieveLiabilitiesErr);
    end;

    [Test]
    procedure GetVATLiabilitiesAndShowResult_OneNewLbl_DisabledOutput()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] PAG 10530 "MTD Liabilities" action "Get Liabilities" in case of a one new liability
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);

        GetVATLiabilities(DummyVATLiability, false, true, 1, 1, 0);

        VerifyOneLiability(DummyVATLiability);
        VerifyLatestHttpLogSucess(GetRetrieveLiabilitiesMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('GetMTDRecords_RPH,MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_OneNewLbl_UI()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 10530 "MTD Liabilities" action "Get Liabilities" in case of a one new liability
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);

        GetVATLiabilitiesAndShowResultViaPage(DummyVATLiability);

        VerifyGetLiabilitiesRequestJson(DummyVATLiability);
        VerifyOneLiability(DummyVATLiability);
        VerifyLatestHttpLogSucess(GetRetrieveLiabilitiesMsg(1, 0));
        Assert.ExpectedMessage(GetLiabilitiesLbl, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(GetRetrieveLiabilitiesMsg(1, 0), LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_OneUpToDateLbl()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one up to date liability
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability, DummyVATLiability."Original Amount", DummyVATLiability."Outstanding Amount", DummyVATLiability."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability, 1, 0, 0);

        VerifyGetOneLblScenario(DummyVATLiability, RetrieveLiabilitiesUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_OrgAmt()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Original Amount")
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability, DummyVATLiability."Original Amount" + 0.01, DummyVATLiability."Outstanding Amount", DummyVATLiability."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_OutstAmt()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Outstanding Amount")
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability, DummyVATLiability."Original Amount", DummyVATLiability."Outstanding Amount" + 0.01, DummyVATLiability."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_OneModifiedLbl_DueDate()
    var
        DummyVATLiability: Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a one modified liability ("Due Date")
        ResponseJson := CreateOneLblJsonResponse(DummyVATLiability);
        InitGetOneLiabilityScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability, DummyVATLiability."Original Amount", DummyVATLiability."Outstanding Amount", DummyVATLiability."Due Date" + 1);

        GetVATLiabilitiesAndShowResult(DummyVATLiability, 1, 0, 1);

        VerifyGetOneLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoNewLbl()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two new liabilities
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 2, 0);

        VerifyGetTwoLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(2, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoUpToDateLbl()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two up to date liabilities
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability[1], DummyVATLiability[1]."Original Amount", DummyVATLiability[1]."Outstanding Amount", DummyVATLiability[1]."Due Date");
        MockVATLiability(DummyVATLiability[2], DummyVATLiability[2]."Original Amount", DummyVATLiability[2]."Outstanding Amount", DummyVATLiability[2]."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 0, 0);

        VerifyGetTwoLblScenario(DummyVATLiability, RetrieveLiabilitiesUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoModifiedLbl()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two modified liabilities
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability[1], DummyVATLiability[1]."Original Amount" + 0.01, DummyVATLiability[1]."Outstanding Amount", DummyVATLiability[1]."Due Date");
        MockVATLiability(DummyVATLiability[2], DummyVATLiability[2]."Original Amount", DummyVATLiability[2]."Outstanding Amount" + 0.01, DummyVATLiability[2]."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 0, 2);

        VerifyGetTwoLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(0, 2));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneNew()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one new
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability[1], DummyVATLiability[1]."Original Amount", DummyVATLiability[1]."Outstanding Amount", DummyVATLiability[1]."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 1, 0);

        VerifyGetTwoLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneModified()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one modified
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability[1], DummyVATLiability[1]."Original Amount", DummyVATLiability[1]."Outstanding Amount", DummyVATLiability[1]."Due Date");
        MockVATLiability(DummyVATLiability[2], DummyVATLiability[2]."Original Amount", DummyVATLiability[2]."Outstanding Amount", DummyVATLiability[2]."Due Date" + 1);

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 0, 1);

        VerifyGetTwoLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATLiabilitiesAndShowResult_TwoLblInclOneNewAndOneModified()
    var
        DummyVATLiability: array[2] of Record "MTD Liability";
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveLiabilities() in case of a two liabilities including one new and one modified
        ResponseJson := CreateTwoLblJsonResponse(DummyVATLiability);
        InitGetTwoLiabilitiesScenario(DummyVATLiability, true, '', ResponseJson);
        MockVATLiability(DummyVATLiability[2], DummyVATLiability[2]."Original Amount", DummyVATLiability[2]."Outstanding Amount" + 0.01, DummyVATLiability[2]."Due Date");

        GetVATLiabilitiesAndShowResult(DummyVATLiability[1], 2, 1, 1);

        VerifyGetTwoLblScenario(DummyVATLiability, GetRetrieveLiabilitiesMsg(1, 1));
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
        MTDLiability: Record "MTD Liability";
    begin
        NameValueBuffer.DeleteAll();
        MTDLiability.DeleteAll();
    end;

    local procedure InitGetOneLiabilityScenario(var VATLiability: Record "MTD Liability"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATLiability(VATLiability);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitGetTwoLiabilitiesScenario(var VATLiability: array[2] of Record "MTD Liability"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATLiability(VATLiability[1]);
        InitDummyVATLiability(VATLiability[2]);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitDummyVATLiability(var VATLiability: Record "MTD Liability")
    begin
        with VATLiability do begin
            if "From Date" = 0D then
                "From Date" := LibraryRandom.RandDate(10);
            if "To Date" = 0D then
                "To Date" := LibraryRandom.RandDateFrom("From Date", 10);
        end;
    end;

    local procedure InitDummyVATLiabilityValues(var VATLiability: Record "MTD Liability")
    begin
        InitDummyVATLiability(VATLiability);
        with VATLiability do begin
            "Original Amount" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Outstanding Amount" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Due Date" := LibraryRandom.RandDate(10);
        end;
    end;

    local procedure CreateOneLblJsonResponse(var MTDLiability: Record "MTD Liability"): Text
    begin
        InitDummyVATLiabilityValues(MTDLiability);
        exit('{"liabilities":[' + CreateLblJsonDetails(MTDLiability) + ']}');
    end;

    local procedure CreateTwoLblJsonResponse(var MTDLiability: array[2] of Record "MTD Liability"): Text
    begin
        InitDummyVATLiabilityValues(MTDLiability[1]);
        InitDummyVATLiabilityValues(MTDLiability[2]);
        exit('{"liabilities":[' + CreateLblJsonDetails(MTDLiability[1]) + ',' + CreateLblJsonDetails(MTDLiability[2]) + ']}');
    end;

    local procedure CreateLblJsonDetails(var VATLiability: Record "MTD Liability"): Text
    begin
        with VATLiability do
            exit(
                StrSubstNo(
                    '{"taxPeriod":{"from":"%1","to":"%2"},"type":"VAT Return Debit Charge","originalAmount":"%3","outstandingAmount":"%4","due":"%5"}',
                    FormatValue("From Date"), FormatValue("To Date"),
                    FormatValue("Original Amount"), FormatValue("Outstanding Amount"), FormatValue("Due Date")));
    end;

    local procedure MockAndGetVATLiability(var VATLiability: Record "MTD Liability"; StartDate: Date; EndDate: Date; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    begin
        LibraryMakingTaxDigital.MockVATLiability(VATLiability, StartDate, EndDate, VATLiability.Type::"VAT Return Debit Charge", OriginalAmount, OutstandingAmount, DueDate);
    end;

    local procedure MockVATLiability(DummyVATLiability: Record "MTD Liability"; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    var
        VATLiability: Record "MTD Liability";
    begin
        MockAndGetVATLiability(VATLiability, DummyVATLiability."From Date", DummyVATLiability."To Date", OriginalAmount, OutstandingAmount, DueDate);
    end;

    local procedure GetVATLiabilitiesAndShowResult(DummyVATLiability: Record "MTD Liability"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATLiabilities(DummyVATLiability, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATLiabilities(DummyVATLiability: Record "MTD Liability"; ShowMessage: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
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
            MTDMgt.RetrieveLiabilities(DummyVATLiability."From Date", DummyVATLiability."To Date", TotalCount, NewCount, ModifiedCount, ShowMessage), 'MTDMgt.RetrieveLiabilities');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveLiabilities - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveLiabilities - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveLiabilities - ModifiedCount');
    end;

    local procedure GetVATLiabilitiesAndShowResultViaPage(DummyVATLiability: Record "MTD Liability")
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDLiabilities: TestPage "MTD Liabilities";
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Commit();
        LibraryVariableStorage.Enqueue(DummyVATLiability."From Date");
        LibraryVariableStorage.Enqueue(DummyVATLiability."To Date");
        MTDLiabilities.OpenEdit();
        MTDLiabilities."Get VAT Liabilities".Invoke();
        MTDLiabilities.Close();
    end;

    local procedure GetRetrieveLiabilitiesMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrieveLiabilitiesMsg, StrSubstNo(LibraryMakingTaxDigital.GetIncludingLbl(), NewCount, ModifiedCount)));
    end;

    procedure FormatValue(Value: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(Value));
    end;

    local procedure VerifyGetLiabilitiesRequestJson(DummyVATLiability: Record "MTD Liability")
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath :=
            StrSubstNo(
                '/organisations/vat/%1/liabilities?from=%2&to=%3',
                CompanyInformation."VAT Registration No.",
                FormatValue(DummyVATLiability."From Date"), FormatValue(DummyVATLiability."To Date"));

        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath);
    end;

    local procedure VerifyGetLblFailureScenario(ExpectedMessage: Text)
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordIsEmpty(MTDLiability);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(ExpectedMessage);
        VerifyLatestHttpLogFailure(ExpectedMessage);
    end;

    local procedure VerifyGetOneLblScenario(DummyVATLiability: Record "MTD Liability"; ExpectedMessage: Text)
    begin
        VerifyOneLiability(DummyVATLiability);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyGetTwoLblScenario(DummyVATLiability: array[2] of Record "MTD Liability"; ExpectedMessage: Text)
    begin
        VerifyTwoLiabilities(DummyVATLiability);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyOneLiability(DummyVATLiability: Record "MTD Liability")
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordCount(MTDLiability, 1);
        MTDLiability.FindFirst();
        VerifySingleLiabilityRecord(MTDLiability, DummyVATLiability);
    end;

    local procedure VerifyTwoLiabilities(DummyVATLiability: array[2] of Record "MTD Liability")
    var
        MTDLiability: Record "MTD Liability";
    begin
        Assert.RecordCount(MTDLiability, 2);
        MTDLiability.FindFirst();
        VerifySingleLiabilityRecord(MTDLiability, DummyVATLiability[1]);
        MTDLiability.Next();
        VerifySingleLiabilityRecord(MTDLiability, DummyVATLiability[2]);
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
            ExpectedResult, LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATLiabilitiesTxt, ExpectedActivityMessage, true);
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