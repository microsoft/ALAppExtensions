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

    local procedure InitTest()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
    end;

    [Test]
    procedure TestTransferDiscountInServiceCommitmentPackage()
    begin
        InitTest();
        CreateServiceCommitmentTemplateWithDiscount();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.TestField(Discount, true);
    end;

    [Test]
    procedure TestTransferDiscountInServiceCommitment()
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        CreateServiceCommitmentTemplateWithDiscount();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Item No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment.TestField(Discount, true);
            until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure ExpectErrorOnAssignDiscountInvoiceViaSalesInServiceCommitmentTemplate()
    begin
        InitTest();
        CreateServiceCommitmentTemplateWithDiscount();
        asserterror ServiceCommitmentTemplate.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    procedure ExpectErrorOnAssignDiscountInvoiceViaSalesInServiceCommitmentPackage()
    begin
        InitTest();
        CreateServiceCommitmentTemplateWithDiscount();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        asserterror ServiceCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
    end;

    [Test]
    procedure ExpectErrorOnAssignDiscountToInvoicingItemInServiceCommitmentPackage()
    begin
        InitTest();
        CreateServiceCommitmentTemplateWithDiscount();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        asserterror ServiceCommitmentTemplate.Validate("Invoicing Item No.", Item."No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDiscountInBillingLinesCustomerContract()
    begin
        CreateBillingProposalForCustomerContract();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.SetRange(Discount, true);
        BillingLine.FindSet();
        repeat
            if BillingLine."Service Amount" >= 0 then
                Error('Discount Billing line must have negative amount');
            if BillingLine."Service Obj. Quantity Decimal" >= 0 then
                Error('Discount Billing line must have negative quantity');
            if BillingLine."Unit Price" < 0 then
                Error('Discount Billing line must have positive price');
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfSalesInvoiceIsCreatedFromRecurringBilling()
    begin
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        //Check if document is created for each billing line (both discount and standard)
        if BillingLine.FindSet() then
            repeat
                BillingLine.TestField("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
                BillingLine.TestField("Document No.");
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestSalesInvoiceRecurringDiscountLines()
    begin
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
                    Error('Discount Sales line must have negative amount');
                if SalesLine."Amount Including VAT" >= 0 then
                    Error('Discount Sales line must have negative amount');
                if SalesLine."Unit Price" < 0 then
                    Error('Discount Sales line must have positive price');
                if SalesLine.Quantity > 0 then
                    Error('Discount Sales line must have negative price');
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestBillingLineArchiveOnRecurringDiscount()
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
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
    var
        CustomerContractDeferral: Record "Customer Contract Deferral";
    begin
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        CustomerContractDeferral.SetRange("Document Type", CustomerContractDeferral."Document Type"::Invoice);
        CustomerContractDeferral.SetRange("Document No.", PostedDocumentNo);
        CustomerContractDeferral.SetRange(Discount, true);
        CustomerContractDeferral.FindSet();
        repeat
            if CustomerContractDeferral.Amount < 0 then
                Error('Discount Deferral line must have positive amount');
            if CustomerContractDeferral."Deferral Base Amount" < 0 then
                Error('Discount Billing line must have positive Deferral Base Amount');
        until CustomerContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestSalesCreditMemoRecurringDiscountLine()
    begin
        CreateBillingProposalForCustomerContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Discount", true);
        SalesLine.FindSet();
        repeat
            if SalesLine.Amount >= 0 then
                Error('Discount Sales line must have negative amount');
            if SalesLine."Amount Including VAT" >= 0 then
                Error('Discount Sales line must have negative amount');
            if SalesLine."Unit Price" < 0 then
                Error('Discount Sales line must have positive price');
            if SalesLine.Quantity > 0 then
                Error('Discount Sales line must have negative price');
        until SalesLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestDiscountInBillingLinesVendorContract()
    begin
        CreateBillingProposalForVendorContract();
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange("Service Object No.", ServiceObject."No.");
        BillingLine.SetRange(Discount, true);
        BillingLine.FindSet();
        repeat
            if BillingLine."Service Amount" >= 0 then
                Error('Discount Billing line must have negative amount');
            if BillingLine."Service Obj. Quantity Decimal" >= 0 then
                Error('Discount Billing line must have negative quantity');
            if BillingLine."Unit Price" < 0 then
                Error('Discount Billing line must have positive price');
        until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfPurchaseInvoiceIsCreatedFromRecurringBilling()
    begin
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        //Check if document is created for each billing line (both discount and standard)
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
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.SetRange(Discount, true);
        if BillingLine.FindSet() then
            repeat
                PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
                if PurchaseLine.Amount >= 0 then
                    Error('Discount Purchase line must have negative amount');
                if PurchaseLine."Amount Including VAT" >= 0 then
                    Error('Discount Purchase line must have negative amount');
                if PurchaseLine."Unit Cost" < 0 then
                    Error('Discount Purchase line must have positive price');
                if PurchaseLine.Quantity > 0 then
                    Error('Discount Purchase line must have negative price');
            until BillingLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestVendorBillingLineArchiveOnRecurringDiscount()
    var
        BillingArchiveLine: Record "Billing Line Archive";
    begin
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        UpdateAndPostPurchaseHeader();

        BillingArchiveLine.FilterBillingLineArchiveOnDocument(BillingArchiveLine."Document Type"::Invoice, PostedDocumentNo);
        Assert.AreNotEqual(0, BillingArchiveLine.Count, 'Billing Archive Lines are not created for Recurring Discount Lines');
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestVendorContractDeferralsDiscountLines()
    var
        VendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        UpdateAndPostPurchaseHeader();
        VendorContractDeferral.SetRange("Document Type", VendorContractDeferral."Document Type"::Invoice);
        VendorContractDeferral.SetRange("Document No.", PostedDocumentNo);
        VendorContractDeferral.SetRange(Discount, true);
        VendorContractDeferral.FindSet();
        repeat
            if VendorContractDeferral.Amount > 0 then
                Error('Discount Deferral line must have positive amount');
            if VendorContractDeferral."Deferral Base Amount" > 0 then
                Error('Discount Billing line must have positive Deferral Base Amount');
        until VendorContractDeferral.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestPurchaseCreditMemoRecurringDiscountLine()
    begin
        CreateBillingProposalForVendorContract();
        CreateBillingDocuments();
        BillingLine.FindLast();
        UpdateAndPostPurchaseHeader();
        PurchInvHeader.Get(PostedDocumentNo);
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Discount", true);
        PurchaseLine.FindSet();
        repeat
            if PurchaseLine.Amount >= 0 then
                Error('Discount Purchase line must have negative amount');
            if PurchaseLine."Amount Including VAT" >= 0 then
                Error('Discount Purchase line must have negative amount');
            if PurchaseLine."Unit Cost" < 0 then
                Error('Discount Purchase line must have positive price');
            if PurchaseLine.Quantity > 0 then
                Error('Discount Purchase line must have negative price');
        until PurchaseLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    internal procedure CreateContractInvoiceFromCustomerContractWhenDiscountLineIsFirst()
    begin
        // when first Service Commitment is discount, but the document total amount is positive, Sales Invoice should be created
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        IncreaseCalculationBaseAmountForNonDiscountServiceCommitment(); // to get positive total amount of billing lines
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        BillingProposal.CreateBillingProposalFromContract(CustomerContract."No.", CustomerContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Customer);
        BillingLine.FindLast();
        // Test that correct sales document type has been created
        SalesLine.Get("Sales Document Type"::Invoice, BillingLine."Document No.", BillingLine."Document Line No.");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,CreateBillingDocumentPageHandler,MessageHandler')]
    internal procedure CreateContractInvoiceFromVendorContractWhenDiscountLineIsFirst()
    begin
        // when first Service Commitment is discount, but the document total amount is positive, Purchase Invoice should be created
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Last Direct Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Vendor, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        IncreaseCalculationBaseAmountForNonDiscountServiceCommitment(); // to get positive total amount of billing lines
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
        BillingProposal.CreateBillingProposalFromContract(VendorContract."No.", VendorContract.GetFilter("Billing Rhythm Filter"), "Service Partner"::Vendor);
        BillingLine.FindLast();
        // Test that correct purchase document type has been created
        PurchaseLine.Get("Purchase Document Type"::Invoice, BillingLine."Document No.", BillingLine."Document Line No.");
    end;

    [Test]
    procedure TestDiscountInSalesServiceCommitments()
    begin
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
    begin
        SetupSalesServiceData();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ServiceObject.FindLast();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            if ServiceCommitment.Price < 0 then
                Error('Price should be positive in service commitments with discounts');
            if ServiceCommitment."Calculation Base Amount" < 0 then
                Error('Calculation Base Amount should be positive in service commitments with discounts');
            if ServiceCommitment."Service Amount" < 0 then
                Error('Service Amount should be positive in service commitments with discounts');
            ServiceCommitment.TestField(Discount, true);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure ExpectErrorOnAssignRecurringDiscountToSalesServiceCommitment()
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        asserterror ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    [Test]
    procedure ExpectErrorOnAssignRecurringDiscountToInvoicingItem()
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        asserterror ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure TestServiceAmountInDiscountSalesServiceCommitments()
    var
        ContractsTestSubscriber: Codeunit "Contracts Test Subscriber";
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        Item.Modify(false);

        ContractsTestSubscriber.SetCallerName('RecurringDiscountTest - TestServiceAmountInDiscountSalesServiceCommitments');
        BindSubscription(ContractsTestSubscriber);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        UnbindSubscription(ContractsTestSubscriber);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));

        SalesServiceCommitment.Reset();
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange(Discount, true);
        SalesServiceCommitment.FindSet();
        repeat
            if SalesServiceCommitment."Service Amount" > 0 then
                Error('Service Amount in Sales Service Commitments with Discount is not calculated properly.')
        until SalesServiceCommitment.Next() = 0;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
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
    procedure CreateBillingDocumentPageHandler(var CreateBillingDocument: TestPage "Create Billing Document")
    begin
        CreateBillingDocument.BillingDate.SetValue(WorkDate());
        CreateBillingDocument.BillingTo.SetValue(WorkDate());
        CreateBillingDocument.OpenDocument.SetValue(false);
        CreateBillingDocument.PostDocument.SetValue(false);
        CreateBillingDocument.OK().Invoke()
    end;

    local procedure CreateBillingDocuments()
    begin
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        Commit(); //retain posted data
    end;

    procedure CreateBillingProposalForCustomerContract()
    begin
        SetupServiceData(Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        CustomerContract.SetRange("No.", CustomerContract."No.");
        ContractTestLibrary.CreateRecurringBillingTemplate(BillingTemplate, '<2M-CM>', '<8M+CM>', CustomerContract.GetView(), Enum::"Service Partner"::Customer);
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
    end;

    procedure CreateBillingProposalForVendorContract()
    begin
        SetupServiceData(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.");
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

    local procedure SetupServiceData(ServicePartner: Enum "Service Partner")
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Last Direct Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', ServicePartner, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', ServicePartner, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
    end;

    local procedure UpdateAndPostPurchaseHeader()
    begin
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure SetupSalesServiceData()
    begin
        InitTest();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateServiceCommitmentTemplateSetup('<12M>');
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', "Service Partner"::Customer, Item."No.", "Invoicing Via"::Contract, "Calculation Base Type"::"Item Price", '', '<1M>', true);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
    end;

    local procedure CreateServiceCommitmentTemplateWithDiscount()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate.Validate(Discount, true);
        ServiceCommitmentTemplate.Modify(false);
    end;

    local procedure IncreaseCalculationBaseAmountForNonDiscountServiceCommitment()
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Discount, false);
        ServiceCommitment.FindLast();
        ServiceCommitment.Validate("Calculation Base Amount", ServiceCommitment."Calculation Base Amount" + LibraryRandom.RandDecInRange(1000, 2000, 2));
        ServiceCommitment.Modify(false);
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.OK().Invoke();
    end;

    var
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        BillingLine: Record "Billing Line";
        Item: Record Item;
        BillingTemplate: Record "Billing Template";
        Customer: Record Customer;
        Vendor: Record Vendor;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesServiceCommitment: Record "Sales Service Commitment";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        BillingProposal: Codeunit "Billing Proposal";
        Assert: Codeunit Assert;
        PostedDocumentNo: Code[20];
}
