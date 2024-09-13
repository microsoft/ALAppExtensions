namespace Microsoft.SubscriptionBilling;

using System.Security.User;
using Microsoft.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 139912 "Customer Deferrals Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        CustomerContract: Record "Customer Contract";
        Customer: Record Customer;
        Item: Record Item;
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        BillingTemplate: Record "Billing Template";
        BillingLine: Record "Billing Line";
        ServiceObject: Record "Service Object";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustomerContractDeferral: Record "Customer Contract Deferral";
        SalesInvoiceDeferral: Record "Customer Contract Deferral";
        SalesCrMemoDeferral: Record "Customer Contract Deferral";
        SalesLine: Record "Sales Line";
        UserSetup: Record "User Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibrarySales: Codeunit "Library - Sales";
        AssertThat: Codeunit Assert;
        PostingDate: Date;
        PostedDocumentNo: Code[20];
        CorrectedDocumentNo: Code[20];
        CustomerDeferralsCount: Integer;
        FirstMonthDefBaseAmount: Decimal;
        LastMonthDefBaseAmount: Decimal;
        MonthlyDefBaseAmount: Decimal;
        DeferralBaseAmount: Decimal;
        TotalNumberOfMonths: Integer;
        PrevGLEntry: Integer;

    local procedure CreateCustomerContractWithDeferrals(BillingDateFormula: Text; IsCustomerContractLCY: Boolean)
    begin
        ClearAll();
        GLSetup.Get();
        if IsCustomerContractLCY then
            ContractTestLibrary.CreateCustomerInLCY(Customer)
        else
            ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        Item.Validate("Unit Price", 1200);
        Item.Modify(false);

        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");

        ServiceObject.Validate("Quantity Decimal", 1);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 10, Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price");

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, Item."No.");

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(CalcDate(BillingDateFormula, WorkDate()), ServiceCommitmentPackage);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
    end;

    local procedure CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula: Text; BillingToDateFormula: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, BillingDateFormula, BillingToDateFormula, '', Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine); //CreateCustomerBillingDocsContractPageHandler, MessageHandler
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorOnPostSalesDocumentWithDeferralsWOGeneralPostingSetup()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                ContractTestLibrary.SetGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group", true, Enum::"Service Partner"::Customer);
            until SalesLine.Next() = 0;
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorOnPreviewPostSalesDocumentWithDeferrals()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        asserterror LibrarySales.PreviewPostSalesDocument(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostSalesDocument()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesHeaderAndFetchCustContractDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostSalesCreditMemo()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);
        FetchCustomerContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectEqualBillingMonthsNumberAndCustContractDeferrals()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        CalculateNumberOfBillingMonths();
        PostSalesDocumentAndGetSalesInvoice();

        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetRange("Document No.", PostedDocumentNo);
        CustomerDeferralsCount := CustomerContractDeferral.Count;
        AssertThat.AreEqual(CustomerDeferralsCount, TotalNumberOfMonths, 'Number of Customer deferrals must be the same as total number of billing months');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullOnAfterPostSalesCrMemo()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        SalesCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        SalesInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        AssertThat.AreEqual(SalesInvoiceDeferral.Count, SalesCrMemoDeferral.Count, 'Deferrals were not corrected properly.');

        CustomerContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        CustomerContractDeferral.SetRange(Released, true);
        CustomerContractDeferral.CalcSums(Amount, "Discount Amount");
        AssertThat.AreEqual(0, CustomerContractDeferral.Amount, 'Deferrals were not corrected properly.');
        AssertThat.AreEqual(0, CustomerContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestSalesCrMemoDeferrals()
    begin
        SetPostingAllowTo(WorkDate());
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();
        FetchCustomerContractDeferrals(PostedDocumentNo);
        PostSalesCreditMemoAndFetchDeferrals();
        repeat
            SalesCrMemoDeferral.TestField("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
            SalesCrMemoDeferral.TestField("Document No.", CorrectedDocumentNo);
            SalesCrMemoDeferral.TestField("Posting Date", CustomerContractDeferral."Posting Date");
            SalesCrMemoDeferral.TestField("Release Posting Date", SalesCrMemoHeader."Posting Date");
            CustomerContractDeferral.Next();
        until SalesCrMemoDeferral.Next() = 0;
    end;


    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestSalesInvoiceDeferralsOnAfterPostSalesCrMemo()
    begin
        SetPostingAllowTo(WorkDate());
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();
        PostSalesCreditMemoAndFetchDeferrals();

        SalesInvoiceDeferral.SetRange("Document No.", PostedDocumentNo); //Fetch updated Sales Invoice Deferral
        SalesInvoiceDeferral.FindFirst();
        TestGLEntryFields(SalesInvoiceDeferral."G/L Entry No.", SalesInvoiceDeferral);
        repeat
            TestSalesInvoiceDeferralsReleasedFields(SalesInvoiceDeferral, SalesCrMemoHeader."Posting Date");
        until SalesInvoiceDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestReleasingCustomerContractDeferrals()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        // [SCENARIO] Making sure that Deferrals are properly realease and contain Contract No. on GLEntries

        // [GIVEN] Contract has been created and the billing proposal with unposted contract invoice
        SetPostingAllowTo(0D);
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        // [WHEN] Post the contract invoice
        PostSalesHeaderAndFetchCustContractDeferrals();

        // [THEN] Releasing each defferal entry should be correct
        repeat
            PostingDate := CustomerContractDeferral."Posting Date";
            ContractDeferralsRelease.Run();  // ContractDeferralsReleaseRequestPageHandler
            CustomerContractDeferral.Get(CustomerContractDeferral."Entry No.");
            GLEntry.Get(CustomerContractDeferral."G/L Entry No.");
            GLEntry.TestField("Sub. Contract No.", CustomerContractDeferral."Contract No.");
            FetchAndTestUpdatedCustomerContractDeferral(CustomerContractDeferral);
        until CustomerContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullAfterPostSalesCrMemoOfReleasedDeferrals()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        SetPostingAllowTo(0D);
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        //Release only first Customer Contract Deferral
        PostSalesHeaderAndFetchCustContractDeferrals();
        PostingDate := CustomerContractDeferral."Posting Date";
        ContractDeferralsRelease.Run();  // ContractDeferralsReleaseRequestPageHandler

        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        CustomerContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        CustomerContractDeferral.SetRange(Released, true);
        CustomerContractDeferral.CalcSums(Amount, "Discount Amount");
        AssertThat.AreEqual(0, CustomerContractDeferral.Amount, 'Deferrals were not corrected properly.');
        AssertThat.AreEqual(0, CustomerContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]

    procedure ExpectErrorIfDeferralsExistOnAfterPostSalesDocumentWODeferrals()
    begin
        CreateSalesDocumentsFromCustomerContractWODeferrals();
        asserterror PostSalesHeaderAndFetchCustContractDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCaclulatedForFullYearLCY()
    begin
        CreateCustomerContractWithDeferrals('<-CY>', true);
        CreateBillingProposalAndCreateBillingDocuments('<-CY>', '<CY>');

        PostSalesHeaderAndFetchCustContractDeferrals();
        repeat
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField(Amount, -10);
            CustomerContractDeferral.TestField("Deferral Base Amount", -120);
            CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
        until CustomerContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearLCY()
    var
        i: Integer;
        CustomerDeferalCount: Integer;
    begin
        SetSalesDocumentAndCustomerContractDeferrals('<-CY+14D>', '<CY+14D>', true, 11, CustomerDeferalCount);
        for i := 1 to CustomerDeferalCount do begin
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount * -1);
            case i of
                1:
                    begin
                        CustomerContractDeferral.TestField(Amount, FirstMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 17);
                    end;
                CustomerDeferalCount:
                    begin
                        CustomerContractDeferral.TestField(Amount, LastMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 14);
                    end;
                else begin
                    CustomerContractDeferral.TestField(Amount, MonthlyDefBaseAmount * -1);
                    CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
                end;
            end;
            CustomerContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForPartialYearLCY()
    var
        i: Integer;
        CustomerDeferalCount: Integer;
    begin
        SetSalesDocumentAndCustomerContractDeferrals('<-CY+14D>', '<CY-1M-9D>', true, 9, CustomerDeferalCount);
        for i := 1 to CustomerDeferalCount do begin
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount * -1);
            case i of
                1:
                    begin
                        CustomerContractDeferral.TestField(Amount, FirstMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 17);
                    end;
                CustomerDeferalCount:
                    begin
                        CustomerContractDeferral.TestField(Amount, LastMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 21);
                    end;
                else begin
                    CustomerContractDeferral.TestField(Amount, MonthlyDefBaseAmount * -1);
                    CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
                end;
            end;
            CustomerContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCaclulatedForFullYearFCY()
    begin
        CreateCustomerContractWithDeferrals('<-CY>', false);
        CreateBillingProposalAndCreateBillingDocuments('<-CY>', '<CY>');

        DeferralBaseAmount := GetDeferralBaseAmount();
        PostSalesHeaderAndFetchCustContractDeferrals();
        repeat
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField(Amount, Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code",
                                                    -5,
                                                    SalesHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            CustomerContractDeferral.TestField("Deferral Base Amount", Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code",
                                                    -60,
                                                    SalesHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
        until CustomerContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearFCY()
    var
        i: Integer;
        CustomerDeferalCount: Integer;
    begin
        SetSalesDocumentAndCustomerContractDeferrals('<-CY+14D>', '<CY+14D>', false, 11, CustomerDeferalCount);
        for i := 1 to CustomerDeferalCount do begin
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField("Deferral Base Amount", Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code",
                                                    DeferralBaseAmount * -1,
                                                    SalesHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            case i of
                1:
                    begin
                        CustomerContractDeferral.TestField(Amount, FirstMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 17);
                    end;
                CustomerDeferalCount:
                    begin
                        CustomerContractDeferral.TestField(Amount, LastMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 14);
                    end;
                else begin
                    CustomerContractDeferral.TestField(Amount, MonthlyDefBaseAmount * -1);
                    CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
                end;
            end;
            CustomerContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForPartialYearFCY()
    var
        i: Integer;
        CustomerDeferalCount: Integer;
    begin
        SetSalesDocumentAndCustomerContractDeferrals('<-CY+14D>', '<CY-1M-9D>', false, 9, CustomerDeferalCount);
        for i := 1 to CustomerDeferalCount do begin
            TestCustomerContractDeferralsFields();
            CustomerContractDeferral.TestField("Deferral Base Amount", CurrExchRate.ExchangeAmtFCYToLCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code",
                                                    DeferralBaseAmount * -1,
                                                    SalesHeader."Currency Factor"));
            case i of
                1:
                    begin
                        CustomerContractDeferral.TestField(Amount, FirstMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 17);
                    end;
                CustomerDeferalCount:
                    begin
                        CustomerContractDeferral.TestField(Amount, LastMonthDefBaseAmount * -1);
                        CustomerContractDeferral.TestField("Number of Days", 21);
                    end;
                else begin
                    CustomerContractDeferral.TestField(Amount, MonthlyDefBaseAmount * -1);
                    CustomerContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', CustomerContractDeferral."Posting Date"), 1));
                end;
            end;
            CustomerContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure ExpectAmountOnContractDeferralAccountToBeZero()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
        StartingGLAmount: Decimal;
        GLAmountAfterInvoicing: Decimal;
        FinalGLAmount: Decimal;
        GLAmountAfterRelease: Decimal;
    begin
        SetPostingAllowTo(0D);
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        GeneralPostingSetup.Get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        //After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Cust. Contr. Deferral Account");

        //Release only first Customer Contract Deferral
        PostSalesHeaderAndFetchCustContractDeferrals();
        PostingDate := CustomerContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Cust. Contr. Deferral Account");

        //Expect Amount on GL Account to be decreased by Released Customer Deferral
        ContractDeferralsRelease.Run();  // ContractDeferralsReleaseRequestPageHandler
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Cust. Contr. Deferral Account");
        AssertThat.AreEqual(GLAmountAfterInvoicing - CustomerContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Cust. Contr. Deferral Account");
        AssertThat.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestCorrectReleasedSalesInvoiceDeferrals()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        //Step 1 Create contract invoice with deferrals
        //Step 2 Release deferrals
        //Step 3 Correct posted sales invoice
        //Expectation:
        // -Customer Contract Deferrals with opposite sign are created
        // -Invoice Contract Deferrals are released
        // -Credit Memo Contract Deferrals are released
        // -GL Entries are posted on the Credit Memo Posting date
        SetPostingAllowTo(0D);
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesHeaderAndFetchCustContractDeferrals();

        PostingDate := CustomerContractDeferral."Posting Date"; //Used in request page handler
        ContractDeferralsRelease.Run(); // ContractDeferralsReleaseRequestPageHandler
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        PostingDate := SalesCrMemoHeader."Posting Date";
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetRange("Document No.", CorrectedDocumentNo, PostedDocumentNo);
        CustomerContractDeferral.SetRange(Released, false);
        asserterror CustomerContractDeferral.FindFirst();

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", CorrectedDocumentNo);
        if GLEntry.FindSet() then
            repeat
                GLEntry.TestField("Posting Date", PostingDate);
            until GLEntry.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostSalesCreditMemoWithoutAppliesToDocNo()
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        //Force Applies to Doc No. and Doc Type to be empty
        SalesCrMemoHeader."Applies-to Doc. Type" := SalesCrMemoHeader."Applies-to Doc. Type"::Invoice;
        SalesCrMemoHeader."Applies-to Doc. No." := '';
        SalesCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);
        FetchCustomerContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectThatDeferralsForSalesCreditMemoAreCreateOnce()
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostSalesDocumentAndGetSalesInvoice();

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);
        FetchCustomerContractDeferrals(CorrectedDocumentNo);

        SalesCrMemoHeader.Init();
        SalesCrMemoHeader.Validate("Document Type", SalesCrMemoHeader."Document Type"::"Credit Memo");
        SalesCrMemoHeader.Validate("Sell-to Customer No.", SalesInvoiceHeader."Sell-to Customer No.");
        SalesCrMemoHeader.Insert(true);

        CopyDocumentMgt.CopySalesDoc(Enum::"Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);
        asserterror FetchCustomerContractDeferrals(CorrectedDocumentNo);
    end;

    procedure CreateSalesDocumentsFromCustomerContractWODeferrals()
    begin
        ClearAll();
        CreateCustomerContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        CustomerContract."Without Contract Deferrals" := true;
        CustomerContract.Modify(false);
    end;

    local procedure TestCustomerContractDeferralsFields()
    begin
        CustomerContractDeferral.TestField("Contract No.", BillingLine."Contract No.");
        CustomerContractDeferral.TestField("Document No.", PostedDocumentNo);
        CustomerContractDeferral.TestField("Customer No.", SalesHeader."Sell-to Customer No.");
        CustomerContractDeferral.TestField("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        CustomerContractDeferral.TestField("Document Posting Date", SalesHeader."Posting Date");
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure CalculateNumberOfBillingMonths()
    var
        StartingDate: Date;
    begin
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.FindSet();
        repeat
            StartingDate := SalesLine."Recurring Billing from";
            repeat
                TotalNumberOfMonths += 1;
                StartingDate := CalcDate('<1M>', StartingDate);
            until StartingDate > CalcDate('<CM>', SalesLine."Recurring Billing to");
        until SalesLine.Next() = 0;
    end;

    local procedure GetCalculatedMonthAmountsForDeferrals(SourceDeferralBaseAmount: Decimal; NumberOfPeriods: Integer; FirstDayOfBillingPeriod: Date; LastDayOfBillingPeriod: Date; CalculateInLCY: Boolean)
    var
        DailyDefBaseAmount: Decimal;
        FirstMonthDays: Integer;
        LastMonthDays: Integer;
    begin
        DailyDefBaseAmount := SourceDeferralBaseAmount / (LastDayOfBillingPeriod - FirstDayOfBillingPeriod + 1);
        if not CalculateInLCY then begin
            DailyDefBaseAmount := CurrExchRate.ExchangeAmtFCYToLCY(SalesHeader."Posting Date", SalesHeader."Currency Code", DailyDefBaseAmount, SalesHeader."Currency Factor");
            SourceDeferralBaseAmount := CurrExchRate.ExchangeAmtFCYToLCY(SalesHeader."Posting Date", SalesHeader."Currency Code", SourceDeferralBaseAmount, SalesHeader."Currency Factor");
        end;
        FirstMonthDays := CalcDate('<CM>', FirstDayOfBillingPeriod) - FirstDayOfBillingPeriod + 1;
        FirstMonthDefBaseAmount := Round(FirstMonthDays * DailyDefBaseAmount, GLSetup."Amount Rounding Precision");
        LastMonthDays := Date2DMY(LastDayOfBillingPeriod, 1);
        LastMonthDefBaseAmount := Round(LastMonthDays * DailyDefBaseAmount, GLSetup."Amount Rounding Precision");
        MonthlyDefBaseAmount := Round((SourceDeferralBaseAmount - FirstMonthDefBaseAmount - LastMonthDefBaseAmount) / NumberOfPeriods, GLSetup."Amount Rounding Precision");
        LastMonthDefBaseAmount := SourceDeferralBaseAmount - MonthlyDefBaseAmount * NumberOfPeriods - FirstMonthDefBaseAmount;
    end;

    local procedure TestGLEntryFields(EntryNo: Integer; UpdatedCustomerContractDeferral: Record "Customer Contract Deferral")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Get(EntryNo);
        GLEntry.TestField("Document No.", UpdatedCustomerContractDeferral."Document No.");
        GLEntry.TestField("Dimension Set ID", UpdatedCustomerContractDeferral."Dimension Set ID");
        GLEntry.TestField("Sub. Contract No.", UpdatedCustomerContractDeferral."Contract No.");
    end;

    local procedure SetPostingAllowTo(PostingTo: Date)
    begin
        if UserSetup.Get(UserId) then begin
            UserSetup."Allow Posting From" := 0D;
            UserSetup."Allow Posting To" := PostingTo;
            UserSetup.Modify(false);
        end;
        GLSetup.Get();
        GLSetup."Allow Posting From" := 0D;
        GLSetup."Allow Posting To" := PostingTo;
        GLSetup.Modify(false);
    end;

    local procedure TestSalesInvoiceDeferralsReleasedFields(DeferralsToTest: Record "Customer Contract Deferral"; DocumentPostingDate: Date)
    begin
        DeferralsToTest.TestField("Release Posting Date", DocumentPostingDate);
        DeferralsToTest.TestField(Released, true);
    end;

    local procedure FetchAndTestUpdatedCustomerContractDeferral(CustomerDeferrals: Record "Customer Contract Deferral")
    var
        UpdatedCustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        UpdatedCustomerContractDeferral.Get(CustomerDeferrals."Entry No.");
        AssertThat.AreNotEqual(PrevGLEntry, UpdatedCustomerContractDeferral."G/L Entry No.", 'G/L Entry No. is not properly assigned');
        TestSalesInvoiceDeferralsReleasedFields(UpdatedCustomerContractDeferral, PostingDate);
        TestGLEntryFields(UpdatedCustomerContractDeferral."G/L Entry No.", UpdatedCustomerContractDeferral);
        PrevGLEntry := UpdatedCustomerContractDeferral."G/L Entry No.";
    end;

    procedure GetDeferralBaseAmount(): Decimal
    begin
        SalesLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        exit(SalesLine.Amount);
    end;

    local procedure FetchCustomerContractDeferrals(DocumentNo: Code[20])
    begin
        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetRange("Document No.", DocumentNo);
        CustomerContractDeferral.FindFirst();
    end;

    local procedure PostSalesHeaderAndFetchCustContractDeferrals()
    begin
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchCustomerContractDeferrals(PostedDocumentNo);
    end;

    local procedure PostSalesDocumentAndGetSalesInvoice()
    begin
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
    end;

    local procedure SetSalesDocumentAndCustomerContractDeferrals(BillingDateFormula: Text; BillingToDateFormula: Text; CalculateInLCY: Boolean; NumberOfPeriods: Integer; var CustomerDeferalCount: Integer)
    begin
        CreateCustomerContractWithDeferrals(BillingDateFormula, true);
        CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula, BillingToDateFormula);

        DeferralBaseAmount := GetDeferralBaseAmount();
        PostSalesHeaderAndFetchCustContractDeferrals();
        CustomerDeferalCount := CustomerContractDeferral.Count;
        GetCalculatedMonthAmountsForDeferrals(DeferralBaseAmount, NumberOfPeriods, CalcDate(BillingDateFormula, WorkDate()), CalcDate(BillingToDateFormula, WorkDate()), CalculateInLCY);
    end;

    local procedure PostSalesCreditMemoAndFetchDeferrals()
    begin
        SalesInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        SalesInvoiceDeferral.FindFirst();
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        SalesCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        SalesCrMemoDeferral.FindFirst();
    end;

    local procedure GetGLEntryAmountFromAccountNo(var GlEntryAmount: Decimal; GLAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.CalcSums(Amount);
        GlEntryAmount := GLEntry.Amount;
    end;

    [RequestPageHandler]
    procedure ContractDeferralsReleaseRequestPageHandler(var ContractDeferralsRelease: TestRequestPage "Contract Deferrals Release")
    begin
        ContractDeferralsRelease.PostingDateReq.SetValue(PostingDate);
        ContractDeferralsRelease.PostUntilDateReq.SetValue(PostingDate);
        ContractDeferralsRelease.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure ExpectAmountOnContractDeferralAccountToBeZeroForContractLinesWithDiscount()
    var
        ServiceCommitment: Record "Service Commitment";
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
        StartingGLAmount: Decimal;
        GLAmountAfterInvoicing: Decimal;
        FinalGLAmount: Decimal;
        GLAmountAfterRelease: Decimal;
        GLLineDiscountAmountAfterInvoicing: Decimal;
    begin
        SetPostingAllowTo(0D);
        CreateCustomerContractWithDeferrals('<2M-CM>', true);

        // use discounts on Service Commitment
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.Validate("Discount %", 10);
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        GeneralPostingSetup.Get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        GeneralPostingSetup.TestField("Sales Line Disc. Account");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        GLEntry.DeleteAll(false);

        //After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Cust. Contr. Deferral Account");

        //Release only first Customer Contract Deferral
        PostSalesHeaderAndFetchCustContractDeferrals();
        PostingDate := CustomerContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Cust. Contr. Deferral Account");
        GetGLEntryAmountFromAccountNo(GLLineDiscountAmountAfterInvoicing, GeneralPostingSetup."Sales Line Disc. Account");
        AssertThat.AreEqual(0, GLLineDiscountAmountAfterInvoicing, 'There should not be amount posted into Sales Line Discount Account.');

        //Expect Amount on GL Account to be decreased by Released Customer Deferral
        ContractDeferralsRelease.Run(); // ContractDeferralsReleaseRequestPageHandler
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Cust. Contr. Deferral Account");
        AssertThat.AreEqual(GLAmountAfterInvoicing - CustomerContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesCrMemoHeader);
        CorrectedDocumentNo := LibrarySales.PostSalesDocument(SalesCrMemoHeader, true, true);

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Cust. Contr. Deferral Account");
        AssertThat.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;
}