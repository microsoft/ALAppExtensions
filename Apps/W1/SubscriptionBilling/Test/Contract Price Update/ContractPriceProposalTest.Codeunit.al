namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.Currency;

codeunit 139690 "Contract Price Proposal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        Currency: Record Currency;
        TempContractPriceUpdateLine: Record "Contract Price Update Line" temporary;
        PriceUpdateTemplateCustomer: Record "Price Update Template";
        PriceUpdateTemplateVendor: Record "Price Update Template";
        ContractPriceUpdateLine: Record "Contract Price Update Line";
        BillingTemplate: Record "Billing Template";
        BillingLine: Record "Billing Line";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        PriceUpdateManagement: Codeunit "Price Update Management";
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        StrMenuHandlerStep: Integer;
        IsInitialized: Boolean;

    [Test]
    procedure TestCreateContractPriceUpdateProposal()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsNotEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandlerDeleteProposal')]
    procedure TestDeleteContractPriceUpdateProposal()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');

        StrMenuHandlerStep := 1;
        PriceUpdateManagement.DeleteProposal(PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.Reset();
        Assert.RecordIsEmpty(ContractPriceUpdateLine);

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());

        StrMenuHandlerStep := 2;
        PriceUpdateManagement.DeleteProposal(PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    procedure TestCreateContractPriceUpdateProposalCalculationBaseByPerc()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Service Amount", ServiceCommitment."Service Amount");

            ContractPriceUpdateLine.TestField("New Calculation Base %", PriceUpdateTemplateCustomer."Update Value %");
            ContractPriceUpdateLine.TestField("New Calculation Base", ContractPriceUpdateLine."Old Calculation Base");
            ContractPriceUpdateLine.TestField("New Price", Round(ContractPriceUpdateLine."New Calculation Base" * ContractPriceUpdateLine."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("New Service Amount", Round((ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity), Currency."Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("Additional Service Amount", ContractPriceUpdateLine."New Service Amount" - ContractPriceUpdateLine."Old Service Amount");
            ContractPriceUpdateLine.TestField("Discount Amount", ContractPriceUpdateLine."Discount %" * ContractPriceUpdateLine."New Service Amount");
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    procedure TestCreateContractPriceUpdateProposalPriceByPerc()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Price by %", WorkDate(), '<12M>', '<1M>', LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        Currency.InitRoundingPrecision();
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Service Amount", ServiceCommitment."Service Amount");

            ContractPriceUpdateLine.TestField("New Calculation Base %", ContractPriceUpdateLine."Old Calculation Base %");
            ContractPriceUpdateLine.TestField("New Calculation Base", Round(ContractPriceUpdateLine."Old Calculation Base" + ContractPriceUpdateLine."Old Calculation Base" * PriceUpdateTemplateCustomer."Update Value %" / 100, Currency."Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("New Price", Round(ContractPriceUpdateLine."Old Price" + ContractPriceUpdateLine."Old Price" * PriceUpdateTemplateCustomer."Update Value %" / 100, Currency."Unit-Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("New Service Amount", Round(ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity, Currency."Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("Additional Service Amount", ContractPriceUpdateLine."New Service Amount" - ContractPriceUpdateLine."Old Service Amount");
            ContractPriceUpdateLine.TestField("Discount Amount", ContractPriceUpdateLine."Discount %" * ContractPriceUpdateLine."New Service Amount");
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    procedure TestCreateContractPriceUpdateProposalRecentItemPrices()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", WorkDate(), '<12M>', '<1M>', 0, '<12M>', '<12M>', '<12M>');

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
            ContractPriceUpdateLine.TestField("Old Price", ServiceCommitment.Price);
            ContractPriceUpdateLine.TestField("Old Calculation Base", ServiceCommitment."Calculation Base Amount");
            ContractPriceUpdateLine.TestField("Old Calculation Base %", ServiceCommitment."Calculation Base %");
            ContractPriceUpdateLine.TestField("Old Service Amount", ServiceCommitment."Service Amount");

            ContractPriceUpdateLine.TestField("New Calculation Base %", ContractPriceUpdateLine."Old Calculation Base %");
            ContractPriceUpdateLine.TestField("New Price", Round(ContractPriceUpdateLine."New Calculation Base" * ContractPriceUpdateLine."New Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("New Service Amount", Round((ContractPriceUpdateLine."New Price" * ContractPriceUpdateLine.Quantity), Currency."Amount Rounding Precision"));
            ContractPriceUpdateLine.TestField("Additional Service Amount", ContractPriceUpdateLine."New Service Amount" - ContractPriceUpdateLine."Old Service Amount");
            ContractPriceUpdateLine.TestField("Discount Amount", ContractPriceUpdateLine."Discount %" * ContractPriceUpdateLine."New Service Amount");
        until ContractPriceUpdateLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckContractPriceUpdatePageGroupingLines()
    var
        CustomerContract: Record "Customer Contract";
        CustomerContract2: Record "Customer Contract";
    begin
        Initialize();

        CreateCustomerContractPriceUpdateFromMultipleContracts(CustomerContract, CustomerContract2);
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::None);
        TempContractPriceUpdateLine.SetRange(Indent, 0);
        Assert.IsTrue(TempContractPriceUpdateLine.IsEmpty(), 'Grouping Line should not be found.');

        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::Contract);
        TempContractPriceUpdateLine.SetFilter("Contract No.", '%1|%2', CustomerContract."No.", CustomerContract2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual(CustomerContract."No.", TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Customer."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual(CustomerContract2."No.", TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Customer2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.SetRange("Contract No.");
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempContractPriceUpdateLine.SetFilter("Partner No.", '%1|%2', Customer."No.", Customer2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual('', TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Customer."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual('', TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Customer2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure CheckRecurringBillingPageGroupingLinesForVendor()
    var
        VendorContract: Record "Vendor Contract";
        VendorContract2: Record "Vendor Contract";
    begin
        Initialize();

        CreateVendorContractPriceUpdateFromMultipleContracts(VendorContract, VendorContract2);
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::None);
        TempContractPriceUpdateLine.SetRange(Indent, 0);
        Assert.IsTrue(TempContractPriceUpdateLine.IsEmpty(), 'Grouping Line should not be found.');

        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::Contract);

        TempContractPriceUpdateLine.SetFilter("Contract No.", '%1|%2', VendorContract."No.", VendorContract2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual(VendorContract."No.", TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Vendor."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual(VendorContract2."No.", TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by Contract).');
        Assert.AreEqual(Vendor2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by Contract).');

        TempContractPriceUpdateLine.SetRange("Contract No.");
        PriceUpdateManagement.InitTempTable(TempContractPriceUpdateLine, Enum::"Contract Billing Grouping"::"Contract Partner");
        TempContractPriceUpdateLine.SetFilter("Partner No.", '%1|%2', Vendor."No.", Vendor2."No.");
        TempContractPriceUpdateLine.FindFirst();
        Assert.AreEqual('', TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Vendor."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');

        TempContractPriceUpdateLine.Next();
        Assert.AreEqual('', TempContractPriceUpdateLine."Contract No.", 'Contract No. is not set correctly in grouping line (Group by "Contract Partner").');
        Assert.AreEqual(Vendor2."No.", TempContractPriceUpdateLine."Partner No.", 'Partner No. is not set correctly in grouping line (Group by "Contract Partner").');
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestServiceCommitmentAfterPerformPriceUpdate()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustomerContract: Record "Customer Contract";
        TempContractPriceUpdateLine2: Record "Contract Price Update Line" temporary;
        TempServiceCommitment: Record "Service Commitment" temporary;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", WorkDate(), '<12M>', '<12M>', LibraryRandom.RandDec(100, 2), '<1M>', '<1M>', '<1M>');
        //Make sure that the service commitment is fully invoice until date of next price update
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            TempContractPriceUpdateLine2 := ContractPriceUpdateLine;
            TempContractPriceUpdateLine2.Insert(false);
            ServiceCommitment.Get(TempContractPriceUpdateLine2."Service Commitment Entry No.");
            TempServiceCommitment := ServiceCommitment;
            TempServiceCommitment.Insert(false);
        until ContractPriceUpdateLine.Next() = 0;

        PerformPriceUpdate();
        TempContractPriceUpdateLine2.Reset();
        TempContractPriceUpdateLine2.FindSet();
        repeat
            ServiceCommitment.Get(TempContractPriceUpdateLine2."Service Commitment Entry No.");
            TempServiceCommitment.Get(ServiceCommitment."Entry No.");
            TestServiceCommitmentPrices(TempContractPriceUpdateLine2."New Price", TempContractPriceUpdateLine2."New Calculation Base %", TempContractPriceUpdateLine2."New Calculation Base", TempContractPriceUpdateLine2."New Service Amount", TempContractPriceUpdateLine2."Next Price Update");
            TestIfArchivedServiceCommitmentIsCreated(TempServiceCommitment);
        until TempContractPriceUpdateLine2.Next() = 0;
    end;

    [Test]
    procedure TestPlannedServiceCommitmentAfterPerformPriceUpdate()
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
        TempContractPriceUpdateLine2: Record "Contract Price Update Line" temporary;
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');

        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        ContractPriceUpdateLine.FindSet();
        repeat
            TempContractPriceUpdateLine2 := ContractPriceUpdateLine;
            TempContractPriceUpdateLine2.Insert(false);
        until ContractPriceUpdateLine.Next() = 0;

        PerformPriceUpdate();
        TempContractPriceUpdateLine2.Reset();
        TempContractPriceUpdateLine2.FindSet();
        repeat
            PlannedServiceCommitment.Get(TempContractPriceUpdateLine2."Service Commitment Entry No.");
            TestPlannedServiceCommitment(PlannedServiceCommitment, TempContractPriceUpdateLine2."New Price", TempContractPriceUpdateLine2."New Calculation Base %", TempContractPriceUpdateLine2."New Calculation Base", TempContractPriceUpdateLine2."New Service Amount", CalcDate(PriceUpdateTemplateCustomer."Price Binding Period", ContractPriceUpdateLine."Perform Update On"));
        until TempContractPriceUpdateLine2.Next() = 0;
    end;

    [Test]
    procedure TestIfContractPriceUpdateLinesAreDeletedAfterPerformPriceUpdate()
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');

        PerformPriceUpdate();
        ContractPriceUpdateLine.Reset();
        Assert.RecordIsEmpty(ContractPriceUpdateLine);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestIfServiceCommIsUpdatedFromPlannedServiceCommitmentAfterPostSalesInvoice()
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
        SalesHeader: Record "Sales Header";
        CustomerContract: Record "Customer Contract";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        PerformPriceUpdate();

        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        Assert.IsTrue(ServiceCommitment."Planned Serv. Comm. exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);

        //Service commitment is updated from Planned service commitment
        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestServiceCommitmentPrices(PlannedServiceCommitment.Price, PlannedServiceCommitment."Calculation Base %", PlannedServiceCommitment."Calculation Base Amount", PlannedServiceCommitment."Service Amount", PlannedServiceCommitment."Next Price Update");

        //Planned service commitment will be deleted after sales invoice is posted
        asserterror PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestIfServiceCommIsUpdatedFromPlannedServiceCommitmentAfterPostPurchaseInvoice()
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForVendorServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        PerformPriceUpdate();

        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        Assert.IsTrue(ServiceCommitment."Planned Serv. Comm. exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        CreateAndPostPurchaseBillingDocuments(PurchaseHeader, PurchInvHeader);

        //Service commitment is updated from Planned service commitment
        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestServiceCommitmentPrices(PlannedServiceCommitment.Price, PlannedServiceCommitment."Calculation Base %", PlannedServiceCommitment."Calculation Base Amount", PlannedServiceCommitment."Service Amount", PlannedServiceCommitment."Next Price Update");

        //Planned service commitment will be deleted after sales invoice is posted
        asserterror PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestCancelPostedSalesInvoiceWithContractPriceUpdate()
    var
        OldServiceCommitment: Record "Service Commitment";
        PlannedServiceCommitment: Record "Planned Service Commitment";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustomerContract: Record "Customer Contract";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForCustomerServiceCommitments("Price Update Method"::"Calculation Base by %", CalcDate('<1M>', WorkDate()), '<12M>', '<12M>', 50, '<12M>', '<24M>', '<12M>');

        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        PerformPriceUpdate();

        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        Assert.IsTrue(ServiceCommitment."Planned Serv. Comm. exists", 'Planned Service Commitment was not created on Process Price Update.');

        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, ServiceObject."End-User Customer No.");
        CreateAndPostSalesBillingDocuments(SalesHeader, SalesInvoiceHeader);

        ServiceCommitmentArchive.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", ServiceCommitment."Entry No.");
        ServiceCommitmentArchive.FindLast();
        OldServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");

        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        //Service commitment is updated from service commitment archive
        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestServiceCommitmentPrices(ServiceCommitmentArchive.Price, ServiceCommitmentArchive."Calculation Base %", ServiceCommitmentArchive."Calculation Base Amount", ServiceCommitmentArchive."Service Amount", ServiceCommitmentArchive."Next Price Update");

        //Planned service commitment will be updated with old service commitment
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestPlannedServiceCommitment(PlannedServiceCommitment, OldServiceCommitment.Price, OldServiceCommitment."Calculation Base %", OldServiceCommitment."Calculation Base Amount", OldServiceCommitment."Service Amount", OldServiceCommitment."Next Price Update");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,ExchangeRateSelectionModalPageHandler,MessageHandler')]
    procedure TestCancelPostedPurchaseInvoiceWithContractPriceUpdate()
    var
        OldServiceCommitment: Record "Service Commitment";
        PlannedServiceCommitment: Record "Planned Service Commitment";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        ServiceCommitmentArchive: Record "Service Commitment Archive";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
    begin
        Initialize();

        CreateContractPriceUpdateProposalForVendorServiceCommitments("Price Update Method"::"Recent Item Prices", CalcDate('<1M>', WorkDate()), 0, '<12M>', '<24M>', '<12M>');
        ContractPriceUpdateLine.Reset();
        ContractPriceUpdateLine.FindLast();

        PerformPriceUpdate();

        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        Assert.IsTrue(ServiceCommitment."Planned Serv. Comm. exists", 'Planned Service Commitment was not created on Process Price Update.');
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");

        CreateAndPostPurchaseBillingDocuments(PurchaseHeader, PurchInvHeader);

        ServiceCommitmentArchive.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
        ServiceCommitmentArchive.SetRange("Original Entry No.", ServiceCommitment."Entry No.");
        ServiceCommitmentArchive.FindLast();
        OldServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");

        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        //Service commitment is updated from service commitment archive
        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestServiceCommitmentPrices(ServiceCommitmentArchive.Price, ServiceCommitmentArchive."Calculation Base %", ServiceCommitmentArchive."Calculation Base Amount", ServiceCommitmentArchive."Service Amount", ServiceCommitmentArchive."Next Price Update");

        //Planned service commitment will be updated with old service commitment
        PlannedServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        TestPlannedServiceCommitment(PlannedServiceCommitment, OldServiceCommitment.Price, OldServiceCommitment."Calculation Base %", OldServiceCommitment."Calculation Base Amount", OldServiceCommitment."Service Amount", OldServiceCommitment."Next Price Update");
    end;

    [Test]
    procedure TestIfServiceCommitmentWithoutNextPriceUpdateIsIncludedInContractPriceUpdateProposal()
    begin
        Initialize();

        InitTest();
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, Enum::"Price Update Method"::"Calculation Base by %", LibraryRandom.RandDec(100, 2), '<12M>', '<12M>', '<12M>');
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, '<12M>', Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, '<12M>');
        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);

        //Force Next Price Update Date to empty
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment."Next Price Update" := 0D;
            ServiceCommitment.Modify(false);
        until ServiceCommitment.Next() = 0;

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
        ContractPriceUpdateLine.SetRange("Price Update Template Code", PriceUpdateTemplateCustomer.Code);
        Assert.RecordIsNotEmpty(ContractPriceUpdateLine);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Contract Price Proposal Test");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Contract Price Proposal Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateJournalTemplMandatory(false);
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Contract Price Proposal Test");
    end;

    local procedure CreateBillingDocuments()
    begin
        BillingLine.SetRange("Billing Template Code", BillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingTemplate.Partner);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
        Commit(); // retain data after asserterror
    end;

    local procedure InitTest()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        Currency.InitRoundingPrecision();
    end;

    local procedure CreateCustomerContractPriceUpdateFromMultipleContracts(var CustomerContract: Record "Customer Contract"; var CustomerContract2: Record "Customer Contract")
    var
        ServiceObject2: Record "Service Object";
    begin
        InitTest();
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, "Price Update Method"::"Recent Item Prices", 0, '<12M>', '<12M>', '<12M>');
        PriceUpdateTemplateCustomer."Group by" := Enum::"Contract Billing Grouping"::Contract;

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.", false);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract2, ServiceObject2, Customer2."No.", false);

        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
    end;

    local procedure CreateVendorContractPriceUpdateFromMultipleContracts(var VendorContract: Record "Vendor Contract"; var VendorContract2: Record "Vendor Contract")
    var
        ServiceObject2: Record "Service Object";
    begin
        InitTest();
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateVendor, "Service Partner"::Vendor, "Price Update Method"::"Recent Item Prices", 0, '<24M>', '<24M>', '<12M>');
        PriceUpdateTemplateCustomer."Group by" := Enum::"Contract Billing Grouping"::Contract;

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", false);
        UpdateItemUnitCost(ServiceObject."Item No.");
        ContractTestLibrary.CreateVendor(Vendor2);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract2, ServiceObject2, Vendor2."No.", false);
        UpdateItemUnitCost(ServiceObject2."Item No.");
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateVendor.Code, CalcDate(PriceUpdateTemplateVendor.InclContrLinesUpToDateFormula, WorkDate()), WorkDate());
    end;

    local procedure UpdateItemUnitCost(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
        Item."Last Direct Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);
    end;

    local procedure TestIfArchivedServiceCommitmentIsCreated(TempServiceCommitment: Record "Service Commitment" temporary)
    var
        ServiceCommitmentArchive: Record "Service Commitment Archive";
    begin
        ServiceCommitmentArchive.FilterOnServiceCommitment(TempServiceCommitment."Entry No.");
        Assert.AreEqual(1, ServiceCommitmentArchive.Count, 'Service commitment was not archived properly on after perforom price update');

        ServiceCommitmentArchive.FindLast();
        ServiceCommitmentArchive.TestField(Price, TempServiceCommitment.Price);
        ServiceCommitmentArchive.TestField("Service Amount", TempServiceCommitment."Service Amount");
        ServiceCommitmentArchive.TestField("Calculation Base %", TempServiceCommitment."Calculation Base %");
        ServiceCommitmentArchive.TestField("Calculation Base Amount", TempServiceCommitment."Calculation Base Amount");
        ServiceCommitmentArchive.TestField("Type Of Update", Enum::"Type Of Price Update"::"Price Update");
    end;

    local procedure TestServiceCommitmentPrices(ExpectedPrice: Decimal; ExpectedCalculationBase: Decimal; ExpectedCalculationBaseAmount: Decimal; ExpectedServiceAmount: Decimal; ExpectedNextPriceUpdate: Date)
    begin
        ServiceCommitment.TestField(Price, ExpectedPrice);
        ServiceCommitment.TestField("Calculation Base %", ExpectedCalculationBase);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
        ServiceCommitment.TestField("Next Price Update", ExpectedNextPriceUpdate);
    end;

    local procedure TestPlannedServiceCommitment(PlannedServiceCommitment: Record "Planned Service Commitment"; ExpectedPrice: Decimal; ExpectedCalculationBase: Decimal; ExpectedCalculationBaseAmount: Decimal; ExpectedServiceAmount: Decimal; ExpectedNextPriceUpdate: Date)
    begin
        PlannedServiceCommitment.TestField(Price, ExpectedPrice);
        PlannedServiceCommitment.TestField("Calculation Base %", ExpectedCalculationBase);
        PlannedServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        PlannedServiceCommitment.TestField("Service Amount", ExpectedServiceAmount);
        PlannedServiceCommitment.TestField("Next Price Update", ExpectedNextPriceUpdate);
    end;

    local procedure CreateAndPostPurchaseBillingDocuments(var PurchaseHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header")
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Vendor);
        CreateBillingDocuments();
        BillingLine.Reset();
        BillingLine.FindFirst();
        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify(false);
        PurchInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateAndPostSalesBillingDocuments(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        ContractTestLibrary.CreateBillingProposal(BillingTemplate, Enum::"Service Partner"::Customer);
        CreateBillingDocuments();
        BillingLine.Reset();
        BillingLine.FindFirst();
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateContractPriceUpdateProposalForCustomerServiceCommitments(PriceUpdateMethod: Enum "Price Update Method"; ContractPriceUpdateBaseDate: Date; CalculationBaseFormula: Text; CalculationRhythmDateFormula: Text; UpdateValuePerc: Decimal; PerformUpdateOnFormula: Text; InclContrLinesUpToDateFormula: Text; PriceBindingPeriod: Text)
    begin
        InitTest();
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateCustomer, "Service Partner"::Customer, PriceUpdateMethod, UpdateValuePerc, PerformUpdateOnFormula, InclContrLinesUpToDateFormula, PriceBindingPeriod);
        ContractTestLibrary.CreateMultipleServiceObjectsWithItemSetup(Customer, ServiceObject, Item, 2);
        ContractTestLibrary.CreateServiceCommitmentTemplateSetup(ServiceCommitmentTemplate, CalculationBaseFormula, Enum::"Invoicing Via"::Contract);
        ContractTestLibrary.CreateServiceCommPackageAndAssignItemToServiceCommitmentSetup(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine, Item, CalculationRhythmDateFormula);

        ContractTestLibrary.InsertServiceCommitmentFromServiceCommPackageSetup(ServiceCommitmentPackage, ServiceObject);
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateCustomer.Code, CalcDate(PriceUpdateTemplateCustomer.InclContrLinesUpToDateFormula, ContractPriceUpdateBaseDate), ContractPriceUpdateBaseDate);
    end;

    local procedure CreateContractPriceUpdateProposalForVendorServiceCommitments(PriceUpdateMethod: Enum "Price Update Method"; ContractPriceUpdateBaseDate: Date; UpdateValuePerc: Decimal; PerformUpdateOnFormula: Text; InclContrLinesUpToDateFormula: Text; PriceBindingPeriod: Text)
    var
        VendorContract: Record "Vendor Contract";
    begin
        InitTest();
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplateVendor, "Service Partner"::Vendor, PriceUpdateMethod, UpdateValuePerc, PerformUpdateOnFormula, InclContrLinesUpToDateFormula, PriceBindingPeriod);
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, Vendor."No.", false);
        UpdateItemUnitCost(ServiceObject."Item No.");
        PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplateVendor.Code, CalcDate(PriceUpdateTemplateVendor.InclContrLinesUpToDateFormula, ContractPriceUpdateBaseDate), ContractPriceUpdateBaseDate);
    end;

    local procedure PerformPriceUpdate()
    begin
        Commit(); // Commit before processing
        PriceUpdateManagement.PerformPriceUpdate();
        Commit(); // Commit after processing
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
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [StrMenuHandler]
    procedure StrMenuHandlerDeleteProposal(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        case StrMenuHandlerStep of
            1:
                Choice := 1;
            2:
                Choice := 2;
            else
                Choice := 0;
        end;
    end;
}
