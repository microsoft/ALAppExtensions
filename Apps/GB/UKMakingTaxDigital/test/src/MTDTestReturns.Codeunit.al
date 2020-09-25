// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148087 "MTDTestReturns"
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
        ConfirmSubmitQst: Label 'When you submit this VAT information you are making a legal declaration that the information is true and complete. A false declaration can result in prosecution. Do you want to continue?';
        WrongVATSatementSetupErr: Label 'VAT statement template %1 name %2 has a wrong setup. There must be nine rows, each with a value between 1 and 9 for the Box No. field.';
        PeriodLinkErr: Label 'There is no return period linked to this VAT return.\\Use the Create From VAT Return Period action on the VAT Returns page or the Create VAT Return action on the VAT Return Periods page.';

    [Test]
    [Scope('OnPrem')]
    procedure MTDReturnDetails_DiffersFromReturn()
    var
        MTDReturnDetails: array[2] of Record "MTD Return Details";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 258181] TAB 10535 MTDReturnDetails.DiffersFromLiability()
        MockAndGetVATReturnDetail(MTDReturnDetails[1], WorkDate(), WorkDate(), 'a', 1, 2, 3, 4, 5, 6, 7, 8, 9, false);

        MTDReturnDetails[2] := MTDReturnDetails[1];
        Assert.IsFalse(MTDReturnDetails[1].DiffersFromReturn(MTDReturnDetails[2]), '');

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
    [Scope('OnPrem')]
    procedure VATReturnCard_DetailsSubpageRounding()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
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
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
    procedure VATReturn_CreateReturnContent()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        JsonString: Text;
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
    [Scope('OnPrem')]
    procedure VATReturn_CreateReturnContent_NegativeNetVATDue()
    var
        DummyMTDReturnDetails: Record "MTD Return Details";
        VATReturnPeriod: Record "VAT Return Period";
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        JsonString: Text;
    begin
        // [SCENARIO 303221] COD 10531 "MTD Create Return Content" in case of negative Box 5 "Net VAT Due" value
        // [SCENARIO 306708] COD 10531 "MTD Create Return Content" in case of indirect permissions on VAT Report Archive
        LibraryLowerPermissions.SetOutsideO365Scope();
        Initialize();

        // [GIVEN] VAT Return with suggested lines with Box No 5 Amount = -100
        InitSubmitReturnScenario(VATReturnPeriod, VATReportHeader, VATReportHeader.Status::Released);
        LibraryMakingTaxDigital.FindVATStatementReportLine(VATStatementReportLine, VATReportHeader, '5');
        VATStatementReportLine.Validate(Amount, -LibraryRandom.RandDecInRange(1000, 2000, 2));
        VATStatementReportLine.Modify(false); // ignore vat report header checks

        // [WHEN] Submit VAT Return
        LibraryLowerPermissions.SetO365BusFull();
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
    [Scope('OnPrem')]
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
    [HandlerFunctions('VATReportRequestPage_MPH')]
    [Scope('OnPrem')]
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

        VATStatementLine.Get(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", '10000');
        VATStatementLine.Delete();

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    [Scope('OnPrem')]
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

        VATStatementName.Get(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name");
        MockVATStatementLine(VATStatementName, '10');

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    [Scope('OnPrem')]
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

        VATStatementLine.Get(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", '10000');
        VATStatementLine."Box No." := '2';
        VATStatementLine.Modify();

        VerifySuggestLinesCheckBoxNoError(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATReportRequestPage_MPH')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
            VATStatementReportLine.TestField("Box No.", Format(i));
            VATStatementReportLine.Next();
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BlockSubmitForWrongPeriodLink()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReturnPeriod: Record "VAT Return Period";
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
        asserterror Codeunit.Run(Codeunit::"MTD Create Return Content", VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(PeriodLinkErr);

        // UT COD 10532 "MTD Submit Return"
        asserterror Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(PeriodLinkErr);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        ClearRecords();

        if IsInitialized then
            exit;
        IsInitialized := true;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
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

    local procedure InitDummyVATReturn(var DummyMTDReturnDetails: Record "MTD Return Details")
    begin
        with DummyMTDReturnDetails do BEGIN
            "Start Date" := LibraryRandom.RandDate(10);
            "End Date" := LibraryRandom.RandDateFrom("Start Date", 10);
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
        VATStatementLine.Get(VATReportHeader."Statement Template Name", VATReportHeader."Statement Name", LineNo);
        VATStatementLine."Box No." := NewBoxNoValue;
        VATStatementLine.Modify();
    end;

    local procedure SubmitVATReturnScenario(VATReportHeader: Record "VAT Report Header"; Confirm: Boolean)
    begin
        Commit();
        LibraryVariableStorage.Enqueue(Confirm);
        Codeunit.Run(Codeunit::"MTD Submit Return", VATReportHeader);
    end;

    local procedure VerifySuggestLinesCheckBoxNoError(VATReportHeader: Record "VAT Report Header")
    begin
        Commit();
        asserterror Report.RunModal(Report::"VAT Report Request Page", true, false, VATReportHeader);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(
            StrSubstNo(WrongVATSatementSetupErr, VATReportHeader."Statement Template Name", VATReportHeader."Statement Name"));
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATReportRequestPage_MPH(var VATReportRequestPage: TestRequestPage "VAT Report Request Page");
    begin
        VATReportRequestPage.OK().Invoke();
    end;
}
