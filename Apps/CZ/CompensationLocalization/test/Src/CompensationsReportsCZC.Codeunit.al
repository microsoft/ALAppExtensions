codeunit 148091 "Compensations Reports CZC"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Compensations] [Reports]
        isInitialized := false;
    end;

    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        LibraryCompensationCZC: Codeunit "Library - Compensation CZC";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        CompensationSourceTypeCZC: Enum "Compensation Source Type CZC";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Compensations Reports CZC");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Compensations Reports CZC");

        CompensationsSetupCZC.Get();
        CompensationsSetupCZC."Compensation Nos." := LibraryERM.CreateNoSeriesCode();
        CompensationsSetupCZC."Compensation Bal. Account No." := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC."Compensation Proposal Method" := CompensationsSetupCZC."Compensation Proposal Method"::"Registration No.";
        CompensationsSetupCZC."Max. Rounding Amount" := 1;
        CompensationsSetupCZC."Debit Rounding Account" := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC."Credit Rounding Account" := LibraryERM.CreateGLAccountNo();
        CompensationsSetupCZC.Modify();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Compensations Reports CZC");
    end;

    [Test]
    [HandlerFunctions('RequestPageCompensationHandler')]
    procedure PrintingCompensationWithCustLedgEntries()
    begin
        PrintingCompensation(CompensationSourceTypeCZC::Customer);
    end;

    [Test]
    [HandlerFunctions('RequestPageCompensationHandler')]
    procedure PrintingCompensationWithVendLedgEntries()
    begin
        PrintingCompensation(CompensationSourceTypeCZC::Vendor);
    end;

    local procedure PrintingCompensation(CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC1: Record "Compensation Line CZC";
        CompensationLineCZC2: Record "Compensation Line CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // [SCENARIO] Print Compensation Report
        Initialize();

        // [GIVEN] New compensation header has been created
        CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC);

        // [GIVEN] New compensation lines has been created
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    FindCustomerLedgerEntryForInvoice(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                    FindCustomerLedgerEntryForCrMemo(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    FindVendorLedgerEntryForInvoice(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                    FindVendorLedgerEntryForCrMemo(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                end;
        end;

        // [GIVEN] Compensation lines has been balanced
        if Abs(CompensationLineCZC1."Amount (LCY)") > Abs(CompensationLineCZC2."Amount (LCY)") then
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC1, -CompensationLineCZC2."Amount (LCY)")
        else
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC2, -CompensationLineCZC1."Amount (LCY)");

        // [GIVEN] Compensation has been printed
        PrintCompensation(CompensationHeaderCZC);

        // [WHEN] Print compensation
        CompensationHeaderCZC.SetRecFilter();
        LibraryReportDataset.RunReportAndLoad(LibraryCompensationCZC.GetCompensationReport(), CompensationHeaderCZC, '');

        // [THEN] Report dataset will contain Compensation Header No.
        LibraryReportDataset.AssertElementWithValueExists('CompensationHeader_No', CompensationHeaderCZC."No.");

        // [THEN] Report dataset will contain Compensation Lines Amount
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    LibraryReportDataset.AssertElementWithValueExists('CustomerCompensationLine_Amount', CompensationLineCZC1.Amount);
                    LibraryReportDataset.AssertElementWithValueExists('CustomerCompensationLine_Amount', CompensationLineCZC2.Amount);
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    LibraryReportDataset.AssertElementWithValueExists('VendorCompensationLine_Amount', -CompensationLineCZC1.Amount);
                    LibraryReportDataset.AssertElementWithValueExists('VendorCompensationLine_Amount', -CompensationLineCZC2.Amount);
                end;
        end;
    end;

    [Test]
    [HandlerFunctions('RequestPagePostedCompensationHandler')]
    procedure PrintingPostedCompensationWithCustLedgEntries()
    begin
        PrintingPostedCompensation(CompensationSourceTypeCZC::Customer);
    end;

    [Test]
    [HandlerFunctions('RequestPagePostedCompensationHandler')]
    procedure PrintingPostedCompensationWithVendLedgEntries()
    begin
        PrintingPostedCompensation(CompensationSourceTypeCZC::Vendor);
    end;

    local procedure PrintingPostedCompensation(CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC1: Record "Compensation Line CZC";
        CompensationLineCZC2: Record "Compensation Line CZC";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // [SCENARIO] Print Posted Compensation Reports
        Initialize();

        // [GIVEN] New compensation header hase been created
        CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC);

        // [GIVEN] New compensation lines has been created
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    FindCustomerLedgerEntryForInvoice(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                    FindCustomerLedgerEntryForCrMemo(CustLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, CustLedgerEntry."Entry No.");
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    FindVendorLedgerEntryForInvoice(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC1, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                    FindVendorLedgerEntryForCrMemo(VendorLedgerEntry);
                    CreateCompensationLine(
                      CompensationLineCZC2, CompensationHeaderCZC, CompensationSourceTypeCZC, VendorLedgerEntry."Entry No.");
                end;
        end;

        // [GIVEN] Compensation lines has been balanced
        if Abs(CompensationLineCZC1."Amount (LCY)") > Abs(CompensationLineCZC2."Amount (LCY)") then
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC1, -CompensationLineCZC2."Amount (LCY)")
        else
            LibraryCompensationCZC.UpdateCompensationLine(CompensationLineCZC2, -CompensationLineCZC1."Amount (LCY)");

        // [GIVEN] Compensation has been posted
        PostCompensation(CompensationHeaderCZC);

        // [GIVEN] Posted Compensation has been printed
        PostedCompensationHeaderCZC.Get(CompensationHeaderCZC."No.");
        PrintPostedCompensation(PostedCompensationHeaderCZC);

        // [WHEN] Print posted compensation
        PostedCompensationHeaderCZC.SetRecFilter();
        LibraryReportDataset.RunReportAndLoad(LibraryCompensationCZC.GetPostedCompensationReport(), PostedCompensationHeaderCZC, '');

        // [THEN] Report dataset will contain Compensation Header No.
        LibraryReportDataset.AssertElementWithValueExists('CompensationHeader_No', CompensationHeaderCZC."No.");

        // [THEN] Report dataset will contain Compensation Lines Amount
        case CompensationSourceTypeCZC of
            CompensationLineCZC1."Source Type"::Customer:
                begin
                    LibraryReportDataset.AssertElementWithValueExists('CustomerCompensationLine_Amount', CompensationLineCZC1.Amount);
                    LibraryReportDataset.AssertElementWithValueExists('CustomerCompensationLine_Amount', CompensationLineCZC2.Amount);
                end;
            CompensationLineCZC1."Source Type"::Vendor:
                begin
                    LibraryReportDataset.AssertElementWithValueExists('VendorCompensationLine_Amount', -CompensationLineCZC1.Amount);
                    LibraryReportDataset.AssertElementWithValueExists('VendorCompensationLine_Amount', -CompensationLineCZC2.Amount);
                end;
        end;
    end;

    local procedure CreateCompensationHeader(var CompensationHeaderCZC: Record "Compensation Header CZC"; CompensationSourceTypeCZC: Enum "Compensation Source Type CZC")
    begin
        case CompensationSourceTypeCZC of
            CompensationSourceTypeCZC::Customer:
                LibraryCompensationCZC.CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC, LibrarySales.CreateCustomerNo());
            CompensationSourceTypeCZC::Vendor:
                LibraryCompensationCZC.CreateCompensationHeader(CompensationHeaderCZC, CompensationSourceTypeCZC, LibraryPurchase.CreateVendorNo());
        end;
    end;

    local procedure CreateCompensationLine(var CompensationLineCZC: Record "Compensation Line CZC"; CompensationHeaderCZC: Record "Compensation Header CZC";
                                           CompensationSourceTypeCZC: Enum "Compensation Source Type CZC"; SourceEntryNo: Integer)
    begin
        LibraryCompensationCZC.CreateCompensationLine(CompensationLineCZC, CompensationHeaderCZC, CompensationSourceTypeCZC, SourceEntryNo);
    end;

    local procedure FindCustomerLedgerEntryForInvoice(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        LibraryCompensationCZC.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Invoice);
    end;

    local procedure FindCustomerLedgerEntryForCrMemo(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        LibraryCompensationCZC.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::"Credit Memo");
    end;

    local procedure FindVendorLedgerEntryForInvoice(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        LibraryCompensationCZC.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice);
    end;

    local procedure FindVendorLedgerEntryForCrMemo(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        LibraryCompensationCZC.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::"Credit Memo");
    end;

    local procedure PostCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        LibraryCompensationCZC.RunPostCompensation(CompensationHeaderCZC);
    end;

    local procedure PrintCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        Commit();
        LibraryCompensationCZC.RunPrintCompensation(CompensationHeaderCZC, true);
    end;

    local procedure PrintPostedCompensation(var PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC")
    begin
        Commit();
        LibraryCompensationCZC.RunPrintPostedCompensation(PostedCompensationHeaderCZC, true);
    end;

    [RequestPageHandler]
    procedure RequestPageCompensationHandler(var CompensationCZC: TestRequestPage "Compensation CZC")
    begin
        CompensationCZC.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPagePostedCompensationHandler(var PostedCompensationCZC: TestRequestPage "Posted Compensation CZC")
    begin
        PostedCompensationCZC.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}
