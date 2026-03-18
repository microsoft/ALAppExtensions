// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.TestLibraries.Utilities;

codeunit 144029 "SEPA.08 DD Functional Test"
{
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
        LibraryERM: Codeunit "Library - ERM";
        LibraryFRLocalization: Codeunit "Library - Localization FR";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXMLRead: Codeunit "Library - XML Read";
        SEPA_PartnerType: Option ,Company,Person;
        UnexpectedEmptyNodeErr: Label 'Unexpected empty value for node <%1> of subtree <%2>.', Comment = '%1 = Node Name, %2 = Subtree Root Name';
        OneToManyNotAllowedErr: Label 'You cannot export a SEPA customer payment that is applied to multiple documents.';
        ErrorsExistErr: Label 'The file export has one or more errors. For each of the lines to be exported, resolve any errors that are displayed in the File Export Errors FactBox.';
        MissingMandateErr: Label 'Mandate ID must have a value in the currently selected record.';
        UnappliedLinesNotAllowedErr: Label 'Payment slip line %1 must be applied to a customer invoice.', Comment = '%1 = No.';
        BankAccErr: Label 'You must use customer bank account, %1, which you specified in the selected direct debit mandate.', Comment = '%1 = Code';
        AccTypeErr: Label 'Only customer transactions are allowed.';
        PartnerTypeErr: Label 'The customer''s Partner Type, Company, must be equal to the Partner Type, Person, specified in the collection.';

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler,SuggestCustPaymentsReqPageHandler')]
    procedure SuggestCustPayments()
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        PaymentHeader: Record "Payment Header FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        SuggestCustomerPayments: Report "Suggest Cust. Payments";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentHeader(PaymentHeader, SEPA_PartnerType::Company);
        CreateDirectDebitMandate(SEPADirectDebitMandate, Customer."No.", '');
        CreateCustomerLedgerEntry(CustLedgerEntry, Customer."No.", SEPADirectDebitMandate.ID);
        CreateCustomerLedgerEntry(CustLedgerEntry, Customer."No.", '');

        // Exercise.
        SuggestCustomerPayments.SetGenPayLine(PaymentHeader);
        Customer.SetRange("No.", Customer."No.");
        SuggestCustomerPayments.SetTableView(Customer);
        SuggestCustomerPayments.RunModal();

        // Verify.
        VerifyPaymentLines(PaymentHeader, Customer);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler,SuggestCustPaymentsReqPageHandler')]
    procedure SuggestCustPaymentsDiffPartnerType()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        Customer1: Record Customer;
        SuggestCustomerPayments: Report "Suggest Cust. Payments";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreateCustomerWithInvoice(Customer1, CustLedgerEntry, SEPA_PartnerType::Person);
        CreatePaymentHeader(PaymentHeader, SEPA_PartnerType::Person);

        // Exercise.
        SuggestCustomerPayments.SetGenPayLine(PaymentHeader);
        Customer.SetFilter("No.", '%1|%2', Customer."No.", Customer1."No.");
        Customer.SetRange("Partner Type", Customer."Partner Type");
        Commit();
        SuggestCustomerPayments.SetTableView(Customer);
        SuggestCustomerPayments.RunModal();

        // Verify.
        VerifyPaymentLines(PaymentHeader, Customer);
        PaymentHeader.Find();
        PaymentHeader.TestField("Partner Type", SEPA_PartnerType::Company);
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        PaymentLine.SetRange("Account Type", PaymentLine."Account Type"::Customer);
        PaymentLine.SetRange("Account No.", Customer1."No.");
        Assert.IsTrue(PaymentLine.IsEmpty, 'No payment lines should be created for customer ' + Customer1."No.");
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineWithoutApplication()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);

        // Exercise.
        asserterror ExportSEPAFile(PaymentHeader);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.",
          PaymentLine."Line No.", StrSubstNo(UnappliedLinesNotAllowedErr, PaymentLine."Line No."), 1);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineWithAppliesToDocNo()
    var
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SEPAFilePath: Text;
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Modify();

        // Exercise.
        SEPAFilePath := ExportSEPAFile(PaymentHeader);
        Commit();
        LibraryXMLRead.Initialize(SEPAFilePath);

        // Verify.
        VerifySEPADDXmlFile(PaymentHeader, PaymentLine, GetMessageToRecipient(CustLedgerEntry));
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 1);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineWithAppliesToID()
    var
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SEPAFilePath: Text;
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine.Validate("Applies-to ID", PaymentLine."Document No.");
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Modify();
        CustLedgerEntry."Applies-to ID" := PaymentLine."Document No.";
        CustLedgerEntry.Modify();

        // Exercise.
        SEPAFilePath := ExportSEPAFile(PaymentHeader);
        Commit();
        LibraryXMLRead.Initialize(SEPAFilePath);

        // Verify.
        VerifySEPADDXmlFile(PaymentHeader, PaymentLine, GetMessageToRecipient(CustLedgerEntry));
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 1);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineOneToManyNotAllowed()
    var
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine."Applies-to ID" := PaymentLine."Document No.";
        PaymentLine.Modify();
        CustLedgerEntry."Applies-to ID" := PaymentLine."Document No.";
        CustLedgerEntry.Modify();
        CreateCustomerLedgerEntry(CustLedgerEntry, PaymentLine."Account No.", '');
        CustLedgerEntry."Applies-to ID" := PaymentLine."Document No.";
        CustLedgerEntry.Modify();

        // Exercise.
        asserterror ExportSEPAFile(PaymentHeader);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.", OneToManyNotAllowedErr, 0);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineDiffThanInvoiceNotAllowed()
    var
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::"Credit Memo";
        CustLedgerEntry.Modify();
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        PaymentLine.Modify();

        // Exercise.
        asserterror ExportSEPAFile(PaymentHeader);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.", UnappliedLinesNotAllowedErr, 0);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportPmtLineDiffThanCustomerNotAllowed()
    var
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine.Validate("Account Type", PaymentLine."Account Type"::Vendor);
        PaymentLine.Modify();

        // Exercise.
        asserterror ExportSEPAFile(PaymentHeader);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.", AccTypeErr, 1);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ValidateBankAccCodeOnPmtLine()
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        CreateCustomerBankAccount(CustomerBankAccount, CustLedgerEntry."Customer No.");

        // Exercise.
        asserterror PaymentLine.Validate("Bank Account Code", CustomerBankAccount.Code);

        // Verify.
        Assert.ExpectedError(StrSubstNo(BankAccErr, PaymentLine."Bank Account Code"));
        VerifyCollectionWasDeleted(PaymentHeader);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ValidateMandateIdOnPmtLineWithBankAcc()
    var
        Customer: Record Customer;
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", '', SEPA_PartnerType::Company);
        CreateCustomerBankAccount(CustomerBankAccount, CustLedgerEntry."Customer No.");
        CreateDirectDebitMandate(SEPADirectDebitMandate, CustLedgerEntry."Customer No.", CustomerBankAccount.Code);

        // Exercise.
        PaymentLine.Validate("Direct Debit Mandate ID", SEPADirectDebitMandate.ID);
        PaymentLine.Modify(true);

        // Verify.
        PaymentLine.TestField("Bank Account Code", SEPADirectDebitMandate."Customer Bank Account Code");

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ValidateMandateIdOnPmtLineWithoutBankAcc()
    var
        Customer: Record Customer;
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", '', SEPA_PartnerType::Company);
        CreateCustomerBankAccount(CustomerBankAccount, CustLedgerEntry."Customer No.");
        CreateDirectDebitMandate(SEPADirectDebitMandate, CustLedgerEntry."Customer No.", CustomerBankAccount.Code);

        // Exercise.
        PaymentLine.Validate("Bank Account Code", '');
        PaymentLine.Validate("Direct Debit Mandate ID", SEPADirectDebitMandate.ID);
        PaymentLine.Modify(true);

        // Verify.
        PaymentLine.TestField("Bank Account Code", SEPADirectDebitMandate."Customer Bank Account Code");

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure CheckPmtLineExportErrors()
    var
        Customer: Record Customer;
        PaymentStep: Record "Payment Step FR";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentMgt: Codeunit "Payment Management FR";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", '', SEPA_PartnerType::Company);
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Modify();

        // Exercise.
        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::File);
        asserterror PaymentMgt.ProcessPaymentSteps(PaymentHeader, PaymentStep);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.", MissingMandateErr, 1);
        VerifyCollectionWasDeleted(PaymentHeader);
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 0);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure CheckPmtLineDeleteExportErrors()
    var
        Customer: Record Customer;
        PaymentStep: Record "Payment Step FR";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentMgt: Codeunit "Payment Management FR";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", '', SEPA_PartnerType::Company);
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Modify();

        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::File);
        asserterror PaymentMgt.ProcessPaymentSteps(PaymentHeader, PaymentStep);
        Assert.ExpectedError(ErrorsExistErr);

        // Exercise.
        PaymentLine.Delete(true);

        // Verify.
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.", MissingMandateErr, 0);
        VerifyCollectionWasDeleted(PaymentHeader);
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 0);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure CheckPmtLinePartnerTypeError()
    var
        Customer: Record Customer;
        PaymentStep: Record "Payment Step FR";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentMgt: Codeunit "Payment Management FR";
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID",
          SEPA_PartnerType::Person);
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Modify();

        // Exercise.
        PaymentStep.SetRange("Action Type", PaymentStep."Action Type"::File);
        asserterror PaymentMgt.ProcessPaymentSteps(PaymentHeader, PaymentStep);

        // Verify.
        Assert.ExpectedError(ErrorsExistErr);
        VerifyPaymentErrors(DATABASE::"Payment Header FR", PaymentHeader."No.", PaymentLine."Line No.",
          PartnerTypeErr, 1);
        VerifyCollectionWasDeleted(PaymentHeader);
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 0);

        // Clean data
        PaymentHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ReplaceClosedMandate()
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        Customer: Record Customer;
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SEPAFilePath: Text;
    begin
        // Setup.

        CreateCustomerWithInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);
        SEPADirectDebitMandate.Get(CustLedgerEntry."Direct Debit Mandate ID");
        SEPADirectDebitMandate.Validate(Closed, true);
        SEPADirectDebitMandate.Modify(true);
        Clear(SEPADirectDebitMandate);

        CreateDirectDebitMandate(SEPADirectDebitMandate, Customer."No.", Customer."Preferred Bank Account Code");
        CreatePaymentSlip(PaymentHeader, PaymentLine, Customer."No.", CustLedgerEntry."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine."Applies-to Doc. Type" := CustLedgerEntry."Document Type";
        PaymentLine."Applies-to Doc. No." := CustLedgerEntry."Document No.";
        CustLedgerEntry.CalcFields("Remaining Amount");
        PaymentLine.Validate("Credit Amount", CustLedgerEntry."Remaining Amount");
        PaymentLine.Validate("Direct Debit Mandate ID", SEPADirectDebitMandate.ID);
        PaymentLine.Modify(true);

        // Exercise.
        SEPAFilePath := ExportSEPAFile(PaymentHeader);
        Commit();
        LibraryXMLRead.Initialize(SEPAFilePath);

        // Verify.
        VerifySEPADDXmlFile(PaymentHeader, PaymentLine, GetMessageToRecipient(CustLedgerEntry));
        VerifySEPAMandate(CustLedgerEntry."Direct Debit Mandate ID", 0);
        VerifySEPAMandate(PaymentLine."Direct Debit Mandate ID", 1);
    end;

    local procedure CreateSEPABankAccount(var BankAccount: Record "Bank Account")
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate(Balance, LibraryRandom.RandIntInRange(100000, 1000000));
        BankAccount.Validate("Bank Account No.", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Bank Account No."), DATABASE::"Bank Account"));
        BankAccount.Validate("Country/Region Code", 'FR');
        BankAccount.Validate(IBAN, LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(IBAN), DATABASE::"Bank Account"));
        BankAccount.Validate("SEPA Direct Debit Exp. Format", FindSEPADDPaymentFormat());
        BankAccount.Validate("Direct Debit Msg. Nos.", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("SWIFT Code", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("SWIFT Code"), DATABASE::"Bank Account"));
        BankAccount.Validate("Creditor No.", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Creditor No."), DATABASE::"Bank Account"));
        BankAccount.Modify(true);
    end;

    [Test]
    [HandlerFunctions('PaymentClassHandler,ConfirmHandler')]
    procedure ExportSecondPmtHeaderWithoutError()
    var
        Customer: Record Customer;
        PaymentHeader: array[2] of Record "Payment Header FR";
        PaymentLine: array[2] of Record "Payment Line FR";
        CustLedgerEntry: array[2] of Record "Cust. Ledger Entry";
        SEPAFilePath: Text;
    begin
        // [SCENARIO 460340] FR local - not possible to re-create a payment file in Payment Slip 2 if an error exists in Payment Slip 1
        // [GIVEN] Create customer with 2 Invoices

        CreateCustomerWithTwoInvoice(Customer, CustLedgerEntry, SEPA_PartnerType::Company);

        // [GIVEN] Create Payment slip of first Invoice
        CreatePaymentSlip(PaymentHeader[1], PaymentLine[1], Customer."No.", CustLedgerEntry[1]."Direct Debit Mandate ID", SEPA_PartnerType::Company);

        // [GIVEN] Update credit amount on Payment Line and set Applies-to ID on Cust. Ledger Entry on first CLE entry
        PaymentLine[1].Validate("Applies-to ID", PaymentLine[1]."Document No.");
        CustLedgerEntry[1].CalcFields("Remaining Amount");
        PaymentLine[1].Validate("Credit Amount", CustLedgerEntry[1]."Remaining Amount");
        PaymentLine[1].Modify();
        CustLedgerEntry[1]."Applies-to ID" := PaymentLine[1]."Document No.";
        CustLedgerEntry[1].Modify();

        // [GIVEN] Update Posting date and Document date to get error during Generate XML file
        PaymentHeader[1].Validate("Posting Date", CalcDate('<-1D>', WorkDate()));
        PaymentHeader[1].Validate("Document Date", CalcDate('<-1D>', WorkDate()));
        PaymentHeader[1].Modify();

        // [VERIFY] Verify error will come on SEPA export file of first Cust Ledger Entry
        asserterror ExportSEPAFile(PaymentHeader[1]);

        // [GIVEN] Create Second Payment Slip and update Applies to id and Credit amount.
        CreatePaymentSlip(PaymentHeader[2], PaymentLine[2], Customer."No.", CustLedgerEntry[2]."Direct Debit Mandate ID", SEPA_PartnerType::Company);
        PaymentLine[2].Validate("Applies-to ID", PaymentLine[2]."Document No.");
        CustLedgerEntry[2].CalcFields("Remaining Amount");
        PaymentLine[2].Validate("Credit Amount", CustLedgerEntry[2]."Remaining Amount");
        PaymentLine[2].Modify();
        CustLedgerEntry[2]."Applies-to ID" := PaymentLine[2]."Document No.";
        CustLedgerEntry[2].Modify();

        // [GIVEN] Export SEPA file of second payment slip
        SEPAFilePath := ExportSEPAFile(PaymentHeader[2]);
        Commit();
        LibraryXMLRead.Initialize(SEPAFilePath);

        // [VERIFY] Verify file exported successfully
        VerifySEPADDXmlFile(PaymentHeader[2], PaymentLine[2], GetMessageToRecipient(CustLedgerEntry[2]));
        VerifySEPAMandate(CustLedgerEntry[2]."Direct Debit Mandate ID", 1);

        // [GIVEN] Clean data
        PaymentHeader[1].Delete(true);
        PaymentHeader[2].Delete(true);
    end;

    local procedure CreatePaymentClass(): Text[30]
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
    begin
        LibraryFRLocalization.CreatePaymentClass(PaymentClass);
        PaymentClass.Validate(Name, '');
        PaymentClass.Validate("Header No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        PaymentClass.Validate(Enable, true);
        PaymentClass.Validate(Suggestions, PaymentClass.Suggestions::Customer);
        PaymentClass.Validate("SEPA Transfer Type", PaymentClass."SEPA Transfer Type"::"Direct Debit");
        PaymentClass.Modify(true);
        LibraryFRLocalization.CreatePaymentStatus(PaymentStatus, PaymentClass.Code);
        LibraryFRLocalization.CreatePaymentStep(PaymentStep, PaymentClass.Code);
        PaymentStep.Name := 'Export File';
        PaymentStep."Action Type" := PaymentStep."Action Type"::File;
        PaymentStep."Export Type" := PaymentStep."Export Type"::XMLport;
        PaymentStep."Export No." := XMLPORT::"SEPA DD pain.008.001.08";
        PaymentStep.Modify();
        exit(PaymentClass.Code);
    end;

    local procedure CreatePaymentHeader(var PaymentHeader: Record "Payment Header FR"; SEPAPartnerType: Option)
    var
        BankAccount: Record "Bank Account";
        PaymentClassCode: Code[30];
    begin
        PaymentClassCode := CreatePaymentClass();
        LibraryVariableStorage.Enqueue(PaymentClassCode);
        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        PaymentHeader.Validate("Account Type", PaymentHeader."Account Type"::"Bank Account");
        CreateSEPABankAccount(BankAccount);
        PaymentHeader.Validate("Account No.", BankAccount."No.");
        PaymentHeader.Validate("Partner Type", SEPAPartnerType);
        PaymentHeader.Modify();
    end;

    local procedure CreatePaymentSlip(var PaymentHeader: Record "Payment Header FR"; var PaymentLine: Record "Payment Line FR"; CustomerNo: Code[20]; MandateID: Code[35]; SEPAPartnerType: Option)
    begin
        CreatePaymentHeader(PaymentHeader, SEPAPartnerType);
        LibraryFRLocalization.CreatePaymentLine(PaymentLine, PaymentHeader."No.");

        PaymentLine.Validate("Account Type", PaymentLine."Account Type"::Customer);
        PaymentLine.Validate("Account No.", CustomerNo);
        PaymentLine.Validate("Credit Amount", LibraryRandom.RandDec(100, 2));
        PaymentLine.Validate("Direct Debit Mandate ID", MandateID);
        PaymentLine.Modify(true);
    end;

    local procedure CreateCustomerWithInvoice(var Customer: Record Customer; var CustLedgerEntry: Record "Cust. Ledger Entry"; SEPAPartnerType: Option)
    var
        CustomerBankAccount: Record "Customer Bank Account";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCustomerAddress(Customer);
        CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        CreateDirectDebitMandate(SEPADirectDebitMandate, Customer."No.", CustomerBankAccount.Code);
        CreateCustomerLedgerEntry(CustLedgerEntry, Customer."No.", SEPADirectDebitMandate.ID);
        Customer.Validate("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.Validate("Partner Type", SEPAPartnerType);
        Customer.Modify(true);
    end;

    local procedure ExportSEPAFile(var PaymentHeader: Record "Payment Header FR") ExportedFilePath: Text
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
        OutStr: OutStream;
        File: File;
    begin
        DirectDebitCollection.CreateRecord(PaymentHeader."No.", PaymentHeader."Account No.", PaymentHeader."Partner Type");
        DirectDebitCollection."Source Table ID" := DATABASE::"Payment Header FR";
        DirectDebitCollection.Modify();
        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", DirectDebitCollection."No.");
        ExportedFilePath := TemporaryPath + LibraryUtility.GenerateGUID() + '.xml';
        File.Create(ExportedFilePath);
        File.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPORT::"SEPA DD pain.008.001.08", OutStr, DirectDebitCollectionEntry);
        File.Close();
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account"; CustomerNo: Code[20])
    begin
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, CustomerNo);
        CustomerBankAccount.IBAN := LibraryUtility.GenerateGUID();
        CustomerBankAccount."SWIFT Code" := LibraryUtility.GenerateGUID();
        CustomerBankAccount.Modify();
    end;

    local procedure CreateCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; CustomerNo: Code[20]; SEPADirectDebitMandateID: Code[35])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer,
          CustomerNo, LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Direct Debit Mandate ID" := SEPADirectDebitMandateID;
        GenJournalLine."Payment Method Code" := '';
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
        CustLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
        CustLedgerEntry.FindLast();
    end;

    local procedure CreateCustomerAddress(var Customer: Record Customer)
    begin
        Customer.Validate(Address, LibraryUtility.GenerateRandomCode(Customer.FieldNo(Address), DATABASE::Customer));
        Customer.Validate("Country/Region Code", 'FR');
        Customer.Validate(City, LibraryUtility.GenerateRandomCode(Customer.FieldNo(City), DATABASE::Customer));
        Customer.Validate("Post Code", LibraryUtility.GenerateRandomCode(Customer.FieldNo("Post Code"), DATABASE::Customer));
        Customer.Modify(true);
    end;

    local procedure CreateDirectDebitMandate(var SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate"; CustomerNo: Code[20]; CustomerBankAccountCode: Code[20])
    begin
        SEPADirectDebitMandate.Init();
        SEPADirectDebitMandate."Customer No." := CustomerNo;
        SEPADirectDebitMandate."Customer Bank Account Code" := CustomerBankAccountCode;
        SEPADirectDebitMandate."Valid From" := WorkDate();
        SEPADirectDebitMandate."Valid To" := WorkDate() + LibraryRandom.RandIntInRange(300, 600);
        SEPADirectDebitMandate."Date of Signature" := WorkDate();
        SEPADirectDebitMandate."Expected Number of Debits" := LibraryRandom.RandInt(10);
        SEPADirectDebitMandate.Insert(true);
    end;

    local procedure FindSEPADDPaymentFormat(): Code[20]
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
#pragma warning disable AA0210
        BankExportImportSetup.SetFilter("Processing XMLport ID", '%1', XMLPORT::"SEPA DD pain.008.001.08");
#pragma warning restore AA0210
        BankExportImportSetup.FindFirst();
        exit(BankExportImportSetup.Code);
    end;

    local procedure GetMessageToRecipient(CustLedgerEntry: Record "Cust. Ledger Entry"): Text
    begin
        exit(CustLedgerEntry.Description + ' ;' + CustLedgerEntry."Document No.");
    end;

    local procedure VerifySEPADDXmlFile(PaymentHeader: Record "Payment Header FR"; PaymentLine: Record "Payment Line FR"; MsgToRecipient: Text)
    begin
        VerifyXmlFileDeclarationAndVersion();
        VerifyGroupHeader(PaymentLine);
        VerifyInitiatingParty();
        VerifyPaymentInformationHeader(PaymentLine);
        VerifyCreditor(PaymentHeader, MsgToRecipient);
        VerifyDebitor(PaymentLine);
    end;

    local procedure VerifyXmlFileDeclarationAndVersion()
    begin
        LibraryXMLRead.VerifyXMLDeclaration('1.0', 'UTF-8', 'no');
        LibraryXMLRead.VerifyAttributeValue('Document', 'xmlns', 'urn:iso:std:iso:20022:tech:xsd:pain.008.001.08');
    end;

    local procedure VerifyGroupHeader(PaymentLine: Record "Payment Line FR")
    begin
        // Mandatory/required elements
        VerifyNodeExistsAndNotEmpty('GrpHdr', 'MsgId');
        VerifyNodeExistsAndNotEmpty('GrpHdr', 'CreDtTm');
        LibraryXMLRead.VerifyNodeValueInSubtree('GrpHdr', 'NbOfTxs', '1');
        LibraryXMLRead.VerifyNodeValueInSubtree('GrpHdr', 'CtrlSum', Format(PaymentLine."Credit Amount", 0, 9));
    end;

    local procedure VerifyInitiatingParty()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        VerifyCompanyNameAndPostalAddress(CompanyInformation, 'InitgPty');
        LibraryXMLRead.VerifyNodeValueInSubtree('InitgPty', 'Id', CompanyInformation."VAT Registration No.");
    end;

    local procedure VerifyCompanyNameAndPostalAddress(CompanyInformation: Record "Company Information"; SubtreeRootNodeName: Text)
    begin
        VerifyNameAndPostalAddress(
          SubtreeRootNodeName, CompanyInformation.Name, CompanyInformation.Address,
          CompanyInformation."Post Code", CompanyInformation.City, CompanyInformation."Country/Region Code");
    end;

    local procedure VerifyPaymentInformationHeader(PaymentLine: Record "Payment Line FR")
    begin
        // Mandatory elements
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'PmtMtd', 'DD'); // Hardcoded to 'TRF' by the FR SEPA standard

        // Optional element
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'BtchBookg', 'false');
        // PmtTpInf/InstrPrty removed due to BUG: 267559
        LibraryXMLRead.VerifyElementAbsenceInSubtree('PmtTpInf', 'InstrPrty');

        // Mandatory element
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'ReqdColltnDt', PaymentLine."Posting Date");
        LibraryXMLRead.VerifyNodeValueInSubtree('PmtInf', 'ChrgBr', 'SLEV'); // Hardcoded by FR SEPA standard    
    end;

    local procedure VerifyCreditor(PaymentHeader: Record "Payment Header FR"; MsgToRecipient: Text)
    var
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
    begin
        BankAccount.Get(PaymentHeader."Account No.");
        CompanyInformation.Get();
        LibraryXMLRead.VerifyNodeValueInSubtree('CdtrAcct', 'IBAN', BankAccount.IBAN);
        LibraryXMLRead.VerifyNodeValueInSubtree('CdtrAgt', 'BICFI', BankAccount."SWIFT Code");
        LibraryXMLRead.VerifyNodeValueInSubtree('Othr', 'Id', BankAccount."Creditor No.");
        LibraryXMLRead.VerifyNodeValueInSubtree('SchmeNm', 'Prtry', 'SEPA');
        LibraryXMLRead.VerifyNodeValueInSubtree('Cdtr', 'Nm', CompanyInformation.Name);
        LibraryXMLRead.VerifyNodeValue('Ustrd', MsgToRecipient);
    end;

    local procedure VerifyDebitor(PaymentLine: Record "Payment Line FR")
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        Customer.Get(PaymentLine."Account No.");
        CustomerBankAccount.Get(Customer."No.", PaymentLine."Bank Account Code");
        SEPADirectDebitMandate.Get(PaymentLine."Direct Debit Mandate ID");

        VerifyNameAndPostalAddress(
          'DrctDbtTxInf', Customer.Name, Customer.Address, Customer."Post Code", Customer.City, Customer."Country/Region Code");
        // DrctDbtTxInf/PmtTpInf removed due to BUG: 267559
        LibraryXMLRead.VerifyNodeAbsenceInSubtree('DrctDbtTxInf', 'PmtTpInf');
        LibraryXMLRead.VerifyNodeValueInSubtree('DrctDbtTxInf', 'InstdAmt', PaymentLine."Credit Amount");
        LibraryXMLRead.VerifyAttributeValueInSubtree('DrctDbtTxInf', 'InstdAmt', 'Ccy', 'EUR');
        LibraryXMLRead.VerifyNodeValueInSubtree('DrctDbtTx', 'MndtId', SEPADirectDebitMandate.ID);
        LibraryXMLRead.VerifyNodeValueInSubtree('DrctDbtTx', 'DtOfSgntr', SEPADirectDebitMandate."Date of Signature");
        LibraryXMLRead.VerifyNodeValueInSubtree('Dbtr', 'AnyBIC', CustomerBankAccount."SWIFT Code");
        LibraryXMLRead.VerifyNodeValueInSubtree('DbtrAcct', 'IBAN', CustomerBankAccount.IBAN);
        LibraryXMLRead.VerifyNodeValueInSubtree('DbtrAgt', 'BICFI', CustomerBankAccount."SWIFT Code");
    end;

    local procedure VerifyNameAndPostalAddress(SubtreeRootNodeName: Text; Name: Text; Address: Text; PostCode: Text; City: Text; CountryRegionCode: Text)
    begin
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, 'Nm', Name);
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, 'StrtNm', Address);
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, 'PstCd', PostCode);
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, 'TwnNm', City);
        LibraryXMLRead.VerifyNodeValueInSubtree(SubtreeRootNodeName, 'Ctry', CountryRegionCode);
    end;

    local procedure VerifyNodeExistsAndNotEmpty(SubtreeRootName: Text[30]; NodeName: Text[30])
    begin
        Assert.AreNotEqual(
          '', LibraryXMLRead.GetNodeValueInSubtree(SubtreeRootName, NodeName), StrSubstNo(UnexpectedEmptyNodeErr, NodeName, SubtreeRootName));
    end;

    local procedure VerifyPaymentErrors(SourceTableID: Integer; PaymentDocNo: Code[20]; LineNo: Integer; ExpErrorText: Text; ExpCount: Integer)
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
    begin
        PaymentJnlExportErrorText.SetRange("Journal Template Name", '');
        PaymentJnlExportErrorText.SetRange("Journal Batch Name", Format(SourceTableID));
        PaymentJnlExportErrorText.SetRange("Document No.", PaymentDocNo);
        PaymentJnlExportErrorText.SetRange("Journal Line No.", LineNo);
        PaymentJnlExportErrorText.SetRange("Error Text", ExpErrorText);
        Assert.AreEqual(ExpCount, PaymentJnlExportErrorText.Count, 'Error: ' + ExpErrorText + ', was encountered unexpectedly.');
    end;

    local procedure VerifyCollectionWasDeleted(PaymentHeader: Record "Payment Header FR")
    var
        DirectDebitCollection: Record "Direct Debit Collection";
    begin
        DirectDebitCollection.SetRange(Identifier, PaymentHeader."No.");
        asserterror DirectDebitCollection.FindFirst();
        Clear(DirectDebitCollection);
    end;

    local procedure VerifyPaymentLines(PaymentHeader: Record "Payment Header FR"; Customer: Record Customer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentLine: Record "Payment Line FR";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        Assert.AreEqual(CustLedgerEntry.Count, PaymentLine.Count, 'Wrong number of payment lines.');

        CustLedgerEntry.FindSet();
        repeat
            PaymentLine.SetRange("Account Type", PaymentLine."Account Type"::Customer);
            PaymentLine.SetRange("Account No.", CustLedgerEntry."Customer No.");
            PaymentLine.SetRange("Applies-to Doc. Type", CustLedgerEntry."Document Type");
            PaymentLine.SetRange("Applies-to Doc. No.", CustLedgerEntry."Document No.");
            PaymentLine.SetRange("Direct Debit Mandate ID", CustLedgerEntry."Direct Debit Mandate ID");
            Assert.AreEqual(1, PaymentLine.Count, PaymentLine.GetFilters);
            PaymentLine.FindFirst();
            if SEPADirectDebitMandate.Get(CustLedgerEntry."Direct Debit Mandate ID") then
                PaymentLine.TestField("Bank Account Code", SEPADirectDebitMandate."Customer Bank Account Code")
            else
                PaymentLine.TestField("Bank Account Code", Customer."Preferred Bank Account Code");
        until CustLedgerEntry.Next() = 0;
    end;

    local procedure VerifySEPAMandate(SEPADirectDebitMandateID: Text[35]; ExpCounter: Integer)
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        SEPADirectDebitMandate.Get(SEPADirectDebitMandateID);
        SEPADirectDebitMandate.TestField("Debit Counter", ExpCounter);
    end;

    local procedure CreateCustomerWithTwoInvoice(var Customer: Record Customer; var CustLedgerEntry: array[2] of Record "Cust. Ledger Entry"; SEPAPartnerType: Option)
    var
        CustomerBankAccount: Record "Customer Bank Account";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCustomerAddress(Customer);
        CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        CreateDirectDebitMandate(SEPADirectDebitMandate, Customer."No.", CustomerBankAccount.Code);
        CreateCustomerLedgerEntry(CustLedgerEntry[1], Customer."No.", SEPADirectDebitMandate.ID);
        CreateCustomerLedgerEntry(CustLedgerEntry[2], Customer."No.", SEPADirectDebitMandate.ID);
        Customer.Validate("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.Validate("Partner Type", SEPAPartnerType);
        Customer.Modify(true);
    end;

    [ModalPageHandler]
    procedure PaymentClassHandler(var PaymentClassList: TestPage "Payment Class List FR")
    var
        PaymentClassCode: Variant;
    begin
        LibraryVariableStorage.Dequeue(PaymentClassCode);
        PaymentClassList.GotoKey(PaymentClassCode);
        PaymentClassList.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure SuggestCustPaymentsReqPageHandler(var SuggestCustomerPayments: TestRequestPage "Suggest Cust. Payments")
    begin
        SuggestCustomerPayments.LastPaymentDate.SetValue(WorkDate());
        SuggestCustomerPayments.OK().Invoke();
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}
