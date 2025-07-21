namespace Microsoft.Finance.VAT.Reporting;

using System.TestLibraries.Utilities;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Enums;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.VAT.Ledger;

codeunit 148101 "UT REP VATREP GB"
{

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        ManualVATDifferenceCapLbl: Label 'Manual_VAT_Difference';
        VATEntryAmountCapLbl: Label 'VAT_Entry_Amount';

    [Test]
    [HandlerFunctions('VATEntryExceptionReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreReportVATEntryExceptionReportError()
    begin
        // Purpose of the test is to validate OnPreReport Trigger of Report 10511 - VAT Entry Exception Report.

        // Setup.
        Initialize();

        // Exercise.
        asserterror REPORT.Run(REPORT::"VAT Entry Exception Report GB");

        // Verify: Verify error 'No checking selected'.
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [HandlerFunctions('VATEntryExceptionReportWithVATRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordVATEntryWithoutBaseVATEntryExceptionReport()
    var
        VATEntry: Record "VAT Entry";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of Report 10511 - VAT Entry Exception Report with Zero Base.

        // Setup.
        Initialize();
        CreateVATEntry(VATEntry, VATEntry.Type::Purchase, 0, '', '', CreateVendor());  // Taken Zero for Base and blank for VATProdPostingGroup, VATBusPostingGroup.
        LibraryVariableStorage.Enqueue(VATEntry."Document No.");  // Enqueue for VATEntryExceptionReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"VAT Entry Exception Report GB");

        // Verify.
        VerifyValuesOnReport(ManualVATDifferenceCapLbl, VATEntryAmountCapLbl, VATEntry."VAT Difference", VATEntry.Amount)
    end;

    [Test]
    [HandlerFunctions('VATEntryExceptionReportWithVATRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordVATEntryWithBaseVATEntryExceptionReport()
    var
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // Purpose of the test is to validate OnAfterGetRecord Trigger of Report 10511 - VAT Entry Exception Report with Random Base.

        // Setup.
        Initialize();
        FindVATPostingSetup(VATPostingSetup);
        CreateVATEntry(
          VATEntry, VATEntry.Type::Purchase, LibraryRandom.RandDec(10, 2),
          VATPostingSetup."VAT Prod. Posting Group", VATPostingSetup."VAT Bus. Posting Group", CreateVendor());  // Taken random for Base.
        LibraryVariableStorage.Enqueue(VATEntry."Document No.");  // Enqueue for VATEntryExceptionReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"VAT Entry Exception Report GB");

        // Verify.
        VerifyValuesOnReport(ManualVATDifferenceCapLbl, VATEntryAmountCapLbl, VATEntry."VAT Difference", VATEntry.Amount)
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateVATEntry(var VATEntry: Record "VAT Entry"; Type: Enum "General Posting Type"; Base: Decimal; VATProdPostingSetup: Code[20]; VATBusPostingSetup: Code[20]; BillToPayToNo: Code[20])
    var
        VATEntry2: Record "VAT Entry";
    begin
        VATEntry2.FindLast();
        VATEntry."Entry No." := VATEntry2."Entry No." + 1;
        VATEntry.Type := Type;
        VATEntry."Bill-to/Pay-to No." := BillToPayToNo;
        VATEntry."Document No." := LibraryUTUtility.GetNewCode();
        VATEntry."VAT Bus. Posting Group" := VATBusPostingSetup;
        VATEntry."VAT Prod. Posting Group" := VATProdPostingSetup;
        VATEntry.Base := Base;
        VATEntry."VAT Base Discount %" := LibraryRandom.RandDec(10, 2);
        VATEntry."VAT Difference" := LibraryRandom.RandDec(10, 2);
        VATEntry.Amount := LibraryRandom.RandDec(10, 2);
        VATEntry."Posting Date" := WorkDate();
        VATEntry.Insert();
    end;

    local procedure CreateVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Insert();
        exit(Vendor."No.");
    end;

    local procedure FindVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>''''');
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>''''');
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetFilter("VAT %", '>0');
        VATPostingSetup.FindFirst();
    end;

    local procedure VerifyValuesOnReport(ElementName: Text; ElementName2: Text; ExpectedValue: Variant; ExpectedValue2: Variant)
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(ElementName, ExpectedValue);
        LibraryReportDataset.AssertElementWithValueExists(ElementName2, ExpectedValue2);
    end;

    local procedure SaveAsXMLVATEntryExceptionReport(var VATEntryExceptionReport: TestRequestPage "VAT Entry Exception Report GB"; VATBaseDiscount: Boolean; ManualVATDifference: Boolean; VATCalculationTypes: Boolean; VATRate: Boolean)
    begin
        VATEntryExceptionReport.VATBaseDiscount.SetValue(VATBaseDiscount);
        VATEntryExceptionReport.ManualVATDifference.SetValue(ManualVATDifference);
        VATEntryExceptionReport.VATCalculationTypes.SetValue(VATCalculationTypes);
        VATEntryExceptionReport.VATRate.SetValue(VATRate);
        VATEntryExceptionReport.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure VATEntryExceptionReportWithVATRequestPageHandler(var VATEntryExceptionReport: TestRequestPage "VAT Entry Exception Report GB")
    var
        DocumentNo: Variant;
    begin
        LibraryVariableStorage.Dequeue(DocumentNo);
        VATEntryExceptionReport."VAT Entry".SetFilter("Document No.", DocumentNo);
        SaveAsXMLVATEntryExceptionReport(VATEntryExceptionReport, true, true, true, true);
    end;

    [RequestPageHandler]
    procedure VATEntryExceptionReportRequestPageHandler(var VATEntryExceptionReport: TestRequestPage "VAT Entry Exception Report GB")
    begin
        SaveAsXMLVATEntryExceptionReport(VATEntryExceptionReport, false, false, false, false);
    end;
}