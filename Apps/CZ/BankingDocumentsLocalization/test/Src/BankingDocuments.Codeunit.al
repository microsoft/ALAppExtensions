codeunit 148079 "Banking Documents CZB"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Banking Documents]
        isInitialized := false;
    end;


    var
        Assert: Codeunit Assert;
        LibraryBankDocumentsCZB: Codeunit "Library - Bank Documents CZB";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryRandom: Codeunit "Library - Random";
        BankingLineTypeCZB: Enum "Banking Line Type CZB";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Banking Documents CZB");
        LibraryRandom.Init();
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Banking Documents CZB");

        LibraryBankDocumentsCZB.UpdateBankAccount(true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Banking Documents CZB");
    end;

    [Test]
    procedure PaymentOrderCreation()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        // [SCENARIO] Check if the system allows creating a new Payment Order
        Initialize();

        // [GIVEN] Payment Order has been created
        CreatePaymentOrder(PaymentOrderHeaderCZB, PaymentOrderLineCZB);

        // [WHEN] Get Payment Order Header
        PaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."No.");

        // [THEN] One Payment Order Line will be created
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        Assert.AreEqual(1, PaymentOrderLineCZB.Count(), 'One payment order line was expected for this record.');
    end;

    [Test]
    [HandlerFunctions('SuggestPaymentsHandler,MessageHandler')]
    procedure PaymentsSuggestionFromPostedPurchInvoice()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SuggestPaymentsErr: Label 'Payment Order Line was not created.';
    begin
        // [SCENARIO] Tests that execution of report "Suggest Payments" suggest payments from Posted Purchase Invoice and create Payment Order Lines
        Initialize();

        // [GIVEN] Purchase Invoice for payments suggestion has been created and posted
        CreatePurchaseInvoice(PurchaseHeader, PurchaseLine);
        PostPurchaseDocument(PurchaseHeader);

        // [WHEN] Create Payment Order with lines of suggested from Purchase Invoice
        CreatePaymentOrderFromPurchaseInvoice(PaymentOrderHeaderCZB, PurchaseHeader);

        // [THEN] Payment Order Line that corresponds to the Purchase Invoice will be created
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type::Vendor);
        PaymentOrderLineCZB.SetRange("No.", PurchaseHeader."Buy-from Vendor No.");
        PaymentOrderLineCZB.SetRange("Cust./Vendor Bank Account Code", PurchaseHeader."Bank Account Code CZL");
        PaymentOrderLineCZB.SetRange("Account No.", PurchaseHeader."Bank Account No. CZL");
        PaymentOrderLineCZB.SetRange("Amount (Paym. Order Currency)", PurchaseLine.Amount);
        Assert.IsFalse(PaymentOrderLineCZB.IsEmpty(), SuggestPaymentsErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckIssuePaymentOrder()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        // [SCENARIO] Issuing Payment Order and create Issued Payment Order
        Initialize();

        // [GIVEN] Payment Order has been created
        CreatePaymentOrder(PaymentOrderHeaderCZB, PaymentOrderLineCZB);

        // [WHEN] Execute process of issuing Payment Order
        IssuePaymentOrder(PaymentOrderHeaderCZB);

        // [THEN] Issued Payment Order Header will be created
        IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");

        // [THEN] Issued Payment Order Line will be created
        IssPaymentOrderLineCZB.Get(IssPaymentOrderHeaderCZB."No.", PaymentOrderLineCZB."Line No.");
    end;

    [Test]
    [HandlerFunctions('CopyPaymentOrderHandler,MessageHandler')]
    procedure CopyingPaymentOrderToBankStatement()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        CopyingPayOrderErr: Label 'Bank Statement Line was not created.';
    begin
        // [SCENARIO] Copying Payment Order to Bank Statement
        Initialize();

        // [GIVEN] Payment Order has been created
        CreatePaymentOrder(PaymentOrderHeaderCZB, PaymentOrderLineCZB);

        // [GIVEN] Execute process of issuing Payment Order
        IssuePaymentOrder(PaymentOrderHeaderCZB);

        // [WHEN] Create Bank Statement with lines of copied from Payment Order
        CreateBankStatementFromPaymentOrder(BankStatementHeaderCZB, PaymentOrderHeaderCZB);

        // [THEN] Bank Statement Line that corresponds to Account No. and Variable Symbol will be created
        BankStatementLineCZB.Reset();
        BankStatementLineCZB.SetRange("Bank Statement No.", BankStatementHeaderCZB."No.");
        BankStatementLineCZB.SetRange("Account No.", PaymentOrderLineCZB."Account No.");
        BankStatementLineCZB.SetRange("Variable Symbol", PaymentOrderLineCZB."Variable Symbol");
        BankStatementLineCZB.SetRange(Amount, -PaymentOrderLineCZB.Amount);
        Assert.IsFalse(BankStatementLineCZB.IsEmpty(), CopyingPayOrderErr);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler,MessageHandler')]
    procedure ApplyingBankStatementWithSalesInvoice()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentJournalLineErr: Label 'Payment Journal Line was not created.';
    begin
        // [SCENARIO] Applying bank statement with Sales Invoice and creating Payment Journal that corresponds to the Sales Invoice
        Initialize();

        // [GIVEN] Sales Invoice has been created and posted
        CreateSalesInvoice(SalesHeader, SalesLine);
        PostSalesDocument(SalesHeader);
        CustLedgerEntry.FindLast();
        CustLedgerEntry.CalcFields(Amount);

        // [GIVEN] Bank Statement line related to Customer Ledger Entry has been created
        LibraryBankDocumentsCZB.CreateBankStatementHeader(BankStatementHeaderCZB);
        LibraryBankDocumentsCZB.CreateBankStatementLine(BankStatementLineCZB, BankStatementHeaderCZB, BankingLineTypeCZB::" ", '', CustLedgerEntry.Amount, CustLedgerEntry."Variable Symbol CZL");
        BankStatementLineCZB.Modify(true);

        // [WHEN] Execute process of issuing and creating Gen. Journal Lines
        IssueBankStatementAndPrint(BankStatementHeaderCZB);

        // [THEN] Gen. Journal Line that corresponds to the Sales Invoice will be created
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", CustLedgerEntry."Customer No.");
        GenJournalLine.SetRange(Amount, -CustLedgerEntry.Amount);
        GenJournalLine.SetRange("Variable Symbol CZL", CustLedgerEntry."Variable Symbol CZL");
        Assert.IsFalse(GenJournalLine.IsEmpty(), PaymentJournalLineErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ErrorMessagesHandler')]
    procedure InvalidFormatBankAccountNoDuringIssuing()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        InvalidFormatBankAccountErr: Label 'Account No. %1 in Payment Order Line CZB: %2,%3 is malformed.', Comment = '%1 = Account No.; %2 = Payment Order No.; %3 = Line No.';
    begin
        // [SCENARIO] Test that invalid bank account no. will cause error during the issuing
        Initialize();

        // [GIVEN] Payment Order has been created
        CreatePaymentOrder(PaymentOrderHeaderCZB, PaymentOrderLineCZB);

        // [GIVEN] Invalid Bank Account No. has been set
        PaymentOrderLineCZB."Account No." := LibraryBankDocumentsCZB.GetInvalidBankAccountNo();
        PaymentOrderLineCZB.Modify(true);

        // [WHEN] Issue Payment Order
        asserterror IssuePaymentOrder(PaymentOrderHeaderCZB);

        // [THEN] Invalid Format Bank error will occur
        Assert.ExpectedError(
          StrSubstNo(InvalidFormatBankAccountErr, PaymentOrderLineCZB."Account No.", PaymentOrderLineCZB."Payment Order No.", PaymentOrderLineCZB."Line No."));
    end;

    [Test]
    [HandlerFunctions('SuggestPaymentsHandler,MessageHandler')]
    procedure BlockingEntriesToPaymentOrder()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderHeaderCZB2: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        BlockingEntriesErr: Label 'Payment Order Line was created.';
    begin
        // [SCENARIO] Test suggests that payment of the invoice within two Payment Orders
        Initialize();

        // [GIVEN] Purchase Invoice for payments suggestion has been created and posted
        CreatePurchaseInvoice(PurchaseHeader, PurchaseLine);
        PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] Payment Order from Purchase Invoice has been created
        CreatePaymentOrderFromPurchaseInvoice(PaymentOrderHeaderCZB, PurchaseHeader);

        // [WHEN] Create second Payment Order from Purchase Invoice
        CreatePaymentOrderFromPurchaseInvoice(PaymentOrderHeaderCZB2, PurchaseHeader);

        // [THEN] Second Payment Order will have no line
        PaymentOrderLineCZB.Reset();
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB2."No.");
        Assert.IsTrue(PaymentOrderLineCZB.IsEmpty(), BlockingEntriesErr);
    end;

    [Test]
    [HandlerFunctions('RequestPagePaymentOrderHandler,MessageHandler')]
    procedure PrintingIssuedPaymentOrder()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        // [SCENARIO] Print Issued Payment Order
        Initialize();

        // [GIVEN] Payment Order has been created
        CreatePaymentOrder(PaymentOrderHeaderCZB, PaymentOrderLineCZB);

        // [GIVEN] Payment Order has been issued
        IssuePaymentOrder(PaymentOrderHeaderCZB);
        IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");

        // [WHEN] Print Payment Order
        PrintPaymentOrder(IssPaymentOrderHeaderCZB);

        // [THEN] Report dataset will contain Issued Payment Order No.
        LibraryReportDataset.RunReportAndLoad(Report::"Iss. Payment Order CZB", IssPaymentOrderHeaderCZB, '');
        LibraryReportDataset.AssertElementWithValueExists('IssPaymentOrderHeader_No', IssPaymentOrderHeaderCZB."No.");

        // [THEN] Report dataset will contain Issued Payment Order Amount
        IssPaymentOrderHeaderCZB.CalcFields(Amount);
        LibraryReportDataset.AssertElementWithValueExists('IssPaymentOrderHeader_Amount', IssPaymentOrderHeaderCZB.Amount);
    end;

    [Test]
    [HandlerFunctions('SuggestPaymentsHandler,MessageHandler')]
    procedure SuggestPaymentsWithPaymentPartialSuggestion()
    var
        BankAccount: Record "Bank Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderHeaderCZB2: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedDocumentNo: Code[20];
        BlockingEntriesErr: Label 'Payment Order Line wasn''t created.';
        AmountMustBeCheckedErr: Label 'The "Amount Must Be Checked" field must be checked.';
    begin
        // [SCENARIO] When the "Payment Partial Suggestion" is allowed in bank account then the entry can be suggested into two different lines of payment order.
        //            The "Amount Must Be Checked" field on the second line must be checked.
        Initialize();

        // [GIVEN] The "Payment Partial Suggestion" field on bank account has beend checked
        LibraryBankDocumentsCZB.FindBankAccount(BankAccount);
        BankAccount."Payment Partial Suggestion CZB" := true;
        BankAccount.Modify();

        // [GIVEN] Purchase Invoice for payments suggestion has been created and posted
        CreatePurchaseInvoice(PurchaseHeader, PurchaseLine);
        PostedDocumentNo := PostPurchaseDocument(PurchaseHeader);

        // [GIVEN] Payment Order from Purchase Invoice has been created
        CreatePaymentOrderFromPurchaseInvoice(PaymentOrderHeaderCZB, PurchaseHeader);

        // [WHEN] Create second Payment Order from Purchase Invoice
        CreatePaymentOrderFromPurchaseInvoice(PaymentOrderHeaderCZB2, PurchaseHeader);

        // [THEN] Vendor Ledger Entry will created
        VendorLedgerEntry.SetRange("Document No.", PostedDocumentNo);
        VendorLedgerEntry.SetRange("Posting Date", PurchaseHeader."Posting Date");
        VendorLedgerEntry.FindFirst();

        // [THEN] The "Amount Must Be Checked" field on the second payment order will be checked
        PaymentOrderLineCZB.Reset();
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB2."No.");
        PaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", VendorLedgerEntry."Entry No.");
        Assert.IsTrue(PaymentOrderLineCZB.FindFirst(), BlockingEntriesErr);
        Assert.AreEqual(true, PaymentOrderLineCZB."Amount Must Be Checked", AmountMustBeCheckedErr);
    end;

    local procedure CreatePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var PaymentOrderLineCZB: Record "Payment Order Line CZB")
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryBankDocumentsCZB.CreatePaymentOrderHeader(PaymentOrderHeaderCZB);
        LibraryBankDocumentsCZB.FindBankAccount(BankAccount);
        LibraryBankDocumentsCZB.CreatePaymentOrderLine(
          PaymentOrderLineCZB, PaymentOrderHeaderCZB, PaymentOrderLineCZB.Type::"Bank Account", BankAccount."No.", LibraryRandom.RandInt(1000))
    end;

    local procedure CreatePaymentOrderFromPurchaseInvoice(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; PurchaseHeader: Record "Purchase Header")
    begin
        // Create payment order header
        LibraryBankDocumentsCZB.CreatePaymentOrderHeader(PaymentOrderHeaderCZB);
        PaymentOrderHeaderCZB.Validate("Payment Order Currency Code", PurchaseHeader."Currency Code");
        PaymentOrderHeaderCZB.Modify();

        // Create payment order lines from purchase invoice
        DefaultSuggestPayments(PaymentOrderHeaderCZB);
    end;

    local procedure CreateBankStatementFromPaymentOrder(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        ReqPageParams: array[10] of Variant;
    begin
        // Create bank statement header
        LibraryBankDocumentsCZB.CreateBankStatementHeader(BankStatementHeaderCZB);

        // Create bank statement lines from payment order
        ReqPageParams[1] := PaymentOrderHeaderCZB."Last Issuing No."; // Document No.
        CopyPaymentOrder(BankStatementHeaderCZB, ReqPageParams);
    end;

    local procedure CreatePurchaseInvoice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        FindVendor(Vendor);
        CreateVendorBankAccount(VendorBankAccount, Vendor);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Due Date", WorkDate());
        PurchaseHeader.Validate("Bank Account Code CZL", VendorBankAccount.Code);
        PurchaseHeader.Modify(true);

        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryBankDocumentsCZB.GetGLAccountNo(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
        PurchaseLine.Modify(true);
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');
        SalesHeader.Validate("Variable Symbol CZL", LibraryBankDocumentsCZB.GenerateVariableSymbol());
        SalesHeader.Modify(true);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryBankDocumentsCZB.GetGLAccountNo(), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandInt(1000));
        SalesLine.Modify(true);
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; Vendor: Record Vendor)
    begin
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        VendorBankAccount.Validate("Bank Account No.", LibraryBankDocumentsCZB.GetBankAccountNo());
        VendorBankAccount.Modify();
    end;

    local procedure FindVendor(var Vendor: Record Vendor)
    begin
        Vendor.SetFilter("Vendor Posting Group", '<>''''');
        Vendor.SetFilter("Gen. Bus. Posting Group", '<>''''');
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        Vendor.FindFirst();
    end;

    local procedure PostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure IssuePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        LibraryBankDocumentsCZB.IssuePaymentOrder(PaymentOrderHeaderCZB);
    end;

    local procedure PrintPaymentOrder(var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    begin
        Commit();
        LibraryBankDocumentsCZB.PrintPaymentOrder(IssPaymentOrderHeaderCZB, true);
    end;

    local procedure IssueBankStatementAndPrint(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
        LibraryBankDocumentsCZB.IssueBankStatementAndPrint(BankStatementHeaderCZB);
    end;

    local procedure DefaultSuggestPayments(PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        ReqPageParams: array[10] of Variant;
    begin
        ReqPageParams[1] := WorkDate();  // Last Payment Date
        ReqPageParams[2] := 1 + 1;       // Type Currency (Payment Order)
        ReqPageParams[3] := 1 + 0;       // Vendor Payables (Only Payable Balance)
        ReqPageParams[4] := 1 + 3;       // Customer Payables (No Suggest)
        ReqPageParams[5] := 1 + 1;       // Employee Payables (No Suggest)

        SuggestPayments(PaymentOrderHeaderCZB, ReqPageParams);
    end;

    local procedure SuggestPayments(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; ReqPageParams: array[10] of Variant)
    begin
        // Initialize parameters for request page handler
        LibraryVariableStorage.Enqueue(ReqPageParams[1]);
        LibraryVariableStorage.Enqueue(ReqPageParams[2]);
        LibraryVariableStorage.Enqueue(ReqPageParams[3]);
        LibraryVariableStorage.Enqueue(ReqPageParams[4]);
        LibraryVariableStorage.Enqueue(ReqPageParams[5]);

        LibraryBankDocumentsCZB.SuggestPayments(PaymentOrderHeaderCZB);
    end;

    local procedure CopyPaymentOrder(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; ReqPageParams: array[10] of Variant)
    begin
        // Initialize paramaters for request page handler
        LibraryVariableStorage.Enqueue(ReqPageParams[1]);

        LibraryBankDocumentsCZB.CopyPaymentOrder(BankStatementHeaderCZB);
    end;

    [RequestPageHandler]
    procedure SuggestPaymentsHandler(var SuggestPaymentsCZB: TestRequestPage "Suggest Payments CZB")
    var
        FieldValueVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        SuggestPaymentsCZB.LastDueDateToPayReqCZB.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        SuggestPaymentsCZB.CurrencyTypeCZB.SetValue(SuggestPaymentsCZB.CurrencyTypeCZB.GetOption(FieldValueVariant));
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        SuggestPaymentsCZB.VendorTypeCZB.SetValue(SuggestPaymentsCZB.VendorTypeCZB.GetOption(FieldValueVariant));
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        SuggestPaymentsCZB.CustomerTypeCZB.SetValue(SuggestPaymentsCZB.CustomerTypeCZB.GetOption(FieldValueVariant));
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        SuggestPaymentsCZB.EmployeeTypeCZB.SetValue(SuggestPaymentsCZB.EmployeeTypeCZB.GetOption(FieldValueVariant));
        SuggestPaymentsCZB.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure CopyPaymentOrderHandler(var CopyPaymentOrderCZB: TestRequestPage "Copy Payment Order CZB")
    var
        FieldValueVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CopyPaymentOrderCZB.DocNoCZB.SetValue(FieldValueVariant);
        CopyPaymentOrderCZB.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPagePaymentOrderHandler(var IssPaymentOrderCZB: TestRequestPage "Iss. Payment Order CZB")
    begin
        // Empty handler
    end;

    [PageHandler]
    procedure ErrorMessagesHandler(var ErrorMessages: TestPage "Error Messages")
    begin
        Error(ErrorMessages.Description.Value);
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    var
        IssueBankStatementQst: Label '&Issue,Issue and &Create Journal';
    begin
        case Options of
            IssueBankStatementQst:
                Choice := 2;
        end;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        exit;
    end;
}
