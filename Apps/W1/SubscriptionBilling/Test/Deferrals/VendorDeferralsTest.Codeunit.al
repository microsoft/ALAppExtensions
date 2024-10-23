namespace Microsoft.SubscriptionBilling;

using System.Security.User;
using Microsoft.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 139913 "Vendor Deferrals Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        VendorContract: Record "Vendor Contract";
        Vendor: Record Vendor;
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
        PurchaseHeader: Record "Purchase Header";
        PurchaseCrMemoHeader: Record "Purchase Header";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        VendorContractDeferral: Record "Vendor Contract Deferral";
        PurchaseInvoiceDeferral: Record "Vendor Contract Deferral";
        PurchaseCrMemoDeferral: Record "Vendor Contract Deferral";
        PurchaseLine: Record "Purchase Line";
        UserSetup: Record "User Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        AssertThat: Codeunit Assert;
        PostingDate: Date;
        PostedDocumentNo: Code[20];
        CorrectedDocumentNo: Code[20];
        VendorDeferralsCount: Integer;
        FirstMonthDefBaseAmount: Decimal;
        LastMonthDefBaseAmount: Decimal;
        MonthlyDefBaseAmount: Decimal;
        DeferralBaseAmount: Decimal;
        PrevGLEntry: Integer;
        TotalNumberOfMonths: Integer;

    local procedure CreateVendorContractWithDeferrals(BillingDateFormula: Text; IsVendorContractLCY: Boolean)
    var
        ContractsTestSubscriber: Codeunit "Contracts Test Subscriber";
    begin
        ClearAll();
        GLSetup.Get();
        if IsVendorContractLCY then
            ContractTestLibrary.CreateVendorInLCY(Vendor)
        else
            ContractTestLibrary.CreateVendor(Vendor);

        ContractsTestSubscriber.SetCallerName('VendorDeferralsTest - CreatePurchaseDocumentsFromVendorContractWithDeferrals');
        BindSubscription(ContractsTestSubscriber);

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.");
        UnbindSubscription(ContractsTestSubscriber);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 10, Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price");

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Vendor, Item."No.");

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(CalcDate(BillingDateFormula, WorkDate()), ServiceCommitmentPackage);

        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
    end;

    local procedure CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula: Text; BillingToDateFormula: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, BillingDateFormula, BillingToDateFormula, '', Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine); //CreateVendorBillingDocsContractPageHandler, MessageHandler
        BillingLine.FindLast();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorOnPostPurchDocumentWithDeferralsWOGeneralPostingSetup()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                ContractTestLibrary.SetGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group", true, Enum::"Service Partner"::Vendor);
            until PurchaseLine.Next() = 0;
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorOnPreviewPostPurchDocumentWithDeferrals()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        asserterror LibraryPurchase.PreviewPostPurchaseDocument(PurchaseHeader);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostPurchDocument()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostPurchCreditMemo()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemo();
        FetchVendorContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectEqualBillingMonthsNumberAndVendContractDeferrals()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        CalculateNumberOfBillingMonths();
        PostPurchDocumentAndGetPurchInvoice();

        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", PostedDocumentNo);
        VendorDeferralsCount := VendorContractDeferral.Count;
        AssertThat.AreEqual(VendorDeferralsCount, TotalNumberOfMonths, 'Number of Vendor deferrals must be the same as total number of billing months');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullOnAfterPostPurchCrMemo()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemo();

        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        AssertThat.AreEqual(PurchaseInvoiceDeferral.Count, PurchaseCrMemoDeferral.Count, 'Deferrals were not corrected properly.');

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.SetRange(Released, true);
        VendorContractDeferral.CalcSums(Amount, "Discount Amount");
        AssertThat.AreEqual(0, VendorContractDeferral.Amount, 'Deferrals were not corrected properly.');
        AssertThat.AreEqual(0, VendorContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestPurchaseCrMemoDeferrals()
    begin
        SetPostingAllowTo(WorkDate());
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        PostPurchDocumentAndGetPurchInvoice();
        FetchVendorContractDeferrals(PostedDocumentNo);
        PostPurchCreditMemoAndFetchDeferrals();
        repeat
            PurchaseCrMemoDeferral.TestField("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
            PurchaseCrMemoDeferral.TestField("Document No.", CorrectedDocumentNo);
            PurchaseCrMemoDeferral.TestField("Posting Date", VendorContractDeferral."Posting Date");
            PurchaseCrMemoDeferral.TestField("Release Posting Date", PurchaseCrMemoHeader."Posting Date");
            VendorContractDeferral.Next();
        until PurchaseCrMemoDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorIfDeferralsExistsAfterPostPurchaseDocumentWODeferrals()
    begin
        CreatePurchaseDocumentsFromVendorContractWODeferrals();
        BillingLine.FindLast();
        asserterror PostPurchDocumentAndFetchDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestPurchInvoiceDeferralsOnAfterPostPurchCrMemo()
    begin
        SetPostingAllowTo(WorkDate());
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemoAndFetchDeferrals();

        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo); //Fetch updated Purchase Invoice Deferral
        PurchaseInvoiceDeferral.FindFirst();
        TestGLEntryFields(PurchaseInvoiceDeferral."G/L Entry No.", PurchaseInvoiceDeferral);
        repeat
            TestPurchaseInvoiceDeferralsReleasedFields(PurchaseInvoiceDeferral, PurchaseCrMemoHeader."Posting Date");
        until PurchaseInvoiceDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestReleasingVendorContractDeferrals()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        // [SCENARIO] Making sure that Deferrals are properly realease and contain Contract No. on GLEntries

        // [GIVEN] Contract has been created and the billing proposal with unposted contract invoice
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        // [WHEN] Post the contract invoice
        PostPurchDocumentAndFetchDeferrals();

        // [THEN] Releasing each defferal entry should be correct
        repeat
            PostingDate := VendorContractDeferral."Posting Date";
            ContractDeferralsRelease.Run();
            VendorContractDeferral.Get(VendorContractDeferral."Entry No.");
            GLEntry.Get(VendorContractDeferral."G/L Entry No.");
            GLEntry.TestField("Sub. Contract No.", VendorContractDeferral."Contract No.");
            FetchAndTestUpdatedVendorContractDeferral();
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullAfterPostPurchCrMemoOfReleasedDeferrals()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();
        //Release only first Vendor Contract Deferral
        PostingDate := VendorContractDeferral."Posting Date";
        ContractDeferralsRelease.Run();

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.SetRange(Released, true);
        VendorContractDeferral.CalcSums(Amount, "Discount Amount");
        AssertThat.AreEqual(0, VendorContractDeferral.Amount, 'Deferrals were not corrected properly.');
        AssertThat.AreEqual(0, VendorContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCaclulatedForFullYearLCY()
    begin
        CreateVendorContractWithDeferrals('<-CY>', true);
        CreateBillingProposalAndCreateBillingDocuments('<-CY>', '<CY>');

        PostPurchDocumentAndFetchDeferrals();
        repeat
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField(Amount, 10);
            VendorContractDeferral.TestField("Deferral Base Amount", 120);
            VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearLCY()
    var
        i: Integer;
        VendorDeferalCount: Integer;
    begin
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY+14D>', true, 11, VendorDeferalCount);
        for i := 1 to VendorDeferalCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount);
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferalCount:
                    begin
                        VendorContractDeferral.TestField(Amount, LastMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 14);
                    end;
                else begin
                    VendorContractDeferral.TestField(Amount, MonthlyDefBaseAmount);
                    VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
                end;
            end;
            VendorContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForPartialYearLCY()
    var
        i: Integer;
        VendorDeferalCount: Integer;
    begin
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY-1M-9D>', true, 9, VendorDeferalCount);
        for i := 1 to VendorDeferalCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount);
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferalCount:
                    begin
                        VendorContractDeferral.TestField(Amount, LastMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 21);
                    end;
                else begin
                    VendorContractDeferral.TestField(Amount, MonthlyDefBaseAmount);
                    VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
                end;
            end;
            VendorContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCalculatedForFullYearFCY()
    begin
        CreateVendorContractWithDeferrals('<-CY>', false);
        CreateBillingProposalAndCreateBillingDocuments('<-CY>', '<CY>');
        DeferralBaseAmount := GetDeferralBaseAmount();
        PostPurchDocumentAndFetchDeferrals();
        repeat
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField(Amount, Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    PurchaseHeader."Posting Date",
                                                    PurchaseHeader."Currency Code",
                                                    5,
                                                    PurchaseHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            VendorContractDeferral.TestField("Deferral Base Amount", Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    PurchaseHeader."Posting Date",
                                                    PurchaseHeader."Currency Code",
                                                    60,
                                                    PurchaseHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearFCY()
    var
        i: Integer;
        VendorDeferalCount: Integer;
    begin
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY+14D>', false, 11, VendorDeferalCount);
        for i := 1 to VendorDeferalCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                    PurchaseHeader."Posting Date",
                                                    PurchaseHeader."Currency Code",
                                                    DeferralBaseAmount,
                                                    PurchaseHeader."Currency Factor"), GLSetup."Amount Rounding Precision"));
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferalCount:
                    begin
                        VendorContractDeferral.TestField(Amount, LastMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 14);
                    end;
                else begin
                    VendorContractDeferral.TestField(Amount, MonthlyDefBaseAmount);
                    VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
                end;
            end;
            VendorContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForPartialYearFCY()
    var
        i: Integer;
        VendorDeferalCount: Integer;
    begin
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY-1M-9D>', false, 9, VendorDeferalCount);
        for i := 1 to VendorDeferalCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", CurrExchRate.ExchangeAmtFCYToLCY(
                                                    PurchaseHeader."Posting Date",
                                                    PurchaseHeader."Currency Code",
                                                    DeferralBaseAmount,
                                                    PurchaseHeader."Currency Factor"));
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferalCount:
                    begin
                        VendorContractDeferral.TestField(Amount, LastMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 21);
                    end;
                else begin
                    VendorContractDeferral.TestField(Amount, MonthlyDefBaseAmount);
                    VendorContractDeferral.TestField("Number of Days", Date2DMY(CalcDate('<CM>', VendorContractDeferral."Posting Date"), 1));
                end;
            end;
            VendorContractDeferral.Next();
        end;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ContractDeferralsReleaseRequestPageHandler')]
    procedure ExpectAmountOnContractDeferralAccountToBeZero()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
        StartingGLAmount: Decimal;
        GLAmountAfterInvoicing: Decimal;
        FinalGLAmount: Decimal;
        GLAmountAfterRelease: Decimal;
    begin
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        //After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Vend. Contr. Deferral Account");

        //Release only first Vendor Contract Deferral
        PostPurchDocumentAndFetchDeferrals();
        PostingDate := VendorContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Vend. Contr. Deferral Account");

        //Expect Amount on GL Account to be decreased by Released Vendor Deferral
        ContractDeferralsRelease.Run();
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Vend. Contr. Deferral Account");
        AssertThat.AreEqual(GLAmountAfterInvoicing - VendorContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Vend. Contr. Deferral Account");
        AssertThat.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestCorrectReleasedPurchaseInvoiceDeferrals()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        //Step 1 Create contract invoice with deferrals
        //Step 2 Release deferrals
        //Step 3 Correct posted purchase invoice
        //Expectation:
        // -Vendor Contract Deferrals with opposite sign are created
        // -Invoice Contract Deferrals are released
        // -Credit Memo Contract Deferrals are released
        // -GL Entries are posted on the Credit Memo Posting date
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();

        PostingDate := VendorContractDeferral."Posting Date"; //Used in request page handler
        ContractDeferralsRelease.Run();
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader.Modify(false);
        PostingDate := PurchaseCrMemoHeader."Posting Date";
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);

        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", CorrectedDocumentNo, PostedDocumentNo);
        VendorContractDeferral.SetRange(Released, false);
        asserterror VendorContractDeferral.FindFirst();

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", CorrectedDocumentNo);
        if GLEntry.FindSet() then
            repeat
                GLEntry.TestField("Posting Date", PostingDate);
            until GLEntry.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostPurchCreditMemoWithoutAppliesToDocNo()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader."Applies-to Doc. Type" := PurchaseCrMemoHeader."Applies-to Doc. Type"::" ";
        PurchaseCrMemoHeader."Applies-to Doc. No." := '';
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);
        FetchVendorContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectThatDeferralsForPurchaseCreditMemoAreCreateOnce()
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader."Applies-to Doc. Type" := PurchaseCrMemoHeader."Applies-to Doc. Type"::" ";
        PurchaseCrMemoHeader."Applies-to Doc. No." := '';
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);
        FetchVendorContractDeferrals(CorrectedDocumentNo);

        PurchaseCrMemoHeader.Init();
        PurchaseCrMemoHeader.Validate("Document Type", PurchaseCrMemoHeader."Document Type"::"Credit Memo");
        PurchaseCrMemoHeader.Validate("Buy-from Vendor No.", PurchaseInvoiceHeader."Buy-from Vendor No.");
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader.Insert(true);

        CopyDocumentMgt.CopyPurchDoc(Enum::"Purchase Document Type From"::"Posted Invoice", PurchaseInvoiceHeader."No.", PurchaseCrMemoHeader);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);
        asserterror FetchVendorContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestCreateVendorDeferralsForPaidPurchaseInvoice()
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PurchaseInvoiceHeader.CalcFields("Amount Including VAT");
        //Create payment and apply the invoice only partially
        CreatePaymentAndApplytoInvoice(PurchaseHeader."Buy-from Vendor No.", PostedDocumentNo, PurchaseInvoiceHeader."Amount Including VAT" / 2);

        LibraryPurchase.CreatePurchaseCreditMemoForVendorNo(PurchaseCrMemoHeader, PurchaseInvoiceHeader."Buy-from Vendor No.");
        CopyDocumentMgt.CopyPurchDoc(Enum::"Purchase Document Type From"::"Posted Invoice", PurchaseInvoiceHeader."No.", PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader."Applies-to Doc. Type" := PurchaseCrMemoHeader."Applies-to Doc. Type"::" ";
        PurchaseCrMemoHeader."Applies-to Doc. No." := '';
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);

        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        AssertThat.AreEqual(PurchaseInvoiceDeferral.Count, PurchaseCrMemoDeferral.Count, 'Deferrals were not corrected properly.');

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.CalcSums(Amount);
        AssertThat.AreEqual(0, VendorContractDeferral.Amount, 'Credit Memo deferrals were not corrected properly.');
    end;

    procedure CreatePaymentAndApplytoInvoice(VendorNo: Code[20]; AppliesToDocNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        LibraryERM: Codeunit "Library - ERM";
    begin
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
                                        GenJournalLine."Account Type"::Vendor, VendorNo, Amount);

        // Value of Document No. is not important.
        GenJournalLine.Validate("Document No.", GenJournalLine."Journal Batch Name" + Format(GenJournalLine."Line No."));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocNo);
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure FetchAndTestUpdatedVendorContractDeferral()
    var
        UpdatedVendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        UpdatedVendorContractDeferral.Get(VendorContractDeferral."Entry No.");
        AssertThat.AreNotEqual(PrevGLEntry, UpdatedVendorContractDeferral."G/L Entry No.", 'G/L Entry No. is not properly assigned');
        TestPurchaseInvoiceDeferralsReleasedFields(UpdatedVendorContractDeferral, PostingDate);
        TestGLEntryFields(UpdatedVendorContractDeferral."G/L Entry No.", UpdatedVendorContractDeferral);
        PrevGLEntry := UpdatedVendorContractDeferral."G/L Entry No.";
    end;

    procedure CreatePurchaseDocumentsFromVendorContractWODeferrals()
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        VendorContract."Without Contract Deferrals" := true;
        VendorContract.Modify(false);
    end;

    local procedure TestVendorContractDeferralsFields()
    begin
        VendorContractDeferral.TestField("Contract No.", BillingLine."Contract No.");
        VendorContractDeferral.TestField("Document No.", PostedDocumentNo);
        VendorContractDeferral.TestField("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        VendorContractDeferral.TestField("Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.");
        VendorContractDeferral.TestField("Document Posting Date", PurchaseHeader."Posting Date");
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure CalculateNumberOfBillingMonths()
    var
        StartingDate: Date;
    begin
        BillingLine.FindLast();
        PurchaseLine.SetRange("Document No.", BillingLine."Document No.");
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.FindSet();
        repeat
            StartingDate := PurchaseLine."Recurring Billing from";
            repeat
                TotalNumberOfMonths += 1;
                StartingDate := CalcDate('<1M>', StartingDate);
            until StartingDate > CalcDate('<CM>', PurchaseLine."Recurring Billing to");
        until PurchaseLine.Next() = 0;
    end;

    local procedure GetCalculatedMonthAmountsForDeferrals(SourceDeferralBaseAmount: Decimal; NumberOfPeriods: Integer; FirstDayOfBillingPeriod: Date; LastDayOfBillingPeriod: Date; CalculateInLCY: Boolean)
    var
        DailyDefBaseAmount: Decimal;
        FirstMonthDays: Integer;
        LastMonthDays: Integer;
    begin
        DailyDefBaseAmount := SourceDeferralBaseAmount / (LastDayOfBillingPeriod - FirstDayOfBillingPeriod + 1);
        if not CalculateInLCY then begin
            DailyDefBaseAmount := CurrExchRate.ExchangeAmtFCYToLCY(PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", DailyDefBaseAmount, PurchaseHeader."Currency Factor");
            SourceDeferralBaseAmount := CurrExchRate.ExchangeAmtFCYToLCY(PurchaseHeader."Posting Date", PurchaseHeader."Currency Code", SourceDeferralBaseAmount, PurchaseHeader."Currency Factor");
        end;
        FirstMonthDays := CalcDate('<CM>', FirstDayOfBillingPeriod) - FirstDayOfBillingPeriod + 1;
        FirstMonthDefBaseAmount := Round(FirstMonthDays * DailyDefBaseAmount, GLSetup."Amount Rounding Precision");
        LastMonthDays := Date2DMY(LastDayOfBillingPeriod, 1);
        LastMonthDefBaseAmount := Round(LastMonthDays * DailyDefBaseAmount, GLSetup."Amount Rounding Precision");
        MonthlyDefBaseAmount := Round((SourceDeferralBaseAmount - FirstMonthDefBaseAmount - LastMonthDefBaseAmount) / NumberOfPeriods, GLSetup."Amount Rounding Precision");
        LastMonthDefBaseAmount := SourceDeferralBaseAmount - MonthlyDefBaseAmount * NumberOfPeriods - FirstMonthDefBaseAmount;
    end;

    local procedure TestGLEntryFields(EntryNo: Integer; LocalVendorContractDeferrals: Record "Vendor Contract Deferral")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Get(EntryNo);
        GLEntry.TestField("Document No.", LocalVendorContractDeferrals."Document No.");
        GLEntry.TestField("Dimension Set ID", LocalVendorContractDeferrals."Dimension Set ID");
        GLEntry.TestField("Sub. Contract No.", LocalVendorContractDeferrals."Contract No.");
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

    local procedure TestPurchaseInvoiceDeferralsReleasedFields(DeferralsToTest: Record "Vendor Contract Deferral"; DocumentPostingDate: Date)
    begin
        DeferralsToTest.TestField("Release Posting Date", DocumentPostingDate);
        DeferralsToTest.TestField(Released, true);
    end;

    procedure GetDeferralBaseAmount(): Decimal
    begin
        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        exit(PurchaseLine.Amount);
    end;

    local procedure PostPurchDocumentAndGetPurchInvoice()
    begin
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
    end;

    local procedure FetchVendorContractDeferrals(DocumentNo: Code[20])
    begin
        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", DocumentNo);
        VendorContractDeferral.FindFirst();
    end;

    local procedure PostPurchCreditMemoAndFetchDeferrals()
    begin
        PostPurchCreditMemo();
        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseCrMemoDeferral.FindFirst();
    end;

    local procedure PostPurchCreditMemo()
    begin
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);
    end;

    local procedure PostPurchDocumentAndFetchDeferrals()
    begin
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        FetchVendorContractDeferrals(PostedDocumentNo);
    end;

    local procedure SetPurchDocumentAndVendorContractDeferrals(BillingDateFormula: Text; BillingToDateFormula: Text; CalculateInLCY: Boolean; NumberOfPeriods: Integer; var VendorDeferalCount: Integer)
    begin
        CreateVendorContractWithDeferrals(BillingDateFormula, CalculateInLCY);
        CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula, BillingToDateFormula);

        BillingLine.FindLast();
        DeferralBaseAmount := GetDeferralBaseAmount();
        PostPurchDocumentAndFetchDeferrals();
        VendorDeferalCount := VendorContractDeferral.Count;
        GetCalculatedMonthAmountsForDeferrals(DeferralBaseAmount, NumberOfPeriods, CalcDate(BillingDateFormula, WorkDate()), CalcDate(BillingToDateFormula, WorkDate()), CalculateInLCY);
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ContractDeferralsReleaseRequestPageHandler')]
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
        CreateVendorContractWithDeferrals('<2M-CM>', true);

        // use discounts on Service Commitment
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.Validate("Discount %", 10);
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        GeneralPostingSetup.TestField("Purch. Line Disc. Account");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Purch. Line Disc. Account");
        GLEntry.DeleteAll(false);

        //After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Vend. Contr. Deferral Account");

        //Release only first Vendor Contract Deferral
        PostPurchDocumentAndFetchDeferrals();
        PostingDate := VendorContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Vend. Contr. Deferral Account");
        GetGLEntryAmountFromAccountNo(GLLineDiscountAmountAfterInvoicing, GeneralPostingSetup."Purch. Line Disc. Account");
        AssertThat.AreEqual(0, GLLineDiscountAmountAfterInvoicing, 'There should not be amount posted into Purchase Line Discount Account.');

        //Expect Amount on GL Account to be decreased by Released Vendor Deferral
        ContractDeferralsRelease.Run();
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Vend. Contr. Deferral Account");
        AssertThat.AreEqual(GLAmountAfterInvoicing - VendorContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Vend. Contr. Deferral Account");
        AssertThat.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;
}