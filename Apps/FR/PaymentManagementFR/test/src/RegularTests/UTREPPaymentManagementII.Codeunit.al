// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Currency;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 144035 "UT REP Payment Management II"
{
    // 1 - 29. Purpose of test is to validate error for Report 10882 (Transfer), 10881 (Withdraw), 10880 (ETEBAC Files), 10862 (Suggest Vendor Payments FR), 10864 (Suggest Customer Payments) and 10872 (Duplicate parameter).
    // 30.     Purpose of test is to validate error for Report 10873 (Archive Payment Slips).
    // 31.     Purpose of test is to validate OnAfterGetRecord of Report 10872 (Duplicate Parameter).
    // 
    // Covers Test Cases for WI - 344968
    // ----------------------------------------------------------------------------------------------------------------------
    // Test Function Name
    // ----------------------------------------------------------------------------------------------------------------------
    // OnAfterGetRecordPmtHdrTransferError, OnAfterGetRecordPmtHdrWithdrawError, OnAfterGetRecordPmtHdrETEBACFilesError
    // OnAfterGetRecordPmtHdrAgencyCodeTransferError, OnAfterGetRecordPmtHdrBankBranchNoTransferError
    // OnAfterGetRecordPmtHdrBankAccountNoTransferError, OnAfterGetRecordPmtHdrCurrencyCodeTransferError
    // OnAfterGetRecordPmtHdrAgencyCodeWithdrawError, OnAfterGetRecordPmtHdrBankBranchNoWithdrawError
    // OnAfterGetRecordPmtHdrBankAccountNoWithdrawError, OnAfterGetRecordPmtHdrCurrencyCodeWithdrawError
    // OnAfterGetRecordPmtHdrAgencyCodeETEBACFilesError, OnAfterGetRecordPmtHdrBankBranchNoETEBACFilesError
    // OnAfterGetRecordPmtHdrBankAccountNoETEBACFilesError, OnAfterGetRecordPaymentLineTransferError
    // OnAfterGetRecordPaymentLineWithdrawError, OnAfterGetRecordPaymentLineETEBACFilesError
    // OnAfterGetRecordPmtLineBankBranchNoTransferError, OnAfterGetRecordPmtLineBankBranchNoWithdrawError
    // OnAfterGetRecordPmtLineBankAccountNoWithdrawError, OnAfterGetRecordPmtLineBankAccountNoTransferError
    // OnAfterGetRecordPmtLineBankBranchNoETEBACFilesError, OnAfterGetRecordPmtLineBankAccountNoETEBACFilesError
    // OnPreDataItemVendPmtDateSuggestVendPmtFRError, OnPreDataItemVendPostingDateSuggestVendPmtFRError
    // OnPreDataItemVendPmtDateSuggestCustPmtError, OnPreDataItemVendPostingDateSuggestCustPmtError
    // OnPreDataItemPmtClassDuplParameterError, OnAfterGetRecordPmtClassDuplParameterError
    // OnAfterGetRecordPmtClassNewNameDuplParameterError, OnPostReportArchivePaymentSlips
    // 
    // Covers Test Cases for WI - 345175
    // ----------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                        TFS ID
    // ----------------------------------------------------------------------------------------------------------------------
    // OnAfterGetRecordPaymentClassDuplicateParameter                                                            169524

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
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        ArchiveMsg: Label 'There is no Payment Header to archive.';
        DialogCapLbl: Label 'Dialog';
        ValueMatchMsg: Label 'Value must be same.';

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrWithdrawError()
    begin
        // Purpose of test is to validate Payment Header - OnAfterGetRecord of Report 10881 (Withdraw).
        // Verify actual error: "The RIB of the company's bank account is incorrect. Please verify before continuing."
        PaymentHeaderWithRIBCheckedFalse(REPORT::"Withdraw FR");
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrETEBACFilesError()
    begin
        // Purpose of test is to validate Payment Header - OnAfterGetRecord of Report 10880 (ETEBAC Files).
        // Verify actual error: "The RIB of the company's bank account is incorrect. Please verify before continuing."
        PaymentHeaderWithRIBCheckedFalse(REPORT::"ETEBAC Files FR");
    end;

    local procedure PaymentHeaderWithRIBCheckedFalse(ReportID: Integer)
    begin
        // Setup.
        Initialize();

        CreatePaymentHeader(false);  // RIBChecked as false.

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify.
        Assert.ExpectedErrorCode(DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrAgencyCodeWithdrawError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Agency Code for Report 10881 (Withdraw).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"Withdraw FR", PaymentHeader.FieldNo("Agency Code"), LibraryUTUtility.GetNewCode10())
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrBankBranchNoWithdrawError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Bank Branch No for Report 10881 (Withdraw).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"Withdraw FR", PaymentHeader.FieldNo("Bank Branch No."), LibraryUTUtility.GetNewCode10())
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrBankAccountNoWithdrawError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Bank Account No for Report 10881 (Withdraw).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"Withdraw FR", PaymentHeader.FieldNo("Bank Account No."), LibraryUTUtility.GetNewCode());
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrCurrencyCodeWithdrawError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Currency Code for Report 10881 (Withdraw).
        // Verify actual error: "You can only use currency code EUR."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"Withdraw FR", PaymentHeader.FieldNo("Currency Code"), CreateCurrencyExchangeRate());
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrAgencyCodeETEBACFilesError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Agency Code for Report 10880 (ETEBAC Files).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"ETEBAC Files FR", PaymentHeader.FieldNo("Agency Code"), LibraryUTUtility.GetNewCode10());
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrBankBranchNoETEBACFilesError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Bank Branch No for Report 10880 (ETEBAC Files).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"ETEBAC Files FR", PaymentHeader.FieldNo("Bank Branch No."), LibraryUTUtility.GetNewCode10());
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtHdrBankAccountNoETEBACFilesError()
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Purpose of test is to validate error of Bank Account No for Report 10880 (ETEBAC Files).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        PaymentHeaderWithRIBCheckedTrue(REPORT::"ETEBAC Files FR", PaymentHeader.FieldNo("Bank Account No."), LibraryUTUtility.GetNewCode());
    end;

    local procedure PaymentHeaderWithRIBCheckedTrue(ReportID: Integer; FieldNo: Integer; FieldValue: Code[20])
    begin
        // Setup.
        Initialize();

        UpdatePaymentHeader(CreatePaymentHeader(true), FieldNo, FieldValue);  // RIBChecked as true.

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify.
        Assert.ExpectedErrorCode(DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineWithdrawError()
    begin
        // Purpose of test is to validate Payment Line - OnAfterGetRecord of Report 10881 (Withdraw).
        // Verify actual error: "The RIB of the company's bank account is incorrect. Please verify before continuing."
        CreatePaymentLineAndRunReport(REPORT::"Withdraw FR", LibraryUTUtility.GetNewCode());
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentLineETEBACFilesError()
    begin
        // Purpose of test is to validate Payment Line - OnAfterGetRecord of Report 10880 (ETEBAC Files).
        // Verify actual error: "The RIB of the company's bank account is incorrect. Please verify before continuing."
        CreatePaymentLineAndRunReport(REPORT::"ETEBAC Files FR", CreateCustomer());
    end;

    local procedure CreatePaymentLineAndRunReport(ReportID: Integer; FieldValue: Code[20])
    begin
        // Setup.
        Initialize();

        CreatePaymentLine(FieldValue);

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify.
        Assert.ExpectedErrorCode(DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBankBranchNoWithdrawError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of test is to validate error of Bank Branch No for Report 10881 (Withdraw).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        CreateAndUpdatePaymentLine(PaymentLine.FieldNo("Bank Branch No."), REPORT::"Withdraw FR");
    end;

    [Test]
    [HandlerFunctions('WithdrawRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBankAccountNoWithdrawError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of test is to validate error of Bank Account No for Report 10881 (Withdraw).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        CreateAndUpdatePaymentLine(PaymentLine.FieldNo("Bank Account No."), REPORT::"Withdraw FR");
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBankBranchNoETEBACFilesError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of test is to validate error of Bank Account No for Report 10880 (ETEBAC Files).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        CreateAndUpdatePaymentLine(PaymentLine.FieldNo("Bank Account No."), REPORT::"ETEBAC Files FR");
    end;

    [Test]
    [HandlerFunctions('ETEBACFilesRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtLineBankAccountNoETEBACFilesError()
    var
        PaymentLine: Record "Payment Line FR";
    begin
        // Purpose of test is to validate error of Bank Branch No for Report 10880 (ETEBAC Files).
        // Verify actual error: "Bank Account No. is too long. Please verify before continuing."
        CreateAndUpdatePaymentLine(PaymentLine.FieldNo("Bank Branch No."), REPORT::"ETEBAC Files FR");
    end;

    local procedure CreateAndUpdatePaymentLine(FieldNo: Integer; ReportID: Integer)
    begin
        // Setup.
        Initialize();

        UpdatePaymentLine(CreatePaymentLine(CreateCustomer()), FieldNo, LibraryUTUtility.GetNewCode());

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify.
        Assert.ExpectedErrorCode(DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('SuggestVendorPaymentsFRRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDataItemVendPmtDateSuggestVendPmtFRError()
    begin
        // Purpose of test is to validate error of Payment Date for Report 10862 (Suggest Vendor Payments FR).
        // Verify actual error: "Please enter the last payment date."
        RunMiscellaneousReportsAndVerifyError(0D, REPORT::"Suggest Vend. Payments", DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('SuggestVendorPaymentsFRRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDataItemVendPostingDateSuggestVendPmtFRError()
    begin
        // Purpose of test is to validate error of Posting Date for Report 10862 (Suggest Vendor Payments FR).
        // Verify actual error: "Please enter the posting date."
        RunMiscellaneousReportsAndVerifyError(WorkDate(), REPORT::"Suggest Vend. Payments", DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('SuggestCustomerPaymentsRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDataItemVendPmtDateSuggestCustPmtError()
    begin
        // Purpose of test is to validate error of Payment Date for Report 10864 (Suggest Customer Payments).
        // Verify actual error: "Please enter the last payment date."
        RunMiscellaneousReportsAndVerifyError(0D, REPORT::"Suggest Cust. Payments", DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('SuggestCustomerPaymentsRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDataItemVendPostingDateSuggestCustPmtError()
    begin
        // Purpose of test is to validate error of Posting Date for Report 10864 (Suggest Customer Payments).
        // Verify actual error: "Please enter the posting date."
        RunMiscellaneousReportsAndVerifyError(WorkDate(), REPORT::"Suggest Cust. Payments", DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('DuplicateParameterRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPreDataItemPmtClassDuplParameterError()
    begin
        // Purpose of test is to validate error of New Name for Report 10872 (Duplicate parameter).
        // Verify actual error: "You must precise a new name."
        RunMiscellaneousReportsAndVerifyError('', REPORT::"Duplicate parameter FR", DialogCapLbl);
    end;

    [Test]
    [HandlerFunctions('DuplicateParameterRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtClassDuplParameterError()
    begin
        // Purpose of test is to validate error of New Name for Report 10872 (Duplicate parameter).
        // Verify actual error: "The Payment Class already exists. Identification fields and values.'"
        RunMiscellaneousReportsAndVerifyError(LibraryUTUtility.GetNewCode(), REPORT::"Duplicate parameter FR", 'DB:RecordExists');
    end;

    [Test]
    [HandlerFunctions('DuplicateParameterRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPmtClassNewNameDuplParameterError()
    begin
        // Purpose of test is to validate error of New Name for Report 10872 (Duplicate parameter).
        // Verify actual error: "The name you have put does already exist. Please put an other name."
        RunMiscellaneousReportsAndVerifyError(CreatePaymentClass(), REPORT::"Duplicate parameter FR", DialogCapLbl);
    end;

    local procedure RunMiscellaneousReportsAndVerifyError(InputValue: Variant; ReportID: Integer; ErrorCode: Text[30])
    begin
        // Setup.
        Initialize();


        // Enqueue required for DuplicateParameterRequestPageHandler, SuggestVendorPaymentsFRRequestPageHandler and SuggestCustomerPaymentsRequestPageHandler.
        LibraryVariableStorage.Enqueue(InputValue);

        // Exercise.
        asserterror REPORT.Run(ReportID);

        // Verify.
        Assert.ExpectedErrorCode(ErrorCode);
    end;

    [Test]
    [HandlerFunctions('ArchivePaymentSlipsRequestPageHandler,MessageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnPostReportArchivePaymentSlips()
    begin
        // Purpose of test is to validate error for Report 10873 (Archive Payment Slips).
        // Setup.
        Initialize();

        LibraryVariableStorage.Enqueue(CreatePaymentHeader(true));  // Enqueue Payment Header No for ArchivePaymentSlipsRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Archive Payment Slips FR");

        // Verify: Verification is covered in MessageHandler.
    end;

    [Test]
    [HandlerFunctions('DuplicateParameterRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordPaymentClassDuplicateParameter()
    var
        PaymentClass: TestPage "Payment Class FR";
    begin
        // Purpose of test is to validate OnAfterGetRecord of Report 10872 (Duplicate Parameter).
        // Setup: Create Payment Class and assign value for duplicate class.
        Initialize();

        PaymentClass.OpenEdit();
        PaymentClass.FILTER.SetFilter(Code, CreatePaymentClass());
        LibraryVariableStorage.Enqueue(CopyStr(PaymentClass.Code.Value, 1, 4));  // Enqueue required for DuplicateParameterRequestPageHandler.

        // Exercise: Run Duplicate Parameter batch job report.
        PaymentClass.DuplicateParameter.Invoke();

        // Verify: Verify duplicate class with new name.
        PaymentClass.FILTER.SetFilter(Code, CopyStr(PaymentClass.Code.Value, 1, 4));
        PaymentClass.Code.AssertEquals(CopyStr(PaymentClass.Code.Value, 1, 4));
        PaymentClass.Close();
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure CreateCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        Currency.Code := LibraryUTUtility.GetNewCode10();
        Currency.Insert();
        exit(Currency.Code);
    end;

    local procedure CreateCurrencyExchangeRate(): Code[10]
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyExchangeRate."Currency Code" := CreateCurrency();
        CurrencyExchangeRate."Exchange Rate Amount" := LibraryRandom.RandDec(10, 2);
        CurrencyExchangeRate."Relational Exch. Rate Amount" := LibraryRandom.RandDec(10, 2);
        CurrencyExchangeRate.Insert();
        exit(CurrencyExchangeRate."Currency Code");
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreatePaymentClass(): Text[30]
    var
        PaymentClass: Record "Payment Class FR";
    begin
        PaymentClass.Code := LibraryUTUtility.GetNewCode();
        PaymentClass.Insert();
        exit(PaymentClass.Code);
    end;

    local procedure CreatePaymentHeader(RIBChecked: Boolean): Code[20]
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        PaymentHeader."No." := LibraryUTUtility.GetNewCode();
        PaymentHeader."Payment Class" := LibraryUTUtility.GetNewCode();
        PaymentHeader."Account Type" := PaymentHeader."Account Type"::"Bank Account";
        PaymentHeader."National Issuer No." := Format(CopyStr(LibraryUTUtility.GetNewCode10(), 6));  // National Issuer No should be less than 6 characters.
        PaymentHeader."RIB Checked" := RIBChecked;
        PaymentHeader.Insert();
        exit(PaymentHeader."No.");
    end;

    local procedure CreatePaymentLine(AccountNo: Code[20]): Code[20]
    var
        PaymentLine: Record "Payment Line FR";
    begin
        PaymentLine."No." := CreatePaymentHeader(true);  // RIBChecked as true.
        PaymentLine."Account Type" := PaymentLine."Account Type"::"Bank Account";
        PaymentLine."Account No." := AccountNo;
        PaymentLine."Bank Account No." := LibraryUTUtility.GetNewCode10();
        PaymentLine.Insert();
        exit(PaymentLine."No.");
    end;

    local procedure UpdatePaymentHeader(No: Code[20]; FieldNo: Integer; FieldValue: Code[20])
    var
        PaymentHeader: Record "Payment Header FR";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        PaymentHeader.Get(No);
        RecRef.GetTable(PaymentHeader);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(FieldValue);
        RecRef.SetTable(PaymentHeader);
        PaymentHeader.Modify();
    end;

    local procedure UpdatePaymentLine(No: Code[20]; FieldNo: Integer; FieldValue: Code[20])
    var
        PaymentLine: Record "Payment Line FR";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        PaymentLine.SetRange("No.", No);
        PaymentLine.FindFirst();
        RecRef.GetTable(PaymentLine);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(FieldValue);
        RecRef.SetTable(PaymentLine);
        PaymentLine.Modify();
    end;

    [RequestPageHandler]
    procedure ArchivePaymentSlipsRequestPageHandler(var ArchivePaymentSlips: TestRequestPage "Archive Payment Slips FR")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        ArchivePaymentSlips."Payment Header".SetFilter("No.", No);
        ArchivePaymentSlips.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure DuplicateParameterRequestPageHandler(var Duplicateparameter: TestRequestPage "Duplicate parameter FR")
    var
        NewName: Variant;
    begin
        LibraryVariableStorage.Dequeue(NewName);
        Duplicateparameter.New_Name.SetValue(NewName);
        Duplicateparameter.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure ETEBACFilesRequestPageHandler(var ETEBACFiles: TestRequestPage "ETEBAC Files FR")
    begin
        ETEBACFiles.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(Message, StrSubstNo(ArchiveMsg), ValueMatchMsg);
    end;

    [RequestPageHandler]
    procedure SuggestCustomerPaymentsRequestPageHandler(var SuggestCustomerPayments: TestRequestPage "Suggest Cust. Payments")
    var
        LastPaymentDate: Variant;
    begin
        LibraryVariableStorage.Dequeue(LastPaymentDate);
        SuggestCustomerPayments.LastPaymentDate.SetValue(LastPaymentDate);
        SuggestCustomerPayments.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure SuggestVendorPaymentsFRRequestPageHandler(var SuggestVendorPaymentsFR: TestRequestPage "Suggest Vend. Payments")
    var
        LastPaymentDate: Variant;
    begin
        LibraryVariableStorage.Dequeue(LastPaymentDate);
        SuggestVendorPaymentsFR.LastPaymentDate.SetValue(LastPaymentDate);
        SuggestVendorPaymentsFR.AvailableAmountLCY.SetValue(LibraryRandom.RandDec(10, 2));
        SuggestVendorPaymentsFR.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure WithdrawRequestPageHandler(var Withdraw: TestRequestPage "Withdraw FR")
    begin
        Withdraw.OK().Invoke();
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

