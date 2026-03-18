// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.IO;
using System.TestLibraries.Utilities;

codeunit 144034 "UT REP Payment Management"
{
    //  1. Purpose of the test is to validate On Pre Data Item Trigger of Report ID - 10818 Payment List.
    //  2. Purpose of the test is to verify error on Report ID - 10832 GL/Cust. Ledger Reconciliation.
    //  3. Purpose of the test is to verify error on Report ID - 10833 GL/Vend. Ledger Reconciliation.
    //  4. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10821 'Bill' with Currency.
    //  5. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10829 'Draft' with Currency.
    //  6. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10821 'Bill' without Currency.
    //  7. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10829 'Draft' without Currency.
    //  8. Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10830 'Draft Notice'.
    //  9. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10830 'Draft Notice' with blank Payment Address Code.
    // 10. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10830 'Draft Notice' with Payment Address Code.
    // 11. Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10822 'Withdraw Notice'.
    // 12. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10822 'Withdraw Notice' with blank Payment Address Code.
    // 13. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10822 'Withdraw Notice' with Payment Address Code.
    // 14. Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
    // 15. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
    // 16. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
    // 17. Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation',
    // 18. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation'.
    // 19. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation'.
    // 20. Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10826 Remittance.
    // 
    // Covers Test Cases for WI - 344345
    // ----------------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                         TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------------
    // OnPreDateItemPaymentLinePaymentList                                                                                       169507
    // GLCustLedgerReconciliationDateFilterError                                                                                 169508
    // GLVendLedgerReconciliationDateFilterError                                                                                 169509
    // OnAfterGetRecordPaymentLineWithCurrencyBill, OnAfterGetRecordPaymentLineBlankCurrencyBillError                            169433
    // OnAfterGetRecordPaymentLineWithCurrencyDraft, OnAfterGetRecordPaymentLineBlankCurrencyDraftError                          169510
    // OnPreReportDraftNoticeError, OnAfterGetRecordPmtLineBlankPmtAddressDraftNotice
    // OnAfterGetRecordPmtLinePmtAddressDraftNotice                                                                              169512
    // OnPreReportWithdrawNoticeError, OnAfterGetRecordPmtLineBlankPmtAddressWithdrawNotice
    // OnAfterGetRecordPmtLinePmtAddressWithdrawNotice                                                                           169432
    // OnPreReportDraftRecapitulationError, OnAfterGetRecordPmtLineDraftRecapitulationError                                      169511
    // OnAfterGetRecordPmtLineDraftRecapitulation
    // OnPreReportWithdrawRecapitulationError, OnAfterGetRecordPmtLineWithdrawRecapitulationError
    // OnAfterGetRecordPmtLineWithdrawRecapitulation                                                                             169434
    // OnAfterGetRecordPaymentLineRemittance                                                                                     169513

    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        FileManagement: Codeunit "File Management";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportValidation: Codeunit "Library - Report Validation";
        AmountTxt: Label 'Amount %1', Comment = '%1 = Currency Code';
        DialogErr: Label 'Dialog';
        FileNotExistsMsg: Label 'File Does Not Exists.';
        PaymentLinesAccountNoCapLbl: Label 'Payment_Lines__Account_No__';
        PaymentLineAccountNoCapLbl: Label 'Payment_Line__Account_No__';
        PaymentLines1NoCapLbl: Label 'Payment_Lines1___No__';

    [Test]
    [HandlerFunctions('PaymentListRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDateItemPaymentLinePaymentList()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On Pre Data Item Trigger of Report ID - 10818 Payment List.

        // Setup: Create Payment Line.
        Initialize();

        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, CreateVendor(), '', '');  // Blank value for Currency and Payment Address code.
        LibraryVariableStorage.Enqueue(PaymentLine."No.");  // Enqueue for PaymentListRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Payment List FR");

        // Verify: Verify Account No on Payment List Report.
        VerifyValuesOnXML(PaymentLineAccountNoCapLbl, PaymentLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('GLCustLedgerReconciliationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GLCustLedgerReconciliationDateFilterError()
    begin
        // Purpose of the test is to verify error on Report ID - 10832 GL/Cust. Ledger Reconciliation.

        // Test to verify error 'Specify a filter for the Date Filter field in the Customer table.'.
        GLReconciliationDateFilterError(REPORT::"GL/Cust Ledger Reconciliation");
    end;

    [Test]
    [HandlerFunctions('GLVendLedgerReconciliationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GLVendLedgerReconciliationDateFilterError()
    begin
        // Purpose of the test is to verify error on Report ID - 10833 GL/Vend. Ledger Reconciliation.

        // Test to verify error 'Specify a filter for the Date Filter field in the Vendor table.'.
        GLReconciliationDateFilterError(REPORT::"GL/Vend Ledger Reconciliation");
    end;

    local procedure GLReconciliationDateFilterError(ReportID: Integer)
    begin
        // Setup: Enqueue values for GLCustLedgerReconciliationRequestPageHandler and GLVendLedgerReconciliationRequestPageHandler.
        Initialize();

        LibraryVariableStorage.Enqueue('');  // Blank for No.

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify: Verify expected error code.
        Assert.ExpectedErrorCode('DB:NoFilter');
    end;

    [Test]
    [HandlerFunctions('BillRequestpageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineWithCurrencyBill()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10821 'Bill' with Currency.
        PaymentReportWithCurrency(PaymentLine."Account Type"::Customer, CreateCustomer(), REPORT::"Bill FR");
    end;

    [Test]
    [HandlerFunctions('DraftRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineWithCurrencyDraft()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10829 'Draft' with Currency.
        PaymentReportWithCurrency(PaymentLine."Account Type"::Vendor, CreateVendor(), REPORT::"Draft FR");
    end;

    local procedure PaymentReportWithCurrency(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; ReportID: Integer)
    var
        CurrencyCode: Code[10];
    begin
        // Setup and Exercise.
        Initialize();

        CurrencyCode := CreateCurrency();
        CreatePaymentLineAndRunPaymentReport(AccountType, AccountNo, CurrencyCode, ReportID);

        // Verify: Verify Amount Text on XML after running report.
        VerifyValuesOnXML('AmountText', StrSubstNo(AmountTxt, CurrencyCode));
    end;

    [Test]
    [HandlerFunctions('BillBlankCurrencyRequestpageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineBlankCurrencyBillError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10821 'Bill' without Currency.
        PaymentReportWithoutCurrency(PaymentLine."Account Type"::Customer, CreateCustomer(), REPORT::"Bill FR");
    end;

    [Test]
    [HandlerFunctions('DraftBlankCurrencyRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineBlankCurrencyDraftError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10829 'Draft' without Currency.
        PaymentReportWithoutCurrency(PaymentLine."Account Type"::Vendor, CreateVendor(), REPORT::"Draft FR");
    end;

    local procedure PaymentReportWithoutCurrency(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; ReportID: Integer)
    var
        FileName: Text;
    begin
        // Setup and Exercise.
        Initialize();

        FileName := FileManagement.ServerTempFileName('.pdf');
        LibraryVariableStorage.Enqueue(FileName);  // Enqueue for BillBlankCurrencyRequestpageHandler and DraftBlankCurrencyRequestpageHandler.
        CreatePaymentLineAndRunPaymentReport(AccountType, AccountNo, '', ReportID);  // Blank for Currency code.

        // Verify: Verify File Exists and not Empty.
        Assert.IsTrue(VerifyFileNotEmpty(FileName), FileNotExistsMsg);
    end;

    [Test]
    [HandlerFunctions('DraftNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreReportDraftNoticeError()
    begin
        // Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10830 'Draft Notice'.
        // Setup.
        Initialize();


        // Exercise.
        asserterror REPORT.Run(REPORT::"Draft notice FR");

        // Verify: Verify expected error code. Actual error is 'You must specify a transfer number'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('DraftNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBlankPmtAddressDraftNotice()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10830 'Draft Notice' with blank Payment Address Code.
        RunAndVerifyDraftNoticeReport('');  // Blank for Payment Address code.    
    end;

    [Test]
    [HandlerFunctions('DraftNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLinePmtAddressDraftNotice()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10830 'Draft Notice' with Payment Address Code.
        RunAndVerifyDraftNoticeReport(LibraryUTUtility.GetNewCode10());
    end;

    local procedure RunAndVerifyDraftNoticeReport(PaymentAddressCode: Code[10])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create payment Line.
        Initialize();

        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, CreateVendor(), '', PaymentAddressCode);  // Blank for Currency code.
        PaymentLine.SetRange("No.", PaymentLine."No.");

        // Exercise.
        REPORT.Run(REPORT::"Draft notice FR", true, false, PaymentLine);  // TRUE for ReqWindow and FALSE for SystemPrinter.

        // Verify: Verify Account No on Draft Notice report.
        VerifyValuesOnXML(PaymentLines1NoCapLbl, PaymentLine."No.");
    end;

    [Test]
    [HandlerFunctions('WithdrawNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreReportWithdrawNoticeError()
    begin
        // Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10822 'Withdraw Notice'.
        // Setup.
        Initialize();


        // Exercise.
        asserterror REPORT.Run(REPORT::"Withdraw notice FR");

        // Verify: Verify expected error code. Actual error is 'You must specify a withdraw number'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('WithdrawNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBlankPmtAddressWithdrawNotice()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10822 'Withdraw Notice' with blank Payment Address Code.
        RunAndVerifyWithdrawNoticeReport('');  // Blank for Payment Address code.    
    end;

    [Test]
    [HandlerFunctions('WithdrawNoticeRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLinePmtAddressWithdrawNotice()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10822 'Withdraw Notice' with Payment Address Code.
        RunAndVerifyWithdrawNoticeReport(LibraryUTUtility.GetNewCode10());
    end;

    local procedure RunAndVerifyWithdrawNoticeReport(PaymentAddressCode: Code[10])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create payment Line.
        Initialize();

        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Customer, CreateCustomer(), '', PaymentAddressCode);  // Blank for Currency code.
        PaymentLine.SetRange("No.", PaymentLine."No.");

        // Exercise.
        REPORT.Run(REPORT::"Withdraw notice FR", true, false, PaymentLine);  // TRUE for ReqWindow and FALSE for SystemPrinter.

        // Verify: Verify Account No on Withdraw Notice report.
        VerifyValuesOnXML(PaymentLines1NoCapLbl, PaymentLine."No.");
    end;

    [Test]
    [HandlerFunctions('DraftRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreReportDraftRecapitulationError()
    begin
        // Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
        // Setup.
        Initialize();


        // Exercise.
        asserterror REPORT.Run(REPORT::"Draft recapitulation FR");

        // Verify: Verify expected error code. Actual error is 'You must specify a transfer number'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('DraftRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineDraftRecapitulationError()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
        // Setup & Exercise.
        Initialize();

        asserterror CreatePaymentLineAndRunDraftRecapitulationReport('');  // Blank for AccountNo.

        // Verify: Verify expected error code. Actual error is 'Vendor does not exist'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('DraftRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineDraftRecapitulation()
    var
        VendorNo: Code[20];
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10824 'Draft Recapitulation'.
        // Setup & Exercise.
        Initialize();

        VendorNo := CreateVendor();
        CreatePaymentLineAndRunDraftRecapitulationReport(VendorNo);

        // Verify: Verify Account No on XML after running Draft Recapitulation report.
        VerifyValuesOnXML(PaymentLinesAccountNoCapLbl, VendorNo);
    end;

    [Test]
    [HandlerFunctions('WithdrawRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreReportWithdrawRecapitulationError()
    begin
        // Purpose of the test is to validate On Pre Report Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation',
        // Setup.
        Initialize();


        // Exercise.
        asserterror REPORT.Run(REPORT::"Withdraw recapitulation FR");

        // Verify: Verify expected error code. Actual error is 'You must specify a withdraw number'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('WithdrawRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineWithdrawRecapitulationError()
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation'.
        // Setup & Exercise.
        Initialize();

        asserterror CreatePaymentLineAndRunWithdrawRecapitulationReport('');  // Blank for AccountNo.

        // Verify: Verify expected error code. Actual error is 'Customer  does not exist'.
        Assert.ExpectedErrorCode(DialogErr);
    end;

    [Test]
    [HandlerFunctions('WithdrawRecapitulationRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineWithdrawRecapitulation()
    var
        CustomerNo: Code[20];
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10828 'Withdraw Recapitulation'.
        // Setup & Exercise.
        Initialize();

        CustomerNo := CreateCustomer();
        CreatePaymentLineAndRunWithdrawRecapitulationReport(CustomerNo);

        // Verify: Verify Account No on XML after running Withdraw Recapitulation report.
        VerifyValuesOnXML(PaymentLinesAccountNoCapLbl, CustomerNo);
    end;

    [Test]
    [HandlerFunctions('RemittanceRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineRemittance()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of the test is to validate On After Get Record Trigger of Payment Line for Report ID - 10826 Remittance.
        // Setup: Create payment Line.
        Initialize();

        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Customer, CreateCustomer(), CreateCurrency(), '');  // Blank for Payment Address Code.
        PaymentLine.SetRange("No.", PaymentLine."No.");

        // Exercise.
        REPORT.Run(REPORT::"Remittance FR", true, false, PaymentLine);  // TRUE for ReqWindow and FALSE for SystemPrinter.

        // Verify: Verify Account No on XML after running Remittance report.
        VerifyValuesOnXML(PaymentLineAccountNoCapLbl, PaymentLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('DraftNoticeToExcelRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DraftNoticeSaveToExcel()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 332702] Run report "Draft notice" with saving results to Excel file.
        Initialize();

        LibraryReportValidation.SetFileName(LibraryUtility.GenerateGUID());

        // [GIVEN] Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, CreateVendor(), '', '');

        // [WHEN] Run report "Draft notice", save report output to Excel file.
        PaymentLine.SetRecFilter();
        REPORT.Run(REPORT::"Draft notice FR", true, false, PaymentLine);

        // [THEN] Report output is saved to Excel file.
        LibraryReportValidation.OpenExcelFile();
        LibraryReportValidation.VerifyCellValue(1, 6, '1'); // page number
        Assert.AreNotEqual(0, LibraryReportValidation.FindColumnNoFromColumnCaption('Draft notice'), '');
    end;

    [Test]
    [HandlerFunctions('DraftRecapitulationToExcelRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DraftRecapitulationSaveToExcel()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 332702] Run report "Draft recapitulation FR" with saving results to Excel file.
        Initialize();

        LibraryReportValidation.SetFileName(LibraryUtility.GenerateGUID());

        // [GIVEN] Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, CreateVendor(), '', '');

        // [WHEN] Run report "Draft recapitulation FR", save report output to Excel file.
        PaymentLine.SetRecFilter();
        REPORT.Run(REPORT::"Draft recapitulation FR", true, false, PaymentLine);

        // [THEN] Report output is saved to Excel file.
        LibraryReportValidation.OpenExcelFile();
        LibraryReportValidation.VerifyCellValue(1, 7, '1'); // page number
        Assert.AreNotEqual(0, LibraryReportValidation.FindColumnNoFromColumnCaption('Draft Recapitulation'), '');
    end;

    [Test]
    [HandlerFunctions('RemittanceToExcelRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RemittanceSaveToExcel()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 332702] Run report "Remittance" with saving results to Excel file.
        Initialize();

        LibraryReportValidation.SetFileName(LibraryUtility.GenerateGUID());

        // [GIVEN] Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Customer, CreateCustomer(), '', '');

        // [WHEN] Run report "Remittance", save report output to Excel file.
        PaymentLine.SetRecFilter();
        REPORT.Run(REPORT::"Remittance FR", true, false, PaymentLine);

        // [THEN] Report output is saved to Excel file.
        LibraryReportValidation.OpenExcelFile();
        LibraryReportValidation.VerifyCellValue(1, 8, '1'); // page number
        Assert.AreNotEqual(0, LibraryReportValidation.FindColumnNoFromColumnCaption('Remittance'), '');
    end;

    [Test]
    [HandlerFunctions('WithdrawRecapitulationToExcelRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure WithdrawRecapitulationSaveToExcel()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 332702] Run report "Withdraw recapitulation FR" with saving results to Excel file.
        Initialize();

        LibraryReportValidation.SetFileName(LibraryUtility.GenerateGUID());

        // [GIVEN] Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, CreateVendor(), '', '');

        // [WHEN] Run report "Withdraw recapitulation FR", save report output to Excel file.
        PaymentLine.SetRecFilter();
        REPORT.Run(REPORT::"Withdraw recapitulation FR", true, false, PaymentLine);

        // [THEN] Report output is saved to Excel file.
        LibraryReportValidation.OpenExcelFile();
        LibraryReportValidation.VerifyCellValue(1, 13, '1'); // page number
        Assert.AreNotEqual(0, LibraryReportValidation.FindColumnNoFromColumnCaption('Withdraw Recapitulation'), '');
    end;

    [Test]
    [HandlerFunctions('WithdrawNoticeToExcelRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure WithdrawNoticeSaveToExcel()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // [SCENARIO 337173] Run report "Withdraw notice" with saving results to Excel file.
        Initialize();

        LibraryReportValidation.SetFileName(LibraryUtility.GenerateGUID());

        // [GIVEN] Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Customer, CreateCustomer(), '', '');

        // [WHEN] Run report "Withdraw notice", save report output to Excel file.
        PaymentLine.SetRecFilter();
        REPORT.Run(REPORT::"Withdraw notice FR", true, false, PaymentLine);

        // [THEN] Report output is saved to Excel file.
        LibraryReportValidation.OpenExcelFile();
        LibraryReportValidation.VerifyCellValue(1, 12, '1'); // page number
        Assert.AreNotEqual(0, LibraryReportValidation.FindColumnNoFromColumnCaption('Withdraw'), '');
    end;

    [Test]
    [HandlerFunctions('GLCustLedgerRecoRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RunReportGLCustLedgerRecoWithoutError()
    begin
        // [SCENARIO 455845] Run Report with no error message.
        Initialize();


        // [VERIFY] Run report and save file in pdf successfully in handler page.
        REPORT.Run(REPORT::"GL/Cust Ledger Reconciliation");
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreateVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Insert();
        exit(Vendor."No.");
    end;

    local procedure CreatePaymentHeader(): Code[20]
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        PaymentHeader."No." := LibraryUTUtility.GetNewCode();
        PaymentHeader."Account Type" := PaymentHeader."Account Type"::"Bank Account";
        PaymentHeader.Insert();
        exit(PaymentHeader."No.");
    end;

    local procedure CreatePaymentLine(var PaymentLine: Record "Payment Line FR"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; CurrencyCode: Code[10]; PaymentAddressCode: Code[10])
    begin
        PaymentLine."No." := CreatePaymentHeader();
        PaymentLine."Account Type" := AccountType;
        PaymentLine."Account No." := AccountNo;
        PaymentLine."Currency Code" := CurrencyCode;
        PaymentLine.Marked := true;
        PaymentLine."Payment Address Code" := PaymentAddressCode;
        PaymentLine."Applies-to ID" := LibraryUTUtility.GetNewCode10();
        PaymentLine.Insert();
    end;

    local procedure CreatePaymentLineAndRunDraftRecapitulationReport(VendorNo: Code[20])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Vendor, VendorNo, CreateCurrency(), '');  // Blank for Payment Address code.
        PaymentLine.SetRange("No.", PaymentLine."No.");

        // Exercise.
        REPORT.Run(REPORT::"Draft recapitulation FR", true, false, PaymentLine);  // TRUE for ReqWindow and FALSE for SystemPrinter.    
    end;

    local procedure CreatePaymentLineAndRunWithdrawRecapitulationReport(CustomerNo: Code[20])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create Payment Line.
        CreatePaymentLine(PaymentLine, PaymentLine."Account Type"::Customer, CustomerNo, CreateCurrency(), '');  // Blank for Payment Address code.
        PaymentLine.SetRange("No.", PaymentLine."No.");

        // Exercise.
        REPORT.Run(REPORT::"Withdraw recapitulation FR", true, false, PaymentLine);  // TRUE for ReqWindow and FALSE for SystemPrinter.    
    end;

    local procedure CreatePaymentLineAndRunPaymentReport(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; CurrencyCode: Code[10]; ReportID: Integer)
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Setup: Create Payment Line.
        CreatePaymentLine(PaymentLine, AccountType, AccountNo, CurrencyCode, '');  // Blank for Payment Address code.
        LibraryVariableStorage.Enqueue(PaymentLine."No.");  // Enqueue for BillRequestpageHandler and DraftRequestPageHandler.

        // Exercise.
        REPORT.Run(ReportID);
    end;

    local procedure CreateCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        Currency.Code := LibraryUTUtility.GetNewCode10();
        Currency.Insert();
        exit(Currency.Code);
    end;

    procedure VerifyFileNotEmpty(FileName: Text): Boolean
    var
        File: File;
    begin
        // The parameter FileName should contain the full File Name including path.
        if FileName = '' then
            exit(false);
        if File.Open(FileName) then
            if File.Len > 0 then
                exit(true);
        exit(false);
    end;

    local procedure VerifyValuesOnXML(Caption: Text[50]; Value: Variant)
    begin
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(Caption, Value);
    end;

    local procedure FomatFileName(ReportCaption: Text) ReportFileName: Text
    begin
        ReportFileName := DelChr(ReportCaption, '=', '/') + '.pdf'
    end;

    [RequestPageHandler]
    procedure GLCustLedgerReconciliationRequestPageHandler(var GLCustLedgerReconciliation: TestRequestPage "GL/Cust Ledger Reconciliation")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        GLCustLedgerReconciliation.Customer.SetFilter("No.", No);
        GLCustLedgerReconciliation.Customer.SetFilter("Date Filter", Format(0D));
        GLCustLedgerReconciliation.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure GLVendLedgerReconciliationRequestPageHandler(var GLVendLedgerReconciliation: TestRequestPage "GL/Vend Ledger Reconciliation")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        GLVendLedgerReconciliation.Vendor.SetFilter("No.", No);
        GLVendLedgerReconciliation.Vendor.SetFilter("Date Filter", Format(0D));
        GLVendLedgerReconciliation.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure PaymentListRequestPageHandler(var PaymentList: TestRequestPage "Payment List FR")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        PaymentList."Payment Line".SetFilter("No.", No);
        PaymentList.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure BillRequestpageHandler(var Bill: TestRequestPage "Bill FR")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        Bill."Payment Line".SetFilter("No.", No);
        Bill.IssueDate.SetValue(0D);
        Bill.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure BillBlankCurrencyRequestpageHandler(var Bill: TestRequestPage "Bill FR")
    var
        No: Variant;
        FileName: Variant;
    begin
        LibraryVariableStorage.Dequeue(FileName);
        LibraryVariableStorage.Dequeue(No);
        Bill."Payment Line".SetFilter("No.", No);
        Bill.IssueDate.SetValue(0D);
        Bill.SaveAsPdf(FileName);
    end;

    [RequestPageHandler]
    procedure DraftRequestPageHandler(var Draft: TestRequestPage "Draft FR")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        Draft.IssueDate.SetValue(0D);  // Issue date
        Draft."Payment Line".SetFilter("No.", No);
        Draft.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure DraftBlankCurrencyRequestPageHandler(var Draft: TestRequestPage "Draft FR")
    var
        No: Variant;
        FileName: Variant;
    begin
        LibraryVariableStorage.Dequeue(FileName);
        LibraryVariableStorage.Dequeue(No);
        Draft.IssueDate.SetValue(0D);  // Issue date
        Draft."Payment Line".SetFilter("No.", No);
        Draft.SaveAsPdf(FileName);
    end;

    [RequestPageHandler]
    procedure DraftNoticeRequestPageHandler(var DraftNotice: TestRequestPage "Draft notice FR")
    begin
        DraftNotice.NumberOfCopies.SetValue(LibraryRandom.RandIntInRange(1, 10));
        DraftNotice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure DraftNoticeToExcelRequestPageHandler(var DraftNotice: TestRequestPage "Draft notice FR")
    begin
        DraftNotice.SaveAsExcel(LibraryReportValidation.GetFileName());
    end;

    [RequestPageHandler]
    procedure DraftRecapitulationRequestPageHandler(var DraftRecapitulation: TestRequestPage "Draft recapitulation FR")
    begin
        DraftRecapitulation.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure DraftRecapitulationToExcelRequestPageHandler(var DraftRecapitulation: TestRequestPage "Draft recapitulation FR")
    begin
        DraftRecapitulation.SaveAsExcel(LibraryReportValidation.GetFileName());
    end;

    [RequestPageHandler]
    procedure WithdrawNoticeRequestPageHandler(var WithdrawNotice: TestRequestPage "Withdraw notice FR")
    begin
        WithdrawNotice.NumberOfCopies.SetValue(LibraryRandom.RandIntInRange(1, 10));
        WithdrawNotice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure WithdrawNoticeToExcelRequestPageHandler(var WithdrawNotice: TestRequestPage "Withdraw notice FR")
    begin
        WithdrawNotice.SaveAsExcel(LibraryReportValidation.GetFileName());
    end;

    [RequestPageHandler]
    procedure WithdrawRecapitulationRequestPageHandler(var WithdrawRecapitulation: TestRequestPage "Withdraw recapitulation FR")
    begin
        WithdrawRecapitulation.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure WithdrawRecapitulationToExcelRequestPageHandler(var WithdrawRecapitulation: TestRequestPage "Withdraw recapitulation FR")
    begin
        WithdrawRecapitulation.SaveAsExcel(LibraryReportValidation.GetFileName());
    end;

    [RequestPageHandler]
    procedure RemittanceRequestPageHandler(var Remittance: TestRequestPage "Remittance FR")
    begin
        Remittance.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RemittanceToExcelRequestPageHandler(var Remittance: TestRequestPage "Remittance FR")
    begin
        Remittance.SaveAsExcel(LibraryReportValidation.GetFileName());
    end;

    [RequestPageHandler]
    procedure GLCustLedgerRecoRequestPageHandler(var GLCustLedgerReconciliation: TestRequestPage "GL/Cust Ledger Reconciliation")
    begin
        GLCustLedgerReconciliation.Customer.SetFilter("Date Filter",
          StrSubstNo('%1..%2', CalcDate('<-1Y>', WorkDate()), CalcDate('<+1Y>', WorkDate())));
        GLCustLedgerReconciliation.SaveAsPdf(FomatFileName(GLCustLedgerReconciliation.Caption));
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

