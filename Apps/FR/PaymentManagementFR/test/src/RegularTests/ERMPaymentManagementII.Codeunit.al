// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using System.TestLibraries.Utilities;

codeunit 144017 "ERM Payment Management II"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
        // [FEATURE] [Payment Slip]    
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFRLocalization: Codeunit "Library - Localization FR";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        FilterRangeTxt: Label '%1..%2', Comment = '%1 = No., %2 = No.';
        PaymentClassNameTxt: Label 'Suggest Payments';
        FieldEnableMsg: Label 'Field must not be enabled';
        DocumentCreatedCapLbl: Label 'Document Created';
        HeaderTxt: Label 'A transfer to your bank account  (RIB : %1 %2 %3) has been done on %4.', Comment = '%1 = SWIFT Code, %2 = Agency Code, %3 = IBAN, %4 = Work Date';

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestCustomerPaymentsRequestPageHandler')]
    procedure CustomerNoOnPaymentLineWithCurrency()
    var
        PaymentClassCode: Text[30];
        CurrencyCode: Code[10];
        CustomerNo: Code[20];
        CustomerNo2: Code[20];
    begin
        // Verify Customer No. on Payment Line when Currency is not blank on Payment Header.

        // Setup & Exercise: Create Currency, Customers, Create payment Header.
        Initialize();

        CurrencyCode := CreateCurrency();
        CustomerNo := CreateCustomer(CurrencyCode, '');  // Blank for VAT Bus Posting group.
        CustomerNo2 := CreateCustomer('', '');  // Blank for currency and VAT Bus Posting group.
        PaymentClassCode := CreatePaymentSlipAndSuggestCustomerPayment(CurrencyCode, CustomerNo, CustomerNo2);

        // Verify: Verify Customer No. on Payment Line.
        FindPaymentLineAndVerifyAccountNo(PaymentClassCode, CustomerNo);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestCustomerPaymentsRequestPageHandler')]
    procedure CustomerNoOnPaymentLineWithoutCurrency()
    var
        PaymentClassCode: Text[30];
        CustomerNo: Code[20];
        CustomerNo2: Code[20];
    begin
        // Verify Customer No. on Payment Line when Currency is blank on Payment Header.

        // Setup & Exercise: Create Currency, Customers, Create payment Header.
        Initialize();

        CustomerNo := CreateCustomer(CreateCurrency(), '');  // Blank for VAT Bus Posting group.
        CustomerNo2 := CreateCustomer('', '');  // Blank for currency and VAT Bus Posting group.
        PaymentClassCode := CreatePaymentSlipAndSuggestCustomerPayment('', CustomerNo, CustomerNo2);

        // Verify: Verify Customer No. on Payment Line.
        FindPaymentLineAndVerifyAccountNo(PaymentClassCode, CustomerNo2);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestCustomerPaymentsRequestPageHandler,ConfirmHandlerTrue,CreatePaymentSlipStrMenuHandler,PaymentLinesListModalPageHandler,PaymentSlipPageHandler')]
    procedure PostPaymentSlipWithCurrency()
    var
        CurrencyCode: Code[10];
        OldInvoiceRounding: Boolean;
        PaymentClassCode: Text[30];
    begin
        // Verify Customer Ledger Entry after posting the Payment Slip with Unrealized VAT Reversal is Application on Payment Class.

        // Setup: Create VAT Posting Setup, Payment Class, Bank Account, GL Account, Setup for Payment Slip and Create and Post Sales Invoice.
        Initialize();

        OldInvoiceRounding := UpdateInvoiceRoundingSalesReceivableSetup(false);
        CurrencyCode := CreateCurrency();
        PaymentClassCode := PostSalesInvoiceAndSuggestCustomerPayment(CurrencyCode);
        PostPaymentSlip(PaymentClassCode);

        // Exercise: Create new Payment Slip.
        CODEUNIT.Run(CODEUNIT::"Payment Management FR"); // Invoke CreatePaymentSlipStrMenuHandler.

        // Verify: Verify Customer Ledger Entry after payment.
        VerifyCustomerLedgerEntry(PaymentClassCode, CurrencyCode);

        // Tear Down: Rollback setup value.
        UpdateInvoiceRoundingSalesReceivableSetup(OldInvoiceRounding);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestCustomerPaymentsRequestPageHandler,ConfirmHandlerTrue,CreatePaymentSlipStrMenuHandler,PaymentLinesListModalPageHandler,PaymentSlipPageHandler')]
    procedure PostPaymentSlipWithoutCurrency()
    var
        PaymentLine: Record "Payment Line FR";
        PaymentClassCode: Text[30];
    begin
        // Verify VAT Entry after posting the Payment Slip with Partial Amount.

        // Setup: Create VAT Posting Setup, Payment Class, Bank Account, GL Account, Setup for Payment Slip and Create and Post Sales Invoice.
        Initialize();

        PaymentClassCode := PostSalesInvoiceAndSuggestCustomerPayment('');  // // Blank for currency.
        FindPaymentLineAndUpdateAmount(PaymentLine, PaymentClassCode);
        PostPaymentSlip(PaymentClassCode);

        // Exercise: Create new Payment Slip.
        CODEUNIT.Run(CODEUNIT::"Payment Management FR");  // Invoke CreatePaymentSlipStrMenuHandler.

        // Verify: Verify VAT Entry after payment.
        VerifyVATEntry(PaymentLine."Account No.", CalculateAmount(PaymentLine."Account No."));
    end;

    [Test]
    procedure RealizeVATEnabledOnPaymentStepCard()
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
        PaymentStepCard: TestPage "Payment Step Card FR";
    begin
        // Verify that the Realize VAT field is disabled when the Unrealized VAT Reversal is set to Delayed and Action Type field is changed from Ledger to None.

        // Setup: Create Payment Class, payment Status, Payment Step.
        Initialize();

        PaymentClass.Get(CreatePaymentClass(PaymentClass.Suggestions::Customer, PaymentClass."Unrealized VAT Reversal"::Delayed));
        CreatePaymentStatus(PaymentStatus, PaymentClass.Code, PaymentClass.Code);
        CreatePaymentStep(
          PaymentClass.Code, PaymentClass.Code, PaymentStatus.Line, PaymentStatus.Line, PaymentStep."Action Type"::Ledger, false, 0);  // FALSE for Realize VAT.
        PaymentStepCard.OpenEdit();
        PaymentStepCard.FILTER.SetFilter("Payment Class", PaymentClass.Code);

        // Exercise: Update Action Type on Payment Step Card.
        PaymentStepCard."Action Type".SetValue(PaymentStep."Action Type"::None);

        // Verify: Verify that the Realize VAT field is disabled when Action Type field is changed from Ledger to None.
        Assert.IsFalse(PaymentStepCard."Realize VAT".Enabled(), FieldEnableMsg);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler')]
    procedure UnapplyVendorLedgerEntryAfterDeletePaymentLine()
    var
        PaymentLine: Record "Payment Line FR";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentClassCode: Text[30];
        VendorNo: Code[20];
    begin
        // Verify  that the deletion of an applied Vendor Payment Line unapplies the vendor ledger entry the payment line was applied.

        // Setup: Create and post Purchase Invoice, create Payment Header and Suggest Vendor Payment.
        Initialize();

        PaymentClassCode := PostPurchaseInvoiceAndSuggestVendorPayment('');  // Blank for Currency.
        FindPaymentLine(PaymentLine, PaymentClassCode);
        VendorNo := PaymentLine."Account No.";

        // Exercise.
        PaymentLine.Delete(true);

        // Verify: Verify Applies - to - ID is blank when Payment Line is deleted.
        VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntry.FindFirst();
        VendorLedgerEntry.TestField("Applies-to ID", '');
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler')]
    procedure UpdateDebitAmountOnPaymentLine()
    var
        PaymentLine: Record "Payment Line FR";
        CurrencyCode: Code[10];
        OldInvoiceRounding: Boolean;
        PaymentClassCode: Text[30];
    begin
        // Verify that the Debit Amount can be modified on Vendor Payment when Currency Code is not equal to blank.

        // Setup: Create and post Purchase Invoice, Create Payment Header and Suggest Vendor Payment.
        Initialize();

        OldInvoiceRounding := UpdateInvoiceRoundingPurchasePayableSetup(false);
        CurrencyCode := CreateCurrency();
        PaymentClassCode := PostPurchaseInvoiceAndSuggestVendorPayment(CurrencyCode);

        // Exercise & Verify: Debit Amount is updated successfully on Payment Line
        FindPaymentLineAndUpdateAmount(PaymentLine, PaymentClassCode);

        // Tear Down: Roll back setup value.
        UpdateInvoiceRoundingPurchasePayableSetup(OldInvoiceRounding);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler')]
    procedure VendorNoOnPaymentLineWithCurrency()
    var
        PaymentClassCode: Text[30];
        CurrencyCode: Code[10];
        VendorNo: Code[20];
        VendorNo2: Code[20];
        SummarizePer: Option " ",Vendor,"Due date";
    begin
        // Verify Vendor No. on Payment Line when Currency is not blank on Payment Header.

        // Setup & Exercise: Create Currency, Customers, Create payment Header.
        Initialize();

        CurrencyCode := CreateCurrency();
        VendorNo := CreateVendor(CurrencyCode);
        VendorNo2 := CreateVendor('');
        PaymentClassCode :=
          CreatePaymentSlipAndSuggestVendorPayment(VendorNo, VendorNo2, CurrencyCode, WorkDate(), SummarizePer::" ", StrSubstNo(
              FilterRangeTxt, VendorNo, VendorNo2));

        // Verify: Verify Vendor No. on Payment Line.
        FindPaymentLineAndVerifyAccountNo(PaymentClassCode, VendorNo);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler')]
    procedure VendorNoOnPaymentLineWithoutCurrency()
    var
        PaymentClassCode: Text[30];
        VendorNo: Code[20];
        VendorNo2: Code[20];
        SummarizePer: Option " ",Vendor,"Due date";
    begin
        // Verify Vendor No. on Payment Line when Currency is not blank on Payment Header.

        // Setup & Exercise: Create Currency, Customers, Create payment Header.
        Initialize();

        VendorNo := CreateVendor(CreateCurrency());
        VendorNo2 := CreateVendor('');  // Blank for Currency.
        PaymentClassCode :=
          CreatePaymentSlipAndSuggestVendorPayment(VendorNo, VendorNo2, '', WorkDate(), SummarizePer::" ", StrSubstNo(
              FilterRangeTxt, VendorNo, VendorNo2));  // Blank for Currency.

        // Verify: Verify Vendor No. on Payment Line.
        FindPaymentLineAndVerifyAccountNo(PaymentClassCode, VendorNo2);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler')]
    procedure SuggestedDueDateOnPaymentLine()
    var
        PaymentLine: Record "Payment Line FR";
        DueDate: Date;
        SummarizePer: Option " ",Vendor,"Due date";
        VendorNo: Code[20];
    begin
        // Verify proper Due Date is suggested automatically for combined payments for Vendors when Summarize Per is Vendor.

        // Setup: Create Vendor, Create payment Slip.
        Initialize();

        DueDate := CalcDate('<-' + Format(LibraryRandom.RandInt(5)) + 'M>', WorkDate());
        VendorNo := CreateVendor('');
        CreatePaymentSlipAndSuggestVendorPayment(VendorNo, VendorNo, '', DueDate, SummarizePer::Vendor, '');  // Blank for Currency and VendorFilter.

        // Verify: Verify Due date on Payment Line.
        PaymentLine.SetRange("Account No.", VendorNo);
        PaymentLine.FindFirst();
        PaymentLine.TestField("Due Date", DueDate);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,ConfirmHandlerTrue,BillReportPageHandler')]
    procedure PrintReportBillWithPaymentSlip()
    var
        PaymentClass: Record "Payment Class FR";
        PaymentLine: Record "Payment Line FR";
        PaymentClassCode: Text[30];
        Amount: Decimal;
    begin
        // Setup: Create Payment Slip Setup with Status and Steps. Create Payment Slip.

        PaymentClassCode := CreatePaymentSlipSetup(PaymentClass.Suggestions::None, REPORT::"Bill FR");
        Amount := LibraryRandom.RandDec(10, 2);
        LibraryVariableStorage.Enqueue(PaymentClassCode); // Enqueue value for PaymentClassListModalPageHandler.
        CreatePaymentSlipHeaderAndLine(PaymentLine."Account Type"::Customer, CreateCustomer('', ''), '', -Amount);

        // Exercise: Print Report Bill.
        PrintPaymentSlip(PaymentClassCode);

        // Verify: Verify Amount in Report Bill is correct.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists(
          'FORMAT_Amount_0___Precision_2___Standard_Format_0___', '****' + Format(Amount, 0, '<Precision,2:><Standard Format,0>'));
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,ConfirmHandlerTrue,DraftNoticeRequestPageHandler')]
    procedure ReportDraftNoticeBankAccountInformation()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        CompanyInfo: Record "Company Information";
        PaymentClass: Record "Payment Class FR";
        PaymentLine: Record "Payment Line FR";
        BankAccount: Record "Bank Account";
        PaymentClassCode: Text[30];
    begin
        // Verify bank account information in Report Draft Notice refers to SWIFT and IBAN.

        // Setup: Set SWIFT Code and IBAN for Company and Vendor Bank Account, create Payment Slip.
        CompanyInfo.Get();

        CreateBankAccountWithSEPAInfo(BankAccount);
        CreateVendorWithVendorBankAccount(VendorBankAccount);

        PaymentClassCode := CreatePaymentSlipSetup(PaymentClass.Suggestions::None, REPORT::"Draft notice FR");
        LibraryVariableStorage.Enqueue(PaymentClassCode); // Enqueue value for PaymentClassListModalPageHandler.
        CreatePaymentSlipHeaderAndLine(
          PaymentLine."Account Type"::Vendor, VendorBankAccount."Vendor No.", BankAccount."No.", LibraryRandom.RandDec(10, 2));

        // Exercise: Print Report Draft Notice.
        PrintPaymentSlip(PaymentClassCode);

        // Verify: Verify the Bank Account information refers to SWIFT Code and IBAN.
        VerifyBankAccountInfo(BankAccount, VendorBankAccount);
    end;

    [Test]
    [HandlerFunctions('PaymentClassListModalPageHandler,SuggestVendorPaymentsFRRequestPageHandler,ConfirmHandlerTrue')]
    procedure CancelPaymentFile()
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentStep: Record "Payment Step FR";
        PaymentStatusExported: Record "Payment Status FR";
        PaymentSlip: TestPage "Payment Slip FR";
        PaymentClassCode: Text[30];
    begin
        // [FEATURE] [Export] [Cancel]
        // [SCENARIO 291934] "Payment Header"."File Exporte Completed" becomes FALSE when Stan cancels export payment file
        Initialize();


        // [GIVEN] Payment Slip Setup "X" with steps "StepF" and "StepC"
        // [GIVEN] "StepF"."Action Type" = File.
        // [GIVEN] "StepC"."Action Type" = "Cancel File" and start status = "StepF"
        PaymentClassCode := PostPurchaseInvoiceAndSuggestVendorPayment('');  // Blank for Currency.
        CreatePaymentStatus(PaymentStatusExported, PaymentClassCode, LibraryUtility.GenerateGUID());

        CreatePaymentStep(
          PaymentClassCode, LibraryUtility.GenerateGUID(),
          0, PaymentStatusExported.Line, PaymentStep."Action Type"::File, false, 0);
        CreatePaymentStep(
          PaymentClassCode, LibraryUtility.GenerateGUID(),
          PaymentStatusExported.Line, 0, PaymentStep."Action Type"::"Cancel File", false, 0);

        // [GIVEN] Payment header with generated payment file having "Status" = "StepF", "File Export Completed" = TRUE
        PaymentHeader.SetRange("Payment Class", PaymentClassCode);
        PaymentHeader.FindFirst();
        PaymentHeader."Status No." := PaymentStatusExported.Line;
        PaymentHeader."File Export Completed" := true;
        PaymentHeader.Modify();

        // [WHEN] Post header with "Cance payment file" selection
        OpenPaymentSlip(PaymentSlip, PaymentClassCode);
        PaymentSlip.Post.Invoke();

        // [THEN] Payment header with "Status" = 0, "File Export Completed" = FALSE
        PaymentHeader.FindFirst();
        PaymentHeader.TestField("Status No.", 0);
        PaymentHeader.TestField("File Export Completed", false);
    end;

    local procedure Initialize()
    var
        PaymentClass: Record "Payment Class FR";
        PaymentHeader: Record "Payment Header FR";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"ERM Payment Management II");
        LibraryERM.SetUnrealizedVAT(true);
        PaymentClass.DeleteAll();
        PaymentHeader.DeleteAll();
        LibraryVariableStorage.Clear();
    end;

    local procedure CalculateAmount(No: Code[20]) Amount: Decimal
    var
        Customer: Record Customer;
        PaymentLine: Record "Payment Line FR";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Customer.Get(No);
        VATPostingSetup.SetRange("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
        VATPostingSetup.FindFirst();
        Amount := Round(PaymentLine.Amount * VATPostingSetup."VAT %" / (100 + VATPostingSetup."VAT %"));
    end;

    local procedure CreateAndPostGeneralJournal(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DueDate: Date; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, AccountType, AccountNo,
          LibraryRandom.RandDec(10, 2));  // Taken random Amount.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", CreateBankAccount());
        GenJournalLine.Validate("External Document No.", GenJournalLine."Document No.");
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Due Date", DueDate);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostPurchaseInvoice(CurrencyCode: Code[10]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateVATPostingSetup(VATPostingSetup);
        LibraryPurchase.CreatePurchHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CreateVendorWithVATBusPostingGroup(
            VATPostingSetup."VAT Bus. Posting Group"));
        PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandDec(10, 2));  // Use random value for Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));  // Use random value for Unit Price.
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        exit(PurchaseHeader."Buy-from Vendor No.");
    end;

    local procedure CreateAndPostSalesInvoice(CurrencyCode: Code[10]): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateVATPostingSetup(VATPostingSetup);
        LibrarySales.CreateSalesHeader(
          SalesHeader, SalesHeader."Document Type"::Order, CreateCustomer(CurrencyCode,
            VATPostingSetup."VAT Bus. Posting Group"));
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandDec(10, 2));  // Use random value for Quantity.
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));  // Use random value for Unit Price.
        SalesLine.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(SalesHeader."Sell-to Customer No.");
    end;

    local procedure CreateAndUpdatePaymentHeader(CurrencyCode: Code[10])
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        PaymentHeader.Validate("Currency Code", CurrencyCode);
        PaymentHeader.Modify(true);
    end;

    local procedure CreatePaymentSlipAndSuggestCustomerPayment(CurrencyCode: Code[10]; CustomerNo: Code[20]; CustomerNo2: Code[20]) PaymentClassCode: Text[30]
    var
        GenJournalLine: Record "Gen. Journal Line";
        PaymentClass: Record "Payment Class FR";
        PaymentSlip: TestPage "Payment Slip FR";
        SummarizePer: Option " ",Vendor,"Due date";
    begin
        // Setup.
        PaymentClassCode :=
          SetupForPaymentOnPaymentSlip(
            GenJournalLine."Account Type"::Customer, CustomerNo, CustomerNo2,
            LibraryRandom.RandDec(10, 2), PaymentClass.Suggestions::Customer, CurrencyCode, WorkDate());
        OpenPaymentSlip(PaymentSlip, PaymentClassCode);
        EnqueueValuesForHandler(StrSubstNo(FilterRangeTxt, CustomerNo, CustomerNo2), CurrencyCode, SummarizePer::" ");  // Enqueue for SuggestVendorPaymentsFRRequestPageHandler.

        // Exercise.
        PaymentSlip.SuggestCustomerPayments.Invoke();
    end;

    local procedure CreatePaymentSlipAndSuggestVendorPayment(VendorNo: Code[20]; VendorNo2: Code[20]; CurrencyCode: Code[10]; DueDate: Date; SummarizePer: Option; VendorFilter: Text[30]) PaymentClassCode: Text[30]
    var
        GenJournalLine: Record "Gen. Journal Line";
        PaymentClass: Record "Payment Class FR";
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        // Setup.
        PaymentClassCode :=
          SetupForPaymentOnPaymentSlip(
            GenJournalLine."Account Type"::Vendor, VendorNo, VendorNo2,
            -LibraryRandom.RandDec(10, 2), PaymentClass.Suggestions::Vendor, CurrencyCode, DueDate);
        OpenPaymentSlip(PaymentSlip, PaymentClassCode);
        EnqueueValuesForHandler(VendorFilter, CurrencyCode, SummarizePer);  // Enqueue for SuggestVendorPaymentsFRRequestPageHandler.

        // Exercise.
        PaymentSlip.SuggestVendorPayments.Invoke();
    end;

    local procedure CreateBankAccount(): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        exit(BankAccount."No.");
    end;

    local procedure CreateBankAccountWithSEPAInfo(var BankAccount: Record "Bank Account")
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("SWIFT Code", LibraryUtility.GenerateGUID());
        BankAccount.Validate(IBAN, LibraryUtility.GenerateGUID());
        BankAccount.Modify(true);
    end;

    local procedure CreateCustomer(CurrencyCode: Code[10]; VATBusPostingGroup: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateRandomExchangeRate(Currency.Code);
        exit(Currency.Code);
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreatePaymentClass(Suggestions: Option; UnrealizedVATReversal: Option): Text[30]
    var
        PaymentClass: Record "Payment Class FR";
    begin
        LibraryFRLocalization.CreatePaymentClass(PaymentClass);
        PaymentClass.Validate("Header No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        PaymentClass.Validate("Unrealized VAT Reversal", UnrealizedVATReversal);
        PaymentClass.Validate(Suggestions, Suggestions);
        PaymentClass.Modify(true);
        exit(PaymentClass.Code);
    end;

    local procedure CreatePaymentStatus(var PaymentStatus: Record "Payment Status FR"; PaymentClass: Text[30]; Name: Text[50])
    begin
        LibraryFRLocalization.CreatePaymentStatus(PaymentStatus, PaymentClass);
        PaymentStatus.Validate(Name, Name);
        PaymentStatus.Modify(true);
    end;

    local procedure CreatePaymentStep(PaymentClass: Text[30]; Name: Text[50]; PreviousStatus: Integer; NextStatus: Integer; ActionType: Enum "Payment Step Action Type FR"; RealizeVAT: Boolean; ReportNo: Integer): Integer
    var
        PaymentStep: Record "Payment Step FR";
        NoSeries: Record "No. Series";
    begin
        NoSeries.FindFirst();
        LibraryFRLocalization.CreatePaymentStep(PaymentStep, PaymentClass);
        PaymentStep.Validate(Name, Name);
        PaymentStep.Validate("Previous Status", PreviousStatus);
        PaymentStep.Validate("Next Status", NextStatus);
        PaymentStep.Validate("Action Type", ActionType);
        PaymentStep.Validate("Source Code", CreateSourceCode());
        PaymentStep.Validate("Header Nos. Series", NoSeries.Code);
        PaymentStep.Validate("Realize VAT", RealizeVAT);
        PaymentStep.Validate("Report No.", ReportNo);
        PaymentStep.Modify(true);
        exit(PaymentStep.Line);
    end;

    local procedure CreatePaymentStepLedger(var PaymentStepLedger: Record "Payment Step Ledger FR"; PaymentClass: Text[30]; Sign: Option; AccountingType: Option; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Application: Option; Line: Integer)
    begin
        LibraryFRLocalization.CreatePaymentStepLedger(PaymentStepLedger, PaymentClass, Sign, Line);
        PaymentStepLedger.Validate(Description, PaymentClass);
        PaymentStepLedger.Validate("Accounting Type", AccountingType);
        PaymentStepLedger.Validate("Account Type", AccountType);
        PaymentStepLedger.Validate("Account No.", AccountNo);
        PaymentStepLedger.Validate(Application, Application);
        PaymentStepLedger.Modify(true);
    end;

    local procedure CreateSetupForPaymentSlip(var LineNo: Integer; PaymentClass: Text[30]) LineNo2: Integer
    var
        PaymentStatus: Record "Payment Status FR";
        PaymentStatus2: Record "Payment Status FR";
        PaymentStatus3: Record "Payment Status FR";
        PaymentStatus4: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
    begin
        // Hardcoded values required for Payment Class setup due to avoid Import Parameter setup through automation.
        CreatePaymentStatus(PaymentStatus, PaymentClass, 'New Document In Creation');
        CreatePaymentStatus(PaymentStatus2, PaymentClass, DocumentCreatedCapLbl);
        CreatePaymentStatus(PaymentStatus3, PaymentClass, 'Payment In Creation');
        CreatePaymentStatus(PaymentStatus4, PaymentClass, 'Payment Created');

        // Create Payment Step.
        LineNo :=
          CreatePaymentStep(
            PaymentClass, 'Step1: Creation of documents', PaymentStatus.Line, PaymentStatus2.Line, PaymentStep."Action Type"::Ledger, false,
            0);  // FALSE for Realize VAT.
        CreatePaymentStep(
          PaymentClass, 'Step2: Documents created', PaymentStatus2.Line, PaymentStatus3.Line,
          PaymentStep."Action Type"::"Create New Document", false, 0);  // FALSE for Realize VAT.
        LineNo2 :=
          CreatePaymentStep(
            PaymentClass, 'Step3: Creation of payment', PaymentStatus3.Line, PaymentStatus4.Line,
            PaymentStep."Action Type"::Ledger, true, 0);  // TRUE for Realize VAT.    
    end;

    local procedure CreatePaymentStepLedgerForCustomer(PaymentClass: Text[30]; LineNo: Integer; LineNo2: Integer)
    var
        PaymentStepLedger: Record "Payment Step Ledger FR";
        PaymentStepLedger2: Record "Payment Step Ledger FR";
        PaymentStepLedger3: Record "Payment Step Ledger FR";
        PaymentStepLedger4: Record "Payment Step Ledger FR";
    begin
        // Create Payment Step Ledger for Customer.
        CreatePaymentStepLedger(
          PaymentStepLedger, PaymentClass, PaymentStepLedger.Sign::Debit, PaymentStepLedger."Accounting Type"::"Associated G/L Account",
          PaymentStepLedger."Account Type"::"G/L Account", '', PaymentStepLedger.Application::None, LineNo);  // Blank value for G/L Account No.
        CreatePaymentStepLedger(
          PaymentStepLedger2, PaymentClass, PaymentStepLedger.Sign::Credit, PaymentStepLedger."Accounting Type"::"Payment Line Account",
          PaymentStepLedger."Account Type"::"G/L Account", '', PaymentStepLedger.Application::"Applied Entry", LineNo);  // Blank value for G/L Account No.
        CreatePaymentStepLedger(
          PaymentStepLedger3, PaymentClass, PaymentStepLedger.Sign::Debit, PaymentStepLedger."Accounting Type"::"Setup Account",
          PaymentStepLedger."Account Type"::"Bank Account", CreateBankAccount(), PaymentStepLedger.Application::None, LineNo2);
        CreatePaymentStepLedger(
          PaymentStepLedger4, PaymentClass, PaymentStepLedger.Sign::Credit, PaymentStepLedger."Accounting Type"::"Setup Account",
          PaymentStepLedger."Account Type"::"G/L Account", CreateGLAccount(), PaymentStepLedger.Application::None, LineNo2);
    end;

    local procedure CreatePaymentSlip(Suggestion: Option; CurrencyCode: Code[10]) PaymentClassCode: Text[30]
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
    begin
        PaymentClassCode := CreatePaymentClass(Suggestion, PaymentClass."Unrealized VAT Reversal"::Application);
        CreatePaymentStatus(PaymentStatus, PaymentClassCode, PaymentClassNameTxt);
        LibraryVariableStorage.Enqueue(PaymentClassCode);  // Enqueue value for PaymentClassListModalPageHandler.
        CreateAndUpdatePaymentHeader(CurrencyCode);
        Commit();  // Required for execute report.    
    end;

    local procedure CreatePaymentSlipSetup(Suggestion: Option; ReportNo: Integer) PaymentClassCode: Text[30]
    var
        PaymentClass: Record "Payment Class FR";
        PaymentStatus: Record "Payment Status FR";
        PaymentStep: Record "Payment Step FR";
    begin
        PaymentClassCode := CreatePaymentClass(Suggestion, PaymentClass."Unrealized VAT Reversal"::Application);
        CreatePaymentStatus(PaymentStatus, PaymentClassCode, PaymentClassNameTxt);
        UpdatePaymentStatusParameters(PaymentStatus, true, true);
        CreatePaymentStep(
          PaymentClassCode, LibraryUtility.GenerateGUID(), 0, 0, PaymentStep."Action Type"::Report, false, ReportNo); // FALSE for Realize VAT.    
    end;

    local procedure CreatePaymentSlipHeaderAndLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BankAccountNo: Code[20]; LineAmount: Decimal): Code[20]
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        LibraryFRLocalization.CreatePaymentHeader(PaymentHeader);
        if BankAccountNo <> '' then begin
            PaymentHeader.Validate("Account No.", BankAccountNo);
            PaymentHeader.Modify(true);
        end;
        LibraryFRLocalization.CreatePaymentLine(PaymentLine, PaymentHeader."No.");
        PaymentLine.Validate("Account Type", AccountType);
        PaymentLine.Validate("Account No.", AccountNo);
        PaymentLine.Validate(Amount, LineAmount);
        PaymentLine.Modify(true);
        exit(PaymentHeader."No.");
    end;

    local procedure CreateSourceCode(): Code[10]
    var
        SourceCode: Record "Source Code";
    begin
        LibraryERM.CreateSourceCode(SourceCode);
        exit(SourceCode.Code);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("VAT %", LibraryRandom.RandInt(10));
        VATPostingSetup.Validate("Unrealized VAT Type", VATPostingSetup."Unrealized VAT Type"::Percentage);
        VATPostingSetup.Validate("Purch. VAT Unreal. Account", CreateGLAccount());
        VATPostingSetup.Validate("Sales VAT Unreal. Account", CreateGLAccount());
        VATPostingSetup.Validate("Sales VAT Account", CreateGLAccount());
        VATPostingSetup.Validate("Purchase VAT Account", CreateGLAccount());
        VATPostingSetup.Modify(true);
    end;

    local procedure CreateVendorWithVATBusPostingGroup(VATBusPostingGroup: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateVendor(CurrencyCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateVendorWithVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account")
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        VendorBankAccount.Validate("SWIFT Code", LibraryUtility.GenerateGUID());
        VendorBankAccount.Validate(IBAN, LibraryUtility.GenerateGUID());
        VendorBankAccount.Modify(true);
        Vendor.Validate("Preferred Bank Account Code", VendorBankAccount.Code);
        Vendor.Modify(true);
    end;

    local procedure EnqueueValuesForHandler(Value: Variant; Value2: Variant; Value3: Variant)
    begin
        LibraryVariableStorage.Enqueue(Value);
        LibraryVariableStorage.Enqueue(Value2);
        LibraryVariableStorage.Enqueue(Value3);
    end;

    local procedure FindPaymentLine(var PaymentLine: Record "Payment Line FR"; PaymentClass: Text[30])
    begin
        PaymentLine.SetRange("Payment Class", PaymentClass);
        PaymentLine.FindFirst();
    end;

    local procedure FindCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentNo: Code[20])
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::" ");
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.FindFirst();
    end;

    local procedure FindPaymentLineAndUpdateAmount(var PaymentLine: Record "Payment Line FR"; PaymentClass: Text[30])
    begin
        FindPaymentLine(PaymentLine, PaymentClass);
        PaymentLine.Validate("Debit Amount", PaymentLine."Debit Amount" / 2);
        PaymentLine.Modify(true);
    end;

    local procedure PostPaymentSlip(PaymentClass: Text[30])
    var
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        OpenPaymentSlip(PaymentSlip, PaymentClass);
        PaymentSlip.Post.Invoke();  // Invoke ConfirmHandlerTrue.    
    end;

    local procedure PostSalesInvoiceAndSuggestCustomerPayment(CurrencyCode: Code[10]): Text[30]
    var
        PaymentClass: Record "Payment Class FR";
        PaymentSlip: TestPage "Payment Slip FR";
        SellToCustomerNo: Code[20];
        LineNo: Integer;
        LineNo2: Integer;
        SummarizePer: Option " ",Vendor,"Due date";
    begin
        // Create VAT Posting Setup, Payment Class, Bank Account, GL Account, Setup for Payment Slip and Create and Post Sales Invoice.
        SellToCustomerNo := CreateAndPostSalesInvoice(CurrencyCode);
        PaymentClass.Get(CreatePaymentClass(PaymentClass.Suggestions::Customer, PaymentClass."Unrealized VAT Reversal"::Application));
        LineNo2 := CreateSetupForPaymentSlip(LineNo, PaymentClass.Code);
        CreatePaymentStepLedgerForCustomer(PaymentClass.Code, LineNo, LineNo2);

        LibraryVariableStorage.Enqueue(PaymentClass.Code);  // Enqueue value for PaymentClassListModalPageHandler.
        CreateAndUpdatePaymentHeader(CurrencyCode);
        Commit();  // Required for execute report.

        OpenPaymentSlip(PaymentSlip, PaymentClass.Code);
        EnqueueValuesForHandler(SellToCustomerNo, CurrencyCode, SummarizePer::" ");  // Enqueue for SuggestVendorPaymentsFRRequestPageHandler.
        PaymentSlip.SuggestCustomerPayments.Invoke();
        exit(PaymentClass.Code);
    end;

    local procedure PostPurchaseInvoiceAndSuggestVendorPayment(CurrencyCode: Code[10]) PaymentClassCode: Text[30]
    var
        PaymentClass: Record "Payment Class FR";
        PaymentSlip: TestPage "Payment Slip FR";
        VendorNo: Code[20];
        SummarizePer: Option " ",Vendor,"Due date";
    begin
        VendorNo := CreateAndPostPurchaseInvoice(CurrencyCode);
        PaymentClassCode := CreatePaymentSlip(PaymentClass.Suggestions::Vendor, CurrencyCode);
        OpenPaymentSlip(PaymentSlip, PaymentClassCode);
        EnqueueValuesForHandler(VendorNo, CurrencyCode, SummarizePer::" ");  // Enqueue for SuggestVendorPaymentsFRRequestPageHandler.
        PaymentSlip.SuggestVendorPayments.Invoke();
    end;

    local procedure FindPaymentLineAndVerifyAccountNo(PaymentClassCode: Text[30]; AccountNo: Code[20])
    var
        PaymentLine: Record "Payment Line FR";
    begin
        FindPaymentLine(PaymentLine, PaymentClassCode);
        PaymentLine.TestField("Account No.", AccountNo);
    end;

    local procedure OpenPaymentSlip(var PaymentSlip: TestPage "Payment Slip FR"; PaymentClass: Text[30])
    begin
        PaymentSlip.OpenView();
        PaymentSlip.FILTER.SetFilter("Payment Class", PaymentClass);
    end;

    local procedure SetupForPaymentOnPaymentSlip(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; AccountNo2: Code[20]; Amount: Decimal; Suggestion: Option; CurrencyCode: Code[10]; DueDate: Date) PaymentClassCode: Text[30]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateAndPostGeneralJournal(GenJournalLine, AccountType, AccountNo, DueDate, Amount);
        CreateAndPostGeneralJournal(GenJournalLine, AccountType, AccountNo2, WorkDate(), Amount);
        PaymentClassCode := CreatePaymentSlip(Suggestion, CurrencyCode);
    end;

    local procedure UpdateInvoiceRoundingSalesReceivableSetup(InvoiceRounding: Boolean) OldInvoiceRounding: Boolean
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        OldInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure UpdateInvoiceRoundingPurchasePayableSetup(InvoiceRounding: Boolean) OldInvoiceRounding: Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        OldInvoiceRounding := PurchasesPayablesSetup."Invoice Rounding";
        PurchasesPayablesSetup.Validate("Invoice Rounding", InvoiceRounding);
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure UpdatePaymentStatusParameters(var PaymentStatus: Record "Payment Status FR"; ShowRib: Boolean; ShowAmount: Boolean)
    begin
        PaymentStatus.Validate(RIB, ShowRib);
        PaymentStatus.Validate(Amount, ShowAmount);
        PaymentStatus.Modify(true);
    end;

    local procedure PrintPaymentSlip(PaymentClass: Text[30])
    var
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        OpenPaymentSlip(PaymentSlip, PaymentClass);
        PaymentSlip.Print.Invoke(); // Invoke ConfirmHandlerTrue.    
    end;

    local procedure VerifyCustomerLedgerEntry(PaymentClassCode: Text[30]; CurrencyCode: Code[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentLine: Record "Payment Line FR";
        PaymentSlip: TestPage "Payment Slip FR";
    begin
        OpenPaymentSlip(PaymentSlip, PaymentClassCode);
        PaymentSlip.FILTER.SetFilter("Status Name", DocumentCreatedCapLbl);
        FindCustomerLedgerEntry(CustLedgerEntry, Format(PaymentSlip."No."));
        FindPaymentLine(PaymentLine, PaymentClassCode);
        CustLedgerEntry.CalcFields(Amount, "Amount (LCY)");
        CustLedgerEntry.TestField(Amount, PaymentLine.Amount);
        CustLedgerEntry.TestField("Amount (LCY)", LibraryERM.ConvertCurrency(PaymentLine.Amount, CurrencyCode, '', WorkDate()));
    end;

    local procedure VerifyVATEntry(BillToPayToNo: Code[20]; Amount: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Bill-to/Pay-to No.", BillToPayToNo);
        VATEntry.FindFirst();
        VATEntry.TestField(Amount, Amount);
    end;

    local procedure VerifyBankAccountInfo(BankAccount: Record "Bank Account"; VendorBankAccount: Record "Vendor Bank Account")
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.AssertElementWithValueExists('PaymtHeader__SWIFT_Code__Caption', BankAccount.FieldCaption("SWIFT Code"));
        LibraryReportDataset.AssertElementWithValueExists('PaymtHeader__IBAN__Caption', BankAccount.FieldCaption(IBAN));
        LibraryReportDataset.AssertElementWithValueExists('PaymtHeader_SWIFT_Code', BankAccount."SWIFT Code");
        LibraryReportDataset.AssertElementWithValueExists('PaymtHeader_IBAN', BankAccount.IBAN);
        LibraryReportDataset.AssertElementWithValueExists(
          'HeaderText1',
          StrSubstNo(HeaderTxt, VendorBankAccount."SWIFT Code", VendorBankAccount."Agency Code FR", VendorBankAccount.IBAN, WorkDate()));
    end;

    [ModalPageHandler]
    procedure PaymentClassListModalPageHandler(var PaymentClassList: TestPage "Payment Class List FR")
    var
        "Code": Variant;
    begin
        LibraryVariableStorage.Dequeue(Code);
        PaymentClassList.FILTER.SetFilter(Code, Code);
        PaymentClassList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure PaymentLinesListModalPageHandler(var PaymentLinesList: TestPage "Payment Lines List FR")
    begin
        PaymentLinesList.OK().Invoke();  // Invokes PaymentSlipPageHandler.    
    end;

    [StrMenuHandler]
    procedure CreatePaymentSlipStrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;  // Invokes PaymentLinesListModalPageHandler.    
    end;

    [RequestPageHandler]
    procedure SuggestCustomerPaymentsRequestPageHandler(var SuggestCustomerPayments: TestRequestPage "Suggest Cust. Payments")
    var
        CurrencyFilter: Variant;
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        LibraryVariableStorage.Dequeue(CurrencyFilter);
        SuggestCustomerPayments.Customer.SetFilter("No.", No);
        SuggestCustomerPayments.LastPaymentDate.SetValue(WorkDate());  // Required month end date.
        SuggestCustomerPayments.Currency_Filter.SetValue(CurrencyFilter);
        SuggestCustomerPayments.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure SuggestVendorPaymentsFRRequestPageHandler(var SuggestVendorPaymentsFR: TestRequestPage "Suggest Vend. Payments")
    var
        CurrencyFilter: Variant;
        No: Variant;
        SummarizePer: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        LibraryVariableStorage.Dequeue(CurrencyFilter);
        LibraryVariableStorage.Dequeue(SummarizePer);
        SuggestVendorPaymentsFR.Vendor.SetFilter("No.", No);
        SuggestVendorPaymentsFR.LastPaymentDate.SetValue(CalcDate('<1M>', WorkDate()));  // Required month end date.
        SuggestVendorPaymentsFR.Currency_Filter.SetValue(CurrencyFilter);
        SuggestVendorPaymentsFR.Summarize_Per.SetValue(SummarizePer);
        SuggestVendorPaymentsFR.OK().Invoke();
    end;

    [PageHandler]
    procedure PaymentSlipPageHandler(var PaymentSlip: TestPage "Payment Slip FR")
    begin
        PaymentSlip.Post.Invoke();  // Invokes ConfirmHandlerTrue.    
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure BillReportPageHandler(var Bill: TestRequestPage "Bill FR")
    begin
        Bill.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure DraftNoticeRequestPageHandler(var DraftNotice: TestRequestPage "Draft notice FR")
    begin
        DraftNotice.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

