// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148085 "MTDTestReturnsWebService"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [VAT Return] [Web Service]
    end;

    var
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        RetrieveReturnsErr: Label 'Not possible to retrieve submitted VAT returns.';
        RetrieveVATReturnTxt: Label 'Retrieve VAT Return.', Locked = true;
        RetrieveReturnsUpToDateMsg: Label 'Retrieve submitted VAT returns are up to date.';
        NoSubmittedReturnsMsg: Label 'The remote endpoint has indicated that there is no submitted VAT returns for the specified period.';
        SubmitReturnErr: Label 'Not possible to submit VAT return.';
        SubmitVATReturnTxt: Label 'Submit VAT Return.', Locked = true;
        ConfirmSubmitQst: Label 'When you submit this VAT information you are making a legal declaration that the information is true and complete. A false declaration can result in prosecution. Do you want to continue?';

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_Negative_DisabledOutput()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of HTTP error response and disabled message output
        // <parse key="Packet303" compare="MockServicePacket303" response="MakingTaxDigital\400_blanked.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket303');

        GetVATReturn(DummyMTDReturnDetails, false, false, 0, 0, 0);

        Assert.RecordIsEmpty(DummyMTDReturnDetails);
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request)');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_Negative_Reason()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of HTTP error response with details
        // <parse key="Packet310" compare="MockServicePacket310" response="MakingTaxDigital\400_vrn_invalid.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket310');
        HttpError := 'The provided VRN is invalid.';

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', RetrieveReturnsErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        VerifyLatestHttpLogFailure('HTTP error 400 (Bad Request). The provided VRN is invalid.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_Negative_BlankedJsonResponse()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of blanked http json response
        // <parse key="Packet301" compare="MockServicePacket301" response="MakingTaxDigital\200_blanked.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket301');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        VerifyGetReturnFailureScenario(RetrieveReturnsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_Negative_WrongJsonResponse()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of wrong http json response
        // <parse key="Packet302" compare="MockServicePacket302" response="MakingTaxDigital\200_dummyjson.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket302');

        asserterror GetVATReturn(DummyMTDReturnDetails, true, true, 0, 0, 0);

        VerifyGetReturnFailureScenario(RetrieveReturnsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_New_DisabledOutput()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a new return and disabled message output
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');

        GetVATReturn(DummyMTDReturnDetails, false, true, 1, 1, 0);

        VerifyReturn(DummyMTDReturnDetails);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrieveReturnMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_New_UI()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 258181] PAG 738 "VAT Return Period Card" action "Receive Submitted VAT Returns" in case of a new return
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');

        GetVATReturnAndShowResultViaPage(DummyMTDReturnDetails);

        VerifyGetReturnRequestJson(DummyMTDReturnDetails);
        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(1, 0));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetVATReturns_New_ExpiredToken()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a new return and expired access token
        // <parse key="Packet355" compare="MockServicePacket355" response="MakingTaxDigital\200_vatreturn.txt"/>
        // <parse key="Packet356" compare="MockServicePacket356" response="MakingTaxDigital\401_unauthorized.txt"/>
        // <parse key="Packet357" compare="MockServicePacket357" response="MakingTaxDigital\200_authorize_355.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket357', 'MockServicePacket356');
        InitDummyVATReturn(DummyMTDReturnDetails);

        GetVATReturn(DummyMTDReturnDetails, false, true, 1, 1, 0);

        VerifyReturn(DummyMTDReturnDetails);
        VerifyLatestHttpLogSucess(LibraryMakingTaxDigital.GetRetrieveReturnMsg(1, 0));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_UpToDate()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of up to date return
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due",
                "VAT Reclaimed Curr Period", "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 0);

        VerifyGetReturnScenario(DummyMTDReturnDetails, RetrieveReturnsUpToDateMsg);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_PeriodKey()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Period Key")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, LibraryUtility.GenerateGUID(), "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due",
                "VAT Reclaimed Curr Period", "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_VATDueSales()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Due Sales")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales" + 0.01, "VAT Due Acquisitions", "Total VAT Due",
                "VAT Reclaimed Curr Period", "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_VATDueAcquisitions()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Due Acquisitions")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions" + 0.01, "Total VAT Due",
                "VAT Reclaimed Curr Period", "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_TotalVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total VAT Due")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due" + 0.01,
                "VAT Reclaimed Curr Period", "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_VATReclaimedCurrPeriod()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("VAT Reclaimed Curr Period")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due",
                "VAT Reclaimed Curr Period" + 0.01, "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT",
                "Total Value Goods Suppl. ExVAT", "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_NetVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Net VAT Due")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period",
                "Net VAT Due" + 0.01, "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT",
                "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_TotalValueSalesExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Sales Excl. VAT")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period",
                "Net VAT Due", "Total Value Sales Excl. VAT" + 0.01, "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT",
                "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_TotalValuePurchasesExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Purchases Excl.VAT")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period",
                "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT" + 0.01, "Total Value Goods Suppl. ExVAT",
                "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_TotalValueGoodsSupplExVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Value Goods Suppl. ExVAT")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period",
                "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT" + 0.01,
                "Total Acquisitions Excl. VAT", true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Modified_TotalAcquisitionsExclVAT()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of a modified return ("Total Acquisitions Excl. VAT")
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        with DummyMTDReturnDetails do
            MockVATReturnDetail(
                DummyMTDReturnDetails, "Period Key", "VAT Due Sales", "VAT Due Acquisitions", "Total VAT Due", "VAT Reclaimed Curr Period",
                "Net VAT Due", "Total Value Sales Excl. VAT", "Total Value Purchases Excl.VAT", "Total Value Goods Suppl. ExVAT",
                "Total Acquisitions Excl. VAT" + 0.01, true);

        GetVATReturnAndShowResult(DummyMTDReturnDetails, 1, 0, 1);

        VerifyGetReturnScenario(DummyMTDReturnDetails, LibraryMakingTaxDigital.GetRetrieveReturnMsg(0, 1));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure GetVATReturns_Error404NotFound()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() in case of error 404 "NOT FOUND"
        // <parse key="Packet305" compare="MockServicePacket305" response="MakingTaxDigital\404_not_found_blanked.txt"/>
        Initialize();
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket305');

        GetVATReturn(DummyMTDReturnDetails, true, false, 0, 0, 0);

        Assert.ExpectedMessage(NoSubmittedReturnsMsg, LibraryVariableStorage.DequeueText());
        VerifyLatestHttpLogFailure('HTTP error 404 (Not Found)');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_Negative_Reason()
    var
        RequestJson: Text;
        ResponseJson: Text;
        HttpError: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of HTTP error response with details
        // <parse key="Packet310" compare="MockServicePacket310" response="MakingTaxDigital\400_vrn_invalid.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket310');
        HttpError := 'The provided VRN is invalid.';

        asserterror SubmitVATReturn(RequestJson, ResponseJson, false);

        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo('%1\%2%3', SubmitReturnErr, LibraryMakingTaxDigital.GetResonLbl(), HttpError));
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            false, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt,
            'HTTP error 400 (Bad Request). The provided VRN is invalid.', true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_Positive_BlankedJsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of blanked json response
        // <parse key="Packet301" compare="MockServicePacket301" response="MakingTaxDigital\200_blanked.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket301');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_Positive_WrongJsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of a wrong json response
        // <parse key="Packet302" compare="MockServicePacket302" response="MakingTaxDigital\200_dummyjson.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket302');

        SubmitVATReturn(RequestJson, ResponseJson, true);

        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_Positive_JsonResponse()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of json response
        // <parse key="Packet339" compare="MockServicePacket339" response="MakingTaxDigital\201_submit.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket339');

        RequestJson := '{}';
        SubmitVATReturn(RequestJson, ResponseJson, true);

        VerifySubmitReturnRequestJson();
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        VerifySubmissionResponse(ResponseJson);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_ExpiredToken()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.SubmitVATReturn() in case of expired access token
        // <parse key="Packet343" compare="MockServicePacket343" response="MakingTaxDigital\201_submit.txt"/>
        // <parse key="Packet344" compare="MockServicePacket344" response="MakingTaxDigital\401_unauthorized.txt"/>
        // <parse key="Packet345" compare="MockServicePacket345" response="MakingTaxDigital\200_authorize_343.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket345', 'MockServicePacket344');

        RequestJson := '{}';
        SubmitVATReturn(RequestJson, ResponseJson, true);

        VerifySubmitReturnRequestJson();
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        VerifySubmissionResponse(ResponseJson);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SubmitVATReturns_Timeout()
    var
        RequestJson: Text;
        ResponseJson: Text;
    begin
        // [SCENARIO 313380] COD 10530 MTDMgt.SubmitVATReturn() in case of http timeout error (408)
        // MockServicePacket359 MockService\MakingTaxDigital\408_timeout.txt
        // MockServicePacket360 MockService\MakingTaxDigital\200_authorize_submit.txt
        // MockServicePacket358 MockService\MakingTaxDigital\201_submit.txt
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '\MockServicePacket360', 'MockServicePacket358');

        RequestJson := '{}';
        SubmitVATReturn(RequestJson, ResponseJson, true);

        VerifySubmitReturnRequestJson();
        LibraryMakingTaxDigital.VerifyLatestHttpLogForSandbox(
            true, LibraryMakingTaxDigital.GetInvokeRequestLbl('POST') + ' ' + SubmitVATReturnTxt, '', true);
        VerifySubmissionResponse(ResponseJson);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MarkSubmittedVATReturnAsAccepted()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10530 MTDMgt.RetrieveVATReturns() updates linked VATReturn.Status from "Submitted" to "Accepted"
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        InitGetReturnScenario(DummyMTDReturnDetails, 'MockServicePacket338');
        MockAndGetVATPeriod(VATReturnPeriod, DummyMTDReturnDetails);
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportHeader.Status::Submitted);

        GetVATReturnForGivenPeriod(VATReturnPeriod);

        VATReportHeader.Find();
        VATReportHeader.TESTFIELD(Status, VATReportHeader.Status::Accepted);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure VATReturn_SubmitReturnContent_SubmittedNotAccepted()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        DummyGUID: Guid;
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of submitted return,but not accepted
        // <parse key="Packet339" compare="MockServicePacket339" response="MakingTaxDigital\201_submit.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket339');
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);

        SubmitVATReturnScenario(VATReportHeader, true);

        VerifyVATReportStatus(VATReportHeader, VATReportHeader.Status::Submitted);
        VerifyArchiveSubmissionMessage(VATReportHeader);
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsFalse(VATReportArchive."Response Message BLOB".HasValue(), 'VATReportArchive."Response Message BLOB".HasValue');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure VATReturn_SubmitReturnContent_SubmittedAndAcceptedLater()
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 258181] COD 10532 "MTD Submit Return" in case of submitted return and accepted later
        // <parse key="Packet339" compare="MockServicePacket339" response="MakingTaxDigital\201_submit.txt"/>
        // <parse key="Packet338" compare="MockServicePacket338" response="MakingTaxDigital\200_vatreturn.txt"/>
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket339');
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);

        SubmitAndGetVATReturnScenario(VATReportHeader);

        VerifyVATReportStatus(VATReportHeader, VATReportHeader.Status::Accepted);
        VerifyArchiveResponseMessage(VATReportHeader);
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
        VATReportHeader: Record "VAT Report Header";
        VATReturnPeriod: Record "VAT Return Period";
        MTDReturnDetails: Record "MTD Return Details";
    begin
        VATReportHeader.DeleteAll();
        VATReturnPeriod.DeleteAll();
        MTDReturnDetails.DeleteAll();
    end;

    local procedure InitSubmitReturnScenario(var VATReturnPeriod: Record "VAT Return Period"; var VATReportHeader: Record "VAT Report Header"; VATReportStatus: Option)
    begin
        Initialize();
        LibraryMakingTaxDigital.MockVATReturnPeriod(
            VATReturnPeriod, WorkDate(), WorkDate(), WorkDate(),
            LibraryMakingTaxDigital.HttpPeriodKey(), VATReturnPeriod.Status::Open, WorkDate());
        LibraryMakingTaxDigital.MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod, VATReportStatus);
        LibraryMakingTaxDigital.MockVATStatementReportLinesWithRandomValues(VATReportHeader);
        Codeunit.Run(Codeunit::"MTD Create Return Content", VATReportHeader);
    end;

    local procedure InitGetReturnScenario(var DummyMTDReturnDetails: Record "MTD Return Details"; VATRegNo: Text)
    begin
        Initialize();
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', VATRegNo);
        InitDummyVATReturn(DummyMTDReturnDetails);
    end;

    local procedure InitDummyVATReturn(var DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        with DummyMTDReturnDetails do BEGIN
            "Start Date" := LibraryRandom.RandDate(10);
            "End Date" := LibraryRandom.RandDateFrom("Start Date", 10);
            "Period Key" := LibraryMakingTaxDigital.HttpPeriodKey();
            "VAT Due Sales" := LibraryMakingTaxDigital.HttpAmount1();
            "VAT Due Acquisitions" := "VAT Due Sales" + 0.01;
            "Total VAT Due" := "VAT Due Acquisitions" + 0.01;
            "VAT Reclaimed Curr Period" := "Total VAT Due" + 0.01;
            "Net VAT Due" := "VAT Reclaimed Curr Period" + 0.01;
            "Total Value Sales Excl. VAT" := "Net VAT Due" + 0.01;
            "Total Value Purchases Excl.VAT" := "Total Value Sales Excl. VAT" + 0.01;
            "Total Value Goods Suppl. ExVAT" := "Total Value Purchases Excl.VAT" + 0.01;
            "Total Acquisitions Excl. VAT" := "Total Value Goods Suppl. ExVAT" + 0.01;
        END;
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

    local procedure GetVATReturnAndShowResultViaPage(DummyMTDReturnDetails: Record "MTD Return Details")
    var
        VATReturnPeriod: Record "VAT Return Period";
        VATReturnPeriodCard: TestPage "VAT Return Period Card";
    begin
        MockAndGetVATPeriod(VATReturnPeriod, DummyMTDReturnDetails);

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
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        DummyVATReturnPeriod."Start Date" := DummyMTDReturnDetails."Start Date";
        DummyVATReturnPeriod."End Date" := DummyMTDReturnDetails."End Date";
        DummyVATReturnPeriod."Period Key" := DummyMTDReturnDetails."Period Key";

        Assert.AreEqual(
            ExpectedResult,
            MTDMgt.RetrieveVATReturns(DummyVATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, ShowMessage),
            'MTDMgt.RetrieveVATReturns');
        Assert.AreEqual(ExpectedTotalCount, TotalCount, 'MTDMgt.RetrieveVATReturns - TotalCount');
        Assert.AreEqual(ExpectedNewCount, NewCount, 'MTDMgt.RetrieveVATReturns - NewCount');
        Assert.AreEqual(ExpectedModifiedCount, ModifiedCount, 'MTDMgt.RetrieveVATReturns - ModifiedCount');
    end;

    local procedure GetVATReturnForGivenPeriod(VATReturnPeriod: Record "VAT Return Period")
    var
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        Assert.IsTrue(
            MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, false),
            'MTDMgt.RetrieveVATReturns');
    end;

    local procedure SubmitVATReturn(var RequestJson: Text; var ResponseJson: Text; ExpectedResult: Boolean)
    var
        MTDMgt: Codeunit "MTD Mgt.";
    begin
        Assert.AreEqual(ExpectedResult, MTDMgt.SubmitVATReturn(RequestJson, ResponseJson), 'MTDMgt.SubmitVATReturn');
    end;

    local procedure SubmitVATReturnScenario(VATReportHeader: Record "VAT Report Header"; Confirm: Boolean)
    begin
        Commit();
        LibraryVariableStorage.Enqueue(Confirm);
        Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
    end;

    local procedure SubmitAndGetVATReturnScenario(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        LibraryVariableStorage.Enqueue(true);
        Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', 'MockServicePacket338');
        Assert.AreEqual(
            true,
            MTDMgt.RetrieveVATReturns(VATReturnPeriod, ResponseJson, TotalCount, NewCount, ModifiedCount, false),
            'MTDMgt.RetrieveVATReturns');
        Assert.AreEqual(1, TotalCount, 'MTDMgt.RetrieveVATReturns - TotalCount');
        Assert.AreEqual(1, NewCount, 'MTDMgt.RetrieveVATReturns - NewCount');
        Assert.AreEqual(0, ModifiedCount, 'MTDMgt.RetrieveVATReturns - ModifiedCount');
    end;

    local procedure FormatValue(Value: Variant): Text
    begin
        exit(LibraryMakingTaxDigital.FormatValue(Value));
    end;

    local procedure ReadJsonValue(JToken: JsonToken; Path: Text): Text
    begin
        exit(LibraryMakingTaxDigital.ReadJsonValue(JToken, Path));
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

        LibraryMakingTaxDigital.VerifyRequestJson('GET', ExpectedURLRequestPath, false);
    end;

    local procedure VerifySubmitReturnRequestJson()
    var
        CompanyInformation: Record "Company Information";
        ExpectedURLRequestPath: Text;
    begin
        CompanyInformation.Get();
        ExpectedURLRequestPath := StrSubstNo('/organisations/vat/%1/returns', CompanyInformation."VAT Registration No.");
        LibraryMakingTaxDigital.VerifyRequestJson('POST', ExpectedURLRequestPath, true);
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
        JToken: JsonToken;
    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        Assert.IsTrue(
            JToken.ReadFrom(LibraryMakingTaxDigital.GetVATReportSubmissionText(VATReportHeader)),
            'GetVATReportSubmissionText');
        Assert.AreEqual('POST', ReadJsonValue(JToken, 'SubmissionRequest.Method'), 'SubmissionRequest.Method');
        Assert.AreEqual(
            VATReturnPeriod."Period Key", ReadJsonValue(JToken, 'SubmissionRequest.Content.periodKey'),
            'SubmissionRequest.periodkey');
        VerifySubmissionResponse(ReadJsonValue(JToken, 'SubmissionResponse'));
    end;

    local procedure VerifyArchiveResponseMessage(VATReportHeader: Record "VAT Report Header")
    var
        VATReturnPeriod: Record "VAT Return Period";
        JToken: JsonToken;
    begin
        VATReturnPeriod.Get(VATReportHeader."Return Period No.");
        Assert.IsTrue(
            JToken.ReadFrom(LibraryMakingTaxDigital.GetVATReportResponseText(VATReportHeader)),
            'GetVATReportResponseText');
        Assert.AreEqual(VATReturnPeriod."Period Key", ReadJsonValue(JToken, 'Content.periodKey'), 'periodKey');
    end;

    local procedure VerifyVATReportStatus(VATReportHeader: Record "VAT Report Header"; ExpectedStatus: Option)
    begin
        VATReportHeader.Find();
        Assert.AreEqual(ExpectedStatus, VATReportHeader.Status, 'VATReportHeader.Status');
        Assert.ExpectedMessage(ConfirmSubmitQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifySubmissionResponse(Response: Text)
    var
        JToken: JsonToken;
    begin
        JToken.ReadFrom(Response);
        Assert.AreEqual('BANK', ReadJsonValue(JToken, 'Content.paymentIndicator'), 'json response paymentIndicator');
        Assert.AreEqual('123456789012', ReadJsonValue(JToken, 'Content.formBundleNumber'), 'json response formBundleNumber');
        Assert.AreEqual('abcdefghijklmnop', ReadJsonValue(JToken, 'Content.chargeRefNumber'), 'json response chargeRefNumber');
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;
}
