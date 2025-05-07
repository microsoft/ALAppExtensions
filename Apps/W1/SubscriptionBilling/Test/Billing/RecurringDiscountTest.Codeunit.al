namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

codeunit 139689 "Recurring Discount Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        BillingLine: Record "Billing Line";
        BillingTemplate: Record "Billing Template";
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        SalesServiceCommitment: Record "Sales Subscription Line";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        BillingProposal: Codeunit "Billing Proposal";
        ContractTestLibrary: Codeunit "Contract Test Library";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        PostedDocumentNo: Code[20];
        DiscountDeferralAmountSignErr: Label 'Discount Deferral line must have %1 Amount.', Locked = true;
        DiscountDeferralDeferralBaseAmountSignErr: Label 'Discount Deferral line must have %1 Deferral Base Amount.', Locked = true;
        NoDeferralLinesErr: Label 'No Deferral lines were found.', Locked = true;
        DiscBillingLineNegativeAmtErr: Label 'Discount Billing line must have negative amount', Locked = true;
        DiscBillLineNegativeQtyErr: Label 'Discount Billing line must have negative quantity', Locked = true;
        DiscBillLinePositivePriceErr: Label 'Discount Billing line must have positive price', Locked = true;
        DiscPurchLineNegativeAmtErr: Label 'Discount Purchase line must have negative amount', Locked = true;
        DiscPurchLinePositivePriceErr: Label 'Discount Purchase line must have positive price', Locked = true;
        DiscPurchLineNegativePriceErr: Label 'Discount Purchase line must have negative price', Locked = true;
        DiscSalesLineNegativeAmtErr: Label 'Discount Sales line must have negative amount', Locked = true;
        DiscSalesLinePositivePriceErr: Label 'Discount Sales line must have positive price', Locked = true;
        DiscSalesLineNegativePriceErr: Label 'Discount Sales line must have negative price', Locked = true;

    #region Tests

    [Test]
    procedure ExpectErrorOnAssignDiscountInvoiceViaSalesInServiceCommitmentTemplate()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        asserterror ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    procedure ExpectErrorOnAssignDiscountInvoiceViaSalesInServiceCommitmentPackage()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        asserterror ServiceCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    procedure ExpectErrorOnAssignDiscountToInvoicingItemInServiceCommitmentPackage()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        asserterror ServiceCommitmentTemplate.Validate("Invoicing Item No.", Item."No.");
    end;

    [Test]
    procedure ExpectErrorOnAssignRecurringDiscountToSalesServiceCommitment()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        asserterror ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    [Test]
    procedure ExpectErrorOnAssignRecurringDiscountToInvoicingItem()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        asserterror ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestBillingLineArchiveOnRecurringDiscount()
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        BillingArchiveLine.FilterBillingLineArchiveOnDocument(BillingArchiveLine."Document Type"::Invoice, PostedDocumentNo);
        BillingArchiveLine.SetRange(Discount, true);
        Assert.AreNotEqual(0, BillingArchiveLine.Count, 'Billing Archive Lines are not created for Recurring Discount Lines');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCustomerContractDeferralsDiscountLines()
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        VerifyCustomerContractDeferralLines(CustomerContract."No.", PostedDocumentNo, Enum::"Rec. Billing Document Type"::Invoice, true);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDiscountInBillingLinesCustomerContract()
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Subscription Header No.", ServiceObject."No.");
        BillingLine.SetRange(Discount, true);
        BillingLine.FindSet();
        repeat
            if BillingLine.Amount >= 0 then
                Error(DiscBillingLineNegativeAmtErr);
            if BillingLine."Service Object Quantity" >= 0 then
                Error(DiscBillLineNegativeQtyErr);
            if BillingLine."Unit Price" < 0 then
                Error(DiscBillLinePositivePriceErr);
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDiscountInBillingLinesVendorContract()
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Subscription Header No.", ServiceObject."No.");
        BillingLine.SetRange(Discount, true);
        BillingLine.FindSet();
        repeat
            if BillingLine.Amount >= 0 then
                Error(DiscBillingLineNegativeAmtErr);
            if BillingLine."Service Object Quantity" >= 0 then
                Error(DiscBillLineNegativeQtyErr);
            if BillingLine."Unit Price" < 0 then
                Error(DiscBillLinePositivePriceErr);
        until BillingLine.Next() = 0;
    end;

    [Test]
    procedure TestDiscountInSalesServiceCommitments()
    begin
        Initialize();
        SetupSalesServiceData();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        repeat
            SalesServiceCommitment.TestField(Discount, true);
        until SalesServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure TestDiscountServiceCommitmentsCreatedFromSales()
    var
        PositivePriceErr: Label 'Price should be positive in Subscription Lines with discounts', Locked = true;
        PositiveCalcBaseAmtErr: Label 'Calculation Base Amount should be positive in Subscription Lines with discounts', Locked = true;
        PositiveServAmtErr: Label 'Amount should be positive in Subscription Lines with discounts', Locked = true;
    begin
        Initialize();
        SetupSalesServiceData();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment.Price < 0 then
                Error(PositivePriceErr);
            if ServiceCommitment."Calculation Base Amount" < 0 then
                Error(PositiveCalcBaseAmtErr);
            if ServiceCommitment.Amount < 0 then
                Error(PositiveServAmtErr);
            ServiceCommitment.TestField(Discount, true);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfPurchaseInvoiceIsCreatedFromRecurringBilling()
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        // Check if document is created for each billing line (both discount and standard)
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfSalesInvoiceIsCreatedFromRecurringBilling()
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        // Check if document is created for each billing line (both discount and standard)
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestPurchaseInvoiceRecurringDiscountLines()
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.SetRange(Discount, true);
        if BillingLine.FindSet() then
            repeat
                PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
                if PurchaseLine.Amount >= 0 then
                    Error(DiscPurchLinePositivePriceErr);
                if PurchaseLine."Amount Including VAT" >= 0 then
                    Error(DiscPurchLinePositivePriceErr);
                if PurchaseLine."Unit Cost" < 0 then
                    Error(DiscPurchLinePositivePriceErr);
                if PurchaseLine.Quantity > 0 then
                    Error(DiscPurchLineNegativeAmtErr);
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestPurchaseCreditMemoRecurringDiscountLine()
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        PostedDocumentNo := UpdateAndPostPurchaseHeader(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchInvHeader.Get(PostedDocumentNo);
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Discount, true);
        PurchaseLine.FindSet();
        repeat
            if PurchaseLine.Amount >= 0 then
                Error(DiscPurchLineNegativeAmtErr);
            if PurchaseLine."Amount Including VAT" >= 0 then
                Error(DiscPurchLineNegativeAmtErr);
            if PurchaseLine."Unit Cost" < 0 then
                Error(DiscPurchLinePositivePriceErr);
            if PurchaseLine.Quantity > 0 then
                Error(DiscPurchLineNegativePriceErr);
        until PurchaseLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestSalesInvoiceRecurringDiscountLines()
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.SetRange(Discount, true);
        if BillingLine.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
                SalesLine.SetRange("Document No.", BillingLine."Document No.");
                SalesLine.SetRange("Line No.", BillingLine."Document Line No.");
                SalesLine.FindFirst();
                if SalesLine.Amount >= 0 then
                    Error(DiscSalesLineNegativeAmtErr);
                if SalesLine."Amount Including VAT" >= 0 then
                    Error(DiscSalesLineNegativeAmtErr);
                if SalesLine."Unit Price" < 0 then
                    Error(DiscSalesLinePositivePriceErr);
                if SalesLine.Quantity > 0 then
                    Error(DiscSalesLineNegativePriceErr);
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestSalesCreditMemoRecurringDiscountLine()
    begin
        Initialize();
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Discount, true);
        SalesLine.FindSet();
        repeat
            if SalesLine.Amount >= 0 then
                Error(DiscSalesLineNegativeAmtErr);
            if SalesLine."Amount Including VAT" >= 0 then
                Error(DiscSalesLineNegativeAmtErr);
            if SalesLine."Unit Price" < 0 then
                Error(DiscSalesLinePositivePriceErr);
            if SalesLine.Quantity > 0 then
                Error(DiscSalesLineNegativePriceErr);
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure TestTransferDiscountInServiceCommitment()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.TestField(Discount, true);
            until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure TestTransferDiscountInServiceCommitmentPackage()
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.TestField(Discount, true);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestVendorBillingLineArchiveOnRecurringDiscount()
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        PostedDocumentNo := UpdateAndPostPurchaseHeader(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");

        BillingArchiveLine.FilterBillingLineArchiveOnDocument(BillingArchiveLine."Document Type"::Invoice, PostedDocumentNo);
        Assert.AreNotEqual(0, BillingArchiveLine.Count, 'Billing Archive Lines are not created for Recurring Discount Lines');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestVendorContractDeferralsDiscountLines()
    var
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        Initialize();
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        PostedDocumentNo := UpdateAndPostPurchaseHeader(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        VendorContractDeferral.SetRange("Document Type", VendorContractDeferral."Document Type"::Invoice);
        VendorContractDeferral.SetRange("Document No.", PostedDocumentNo);
        VendorContractDeferral.SetRange(Discount, true);
        VendorContractDeferral.FindSet();
        repeat
            if VendorContractDeferral.Amount > 0 then
                Error(DiscountDeferralAmountSignErr, 'negative');
            if VendorContractDeferral."Deferral Base Amount" > 0 then
                Error(DiscountDeferralDeferralBaseAmountSignErr, 'negative');
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure TestServiceAmountInDiscountSalesServiceCommitments()
    var
        ServAmtCalculationErr: Label 'Amount in Sales Subscription Lines with Discount is not calculated properly.', Locked = true;
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        Item.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate.Validate(Discount, true);
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLineWithInvoicingItem(ServiceCommPackageLine, '');
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));

        SalesServiceCommitment.Reset();
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange(Discount, true);
        SalesServiceCommitment.FindSet();
        repeat
            if SalesServiceCommitment.Amount > 0 then
                Error(ServAmtCalculationErr)
        until SalesServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    procedure CreateContractInvoiceFromCustomerContractWhenDiscountLineIsFirst()
    begin
        // [SCENARIO] first Subscription Line is discount, but the document total amount is positive, Sales Invoice should be created
        Initialize();
        CreateBillingDocuments();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        IncreaseCalculationBaseAmountForNonDiscountServiceCommitment(); // to get positive total amount of billing lines
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        // Test that correct sales document type has been created
        SalesLine.Get("Sales Document Type"::Invoice, BillingLine."Document No.", BillingLine."Document Line No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    procedure CreateContractInvoiceFromVendorContractWhenDiscountLineIsFirst()
    begin
        // [SCENARIO] first Subscription Line is discount, but the document total amount is positive, Purchase Invoice should be created
        Initialize();
        CreateBillingDocuments();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        IncreaseCalculationBaseAmountForNonDiscountServiceCommitment(); // to get positive total amount of billing lines
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        BillingLine.SetRange(Partner);
        BillingLine.FindLast();
        // Test that correct purchase document type has been created
        PurchaseLine.Get("Purchase Document Type"::Invoice, BillingLine."Document No.", BillingLine."Document Line No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateBillingDocumentPageHandler')]
    procedure PostingSalesCreditMemoFromDiscountContractCreatesDeferrals()
    begin
        // [SCENARIO] When Sales Cr. Memo is created from Customer Subscription Contract with discount and posted, deferrals should be created as well
        ClearAll();
        Initialize();
        CreateBillingDocuments();


        // [GIVEN] Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");

        // [GIVEN] Customer and Subscription for it for Subscription Item
        LibrarySales.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        // [GIVEN] Subscription Package Line Template with Discount
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);

        // [GIVEN] Subscription Package with Discount based on Subscription Package Line Template with monthly rhythm
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 100, '', "Service Partner"::Customer, '', "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);

        // [GIVEN] Item is assigned to Subscription Package
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        // [GIVEN] Subscription Line from Subscription Package
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);

        // [GIVEN] Customer Subscription Contract with Contract Line
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.", true);

        // [GIVEN] Billing Proposal with Billing Lines and Sales Cr. Memo
        CustomerContract.CreateBillingProposal();
        BillingLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        BillingLine.FindFirst();

        // [WHEN] Sales Cr. Memo is posted
        SalesHeader.Get(Enum::"Sales Document Type"::"Credit Memo", BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Deferrals are created for Discount Billing Lines
        VerifyCustomerContractDeferralLines(CustomerContract."No.", PostedDocumentNo, Enum::"Rec. Billing Document Type"::"Credit Memo", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CreateBillingDocumentPageHandler')]
    procedure PostingPurchaseCreditMemoFromDiscountContractCreatesDeferrals()
    begin
        // [SCENARIO] When Purchase Cr. Memo is created from Vendor Subscription Contract with discount and posted, deferrals should be created as well
        ClearAll();
        Initialize();
        CreateBillingDocuments();


        // [GIVEN] Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");

        // [GIVEN] Vendor and Subscription for it for Subscription Item
        LibraryPurchase.CreateVendor(Vendor);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.Modify(true);

        // [GIVEN] Subscription Package Line Template with Discount
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);

        // [GIVEN] Subscription Package with Discount based on Subscription Package Line Template with monthly rhythm
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 100, '', "Service Partner"::Vendor, '', "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);

        // [GIVEN] Item is assigned to Subscription Package
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        // [GIVEN] Subscription Line from Subscription Package
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);

        // [GIVEN] Vendor Subscription Contract with Contract Line
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);

        // [GIVEN] Billing Proposal with Billing Lines and Purch. Cr. Memo
        VendorContract.CreateBillingProposal();
        BillingLine.SetRange("Subscription Contract No.", VendorContract."No.");
        BillingLine.SetRange(Partner);
        BillingLine.FindFirst();

        // [WHEN] Purchase Cr. Memo is posted
        PostedDocumentNo := UpdateAndPostPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", BillingLine."Document No.");

        // [THEN] Deferrals are created for Discount Billing Lines
        VerifyVendorContractDeferralLinesCreated(VendorContract."No.", PostedDocumentNo, Enum::"Rec. Billing Document Type"::"Credit Memo", true);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.CreateVATData();
    end;

    local procedure CreateBillingDocuments()
    begin
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        Commit(); // retain posted data
    end;

    local procedure CreateBillingProposalForCustomerContract()
    begin
        SetupServiceData(Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        CustomerContract.SetRange("No.", CustomerContract."No.");
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', CustomerContract.GetView(), Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    local procedure CreateBillingProposalForVendorContract()
    begin
        SetupServiceData(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.");
        VendorContract.SetRange("No.", VendorContract."No.");
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', VendorContract.GetView(), Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
    end;

    local procedure CreateServiceCommitmentTemplateSetup(CalcBasePeriodDateFormulaTxt: Text)
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        if CalcBasePeriodDateFormulaTxt <> '' then
            Evaluate(ServiceCommitmentTemplate."Billing Base Period", CalcBasePeriodDateFormulaTxt);
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);
    end;

    local procedure IncreaseCalculationBaseAmountForNonDiscountServiceCommitment()
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Discount, false);
        ServiceCommitment.FindLast();
        ServiceCommitment.Validate("Calculation Base Amount", ServiceCommitment."Calculation Base Amount" + LibraryRandom.RandDecInRange(1000, 2000, 2));
        ServiceCommitment.Modify(false);
    end;

    local procedure SetupSalesServiceData()
    begin

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
    end;

    local procedure SetupServiceData(ServicePartner: Enum "Service Partner")
    begin

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', ServicePartner, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', ServicePartner, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
    end;

    local procedure UpdateAndPostPurchaseHeader(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]): Code[20]
    begin
        PurchaseHeader.Get(DocumentType, DocumentNo);
        case DocumentType of
            Enum::"Purchase Document Type"::Invoice:
                PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
            Enum::"Purchase Document Type"::"Credit Memo":
                PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        end;
        PurchaseHeader.Modify(false);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure VerifyCustomerContractDeferralLines(ContractNo: Code[20]; DocumentNo: Code[20]; DocumentType: Enum "Rec. Billing Document Type"; Discount: Boolean)
    var
        CustomerContractDeferral: Record "Cust. Sub. Contract Deferral";
    begin
        CustomerContractDeferral.SetRange("Subscription Contract No.", ContractNo);
        CustomerContractDeferral.SetRange("Document Type", DocumentType);
        CustomerContractDeferral.SetRange("Document No.", DocumentNo);
        CustomerContractDeferral.SetRange(Discount, Discount);

        if CustomerContractDeferral.IsEmpty() then
            Error(NoDeferralLinesErr);

        CustomerContractDeferral.SetFilter(Amount, '<0');
        if not CustomerContractDeferral.IsEmpty() then
            Error(DiscountDeferralAmountSignErr, 'positive');
        CustomerContractDeferral.SetRange(Amount);

        CustomerContractDeferral.SetFilter("Deferral Base Amount", '<0');
        if not CustomerContractDeferral.IsEmpty() then
            Error(DiscountDeferralDeferralBaseAmountSignErr, 'positive');
        CustomerContractDeferral.SetRange("Deferral Base Amount");
    end;

    local procedure VerifyVendorContractDeferralLinesCreated(ContractNo: Code[20]; DocumentNo: Code[20]; DocumentType: Enum "Rec. Billing Document Type"; Discount: Boolean)
    var
        VendorContractDeferral: Record "Vend. Sub. Contract Deferral";
    begin
        VendorContractDeferral.SetRange("Subscription Contract No.", ContractNo);
        VendorContractDeferral.SetRange("Document Type", DocumentType);
        VendorContractDeferral.SetRange("Document No.", DocumentNo);
        VendorContractDeferral.SetRange(Discount, Discount);
        if VendorContractDeferral.IsEmpty() then
            Error(NoDeferralLinesErr);
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CreateBillingDocumentPageHandler(var CreateBillingDocument: TestPage "Create Billing Document")
    begin
        CreateBillingDocument.BillingDate.SetValue(WorkDate());
        CreateBillingDocument.BillingTo.SetValue(WorkDate());
        CreateBillingDocument.OpenDocument.SetValue(false);
        CreateBillingDocument.PostDocument.SetValue(false);
        CreateBillingDocument.OK().Invoke()
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.OK().Invoke();
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
