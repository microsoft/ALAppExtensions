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
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchaseCrMemoHeader: Record "Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        UserSetup: Record "User Setup";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        PurchaseCrMemoDeferral: Record "Vend. Sub. Contract Deferral";
        PurchaseInvoiceDeferral: Record "Vend. Sub. Contract Deferral";
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CorrectPostedPurchaseInvoice: Codeunit "Correct Posted Purch. Invoice";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        CorrectedDocumentNo: Code[20];
        PostedDocumentNo: Code[20];
        PostingDate: Date;
        DeferralBaseAmount: Decimal;
        FirstMonthDefBaseAmount: Decimal;
        LastMonthDefBaseAmount: Decimal;
        MonthlyDefBaseAmount: Decimal;
        PrevGLEntry: Integer;
        TotalNumberOfMonths: Integer;
        VendorDeferralsCount: Integer;
        IsInitialized: Boolean;

    #region Tests

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearFCY()
    var
        i: Integer;
        VendorDeferralCount: Integer;
    begin
        Initialize();
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY+14D>', false, 11, VendorDeferralCount);
        for i := 1 to VendorDeferralCount do begin
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
                VendorDeferralCount:
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
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForFullYearLCY()
    var
        i: Integer;
        VendorDeferralCount: Integer;
    begin
        Initialize();
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY+14D>', true, 11, VendorDeferralCount);
        for i := 1 to VendorDeferralCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount);
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferralCount:
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
        VendorDeferralCount: Integer;
    begin
        Initialize();
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY-1M-9D>', false, 9, VendorDeferralCount);
        for i := 1 to VendorDeferralCount do begin
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
                VendorDeferralCount:
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsNotOnFirstDayInMonthCalculatedForPartialYearLCY()
    var
        i: Integer;
        VendorDeferralCount: Integer;
    begin
        Initialize();
        SetPurchDocumentAndVendorContractDeferrals('<-CY+14D>', '<CY-1M-9D>', true, 9, VendorDeferralCount);
        for i := 1 to VendorDeferralCount do begin
            TestVendorContractDeferralsFields();
            VendorContractDeferral.TestField("Deferral Base Amount", DeferralBaseAmount);
            case i of
                1:
                    begin
                        VendorContractDeferral.TestField(Amount, FirstMonthDefBaseAmount);
                        VendorContractDeferral.TestField("Number of Days", 17);
                    end;
                VendorDeferralCount:
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCalculatedForFullYearLCY()
    begin
        Initialize();
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckContractDeferralsWhenStartDateIsOnFirstDayInMonthCalculatedForFullYearFCY()
    begin
        Initialize();
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure DeferralsAreCorrectAfterPostingPartialPurchCreditMemo()
    begin
        Initialize();
        // [SCENARIO] Making sure that Credit Memo Deferrals are created only for existing Credit Memo Lines
        // [SCENARIO] Posted Invoice contains two lines connected for a contract.
        // [SCENARIO] Credit Memo is created for Posted Invoice and one of the lines in a credit memo is deleted.
        // [SCENARIO] Deferral Entries releasing a single invoice line should be created and not for all invoice lines

        // [GIVEN] Contract has been created and the billing proposal with non posted contract invoice
        CreateVendorContractWithDeferrals('<2M-CM>', true, 2);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        // [WHEN] Post the contract invoice and a credit memo crediting only the first invoice line
        PostPurchDocumentAndGetPurchInvoice();
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader.Modify(false);
        PurchInvLine.SetRange("Document No.", PurchaseInvoiceHeader."No.");
        PurchInvLine.SetFilter("Subscription Contract Line No.", '<>0');
        PurchInvLine.FindLast();
        PurchaseLine.SetRange("Document No.", PurchaseCrMemoHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.FindLast();
        PurchaseLine.Delete(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);

        // [THEN] Matching Deferral entries have been created for the first invoice line but not for the second invoice line
        FetchVendorContractDeferrals(CorrectedDocumentNo);
        PurchInvLine.FindFirst();
        VendorContractDeferral.SetRange("Subscription Contract Line No.", PurchInvLine."Subscription Contract Line No.");
        Assert.RecordIsNotEmpty(VendorContractDeferral);
        PurchInvLine.FindLast();
        VendorContractDeferral.SetRange("Subscription Contract Line No.", PurchInvLine."Subscription Contract Line No.");
        Assert.RecordIsEmpty(VendorContractDeferral);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ContractDeferralsReleaseRequestPageHandler')]
    procedure ExpectAmountOnContractDeferralAccountToBeZero()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
        FinalGLAmount: Decimal;
        GLAmountAfterInvoicing: Decimal;
        GLAmountAfterRelease: Decimal;
        StartingGLAmount: Decimal;
    begin
        Initialize();
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        // After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");

        // Release only first Vendor Subscription Contract Deferral
        PostPurchDocumentAndFetchDeferrals();
        PostingDate := VendorContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");

        // Expect Amount on GL Account to be decreased by Released Vendor Deferral
        ContractDeferralsRelease.Run();
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");
        Assert.AreEqual(GLAmountAfterInvoicing - VendorContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");
        Assert.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ContractDeferralsReleaseRequestPageHandler')]
    procedure ExpectAmountOnContractDeferralAccountToBeZeroForContractLinesWithDiscount()
    var
        GLEntry: Record "G/L Entry";
        ServiceCommitment: Record "Subscription Line";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
        FinalGLAmount: Decimal;
        GLAmountAfterInvoicing: Decimal;
        GLAmountAfterRelease: Decimal;
        GLLineDiscountAmountAfterInvoicing: Decimal;
        StartingGLAmount: Decimal;
    begin
        Initialize();
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);

        // use discounts on Subscription Line
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
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

        // After crediting expect this amount to be on GL Entry
        GetGLEntryAmountFromAccountNo(StartingGLAmount, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");

        // Release only first Vendor Subscription Contract Deferral
        PostPurchDocumentAndFetchDeferrals();
        PostingDate := VendorContractDeferral."Posting Date";
        GetGLEntryAmountFromAccountNo(GLAmountAfterInvoicing, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");
        GetGLEntryAmountFromAccountNo(GLLineDiscountAmountAfterInvoicing, GeneralPostingSetup."Purch. Line Disc. Account");
        Assert.AreEqual(0, GLLineDiscountAmountAfterInvoicing, 'There should not be amount posted into Purchase Line Discount Account.');

        // Expect Amount on GL Account to be decreased by Released Vendor Deferral
        ContractDeferralsRelease.Run();
        GetGLEntryAmountFromAccountNo(GLAmountAfterRelease, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");
        Assert.AreEqual(GLAmountAfterInvoicing - VendorContractDeferral.Amount, GLAmountAfterRelease, 'Amount was not moved from Deferrals Account to Contract Account');

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        GetGLEntryAmountFromAccountNo(FinalGLAmount, GeneralPostingSetup."Vend. Sub. Contr. Def. Account");
        Assert.AreEqual(StartingGLAmount, FinalGLAmount, 'Released Contract Deferrals where not reversed properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullAfterPostPurchCrMemoOfReleasedDeferrals()
    var
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        Initialize();
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();
        // Release only first Vendor Subscription Contract Deferral
        PostingDate := VendorContractDeferral."Posting Date";
        ContractDeferralsRelease.Run();

        PurchaseInvoiceHeader.Get(PostedDocumentNo);
        PostPurchCreditMemo();

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.SetRange(Released, true);
        VendorContractDeferral.CalcSums(Amount, "Discount Amount");
        Assert.AreEqual(0, VendorContractDeferral.Amount, 'Deferrals were not corrected properly.');
        Assert.AreEqual(0, VendorContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectAmountsToBeNullOnAfterPostPurchCrMemo()
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemo();

        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        Assert.AreEqual(PurchaseInvoiceDeferral.Count, PurchaseCrMemoDeferral.Count, 'Deferrals were not corrected properly.');

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.SetRange(Released, true);
        VendorContractDeferral.CalcSums(Amount, "Discount Amount");
        Assert.AreEqual(0, VendorContractDeferral.Amount, 'Deferrals were not corrected properly.');
        Assert.AreEqual(0, VendorContractDeferral."Discount Amount", 'Deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectEqualBillingMonthsNumberAndVendContractDeferrals()
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        CalculateNumberOfBillingMonths();
        PostPurchDocumentAndGetPurchInvoice();

        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", PostedDocumentNo);
        VendorDeferralsCount := VendorContractDeferral.Count;
        Assert.AreEqual(VendorDeferralsCount, TotalNumberOfMonths, 'Number of Vendor deferrals must be the same as total number of billing months');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorIfDeferralsExistsAfterPostPurchaseDocumentWODeferrals()
    begin
        Initialize();
        CreatePurchaseDocumentsFromVendorContractWODeferrals();
        BillingLine.FindLast();
        asserterror PostPurchDocumentAndFetchDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectErrorOnPostPurchDocumentWithDeferralsWOGeneralPostingSetup()
    begin
        Initialize();
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
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        asserterror LibraryPurchase.PreviewPostPurchaseDocument(PurchaseHeader);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure ExpectThatDeferralsForPurchaseCreditMemoAreCreatedOnce()
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemo();
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
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestCorrectReleasedPurchaseInvoiceDeferrals()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        Initialize();
        // Step 1 Create contract invoice with deferrals
        // Step 2 Release deferrals
        // Step 3 Correct posted purchase invoice
        // Expectation:
        // -Vendor Subscription Contract Deferrals with opposite sign are created
        // -Invoice Contract Deferrals are released
        // -Credit Memo Contract Deferrals are released
        // -GL Entries are posted on the Credit Memo Posting date
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();

        PostingDate := VendorContractDeferral."Posting Date"; // Used in request page handler
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
        Assert.RecordIsEmpty(VendorContractDeferral);

        GLEntry.Reset();
        GLEntry.SetRange("Document No.", CorrectedDocumentNo);
        if GLEntry.FindSet() then
            repeat
                GLEntry.TestField("Posting Date", PostingDate);
            until GLEntry.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestCreateVendorDeferralsForPaidPurchaseInvoice()
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PurchaseInvoiceHeader.CalcFields("Amount Including VAT");
        // Create payment and apply the invoice only partially
        CreatePaymentAndApplyToInvoice(PurchaseHeader."Buy-from Vendor No.", PostedDocumentNo, PurchaseInvoiceHeader."Amount Including VAT" / 2);

        LibraryPurchase.CreatePurchaseCreditMemoForVendorNo(PurchaseCrMemoHeader, PurchaseInvoiceHeader."Buy-from Vendor No.");
        CopyDocumentMgt.CopyPurchDoc(Enum::"Purchase Document Type From"::"Posted Invoice", PurchaseInvoiceHeader."No.", PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader."Applies-to Doc. Type" := PurchaseCrMemoHeader."Applies-to Doc. Type"::" ";
        PurchaseCrMemoHeader."Applies-to Doc. No." := '';
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);

        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo);
        Assert.AreEqual(PurchaseInvoiceDeferral.Count, PurchaseCrMemoDeferral.Count, 'Deferrals were not corrected properly.');

        VendorContractDeferral.SetFilter("Document No.", '%1|%2', PostedDocumentNo, CorrectedDocumentNo);
        VendorContractDeferral.CalcSums(Amount);
        Assert.AreEqual(0, VendorContractDeferral.Amount, 'Credit Memo deferrals were not corrected properly.');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostPurchCreditMemo()
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemo();
        FetchVendorContractDeferrals(CorrectedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestIfDeferralsExistOnAfterPostPurchCreditMemoWithoutAppliesToDocNo()
    begin
        Initialize();
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
    procedure TestIfDeferralsExistOnAfterPostPurchDocument()
    begin
        Initialize();
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        PostPurchDocumentAndFetchDeferrals();
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler')]
    procedure TestPurchaseCrMemoDeferralsDocumentsAndDate()
    begin
        Initialize();
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
    procedure TestPurchInvoiceDeferralsOnAfterPostPurchCrMemo()
    begin
        Initialize();
        SetPostingAllowTo(WorkDate());
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        PostPurchDocumentAndGetPurchInvoice();
        PostPurchCreditMemoAndFetchDeferrals();

        PurchaseInvoiceDeferral.SetRange("Document No.", PostedDocumentNo); // Fetch updated Purchase Invoice Deferral
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
        Initialize();
        // [SCENARIO] Making sure that Deferrals are properly release and contain Contract No. on GLEntries

        // [GIVEN] Contract has been created and the billing proposal with non posted contract invoice
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        // [WHEN] Post the contract invoice
        PostPurchDocumentAndFetchDeferrals();

        // [THEN] Releasing each deferral entry should be correct
        repeat
            PostingDate := VendorContractDeferral."Posting Date";
            ContractDeferralsRelease.Run();
            VendorContractDeferral.Get(VendorContractDeferral."Entry No.");
            GLEntry.Get(VendorContractDeferral."G/L Entry No.");
            GLEntry.TestField("Subscription Contract No.", VendorContractDeferral."Subscription Contract No.");
            FetchAndTestUpdatedVendorContractDeferral();
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ContractDeferralsReleaseRequestPageHandler,MessageHandler')]
    procedure TestReleasingVendorContractDeferralsForCreditMemoAsDiscount()
    var
        GLEntry: Record "G/L Entry";
        ContractDeferralsRelease: Report "Contract Deferrals Release";
    begin
        Initialize();
        // [SCENARIO] Making sure that Deferrals are properly released when Credit Memo is created from a Serv. Comm Package Line marked as Discount

        // [GIVEN] Contract has been created and the billing proposal with non posted contract credit memo
        SetPostingAllowTo(0D);
        CreateVendorContractWithDeferrals('<2M-CM>', true, 1);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');

        // [WHEN] Post the contract credit memo
        PostPurchDocumentAndFetchDeferrals();

        // [THEN] Releasing each deferral entry should be correct
        repeat
            PostingDate := VendorContractDeferral."Posting Date";
            ContractDeferralsRelease.Run();
            VendorContractDeferral.Get(VendorContractDeferral."Entry No.");
            GLEntry.Get(VendorContractDeferral."G/L Entry No.");
            GLEntry.TestField("Subscription Contract No.", VendorContractDeferral."Subscription Contract No.");
            FetchAndTestUpdatedVendorContractDeferral();
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    procedure UT_CheckFunctionCreateContractDeferralsForPurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        BillingLine: Record "Billing Line";
        SubscriptionLine: Record "Subscription Line";
        VendorSubscriptionContract: Record "Vendor Subscription Contract";
        FunctionReturnedWrongResultErr: Label 'The function for calculating if contract deferrals should be created for a purchase line returned a wrong result.', Locked = true;
    begin
        // [SCENARIO] Testing that the function CreateContractDeferrals always returns the correct result
        Initialize();

        // [GIVEN] Mock Contract, Sales Line, Subscription Line and Billing Line
        MockSubscriptionContract(VendorSubscriptionContract);
        MockSalesLine(PurchaseLine);
        MockSubscriptionLineForContract(SubscriptionLine, VendorSubscriptionContract."No.");
        MockBillingLineForPurchaseLineAndSubscriptionLine(BillingLine, PurchaseLine, SubscriptionLine);

        // [WHEN] "Create Contract Deferral" is set to true in Contract, "Create Contract Deferral" is set to "Contract-dependent" in Subscription Line
        SubscriptionLine."Create Contract Deferrals" := SubscriptionLine."Create Contract Deferrals"::"Contract-dependent";
        SubscriptionLine.Modify(false);

        // [THEN] Function should return correct result
        Assert.IsTrue(PurchaseLine.CreateContractDeferrals(), FunctionReturnedWrongResultErr);

        // [WHEN] "Create Contract Deferral" is set to false in Contract, "Create Contract Deferral" is set to "Contract-dependent" in Subscription Line
        VendorSubscriptionContract."Create Contract Deferrals" := false;
        VendorSubscriptionContract.Modify(false);

        // [THEN] Function should return correct result
        Assert.IsFalse(PurchaseLine.CreateContractDeferrals(), FunctionReturnedWrongResultErr);

        // [WHEN] "Create Contract Deferral" is set to false in Contract, "Create Contract Deferral" is set to Yes in Subscription Line
        SubscriptionLine."Create Contract Deferrals" := SubscriptionLine."Create Contract Deferrals"::Yes;
        SubscriptionLine.Modify(false);

        // [THEN] Function should return correct result
        Assert.IsTrue(PurchaseLine.CreateContractDeferrals(), FunctionReturnedWrongResultErr);

        // [WHEN] "Create Contract Deferral" is set to true in Contract, "Create Contract Deferral" is set to No in Subscription Line
        VendorSubscriptionContract."Create Contract Deferrals" := true;
        VendorSubscriptionContract.Modify(false);
        SubscriptionLine."Create Contract Deferrals" := SubscriptionLine."Create Contract Deferrals"::Yes;
        SubscriptionLine.Modify(false);

        // [THEN] Function should return correct result
        Assert.IsTrue(PurchaseLine.CreateContractDeferrals(), FunctionReturnedWrongResultErr);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Vendor Deferrals Test");
        ClearAll();
        GLSetup.Get();
        ContractTestLibrary.InitContractsApp();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Vendor Deferrals Test");
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Vendor Deferrals Test");

    end;

    local procedure CreatePaymentAndApplyToInvoice(VendorNo: Code[20]; AppliesToDocNo: Code[20]; Amount: Decimal)
    var
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
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

    local procedure CreatePurchaseDocumentsFromVendorContractWODeferrals()
    var
        SubscriptionLine: Record "Subscription Line";
    begin
        CreateVendorContractWithDeferrals('<2M-CM>', true);
        CreateBillingProposalAndCreateBillingDocuments('<2M-CM>', '<8M+CM>');
        VendorContract."Create Contract Deferrals" := false;
        VendorContract.Modify(false);

        SubscriptionLine.SetRange(Partner, SubscriptionLine.Partner::Vendor);
        SubscriptionLine.SetRange("Subscription Contract No.", VendorContract."No.");
        SubscriptionLine.ModifyAll("Create Contract Deferrals", Enum::"Create Contract Deferrals"::No);
    end;

    local procedure GetDeferralBaseAmount(): Decimal
    begin
        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        exit(PurchaseLine.Amount);
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

    local procedure CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula: Text; BillingToDateFormula: Text)
    begin
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, BillingDateFormula, BillingToDateFormula, '', Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine); // CreateVendorBillingDocsContractPageHandler, MessageHandler
        BillingLine.FindLast();
        PurchaseHeader.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.");
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID())
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
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

    local procedure CreateVendorContractWithDeferrals(BillingDateFormula: Text; IsVendorContractLCY: Boolean)
    begin
        CreateVendorContractWithDeferrals(BillingDateFormula, IsVendorContractLCY, 1);
    end;

    local procedure CreateVendorContractWithDeferrals(BillingDateFormula: Text; IsVendorContractLCY: Boolean; ServiceCommitmentCount: Integer)
    var
        i: Integer;
    begin
        if IsVendorContractLCY then
            ContractTestLibrary.CreateVendorInLCY(Vendor)
        else
            ContractTestLibrary.CreateVendor(Vendor);

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.Validate("Unit Cost", 1200);
        Item.Modify(false);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");
        ServiceObject.Validate(Quantity, 1);
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<1M>', 10, Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price", false);
        ContractTestLibrary.CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        for i := 1 to ServiceCommitmentCount do begin
            ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
            ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Vendor, Item."No.");
        end;

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(CalcDate(BillingDateFormula, WorkDate()), ServiceCommitmentPackage);

        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
    end;

    local procedure FetchAndTestUpdatedVendorContractDeferral()
    var
        UpdatedVendorContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        UpdatedVendorContractDeferral.Get(VendorContractDeferral."Entry No.");
        Assert.AreNotEqual(PrevGLEntry, UpdatedVendorContractDeferral."G/L Entry No.", 'G/L Entry No. is not properly assigned');
        TestPurchaseInvoiceDeferralsReleasedFields(UpdatedVendorContractDeferral, PostingDate);
        TestGLEntryFields(UpdatedVendorContractDeferral."G/L Entry No.", UpdatedVendorContractDeferral);
        PrevGLEntry := UpdatedVendorContractDeferral."G/L Entry No.";
    end;

    local procedure FetchVendorContractDeferrals(DocumentNo: Code[20])
    begin
        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", DocumentNo);
        VendorContractDeferral.FindFirst();
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

    local procedure GetGLEntryAmountFromAccountNo(var GlEntryAmount: Decimal; GLAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.CalcSums(Amount);
        GlEntryAmount := GLEntry.Amount;
    end;

    local procedure MockBillingLineForPurchaseLineAndSubscriptionLine(var BillingLine: Record "Billing Line"; PurchaseLine: Record "Purchase Line"; SubscriptionLine: Record "Subscription Line")
    begin
        BillingLine.InitNewBillingLine();
        BillingLine."Document Type" := BillingLine.GetBillingDocumentTypeFromSalesDocumentType(PurchaseLine."Document Type");
        BillingLine."Document No." := PurchaseLine."Document No.";
        BillingLine."Document Line No." := PurchaseLine."Line No.";
        BillingLine."Subscription Line Entry No." := SubscriptionLine."Entry No.";
        BillingLine."Subscription Contract No." := SubscriptionLine."Subscription Contract No.";
        BillingLine.Insert(false);
    end;

    local procedure MockSalesLine(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseLine."Document Type"::Invoice;
        PurchaseHeader.Insert(true);
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::Invoice;
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Insert(false);
    end;

    local procedure MockSubscriptionContract(var VendorSubscriptionContract: Record "Vendor Subscription Contract")
    begin
        VendorSubscriptionContract.Init();
        VendorSubscriptionContract.Insert(true);
    end;

    local procedure MockSubscriptionLineForContract(var SubscriptionLine: Record "Subscription Line"; ContractNo: Code[20])
    var
        ServiceObject: Record "Subscription Header";
    begin
        ServiceObject.Init();
        ServiceObject.Insert(true);
        SubscriptionLine.Init();
        SubscriptionLine."Subscription Header No." := ServiceObject."No.";
        SubscriptionLine."Entry No." := 0;
        SubscriptionLine.Partner := SubscriptionLine.Partner::Vendor;
        SubscriptionLine."Subscription Contract No." := ContractNo;
        SubscriptionLine.Insert(false);
    end;

    local procedure PostPurchCreditMemo()
    begin
        CorrectPostedPurchaseInvoice.CreateCreditMemoCopyDocument(PurchaseInvoiceHeader, PurchaseCrMemoHeader);
        PurchaseCrMemoHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseCrMemoHeader.Modify(false);
        CorrectedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseCrMemoHeader, true, true);
    end;

    local procedure PostPurchCreditMemoAndFetchDeferrals()
    begin
        PostPurchCreditMemo();
        PurchaseCrMemoDeferral.SetRange("Document No.", CorrectedDocumentNo);
        PurchaseCrMemoDeferral.FindFirst();
    end;

    local procedure PostPurchDocumentAndFetchDeferrals()
    begin
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        FetchVendorContractDeferrals(PostedDocumentNo);
    end;

    local procedure PostPurchDocumentAndGetPurchInvoice()
    begin
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.Get(PostedDocumentNo);
    end;

    local procedure SetPostingAllowTo(PostingTo: Date)
    begin
        if UserSetup.Get(UserId) then begin
            UserSetup."Allow Posting From" := 0D;
            UserSetup."Allow Posting To" := PostingTo;
            UserSetup.Modify(false);
        end;
        GLSetup."Allow Posting From" := 0D;
        GLSetup."Allow Posting To" := PostingTo;
        GLSetup.Modify(false);
    end;

    local procedure SetPurchDocumentAndVendorContractDeferrals(BillingDateFormula: Text; BillingToDateFormula: Text; CalculateInLCY: Boolean; NumberOfPeriods: Integer; var VendorDeferralCount: Integer)
    begin
        CreateVendorContractWithDeferrals(BillingDateFormula, CalculateInLCY);
        CreateBillingProposalAndCreateBillingDocuments(BillingDateFormula, BillingToDateFormula);

        BillingLine.FindLast();
        DeferralBaseAmount := GetDeferralBaseAmount();
        PostPurchDocumentAndFetchDeferrals();
        VendorDeferralCount := VendorContractDeferral.Count;
        GetCalculatedMonthAmountsForDeferrals(DeferralBaseAmount, NumberOfPeriods, CalcDate(BillingDateFormula, WorkDate()), CalcDate(BillingToDateFormula, WorkDate()), CalculateInLCY);
    end;

    local procedure TestGLEntryFields(EntryNo: Integer; LocalVendorContractDeferrals: Record "Vend. Sub. Contract Deferral")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Get(EntryNo);
        GLEntry.TestField("Document No.", LocalVendorContractDeferrals."Document No.");
        GLEntry.TestField("Dimension Set ID", LocalVendorContractDeferrals."Dimension Set ID");
        GLEntry.TestField("Subscription Contract No.", LocalVendorContractDeferrals."Subscription Contract No.");
    end;

    local procedure TestPurchaseInvoiceDeferralsReleasedFields(DeferralsToTest: Record "Vend. Sub. Contract Deferral"; DocumentPostingDate: Date)
    begin
        DeferralsToTest.TestField("Release Posting Date", DocumentPostingDate);
        DeferralsToTest.TestField(Released, true);
    end;

    local procedure TestVendorContractDeferralsFields()
    begin
        VendorContractDeferral.TestField("Subscription Contract No.", BillingLine."Subscription Contract No.");
        VendorContractDeferral.TestField("Document No.", PostedDocumentNo);
        VendorContractDeferral.TestField("Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        VendorContractDeferral.TestField("Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.");
        VendorContractDeferral.TestField("Document Posting Date", PurchaseHeader."Posting Date");
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
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

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    #endregion Handlers
}
