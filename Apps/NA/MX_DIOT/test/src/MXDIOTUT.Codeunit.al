codeunit 148041 "MX DIOT UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [DIOT] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryMXDIOT: Codeunit "Library - MX DIOT";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        DIOTDataManagement: Codeunit "DIOT Data Management";
        BaseAmountConceptNo: Integer;
        VATAmountConceptNo: Integer;
        WHTAmountConceptNo: Integer;
        IsInitialized: Boolean;
        BlankStartingDateErr: Label 'Please provide a starting date.';
        BlankEndingDateErr: Label 'Please provide an ending date.';
        LeaseAndRentNonMXErr: Label 'Operations with non-mx Vendor cannot have Lease And Rent Type of operation.';
        NegativeAmountErr: Label 'The amount for Concept No. %1 for Vendor with No. = %2 is negative, which is not valid.';
        NoDataMsg: Label 'There are no VAT Entries for configured concepts in the specified date range.';
        MissingRFCNoErr: Label 'MX vendors must have RFC Number filled in.';

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler')]
    procedure CanGenerateReport()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: array[2] of Record Vendor;
        VATEntry: array[2] of Record "VAT Entry";
    begin
        // [SCENARIO] User can successfully generate report with no errors for local and foreign Vendors
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, 1);
        LibraryMXDIOT.CreateDIOTVendor(Vendor[1], VATPostingSetup."VAT Bus. Posting Group", false);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry[1], VATPostingSetup, WorkDate(), Vendor[1]."No.");
        LibraryMXDIOT.CreateDIOTVendor(Vendor[2], VATPostingSetup."VAT Bus. Posting Group", true);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry[2], VATPostingSetup, WorkDate(), Vendor[2]."No.");

        EnqueueVariablesForDIOTReport(WorkDate(), WorkDate());
        RunDIOTReport();

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler')]
    procedure RequestPage_StartingDateValidation()
    begin
        // [SCENARIO] User must set starting date for report when running
        Initialize();

        EnqueueVariablesForDIOTReport(0D, 0D);
        asserterror RunDIOTReport();
        Assert.ExpectedError(BlankStartingDateErr);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler')]
    procedure RequestPage_EndingDateValidation()
    begin
        // [SCENARIO] User must set ending date for report when running
        Initialize();

        EnqueueVariablesForDIOTReport(WorkDate(), 0D);
        asserterror RunDIOTReport();
        Assert.ExpectedError(BlankEndingDateErr);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler,MessageHandler')]
    procedure RequestPage_DatesMatter()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] No data message is show when there are no records in the specified period
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", true);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");

        EnqueueVariablesForDIOTReport(WorkDate() - 1, WorkDate() - 1);
        LibraryVariableStorage.Enqueue(NoDataMsg);
        RunDIOTReport();
        // UI Handled by MessageHandler
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler,ErrorMessagesPageHandler')]
    procedure ValidationError_RFCNo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] There are validation errors when generating report with wrong data
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        CreateMXVendorWithoutRFCNo(Vendor, VATPostingSetup."VAT Bus. Posting Group");
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");


        EnqueueVariablesForDIOTReport(WorkDate(), WorkDate());
        LibraryVariableStorage.Enqueue(MissingRFCNoErr);
        RunDIOTReport();
        // UI Handled by ErrorMessagesModalPageHandler

        //CleanUp
        VATEntry.Delete(true);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler,ErrorMessagesPageHandler')]
    procedure ValidationError_LeaseAndRent()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] There are validation errors when generating report with wrong data
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");
        VATEntry.Validate("DIOT Type of Operation", VATEntry."DIOT Type of Operation"::"Lease and Rent");
        VATEntry.Modify(true);

        EnqueueVariablesForDIOTReport(WorkDate(), WorkDate());
        LibraryVariableStorage.Enqueue(LeaseAndRentNonMXErr);
        RunDIOTReport();
        // UI Handled by ErrorMessagesModalPageHandler

        //CleanUp
        VATEntry.Delete(true);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DIOTReportRequestPageHandler,ErrorMessagesPageHandler')]
    procedure ValidationError_NegativeAmount()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] There are validation errors when generating report with wrong data
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");
        VATEntry.Base := -LibraryRandom.RandDec(1000, 2);
        VATEntry.Modify(true);

        EnqueueVariablesForDIOTReport(WorkDate(), WorkDate());
        LibraryVariableStorage.Enqueue(StrSubstNo(NegativeAmountErr, BaseAmountConceptNo, Vendor."No."));
        RunDIOTReport();
        // UI Handled by ErrorMessagesModalPageHandler

        //CleanUp
        VATEntry.Delete(true);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure ReportDataSetUT_VendorInfo()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: array[2] of Record Vendor;
        VATEntry: array[2] of Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
    begin
        // [SCENARIO] Report dataset contains relevant info on local and foreign vendors
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.CreateDIOTVendor(Vendor[1], VATPostingSetup."VAT Bus. Posting Group", false);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry[1], VATPostingSetup, WorkDate(), Vendor[1]."No.");
        LibraryMXDIOT.CreateDIOTVendor(Vendor[2], VATPostingSetup."VAT Bus. Posting Group", true);
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry[2], VATPostingSetup, WorkDate(), Vendor[2]."No.");

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        VerifyForeignVendorInfo(TempDIOTReportVendorBuffer, Vendor[1], Vendor[1]."DIOT Type of Operation"::Others);
        VerifyLocalVendorInfo(TempDIOTReportVendorBuffer, Vendor[2], Vendor[2]."DIOT Type of Operation"::Others);
    end;

    [Test]
    procedure ReportDatasetUT_BaseAmountAndVATAmount()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: array[10] of Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        DIOTConcept: Record "DIOT Concept";
        ExpectedBaseAmount: Decimal;
        ExpectedVATAmount: Decimal;
        i: Integer;
    begin
        // [SCENARIO] Multiple VAT Entries are displayed correctly on concept with type "base" and concept with type "vat amount"
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.InsertDIOTConceptLink(VATAmountConceptNo, VATPostingSetup);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);
        for i := 1 to arraylen(VATEntry) do begin
            LibraryMXDIOT.MockPurchaseVATEntry(VATEntry[i], VATPostingSetup, WorkDate(), Vendor."No.");
            ExpectedBaseAmount += VATEntry[i].Base;
        end;
        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        DIOTConcept.Get(3);
        ExpectedVATAmount := ExpectedBaseAmount * (VATPostingSetup."VAT %" / 100) * (DIOTConcept."Non-Deductible Pct" / 100);

        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount);
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, VATAmountConceptNo, ExpectedVATAmount);
    end;

    [Test]
    procedure ReportDatasetUT_NotLinkedVATSetup()
    var
        VATPostingSetup: array[2] of Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        DIOTConcept: Record "DIOT Concept";
        ExpectedBaseAmount: Decimal;
        ExpectedVATAmount: Decimal;
        i: Integer;
    begin
        // [SCENARIO] Only Entries to linked VAT Setups are exported
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup[1], BaseAmountConceptNo);
        LibraryMXDIOT.InsertDIOTConceptLink(VATAmountConceptNo, VATPostingSetup[1]);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup[1]."VAT Bus. Posting Group", false);
        for i := 1 to LibraryRandom.RandIntInRange(3, 10) do begin
            LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup[1], WorkDate(), Vendor."No.");
            ExpectedBaseAmount += VATEntry.Base;
        end;

        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup[2], VATPostingSetup[2]."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandInt(10));
        for i := 1 to LibraryRandom.RandIntInRange(3, 10) do
            LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup[2], WorkDate(), Vendor."No.");

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        DIOTConcept.Get(VATAmountConceptNo);
        ExpectedVATAmount := ExpectedBaseAmount * (VATPostingSetup[1]."VAT %" / 100) * (DIOTConcept."Non-Deductible Pct" / 100);

        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount);
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, VATAmountConceptNo, ExpectedVATAmount);
    end;

    [Test]
    procedure ReportDatasetUT_WHTCalculationSupported()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        DIOTConcept: Record "DIOT Concept";
        ExpectedBaseAmount: Decimal;
        ExpectedVATAmount: Decimal;
        ExpectedWHTAmount: Decimal;
        i: Integer;
    begin
        // [SCENARIO] Only Entries to linked VAT Setups are exported
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        VATPostingSetup.Validate("DIOT WHT %", VATPostingSetup."VAT %" / LibraryRandom.RandIntInRange(2, 5));
        VATPostingSetup.Modify(true);
        LibraryMXDIOT.InsertDIOTConceptLink(VATAmountConceptNo, VATPostingSetup);
        LibraryMXDIOT.InsertDIOTConceptLink(WHTAmountConceptNo, VATPostingSetup);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);
        for i := 1 to LibraryRandom.RandIntInRange(3, 10) do begin
            LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");
            ExpectedBaseAmount += VATEntry.Base;
        end;

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        DIOTConcept.Get(VATAmountConceptNo);
        ExpectedVATAmount := ExpectedBaseAmount * ((VATPostingSetup."VAT %" - VATPostingSetup."DIOT WHT %") / 100) * (DIOTConcept."Non-Deductible Pct" / 100);
        ExpectedWHTAmount := ExpectedBaseAmount * VATPostingSetup."DIOT WHT %" / 100;

        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount);
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, VATAmountConceptNo, ExpectedVATAmount);
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, WHTAmountConceptNo, ExpectedWHTAmount);
    end;

    [Test]
    procedure ReportDatasetUT_SeveralSetupsLinkedToOneConcept()
    var
        VATPostingSetup: array[3] of Record "VAT Posting Setup";
        Vendor: array[3] of Record Vendor;
        VATEntry: Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        ExpectedBaseAmount: array[3] of Decimal;
        i: Integer;
        j: Integer;
    begin
        // [SCENARIO] Concept can have several VAT Posting setups linked to one concept
        Initialize();

        for i := 1 to ArrayLen(VATPostingSetup) do
            PrepareVATPostingSetupAndLink(VATPostingSetup[i], BaseAmountConceptNo);

        for i := 1 to ArrayLen(Vendor) do
            LibraryMXDIOT.CreateDIOTVendor(Vendor[i], VATPostingSetup[i]."VAT Bus. Posting Group", false);
        for i := 1 to LibraryRandom.RandIntInRange(3, 10) do
            for j := 1 to ArrayLen(VATPostingSetup) do begin
                LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup[j], WorkDate(), Vendor[j]."No.");
                ExpectedBaseAmount[j] += VATEntry.Base;
            end;

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        for i := 1 to ArrayLen(VATPostingSetup) do
            VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor[i]."No.", Vendor[i]."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount[i]);
    end;

    [Test]
    procedure VATEntryDIOTTypeOfOperation_UT_PurchInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        VATEntry: Record "VAT Entry";
        PurchInvHeaderNo: Code[20];
    begin
        // [SCENARIO] When posting a new puchase invoice VAT Entry gets DIOT Operation Type from it
        Initialize();

        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        PurchaseHeader.Validate("DIOT Type of Operation", PurchaseHeader."DIOT Type of Operation"::"Prof. Services");
        PurchaseHeader.Modify(true);
        PurchInvHeaderNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        VATEntry.SetRange("Document No.", PurchInvHeaderNo);
        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
        VATEntry.FindFirst();
        VATEntry.TestField("DIOT Type of Operation", VATEntry."DIOT Type of Operation"::"Prof. Services");
    end;

    [Test]
    procedure VATEntryDIOTTypeOfOperation_UT_GenJournal()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] When posting a new invoice from GenJournal VAT Entry gets DIOT Operation Type from it
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);

        CreateAndPostGenJournalLineForDIOTVendor(Vendor."No.");

        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Invoice);
        VATEntry.SetRange("Bill-to/Pay-to No.", Vendor."No.");
        VATEntry.FindFirst();
        VATEntry.TestField("DIOT Type of Operation", VATEntry."DIOT Type of Operation"::"Prof. Services");
    end;

    [Test]
    procedure DIOTFileUT_GeneralLayout()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        TempBLOB: Codeunit "Temp Blob";
        i: Integer;
    begin
        // [SCENARIO] Exported file has exactly 24 columns separated by '|' and line for vendor exists
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);

        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);

        for i := 1 to LibraryRandom.RandIntInRange(3, 10) do
            LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());
        DIOTDataManagement.GenerateDIOTFile(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempBLOB);

        VerifyDIOTFileStructure(TempBLOB);
        Assert.IsTrue(FindLineInDIOTBlob(TempBLOB, Vendor, DIOTDataManagement.GetTypeOfOperationCode(VATEntry."DIOT Type of Operation"::Others)) <> '', 'Line not found in DIOT File');
    end;

    [Test]
    procedure DIOTFileUT_MultipleLinesForSameVendor()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        VATEntry: Record "VAT Entry";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        TempBLOB: Codeunit "Temp Blob";
    begin
        // [SCENARIO] Exported file has lines for same vendor but different type of operation
        Initialize();

        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);

        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);

        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");
        LibraryMXDIOT.MockPurchaseVATEntry(VATEntry, VATPostingSetup, WorkDate(), Vendor."No.");
        VATEntry.Validate("DIOT Type of Operation", VATEntry."DIOT Type of Operation"::"Prof. Services");
        VATEntry.Modify(true);

        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());
        DIOTDataManagement.GenerateDIOTFile(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempBLOB);

        VerifyDIOTFileStructure(TempBLOB);
        Assert.IsTrue(FindLineInDIOTBlob(TempBLOB, Vendor, DIOTDataManagement.GetTypeOfOperationCode(VATEntry."DIOT Type of Operation"::Others)) <> '', 'Line not found in DIOT File');
        Assert.IsTrue(FindLineInDIOTBlob(TempBLOB, Vendor, DIOTDataManagement.GetTypeOfOperationCode(VATEntry."DIOT Type of Operation"::"Prof. Services")) <> '', 'Line not found in DIOT File');
    end;

    [Test]
    procedure DIOTCountryRegionData_UI()
    var
        DIOTCountryRegionData: Record "DIOT Country/Region Data";
        DIOTCountryRegionDataPage: TestPage "DIOT Country/Region Data";
        NewNationality: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO] User can open DIOT Country/Region Data page and edit data on it
        DIOTCountryRegionData.FindFirst();
        DIOTCountryRegionDataPage.OpenEdit();
        DIOTCountryRegionDataPage.GoToRecord(DIOTCountryRegionData);
        NewNationality := LibraryUtility.GenerateGUID();
        DIOTCountryRegionDataPage.Nationality.SetValue(NewNationality);
        DIOTCountryRegionDataPage.Close();

        DIOTCountryRegionData.Find();
        DIOTCountryRegionData.TestField(Nationality, NewNationality);
    end;

    [Test]
    procedure ReportDatasetUT_BaseAmountAndVATAmountUnrealizedVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchInvLine: Record "Purch. Inv. Line";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        PurchaseInvoiceNo: Code[20];
        ExpectedBaseAmount: Decimal;
    begin
        // [FEATURE] [Unrealized VAT]
        // [SCENARIO 367481] DIOT report supports Unrealized VAT = Cash Basis calculations
        Initialize();

        // [GIVEN] VAT Posting Setup created and linked to Base Amount concept
        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);

        // [GIVEN] VAT Setup has Unrealized VAT Type = Cash Basis
        EnableUnrealizedSetup(VATPostingSetup, VATPostingSetup."Unrealized VAT Type"::"Cash Basis");

        // [GIVEN] Vendor was created
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);

        // [GIVEN] Invoice was posted with this VAT Setup for Base Amount = 100 with VAT Amount = 15
        PurchaseInvoiceNo := CreateAndPostPurchaseInvoiceWithVATSetup(PurchaseHeader, VATPostingSetup, Vendor."No.");
        FindPurchaseInvoiceLine(PurchInvLine, PurchaseInvoiceNo);

        // [GIVEN] Payment was posted and applied with amount 115
        CreateAndPostGeneralJournaLineAppliedToInvoice(
          GenJournalLine, GenJournalLine."Document Type"::Payment, PurchaseHeader."Buy-from Vendor No.",
          PurchInvLine."Amount Including VAT", PurchaseInvoiceNo);

        // [WHEN] Run DIOT Report
        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        // [THEN] DIOT Report has Amount 100 for base amount concept for this Vendor
        ExpectedBaseAmount := PurchInvLine.Amount;
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount);
    end;

    [Test]
    procedure DIOTTypeInheritsFromVendorToPurchDoc()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO 405454] "DIOT Type" inherits from vendor to purchase document

        Initialize();
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("DIOT Type of Operation", Vendor."DIOT Type of Operation"::"Prof. Services");
        Vendor.Modify(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.TestField("DIOT Type of Operation", Vendor."DIOT Type of Operation");
    end;

    [Test]
    procedure ReportDatasetUT_BaseAmountAndVATAmountUnrealizedVATSetupAppliedFromInvoice()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchInvLine: Record "Purch. Inv. Line";
        TempDIOTReportBuffer: Record "DIOT Report Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        TempDIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        PurchaseInvoiceNo: Code[20];
        ExpectedBaseAmount: Decimal;
    begin
        // [FEATURE] [Unrealized VAT]
        // [SCENARIO 479227] DIOT considers VAT Entries produced when applying Unrealized VAT Invoice applied to Payment
        Initialize();

        // [GIVEN] VAT Posting Setup created and linked to Base Amount concept
        PrepareVATPostingSetupAndLink(VATPostingSetup, BaseAmountConceptNo);

        // [GIVEN] VAT Setup has Unrealized VAT Type = Cash Basis
        EnableUnrealizedSetup(VATPostingSetup, VATPostingSetup."Unrealized VAT Type"::"Cash Basis");

        // [GIVEN] Vendor was created
        LibraryMXDIOT.CreateDIOTVendor(Vendor, VATPostingSetup."VAT Bus. Posting Group", false);

        // [GIVEN] Invoice was posted with this VAT Setup for Base Amount = 100 with VAT Amount = 15
        PurchaseInvoiceNo := CreateAndPostPurchaseInvoiceWithVATSetup(PurchaseHeader, VATPostingSetup, Vendor."No.");
        FindPurchaseInvoiceLine(PurchInvLine, PurchaseInvoiceNo);

        // [GIVEN] Payment was posted with amount 115
        CreateAndPostGeneralJournaLine(GenJournalLine, GenJournalLine."Document Type"::Payment, PurchaseHeader."Buy-from Vendor No.", PurchInvLine."Amount Including VAT");

        // [GIVEN] Apply Invoice to Payment from Invoice entry
        ApplyVendorLedgerEntry("Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::Payment, PurchaseInvoiceNo, GenJournalLine."Document No.");

        // [WHEN] Run DIOT Report
        DIOTDataManagement.CollectDIOTDataSet(TempDIOTReportBuffer, TempDIOTReportVendorBuffer, TempErrorMessage, WorkDate(), WorkDate());

        // [THEN] DIOT Report has Amount 100 for base amount concept for this Vendor
        ExpectedBaseAmount := PurchInvLine.Amount;
        VerifyDIOTBufferAmount(TempDIOTReportBuffer, Vendor."No.", Vendor."DIOT Type of Operation"::Others, BaseAmountConceptNo, ExpectedBaseAmount);
    end;

    local procedure Initialize()
    begin
        Clear(DIOTDataManagement);
        ClearConceptLinks();
        LibraryTestInitialize.OnTestInitialize(Codeunit::"MX DIOT UT");
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;

        BaseAmountConceptNo := 1;
        VATAmountConceptNo := 3;
        WHTAmountConceptNo := DIOTDataManagement.GetWHTConceptNo();
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"MX DIOT UT");
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"MX DIOT UT");
        LibrarySetupStorage.Save(Database::"General Ledger Setup");
    end;

    local procedure ApplyVendorLedgerEntry(DocumentType: Enum "Gen. Journal Document Type"; DocumentType2: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; DocumentNo2: Code[20])
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, DocumentType, DocumentNo);
        VendorLedgerEntry.CalcFields("Remaining Amount");
        LibraryERM.SetApplyVendorEntry(VendorLedgerEntry, VendorLedgerEntry."Remaining Amount");
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry2, DocumentType2, DocumentNo2);
        VendorLedgerEntry2.FindSet();
        repeat
            VendorLedgerEntry2.CalcFields("Remaining Amount");
            VendorLedgerEntry2.Validate("Amount to Apply", VendorLedgerEntry2."Remaining Amount");
            VendorLedgerEntry2.Modify(true);
        until VendorLedgerEntry2.Next() = 0;
        SetAppliesToIDAndPostEntry(VendorLedgerEntry2, VendorLedgerEntry);
    end;

    local procedure SetAppliesToIDAndPostEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; VendorLedgerEntry2: Record "Vendor Ledger Entry")
    begin
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);
        LibraryERM.PostVendLedgerApplication(VendorLedgerEntry2);
    end;

    local procedure ClearConceptLinks()
    var
        DIOTConceptLink: Record "DIOT Concept Link";
    begin
        DIOTConceptLink.DeleteAll();
    end;

    local procedure CreateAndPostGenJournalLineForDIOTVendor(VendorNo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine2WithBalAcc(
            GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor, VendorNo, GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), -LibraryRandom.RandDecInRange(100, 1000, 2));
        GenJournalLine.Validate("DIOT Type of Operation", GenJournalLine."DIOT Type of Operation"::"Prof. Services");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostPurchaseInvoiceWithVATSetup(var PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup"; VendorNo: Code[20]): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account",
            LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, "General Posting Type"::" "),
            LibraryRandom.RandInt(10));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateAndPostGeneralJournaLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; Amount: Decimal)
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, DocumentType, GenJournalLine."Account Type"::Vendor, AccountNo, Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostGeneralJournaLineAppliedToInvoice(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountNo: Code[20]; Amount: Decimal; AppliesToPurchaseInvoiceNo: Code[20])
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, DocumentType, GenJournalLine."Account Type"::Vendor, AccountNo, Amount);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToPurchaseInvoiceNo);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateMXVendorWithoutRFCNo(var Vendor: Record Vendor; VATBusinessPosingGroup: Code[20])
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusinessPosingGroup);
        Vendor.Validate("Country/Region Code", DIOTDataManagement.GetMXCountryCode());
        Vendor.Validate("DIOT Type of Operation", Vendor."DIOT Type of Operation"::Others);
        Vendor.Modify(true);
    end;

    local procedure EnableUnrealizedSetup(var VATPostingSetup: Record "VAT Posting Setup"; UnrealizedVATType: Option)
    begin
        LibraryERM.SetUnrealizedVAT(true);
        VATPostingSetup.Validate("Unrealized VAT Type", UnrealizedVATType);
        VATPostingSetup.Validate("Purch. VAT Unreal. Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify(true);
    end;

    local procedure FindPurchaseInvoiceLine(var PurchInvLine: Record "Purch. Inv. Line"; PurchaseInvoiceNo: Code[20])
    begin
        PurchInvLine.SetRange("Document No.", PurchaseInvoiceNo);
        PurchInvLine.FindFirst();
    end;

    local procedure FindLineInDIOTBlob(var TempBLOB: Codeunit "Temp Blob"; Vendor: Record Vendor; TypeOfOperation: Text[2]): Text
    var
        iStream: InStream;
        Line: Text;
    begin
        tempBLOB.CreateInStream(iStream);
        while not iStream.EOS() do begin
            iStream.ReadText(Line);
            if StrPos(Line, StrSubstNo('%1|%2|', TypeOfOperation, Vendor.Name)) > -1 then
                exit(Line);
        end;
    end;

    local procedure EnqueueVariablesForDIOTReport(StartingDate: Date; EndingDate: Date)
    begin
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(EndingDate);
    end;

    local procedure PrepareVATPostingSetupAndLink(var VATPostingSetup: Record "VAT Posting Setup"; ConceptNo: Integer)
    begin
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInRange(5, 15, 2));
        LibraryMXDIOT.InsertDIOTConceptLink(ConceptNo, VATPostingSetup);
    end;

    local procedure RunDIOTReport()
    var
        AssistedSetupPage: TestPage "Assisted Setup";
    begin
        AssistedSetupPage.OpenView();
        DIOTDataManagement.SetAssistedSetupComplete();
        AssistedSetupPage.Close();

        Commit();

        Report.Run(Report::"Create DIOT Report");
    end;

    local procedure VerifyDIOTFileStructure(var tempBLOB: Codeunit "Temp Blob")
    var
        iStream: InStream;
        Line: Text;
    begin
        tempBLOB.CreateInStream(iStream);
        while not iStream.EOS() do begin
            iStream.ReadText(Line);
            Assert.AreEqual(24, CountCharsInString(Line, '|'), 'DIOT Line must have exactly 24 | separators');
        end;
    end;

    local procedure CountCharsInString(InputString: Text; Character: Char): Integer
    var
        OnlySymbol: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(InputString) do
            if InputString[i] = Character then
                OnlySymbol := OnlySymbol + InputString[i];
        exit(StrLen(OnlySymbol));
    end;

    local procedure VerifyForeignVendorInfo(var DIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer"; var Vendor: Record Vendor; DIOTTypeOfOperation: Option)
    var
        DIOTDataMgmt: Codeunit "DIOT Data Management";
    begin
        with DIOTReportVendorBuffer do begin
            SetRange("Vendor No.", Vendor."No.");
            SetRange("Type of Operation", DIOTTypeOfOperation);
            FindFirst();
            TestField("Type of Vendor Text", '05');
            TestField("TAX Registration ID", Vendor."VAT Registration No.");
            TestField("RFC Number", Vendor."RFC No.");
            TestField("Vendor Name", Vendor.Name);
            TestField("Country/Region Code", DIOTDataMgmt.ConvertToDIOTCountryCode(Vendor."Country/Region Code"));
            TestField(Nationality, DIOTDataMgmt.GetNationalyForCountryCode("Country/Region Code"));
        end;
    end;

    local procedure VerifyLocalVendorInfo(var DIOTReportVendorBuffer: Record "DIOT Report Vendor Buffer"; var Vendor: Record Vendor; DIOTTypeOfOperation: Option)
    begin
        with DIOTReportVendorBuffer do begin
            SetRange("Vendor No.", Vendor."No.");
            SetRange("Type of Operation", DIOTTypeOfOperation);
            FindFirst();
            TestField("Type of Vendor Text", '04');
            TestField("TAX Registration ID", '');
            TestField("RFC Number", Vendor."RFC No.");
            TestField("Vendor Name", '');
            TestField("Country/Region Code", '');
            TestField(Nationality, '');
        end;
    end;

    local procedure VerifyDIOTBufferAmount(var DIOTReportBuffer: Record "DIOT Report Buffer"; VendorNo: Code[20]; DIOTTypeOfOperation: Option; ConceptNo: Integer; Amount: Decimal)
    begin
        DIOTReportBuffer.Get(VendorNo, DIOTTypeOfOperation, ConceptNo);
        DIOTReportBuffer.TestField(Value, Amount);
    end;

    [RequestPageHandler]
    procedure DIOTReportRequestPageHandler(var CreateDIOTReportRequestPage: TestRequestPage "Create DIOT Report")
    var
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := LibraryVariableStorage.DequeueDate();
        EndingDate := LibraryVariableStorage.DequeueDate();
        if StartingDate <> 0D then
            CreateDIOTReportRequestPage.StartingDate.SetValue(StartingDate);
        if EndingDate <> 0D then
            CreateDIOTReportRequestPage.EndingDate.SetValue(EndingDate);
        CreateDIOTReportRequestPage.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [PageHandler]
    procedure ErrorMessagesPageHandler(var ErrorMessages: TestPage "Error Messages")
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), ErrorMessages.Description.Value());
        ErrorMessages.Close();
    end;
}