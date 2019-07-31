// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148085 "UK MTD Tests - VAT Returns"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Return]
    end;

    var
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        RetrieveReturnsMsg: Label 'Retrieve submitted VAT returns successful';
        RetrieveReturnsErr: Label 'Not possible to retrieve submitted VAT returns.';
        RetrieveVATReturnTxt: Label 'Retrieve VAT Return.', Locked = true;
        RetrieveReturnsUpToDateMsg: Label 'Retrieve submitted VAT returns are up to date.';
        NoSubmittedReturnsMsg: Label 'The remote endpoint has indicated that there is no submitted VAT returns for the specified period.';
        SubmitReturnErr: Label 'Not possible to submit VAT return.';
        SubmitVATReturnTxt: Label 'Submit VAT Return.', Locked = true;
        ConfirmSubmitQst: Label 'When you submit this VAT information you are making a legal declaration that the information is true and complete. A false declaration can result in prosecution. Do you want to continue?';
        WrongVATSatementSetupErr: Label 'VAT statement template %1 name %2 has a wrong setup. There must be nine rows, each with a value between 1 and 9 for the Box No. field.';
        PeriodLinkErr: Label 'There is no return period linked to this VAT return.\\Use the Create From VAT Return Period action on the VAT Returns page or the Create VAT Return action on the VAT Return Periods page.';

    [Test]
    procedure MTDReturnDetails_DiffersFromReturn()
    var
        MTDReturnDetails: array[2] of Record "MTD Return Details";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 258181] TAB 10532 MTDReturnDetails.DiffersFromLiability()
        MockAndGetVATReturnDetail(MTDReturnDetails[1], WorkDate(), WorkDate(), 'a', 1, 2, 3, 4, 5, 6, 7, 8, 9, false);

        MTDReturnDetails[2] := MTDReturnDetails[1];
        Assert.Isfalse(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2]."Period Key" := 'b';
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."VAT Due Sales" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."VAT Due Acquisitions" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Total VAT Due" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."VAT Reclaimed Curr Period" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Net VAT Due" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Total Value Sales Excl. VAT" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Total Value Purchases Excl.VAT" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Total Value Goods Suppl. ExVAT" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2]."Total Acquisitions Excl. VAT" += 0.01;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

        MTDReturnDetails[2] := MTDReturnDetails[1];
        MTDReturnDetails[2].Finalised := not MTDReturnDetails[2].Finalised;
        Assert.IsTrue(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');
    end;

    [Test]
    procedure GetVATReturns_Negative_DisabledOutput()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of http error response and disabled message output
        InitGetReturnScenario(DummyMTDReturnDetails, false, '', '');

        GetVATReturn(DummyMTDReturnDetails, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyMTDReturnDetails);
        VerifyLatestHttpLogFailure(RetrieveReturnsErr);
    end;

    [Test]
    procedure GetVATReturns_Negative_NoReason()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of http error response without details
        InitGetReturnScenario(DummyMTDReturnDetails, false, '', '');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        VerifyGetReturnFailureScenario(RetrieveReturnsErr);
    end;

    [Test]
    procedure GetVATReturns_Negative_Reason()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of http error response with details
        HttpError := LibraryUtility.GenerateGUID();
        InitGetReturnScenario(DummyMTDReturnDetails, false, HttpError, '');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrieveReturnsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure(HttpError);
    end;

    [Test]
    procedure GetVATReturns_Negative_BlankedJsonResponse()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of blanked http json response
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', '');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        VerifyGetReturnFailureScenario(RetrieveReturnsErr);
    end;

    [Test]
    procedure GetVATReturns_Negative_WrongJsonResponse()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of wrong http json response
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', 'wrongjson');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        VerifyGetReturnFailureScenario(RetrieveReturnsErr);
    end;

    [Test]
    procedure GetVATReturns_New_DisabledOutput()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a new return and disabled message output
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));

        GetVATReturn(DummyMTDReturnDetails, false, true, 1, 1, 0);

        VerifyReturn(DummyMTDReturnDetails);
        VerifyLatestHttpLogSucess(GetRetrieveReturnMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_New_UI()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 738 "VAT Return Period Card" action "Receive Submitted VAT Returns" in case of a new return
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));

        GetVATReturnAndShowResultViaPage(DummyMTDReturnDetails);

        VerifyGetReturnRequestJson(DummyMTDReturnDetails);
        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_UpToDate()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of up to date return
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 0);

        VerifyGetReturnScenario(DummyMTDReturnDetails, RetrieveReturnsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_PeriodKey()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Period Key")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, LibraryUtility.GenerateGUID(), "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_VATDueSales()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Due Sales")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales" + 0.01, "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_VATDueAcquisitions()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Due Acquisitions")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions" + 0.01, "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_TotalVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total VAT Due")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due" + 0.01, "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_VATReclaimedCurrPeriod()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Reclaimed Curr Period")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period" + 0.01, "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_NetVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Net VAT Due")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due" + 0.01,
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_TotalValueSalesExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Sales Excl. VAT")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT" + 0.01, "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_TotalValuePurchasesExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Purchases Excl.VAT")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT" + 0.01, "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_TotalValueGoodsSupplExVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Goods Suppl. ExVAT")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT" + 0.01, "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Modified_TotalAcquisitionsExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Acquisitions Excl. VAT")
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period", "Net VAT Due",
                "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT" + 0.01, true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure GetVATReturns_Error404NotFound()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of error 404 "NOT FOUND"
        Initialize();
        InitDummyVATReturn(DummyMTDReturnDetails);
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', '{"code":"404"}');

        GetVATReturn(DummyMTDReturnDetails, true, false, 0, 0, 0);

        Assert.ExpectedMessage(NoSubmittedReturnsMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogFailure(NoSubmittedReturnsMsg);
    end;

    [Test]
    procedure SubmitVATReturns_Negative_NoReason()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of http error response without details
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', '');

        asserterror SubmitVATReturn(RequestJson, ResponseJson, false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(SubmitReturnErr);
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          false, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, SubmitReturnErr, true);
        Assert.AreEqual('', ResponseJson, 'ResponseJson');
    end;

    [Test]
    procedure SubmitVATReturns_Negative_Reason()
    var
        RequestJson: Text;
        ResponseJson: Text;
        HttpError: text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of http error response with details
        Initialize();
        HttpError := LibraryUtility.GenerateGUID();
        LibraryMakingTaxDigital.PrepareCustomResponse(false, HttpError, '', '');

        asserterror SubmitVATReturn(RequestJson, ResponseJson, false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', SubmitReturnErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          false, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, HttpError, true);
        Assert.AreEqual('', ResponseJson, 'ResponseJson');
    end;

    [Test]
    procedure SubmitVATReturns_Positive_BlankedJsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of blanked json response
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '', '');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        Assert.AreEqual('', ResponseJson, 'ResponseJson');
    end;

    [Test]
    procedure SubmitVATReturns_Positive_WrongJsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
        OriginalResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of a wrong json response
        Initialize();
        OriginalResponseJson := 'WrongJson';
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', OriginalResponseJson, '');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        Assert.AreEqual('', ResponseJson, 'ResponseJson');
    end;

    [Test]
    procedure SubmitVATReturns_Positive_JsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
        OriginalResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of json response
        Initialize();
        OriginalResponseJson := '{"A":"B"}';
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', OriginalResponseJson, '');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        VerifySubmitReturnRequestJson();
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        Assert.ExpectedMessage('"A": "B"', ResponseJson);
    end;

    [Test]
    procedure SubmitVATReturns_Timeout()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 312780] COD 10530 MTDMgt.SubmitVATReturn() in case of http timeout error (408)
        Initialize();
        LibraryMakingTaxDigital.PrepareCustomResponse(false, 'timeout', '', '{"code":"408"}');
        LibraryMakingTaxDigital.PrepareResponseOnRequestAccessToken(true, '');
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '{"A":"B"}', '');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        VerifySubmitReturnRequestJson();
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
          true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        Assert.ExpectedMessage('"A": "B"', ResponseJson);
    end;

    [Test]
    procedure VATReturnCard_DetailsSubpageRounding()
    var
        VATReturnPeriod: Record "VAT Return Period";
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriodCard: TestPage "VAT Return Period Card";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] Rounding of "total" fields on Subpage 10532 "MTD Return Details" of PAG 738 "VAT Return Period Card"
        Initialize();
        InitDummyVATReturn(DummyMTDReturnDetails);
        with DummyMTDReturnDetails do
            MockVATReturnDetail(DummyMTDReturnDetails, 'A', 1.11, 2.22, 3.33, 4.44, 5.55, 6.66, 7.77, 8.88, 9.99, true);
        MockAndGetVATPeriod(VATReturnPeriod, DummyMTDReturnDetails);

        VATReturnPeriodCard.OpenEdit();
        VATReturnPeriodCard.Filter.SetFilter("Start Date", Format(VATReturnPeriod."Start Date"));
        VATReturnPeriodCard.Filter.SetFilter("End Date", Format(VATReturnPeriod."End Date"));
        with VATReturnPeriodCard.pageSubmittedVATReturns do begin
            Assert.IsFalse(Editable(), '');
            "VAT Due Sales".AssertEquals(Format(1.11));
            "VAT Due Sales".AssertEquals(Format(1.11));
            "VAT Due Acquisitions".AssertEquals(Format(2.22));
            "Total VAT Due".AssertEquals(Format(3.33));
            "VAT Reclaimed Curr Period".AssertEquals(Format(4.44));
            "Net VAT Due".AssertEquals(Format(5.55));
            "Total Value Sales Excl. VAT".AssertEquals(Format(7));
            "Total Value Purchases Excl.VAT".AssertEquals(Format(8));
            "Total Value Goods Suppl. ExVAT".AssertEquals(Format(9));
            "Total Acquisitions Excl. VAT".AssertEquals(Format(10));
        end;
        VATReturnPeriodCard.Close();
    end;

    [Test]
    procedure MarkSubmittedVATReturnAsAccepted()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() updates linked VATReturn.Status from "Submitted" to "Accepted"
        InitGetReturnScenario(DummyMTDReturnDetails, true, '', CreateReturnJsonResponse(DummyMTDReturnDetails));
        MockAndGetVATPeriod(VATReturnPeriod, DummyMTDReturnDetails);
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportHeader.Status::Submitted);

        GetVATReturnForGivenPeriod(VATReturnPeriod);

        VATReportHeader.Find();
        VATReportHeader.TestField(Status, VATReportHeader.Status::Accepted);
    end;

    [Test]
    procedure VATReturn_Release_UI()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        VATReturnPage: TestPage "VAT Report";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] Release VAT Return
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Open);
        VATReturnPage.Trap();
        Page.Run(Page::"VAT Report", VATReportHeader);

        VATReturnPage.Status.AssertEquals(VATReportHeader.Status::Open);
        Assert.IsFalse(VATReturnPage.Submit.Enabled(), 'Submit.Enabled');

        VATReturnPage.Release.Invoke();

        VATReturnPage.Status.AssertEquals(VATReportHeader.Status::Released);
        Assert.IsTrue(VATReturnPage.Submit.Enabled(), 'Submit.Enabled');

        VATReturnPage.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Restrictive)]
    procedure VATReturn_CreateReturnContent()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        JsonString: text;
    begin
        // [SCENARIO 258181] COD 10531 "MTD Create Return Content"
        // [SCENARIO 306708] COD 10531 "MTD Create Return Content" in case of indirect permissions on VAT Report Archive
        LibraryLowerPermissions.SetOutsideO365Scope();
        Initialize();
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        MockSubmissionMessage(VATReportHeader, 'dummy'); // check it will be overwritten

        LibraryLowerPermissions.SetO365BusFull();
        Codeunit.Run(Codeunit::"MTD Create Return Content", VATReportHeader);

        JsonString := LibraryMakingTaxDigital.GetVATReportSubmissionText(VATReportHeader);
        LibraryMakingTaxDigital.ParseVATReturnDetailsJson(DummyMTDReturnDetails, JsonString);
        with DummyMTDReturnDetails do begin
            Assert.AreEqual(VATReturnPeriod."Period Key", "Period Key", '');
            Assert.AreEqual(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '1'), "VAT Due Sales", 'VAT Due Sales');
            Assert.AreEqual(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '2'), "VAT Due Acquisitions", 'VAT Due Acquisitions');
            Assert.AreEqual(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '3'), "Total VAT Due", 'Total VAT Due');
            Assert.AreEqual(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '4'), "VAT Reclaimed Curr Period", 'VAT Reclaimed Curr Period');
            Assert.AreEqual(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '5'), "Net VAT Due", 'Net VAT Due');
            Assert.AreEqual(Round(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '6'), 1), "Total Value Sales Excl. VAT", 'Total Value Sales Excl. VAT');
            Assert.AreEqual(Round(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '7'), 1), "Total Value Purchases Excl.VAT", 'Total Value Purchases Excl.VAT');
            Assert.AreEqual(Round(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '8'), 1), "Total Value Goods Suppl. ExVAT", 'Total Value Goods Suppl. ExVAT');
            Assert.AreEqual(Round(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '9'), 1), "Total Acquisitions Excl. VAT", 'Total Acquisitions Excl. VAT');
        end;
    end;

    [Test]
    procedure VATReturn_CreateReturnContent_NegativeNetVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        JsonString: text;
    begin
        // [SCENARIO 302621] COD 10531 "MTD Create Return Content" in case of negative Box 5 "Net VAT Due" value
        Initialize();

        // [GIVEN] VAT Return with suggested lines with Box No 5 Amount = -100
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        LibraryMakingTaxDigital.FindVATStatementReportLine(VATStatementReportLine, VATReportHeader, '5');
        VATStatementReportLine.Validate(Amount, -LibraryRandom.RandDecInRange(1000, 2000, 2));
        VATStatementReportLine.Modify(false); // ignore vat report header checks


        // [WHEN] Submit VAT Return
        Codeunit.Run(Codeunit::"MTD Create Return Content", VATReportHeader);

        // [THEN] Submission Json request content has a positive amount for Net VAT Due: "Net VAT Due" = 100
        JsonString := LibraryMakingTaxDigital.GetVATReportSubmissionText(VATReportHeader);
        LibraryMakingTaxDigital.ParseVATReturnDetailsJson(DummyMTDReturnDetails, JsonString);
        Assert.AreEqual(
            Abs(LibraryMakingTaxDigital.GetVATStatementReportLineAmount(VATReportHeader, '5')),
            DummyMTDReturnDetails."Net VAT Due", 'Net VAT Due');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VATReturn_SubmitReturnContent_DenyConfirm()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of deny confirm message
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);

        asserterror SubmitVATReturnScenario(VATReportHeader, false);

        VATReportHeader.Find();
        Assert.AreEqual(VATReportHeader.Status::Released, VATReportHeader.Status, 'VATReportHeader.Status');
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError('');
        Assert.ExpectedMessage(ConfirmSubmitQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Restrictive)]
    procedure VATReturn_SubmitReturnContent_Accepted()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of accepted return
        // [SCENARIO 306708] COD 10532 "MTD Submit Return" in case of indirect permissions on VAT Report Archive
        LibraryLowerPermissions.SetOutsideO365Scope();
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '{"A":"B"}', ''); // response on submit
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', CreateReturnJsonResponseWithPeriodKey(DummyMTDReturnDetails, VATReturnPeriod."Period Key"), ''); // response on retrieve

        LibraryLowerPermissions.SetO365BusFull();
        SubmitVATReturnScenario(VATReportHeader, true);

        VerifyVATReportStatus(VATReportHeader, VATReportHeader.Status::Accepted);
        VerifySubmitReturnRequestJson();
        VerifyGetReturnRequestJson(DummyMTDReturnDetails);
        VerifyArchiveSubmissionMessage(VATReportHeader);
        VerifyArchiveResponseMessage(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VATReturn_SubmitReturnContent_SubmittedNotAccepted()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        DummyGUID: Guid;
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of submitted return, but not accepted
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '{"A":"B"}', ''); // response on submit
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', ''); // response on retrieve

        SubmitVATReturnScenario(VATReportHeader, true);

        VerifyVATReportStatus(VATReportHeader, VATReportHeader.Status::Submitted);
        VerifyArchiveSubmissionMessage(VATReportHeader);
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsFalse(VATReportArchive."Response Message BLOB".HasValue(), 'VATReportArchive."Response Message BLOB".HasValue');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VATReturn_SubmitReturnContent_SubmittedAndAcceptedLater()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of submitted return and accepted later
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', '{"A":"B"}', ''); // submit positive
        LibraryMakingTaxDigital.PrepareCustomResponse(false, '', '', ''); // retrieve negative
        LibraryMakingTaxDigital.PrepareCustomResponse(true, '', CreateReturnJsonResponseWithPeriodKey(DummyMTDReturnDetails, VATReturnPeriod."Period Key"), ''); // retrieve positive

        SubmitAndGetVATReturnScenario(VATReportHeader);

        VerifyVATReportStatus(VATReportHeader, VATReportHeader.Status::Accepted);
        VerifyArchiveResponseMessage(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    procedure VATReturn_SuggestLines_CheckBoxNo_Negative_Less()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [FEATURE] [Suggest Lines]
        // [SCENARIO 312780] REP 742 "VAT Report Request Page" checks VAT Statement setup for "Box No." consistency
        // [SCENARIO 312780] in case of less than 9 "Box No." count
        Initialize();
        MockVATReportWithStatementSetup(VATReportHeader);

        VATStatementLine.GET(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", '10000');
        VATStatementLine.Delete();

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    procedure VATReturn_SuggestLines_CheckBoxNo_Negative_More()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementName: Record "VAT Statement Name";
    begin
        // [FEATURE] [Suggest Lines]
        // [SCENARIO 312780] REP 742 "VAT Report Request Page" checks VAT Statement setup for "Box No." consistency
        // [SCENARIO 312780] in case of more than 9 "Box No." count
        Initialize();
        MockVATReportWithStatementSetup(VATReportHeader);

        VATStatementName.GET(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name");
        MockVATStatementLine(VATStatementName, '10');

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    procedure VATReturn_SuggestLines_CheckBoxNo_Negative_Duplicate()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementLine: Record "VAT Statement Line";
    begin
        // [FEATURE] [Suggest Lines]
        // [SCENARIO 312780] REP 742 "VAT Report Request Page" checks VAT Statement setup for "Box No." consistency
        // [SCENARIO 312780] in case of duplicated "Box No."
        Initialize();
        MockVATReportWithStatementSetup(VATReportHeader);

        VATStatementLine.GET(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", '10000');
        VATStatementLine."Box No." := '2';
        VATStatementLine.Modify();

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    procedure VATReturn_SuggestLines_CheckBoxNo_Negative_NonNumeric()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [FEATURE] [Suggest Lines]
        // [SCENARIO 312780] REP 742 "VAT Report Request Page" checks VAT Statement setup for "Box No." consistency
        // [SCENARIO 312780] in case of non-numeric "Box No." value
        Initialize();
        MockVATReportWithStatementSetup(VATReportHeader);

        ModifyVATStatementLine(VATReportHeader, 10000, 'box1');

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    procedure VATReturn_SuggestLines_CheckBoxNo_Positive_NumericFormat()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        i: Integer;
    begin
        // [FEATURE] [Suggest Lines]
        // [SCENARIO 312780] REP 742 "VAT Report Request Page" checks VAT Statement setup for "Box No." consistency
        // [SCENARIO 312780] in case of "Box No." values in a different numeric format
        Initialize();
        MockVATReportWithStatementSetup(VATReportHeader);

        ModifyVATStatementLine(VATReportHeader, 10000, '1 ');
        ModifyVATStatementLine(VATReportHeader, 20000, ' 2');
        ModifyVATStatementLine(VATReportHeader, 30000, ' 3 ');
        ModifyVATStatementLine(VATReportHeader, 40000, '04');
        ModifyVATStatementLine(VATReportHeader, 50000, '005');

        Commit();
        Report.RunModal(Report::"VAT Report Request Page", true, false, VATReportHeader);

        VATStatementReportLine.FindSet();
        for i := 1 to 9 do begin
            VATStatementReportLine.TESTFIELD("Box No.", Format(i));
            VATStatementReportLine.Next();
        end;
    end;

    [Test]
    procedure BlockSubmitForWrongPeriodLink()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReturnPeriod: Record "VAT Return Period";
        MTDCreateReturnContent: Codeunit "MTD Create Return Content";
        MTDSubmitReturn: Codeunit "MTD Submit Return";
        VATReport: TestPage "VAT Report";
    begin
        // [SCENARIO 309370] Error is shown on Submit VAT Return in case of blanked or wrong Return Period link
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        VATReportHeader."Return Period No." := LibraryUtility.GenerateGUID();
        VATReportHeader.Modify();

        // UI PAG 740 "VAT Report"
        VATReport.OpenEdit();
        VATReport.GoToRecord(VATReportHeader);
        asserterror VATReport.Submit.Invoke();
        VATReport.Close();
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(PeriodLinkErr);

        // UT COD 10531 "MTD Create Return Content"
        asserterror MTDCreateReturnContent.Run(VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(PeriodLinkErr);

        // UT COD 10532 "MTD Submit Return"
        asserterror MTDSubmitReturn.Run(VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(PeriodLinkErr);
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
        VATReportHeader: Record "VAT Report Header";
        VATReturnPeriod: Record "VAT Return Period";
        MTDReturnDetails: Record "MTD Return Details";
    begin
        NameValueBuffer.DeleteAll();
        VATReportHeader.DeleteAll();
        VATReturnPeriod.DeleteAll();
        MTDReturnDetails.DeleteAll();
    end;

    local procedure InitSubmitReturnScenario(var VATReturnPeriod: Record "VAT Return Period"; var VATReportHeader: Record "VAT Report Header"; VATReportStatus: Option)
    begin
        Initialize();
        LibraryMakingTaxDigital.MockVATReturnPeriod(
            VATReturnPeriod, WorkDate(), WorkDate(), WorkDate(), LibraryUtility.GenerateGUID(), VATReturnPeriod.Status::Open, WorkDate());
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportStatus);
        LibraryMakingTaxDigital.MockVATStatementReportLinesWithRandomValues(VATReportHeader);
        Codeunit.Run(Codeunit::"MTD Create Return Content", VATReportHeader);
    end;

    local procedure InitGetReturnScenario(var DummyMTDReturnDetails: Record "MTD Return Details"; HttpResult: Boolean; HttpError: Text; ResponseJsonString: Text)
    begin
        Initialize();
        InitDummyVATReturn(DummyMTDReturnDetails);
        LibraryMakingTaxDigital.PrepareCustomResponse(HttpResult, HttpError, ResponseJsonString, '');
    end;

    local procedure InitDummyVATReturn(var DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        with DummyMTDReturnDetails do begin
            "Start Date" := LibraryRandom.RandDate(10);
            "End Date" := LibraryRandom.RandDateFrom("Start Date", 10);
        end;
    end;

    local procedure InitDummyVATReturnValues(var DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        InitDummyVATReturn(DummyMTDReturnDetails);
        with DummyMTDReturnDetails do begin
            "Period Key" := LibraryUtility.GenerateGUID();
            "VAT Due Sales" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "VAT Due Acquisitions" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Total VAT Due" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "VAT Reclaimed Curr Period" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Net VAT Due" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Total Value Sales Excl. VAT" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Total Value Purchases Excl.VAT" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Total Value Goods Suppl. ExVAT" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            "Total Acquisitions Excl. VAT" := LibraryRandom.RandDecInRange(10000, 20000, 2);
            Finalised := true;
        end;
    end;

    local procedure CreateReturnJsonResponse(var DummyMTDReturnDetails: Record "MTD Return Details"): Text
    begin
        exit(CreateReturnJsonResponseWithPeriodKey(DummyMTDReturnDetails, LibraryUtility.GenerateGUID()));
    end;

    local procedure CreateReturnJsonResponseWithPeriodKey(var DummyMTDReturnDetails: Record "MTD Return Details"; PeriodKey: Code[10]): Text
    begin
        InitDummyVATReturnValues(DummyMTDReturnDetails);
        DummyMTDReturnDetails."Period Key" := PeriodKey;
        with DummyMTDReturnDetails do
            exit(
                StrSubstNo(
                    '{"periodKey":"%1","vatDueSales":"%2","vatDueAcquisitions":"%3","totalVatDue":"%4","vatReclaimedCurrPeriod":"%5",' +
                    '"netVatDue":"%6","totalValueSalesExVAT":"%7","totalValuePurchasesExVAT":"%8","totalValueGoodsSuppliedExVAT":"%9","totalAcquisitionsExVAT":"%10",}',
                    FormatValue("Period Key"), FormatValue("VAT Due Sales"), FormatValue("VAT Due Acquisitions"), FormatValue("Total VAT Due"),
                    FormatValue("VAT Reclaimed Curr Period"), FormatValue("Net VAT Due"), FormatValue("Total Value Sales Excl. VAT"),
                    FormatValue("Total Value Purchases Excl.VAT"), FormatValue("Total Value Goods Suppl. ExVAT"), FormatValue("Total Acquisitions Excl. VAT")));
    end;

    local procedure MockAndGetVATReturnDetail(var MTDReturnDetails: Record "MTD Return Details"; StartDate: Date; EndDate: Date; PeriodKey: Code[10]; VATDueSales: Decimal; VATDueAcquisitions: Decimal; TotalVATDue: Decimal; VATReclaimedCurrPeriod: Decimal; NetVATDue: Decimal; TotalValueSalesExclVAT: Decimal; TotalValuePurchasesExclVAT: Decimal; TotalValueGoodsSupplExVAT: Decimal; TotalAcquisitionsExclVAT: Decimal; NewFinalised: Boolean)
    begin
        LibraryMakingTaxDigital.MockVATReturnDetail(
            MTDReturnDetails, StartDate, EndDate, PeriodKey,
            VATDueSales, VATDueAcquisitions, TotalVATDue, VATReclaimedCurrPeriod, NetVATDue, TotalValueSalesExclVAT,
            TotalValuePurchasesExclVAT, TotalValueGoodsSupplExVAT, TotalAcquisitionsExclVAT, NewFinalised);
    end;

    local procedure MockVATReturnDetail(DummyMTDReturnDetails: Record "MTD Return Details"; PeriodKey: Code[10]; VATDueSales: Decimal; VATDueAcquisitions: Decimal; TotalVATDue: Decimal; VATReclaimedCurrPeriod: Decimal; NetVATDue: Decimal; TotalValueSalesExclVAT: Decimal; TotalValuePurchasesExclVAT: Decimal; TotalValueGoodsSupplExVAT: Decimal; TotalAcquisitionsExclVAT: Decimal; NewFinalised: Boolean)
    var
        MTDReturnDetails: Record "MTD Return Details";
    begin
        MockAndGetVATReturnDetail(
            MTDReturnDetails, DummyMTDReturnDetails."Start Date", DummyMTDReturnDetails."End Date", PeriodKey,
            VATDueSales, VATDueAcquisitions, TotalVATDue, VATReclaimedCurrPeriod, NetVATDue, TotalValueSalesExclVAT,
            TotalValuePurchasesExclVAT, TotalValueGoodsSupplExVAT, TotalAcquisitionsExclVAT, NewFinalised);
    end;

    local procedure MockAndGetVATPeriod(var VATReturnPeriod: Record "VAT Return Period"; DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        LibraryMakingTaxDigital.MockVATReturnPeriod(
            VATReturnPeriod, DummyMTDReturnDetails."Start Date", DummyMTDReturnDetails."End Date",
            WorkDate(), DummyMTDReturnDetails."Period Key", VATReturnPeriod.Status::Open, WorkDate());
    end;

    local procedure MockSubmissionMessage(VATReportHeader: Record "VAT Report Header"; MessageText: Text)
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        DummyGUID: Guid;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Outstream.Write(MessageText);
        VATReportArchive.ArchiveSubmissionMessage(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", TempBlob, DummyGUID);
    end;

    local procedure MockVATReportWithStatementSetup(var VATReportHeader: Record "VAT Report Header")
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementReportLine: Record "VAT Statement Report Line";
        i: Integer;
    begin
        VATStatementLine.DeleteAll();
        VATStatementReportLine.DeleteAll();
        LibraryERM.CreateVATStatementNameWithTemplate(VATStatementName);
        for i := 1 to 9 do
            MockVATStatementLine(VATStatementName, Format(i));
        VATReportHeader.Init();
        VATReportHeader."Statement Template Name" := VATStatementName."Statement Template Name";
        VATReportHeader."Statement Name" := VATStatementName.Name;
        VATReportHeader.Insert();
    end;

    local procedure MockVATStatementLine(VATStatementName: Record "VAT Statement Name"; BoxNo: Text[30])
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Box No." := BoxNo;
        VATStatementLine.Modify();
    end;

    local procedure ModifyVATStatementLine(VATReportHeader: Record "VAT Report Header"; LineNo: Integer; NewBoxNoValue: Text[30])
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        VATStatementLine.GET(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", LineNo);
        VATStatementLine."Box No." := NewBoxNoValue;
        VATStatementLine.Modify();
    end;

    local procedure GetVATReturnAndShowResultViaPage(DummyMTDReturnDetails: Record "MTD Return Details")
    var
        VATReturnPeriod: Record "VAT Return Period";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        VATReturnPeriodCard: TestPage "VAT Return Period Card";
    begin
        MockAndGetVATPeriod(VATReturnPeriod, DummyMTDReturnDetails);

        BindSubscription(LibraryMakingTaxDigitalLcl);
        Commit();
        VATReturnPeriodCard.OpenEdit();
        VATReturnPeriodCard.Filter.SetFilter("Start Date", Format(VATReturnPeriod."Start Date"));
        VATReturnPeriodCard.Filter.SetFilter("End Date", Format(VATReturnPeriod."End Date"));
        VATReturnPeriodCard."Receive Submitted VAT Returns".Invoke();
        VATReturnPeriodCard.Close();
    end;

    local procedure GetVATReturnAndShowResult(DummyMTDReturnDetails: Record "MTD Return Details"; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    begin
        GetVATReturn(DummyMTDReturnDetails, true, true, ExpectedTotalCount, ExpectedNewCount, ExpectedModifiedCount);
    end;

    local procedure GetVATReturn(DummyMTDReturnDetails: Record "MTD Return Details"; ShowMessage: Boolean; ExpectedResult: Boolean; ExpectedTotalCount: Integer; ExpectedNewCount: Integer; ExpectedModifiedCount: Integer)
    var
        DummyVATReturnPeriod: Record "VAT Return Period";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        DummyVATReturnPeriod."Start Date" := DummyMTDReturnDetails."Start Date";
        DummyVATReturnPeriod."End Date" := DummyMTDReturnDetails."End Date";
        DummyVATReturnPeriod."Period Key" := DummyMTDReturnDetails."Period Key";

        BindSubscription(LibraryMakingTaxDigitalLcl);
        Assert.AreEqual(
            ExpectedResult,
            MTDMgt.RetrieveVATReturns(DummyVATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, ShowMessage), 'MTDMgt.RetrieveVATReturns()');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveVATReturns - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveVATReturns - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveVATReturns - ModifiedCount');
    end;

    local procedure GetVATReturnForGivenPeriod(VATReturnPeriod: Record "VAT Return Period")
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Assert.AreEqual(true, MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, false), 'MTDMgt.RetrieveVATReturns');
    end;

    local procedure GetRetrieveReturnMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrieveReturnsMsg, StrSubstNo(LibraryMakingTaxDigital.GetIncludingLbl(), NewCount, ModifiedCount)));
    end;

    local procedure SubmitVATReturn(var RequestJson: Text; var ResponseJson: Text; ExpectedResult: Boolean)
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        MTDMgt: Codeunit "MTD Mgt.";
    begin
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Assert.AreEqual(ExpectedResult, MTDMgt.SubmitVATReturn(RequestJson, ResponseJson), 'MTDMgt.SubmitVATReturn');
    end;

    local procedure SubmitVATReturnScenario(VATReportHeader: Record "VAT Report Header"; Confirm: Boolean)
    var
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
    begin
        Commit();
        LibraryVariableStorage.Enqueue(Confirm);
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
    end;

    local procedure SubmitAndGetVATReturnScenario(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        MTDMgt: Codeunit "MTD Mgt.";
        LibraryMakingTaxDigitalLcl: Codeunit "Library - Making Tax Digital";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;

    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        Commit();
        LibraryVariableStorage.Enqueue(true);
        BindSubscription(LibraryMakingTaxDigitalLcl);
        Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
        Assert.AreEqual(
            true,
            MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, false), 'MTDMgt.RetrieveVATReturns()');
        Assert.AreEqual(1, TotalCount, 'MTDMgt.RetrieveVATReturns - TotalCount');
        Assert.AreEqual(1, NewCount, 'MTDMgt.RetrieveVATReturns - NewCount');
        Assert.AreEqual(0, ModifiedCount, 'MTDMgt.RetrieveVATReturns - ModifiedCount');
    end;

    procedure FormatValue(Value: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(Value));
    end;

    local procedure VerifyGetReturnRequestJson(DummyMTDReturnDetails: Record "MTD Return Details")
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath :=
            StrSubstNo(
                '/organisations/vat/%1/returns/%2',
                CompanyInformation."VAT Registration No.", FormatValue(DummyMTDReturnDetails."Period Key"));

        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath);
    end;

    local procedure VerifySubmitReturnRequestJson()
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath := StrSubstNo('/organisations/vat/%1/returns', CompanyInformation."VAT Registration No.");
        LibraryMakingTaxDigital.VerifyRequestJson('POST', ExpectedURLRequestPath);
    end;

    local procedure VerifyGetReturnFailureScenario(ExpectedMessage: Text)
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        Assert.RecordIsEmpty(DummyMTDReturnDetails);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(ExpectedMessage);
        VerifyLatestHttpLogFailure(ExpectedMessage);
    end;

    local procedure VerifyGetReturnScenario(DummyMTDReturnDetails: Record "MTD Return Details"; ExpectedMessage: Text)
    begin
        VerifyReturn(DummyMTDReturnDetails);
        Assert.ExpectedMessage(ExpectedMessage, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        VerifyLatestHttpLogSucess(ExpectedMessage);
    end;

    local procedure VerifyReturn(DummyMTDReturnDetails: Record "MTD Return Details")
    var
        MTDReturnDetails: Record "MTD Return Details";
    begin
        Assert.RecordCount(MTDReturnDetails, 1);
        MTDReturnDetails.FindFirst();
        VerifySinglReturnDetailsRecord(MTDReturnDetails, DummyMTDReturnDetails);
    end;

    local procedure VerifySinglReturnDetailsRecord(MTDReturnDetails: Record "MTD Return Details"; DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        with MTDReturnDetails do begin
            TestField("Start Date", DummyMTDReturnDetails."Start Date");
            TestField("End Date", DummyMTDReturnDetails."End Date");
            TestField("Period Key", DummyMTDReturnDetails."Period Key");
            TestField("VAT Due Sales", DummyMTDReturnDetails."VAT Due Sales");
            TestField("VAT Due Acquisitions", DummyMTDReturnDetails."VAT Due Acquisitions");
            TestField("Total VAT Due", DummyMTDReturnDetails."Total VAT Due");
            TestField("VAT Reclaimed Curr Period", DummyMTDReturnDetails."VAT Reclaimed Curr Period");
            TestField("Net VAT Due", DummyMTDReturnDetails."Net VAT Due");
            TestField("Total Value Sales Excl. VAT", DummyMTDReturnDetails."Total Value Sales Excl. VAT");
            TestField("Total Value Purchases Excl.VAT", DummyMTDReturnDetails."Total Value Purchases Excl.VAT");
            TestField("Total Value Goods Suppl. ExVAT", DummyMTDReturnDetails."Total Value Goods Suppl. ExVAT");
            TestField("Total Acquisitions Excl. VAT", DummyMTDReturnDetails."Total Acquisitions Excl. VAT");
            TestField(Finalised, true);
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
            ExpectedResult, LibraryMakingTaxDigital.GetInvokeRequestLbl('GET') + ' ' + RetrieveVATReturnTxt, ExpectedActivityMessage, true);
    end;

    local procedure VerifyArchiveSubmissionMessage(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        JsonMgt: Codeunit "JSON Management";
    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        Assert.IsTrue(JsonMgt.InitializeFromString(LibraryMakingTaxDigital.GetVATReportSubmissionText(VATReportHeader)), 'GetVATReportSubmissionText');
        Assert.AreEqual('POST', JsonMgt.GetValue('SubmissionRequest.Method'), 'SubmissionRequest.Method');
        Assert.AreEqual(VATReturnPeriod."Period Key", JsonMgt.GetValue('SubmissionRequest.Content.periodKey'), 'SubmissionRequest.Content.periodkey');
        Assert.AreEqual('B', JsonMgt.GetValue('SubmissionResponse.Content.A'), 'SubmissionResponse.Content');
    end;

    local procedure VerifyArchiveResponseMessage(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        JsonMgt: Codeunit "JSON Management";
    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        Assert.IsTrue(JsonMgt.InitializeFromString(LibraryMakingTaxDigital.GetVATReportResponseText(VATReportHeader)), 'GetVATReportResponseText');
        Assert.AreEqual(VATReturnPeriod."Period Key", JsonMgt.GetValue('Content.periodKey'), 'Content.periodKey');
    end;

    local procedure VerifyVATReportStatus(VATReportHeader: Record "VAT Report Header"; ExpectedStatus: Option)
    begin
        VATReportHeader.Find();
        Assert.AreEqual(ExpectedStatus, VATReportHeader.Status, 'VATReportHeader.Status');
        Assert.ExpectedMessage(ConfirmSubmitQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifySuggestLinesCheckBoxNoError(VATReportHeader: Record "VAT Report Header")
    begin
        Commit();
        asserterror Report.RunModal(Report::"VAT Report Request Page", true, false, VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(
          STRSUBSTNO(WrongVATSatementSetupErr, VATReportHeader."Statement Template Name", VATReportHeader."Statement Name"));
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

    [RequestPageHandler]
    procedure VATReportRequestPage_MPH(var VATReportRequestPage: TestRequestPage "VAT Report Request Page");
    begin
        VATReportRequestPage.OK().Invoke();
    end;
}