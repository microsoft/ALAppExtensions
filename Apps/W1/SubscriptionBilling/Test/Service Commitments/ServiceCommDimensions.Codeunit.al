namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Projects.Project.Job;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;

codeunit 148160 "Service Comm. Dimensions"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
        VendorBillingTemplate: Record "Billing Template";
        CustomerBillingTemplate: Record "Billing Template";
        BillingLine: Record "Billing Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Job: Record Job;
        VendorContract: Record "Vendor Contract";
        CustomerDeferrals: Record "Customer Contract Deferral";
        VendorDeferrals: Record "Vendor Contract Deferral";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ServiceObject: Record "Service Object";
        DimensionValue: Record "Dimension Value";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJob: Codeunit "Library - Job";
        LibraryDimension: Codeunit "Library - Dimension";
        DimMgt: Codeunit DimensionManagement;
        ItemDimSetID: Integer;
        DimSetIDArr: array[10] of Integer;
        NewDimSetID: Integer;

    local procedure Reset()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
    end;

    local procedure CreateServiceObjectItemWithDimensions()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        ContractTestLibrary.CreateServiceObjectItem(Item, false);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Item, Item."No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::Item, Item."No.");
        ItemDimSetID := DimMgt.GetDefaultDimID(DefaultDimSource, '', Item."Global Dimension 1 Code", Item."Global Dimension 2 Code", 0, Database::Item);
    end;

    [Test]
    procedure ExpectEqualServiceCommitmentAndItemDimensionSetIDOnCreateServiceObject()
    begin
        Reset();
        CreateServiceObjectItemWithDimensions();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", ItemDimSetID);
    end;

    // xxx
    [Test]
    procedure ExpectEqualSalesLineAndServiceCommitmentDimensionSetIDOnShipSalesOrder()
    var
        ServiceCommPackageLine: Record "Service Comm. Package Line";
    begin
        Reset();
        ContractTestLibrary.CreateServiceObjectItemWithServiceCommitments(Item);
        ServiceCommPackageLine.FindFirst();
        repeat
            ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, Item."No.");
            ServiceCommPackageLine."Invoicing Item No." := Item."No.";
            ServiceCommPackageLine.Modify(false);
        until ServiceCommPackageLine.Next() = 0;
        CreateAndPostSalesOrder(SalesHeader, SalesLine, '', Item."No.");

        ServiceObject.SetRange("Item No.", Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", SalesLine."Dimension Set ID");
    end;

    [Test]
    procedure ExpectMergedDimensionsForServiceWithInvoicingItemOnShipSalesOrder()
    var
        ServiceObjectItem: Record Item;
        InvoicingItem: Record Item;
        DimensionValueA1: Record "Dimension Value";
        DimensionValueA2: Record "Dimension Value";
        DimensionValueB1: Record "Dimension Value";
        DimensionValueC1: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        DimSetEntry: Record "Dimension Set Entry";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
    begin
        // Test: When using a Invoicing Item, Dimensions on the Service commitment should be merged between Service Object Item and Invoicing Item.
        // Invoicing Item Dimensions should be prioritized
        Reset();

        // Create Invoicing Item + Dimensions
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(InvoicingItem, InvoicingItem."Service Commitment Option"::"Invoicing Item");
        ContractTestLibrary.CreateDefaultDimensionValueForTable(DimensionValueA1, Database::Item, InvoicingItem."No."); // Dimension A1
        ContractTestLibrary.CreateDefaultDimensionValueForTable(DimensionValueB1, Database::Item, InvoicingItem."No."); // Dimension B1

        // Create Service Object Item + Dimensions
        ContractTestLibrary.CreateServiceObjectItem(ServiceObjectItem, false);
        LibraryDimension.CreateDimensionValue(DimensionValueA2, DimensionValueA1."Dimension Code"); // Dimension A2
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Item, ServiceObjectItem."No.", DimensionValueA2."Dimension Code", DimensionValueA2.Code);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(DimensionValueC1, Database::Item, InvoicingItem."No."); // Dimension C1

        // Create Service Commitment including Invoicing Item
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, Item."No.");
        ServiceCommPackageLine.Validate("Invoicing Item No.", InvoicingItem."No.");
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(ServiceObjectItem, ServiceCommitmentPackage.Code, true);

        CreateAndPostSalesOrder(SalesHeader, SalesLine, '', ServiceObjectItem."No.");

        ServiceObject.Reset();
        ServiceObject.SetRange("Item No.", ServiceObjectItem."No.");
        ServiceObject.FindFirst();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();

        ServiceCommitment.TestField("Dimension Set ID");
        DimSetEntry.Get(ServiceCommitment."Dimension Set ID", DimensionValueA1."Dimension Code");
        DimSetEntry.TestField("Dimension Value Code", DimensionValueA1.Code);
        DimSetEntry.Get(ServiceCommitment."Dimension Set ID", DimensionValueB1."Dimension Code");
        DimSetEntry.TestField("Dimension Value Code", DimensionValueB1.Code);
        DimSetEntry.Get(ServiceCommitment."Dimension Set ID", DimensionValueC1."Dimension Code");
        DimSetEntry.TestField("Dimension Value Code", DimensionValueC1.Code);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromCustContractHeaderToServiceCommitment()
    begin
        Reset();
        CreateServiceObjectItemWithDimensions();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        DimSetIDArr[2] := ItemDimSetID;

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        DimSetIDArr[1] := CustomerContract."Dimension Set ID";
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromJobToCustContractHeader()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        Reset();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        DimSetIDArr[1] := CustomerContract."Dimension Set ID";

        LibraryJob.CreateJob(Job);
        Job.Validate("Bill-to Customer No.", Customer."No.");
        Job.Modify(false);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Job, Job."No.");
        CustomerContract.Validate("Dimension from Job No.", Job."No.");
        CustomerContract.Modify(false);

        DimMgt.AddDimSource(DefaultDimSource, Database::Job, Job."No.");
        DimSetIDArr[2] := DimMgt.GetDefaultDimID(DefaultDimSource, '', Job."Global Dimension 1 Code", Job."Global Dimension 2 Code", 0, Database::Job);
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, CustomerContract."Shortcut Dimension 1 Code", CustomerContract."Shortcut Dimension 2 Code");

        CustomerContract.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualItemAndServiceCommitmentDimensionSetIDOnDeleteCustomerContractLine()
    begin
        Reset();
        CreateServiceObjectItemWithDimensions();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.DeleteAll(true);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", ItemDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromVendContractHeaderToServiceCommitment()
    begin
        Reset();
        CreateServiceObjectItemWithDimensions();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);
        DimSetIDArr[2] := ItemDimSetID;

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(VendorContract."Dimension Set ID");
        VendorContract.Modify(false);
        ContractTestLibrary.AssignServiceObjectToVendorContract(VendorContract, ServiceObject, false);
        DimSetIDArr[1] := VendorContract."Dimension Set ID";
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualItemAndServiceCommitmentDimensionSetIDOnDeleteVendorContractLine()
    begin
        Reset();
        CreateServiceObjectItemWithDimensions();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);

        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '');
        VendorContract.Modify(false);

        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        VendorContractLine.DeleteAll(true);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", ItemDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckBillingLineUpdateRequiredForVendContractOnAfterUpdateServiceCommitmentDimension()
    begin
        Reset();
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, '', VendorBillingTemplate);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        GeneralLedgerSetup.Get();
        LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        ServiceCommitment.ModifyAll("Shortcut Dimension 1 Code", DimensionValue.Code, true);

        BillingLine.SetRange("Contract No.", VendorContract."No.");
        BillingLine.FindFirst();
        BillingLine.TestField("Update Required", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckBillingLineUpdateRequiredForCustContractOnAfterUpdateServiceCommDimension()
    begin
        Reset();
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, '', CustomerBillingTemplate);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        GeneralLedgerSetup.Get();
        LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        ServiceCommitment.ModifyAll("Shortcut Dimension 1 Code", DimensionValue.Code, true);

        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.FindFirst();
        BillingLine.TestField("Update Required", true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualDimensionSetIDSalesLineAndCustContractLine()
    begin
        Reset();
        CreateSalesBillingDocuments();
        BillingLine.FindLast();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", BillingLine."Contract No.");
        ServiceCommitment.SetRange("Contract Line No.", BillingLine."Contract Line No.");
        ServiceCommitment.FindFirst();
        DimSetIDArr[2] := ServiceCommitment."Dimension Set ID";

        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange("Line No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        DimSetIDArr[1] := SalesLine."Dimension Set ID";

        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");
        SalesLine.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualDimensionSetIDPurchaseLineAndVendContractLine()
    begin
        Reset();
        CreatePurchaseBillingDocuments();
        BillingLine.FindLast();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", BillingLine."Contract No.");
        ServiceCommitment.SetRange("Contract Line No.", BillingLine."Contract Line No.");
        ServiceCommitment.FindFirst();
        DimSetIDArr[2] := ServiceCommitment."Dimension Set ID";

        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        DimSetIDArr[1] := PurchaseLine."Dimension Set ID";

        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");
        PurchaseLine.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckCustomerContractDeferralsDimension()
    begin
        Reset();
        CreateSalesBillingDocuments();
        BillingLine.FindLast();

        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange("Line No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        CustomerDeferrals.Reset();
        CustomerDeferrals.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        CustomerDeferrals.FindFirst();
        CustomerDeferrals.TestField("Dimension Set ID", SalesLine."Dimension Set ID");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(ServiceCommitment."Dimension Set ID");
        ServiceCommitment.Modify(false);
        CustomerContract.UpdateDimensionsInDeferrals();
        CustomerDeferrals.FindFirst();
        CustomerDeferrals.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckVendorContractDeferralsDimension()
    begin
        Reset();
        CreatePurchaseBillingDocuments();
        BillingLine.FindLast();

        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader."Vendor Invoice No." := PurchaseHeader."No.";
        PurchaseHeader.Modify(false);
        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");

        VendorDeferrals.Reset();
        VendorDeferrals.SetRange("Document No.", LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        VendorDeferrals.FindFirst();
        VendorDeferrals.TestField("Dimension Set ID", PurchaseLine."Dimension Set ID");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(ServiceCommitment."Dimension Set ID");
        ServiceCommitment.Modify(false);
        VendorContract.UpdateDimensionsInDeferrals();
        VendorDeferrals.FindFirst();
        VendorDeferrals.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectCustContractDimensionSyncOnContractsIfEqualServiceTemplate()
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        Reset();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");

        GeneralLedgerSetup.Get();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            DimensionSetEntry.SetRange("Dimension Set ID", ServiceCommitment."Dimension Set ID");
            DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Dimension Code Cust. Contr.");
            DimensionSetEntry.FindFirst();
            DimensionSetEntry.TestField("Dimension Value Code", CustomerContract."No.");
        until ServiceCommitment.Next() = 0;

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.DeleteAll(true);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            DimensionSetEntry.SetRange("Dimension Set ID", ServiceCommitment."Dimension Set ID");
            DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Dimension Code Cust. Contr.");
            if not DimensionSetEntry.IsEmpty() then
                Error('Dimension set entry is not expected.');
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithDifferentServiceCommitments()
    begin
        Reset();
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDIMfromServiceCommPackageToVendorServiceComm()
    var
        ServiceObjectItem: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        CustomerContract2: Record "Customer Contract";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        Reset();
        //Create Service Commitment Template with two packages
        //Assign packages to different customer and vendor contracts
        //Expect the customer contract dimension to be assigned only to vendor service commitment from the same package

        ContractTestLibrary.CreateServiceObjectItem(ServiceObjectItem, false);
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, ServiceObjectItem, false);
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);

        // Create Service Commitment Package with two lines (Vendor + Customer)
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        CreateServiceCommitmentPackageWithTwoLines(ServiceCommitmentTemplate, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(ServiceObjectItem, ServiceCommitmentPackage.Code, true);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, Item."No.");
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(ServiceObjectItem, ServiceCommitmentPackage.Code, true);
        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(WorkDate());

        //Assign first service commitment to customer contract
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract."No.");

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.AssignServiceObjectToVendorContract(VendorContract, ServiceObject, false);

        //Assign second service commitment to separate contract
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.SetFilter("Contract No.", '%1', '');
        ServiceCommitment.FindFirst();
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        ServiceCommitment."Contract No." := CustomerContract."No.";
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract2."No.");

        GeneralLedgerSetup.Get();
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            DimensionSetEntry.SetRange("Dimension Set ID", ServiceCommitment."Dimension Set ID");
            DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Dimension Code Cust. Contr.");
            DimensionSetEntry.FindFirst();
            DimensionSetEntry.TestField("Dimension Value Code", CustomerContract."No.");
        until ServiceCommitment.Next() = 0;
    end;

    local procedure CreateSalesBillingDocuments()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, Customer."No.", CustomerBillingTemplate);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Customer, Customer."No.");
        BillingLine.SetRange("Billing Template Code", CustomerBillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    local procedure CreatePurchaseBillingDocuments()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, Vendor."No.", VendorBillingTemplate);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Vendor, Vendor."No.");
        BillingLine.SetRange("Billing Template Code", VendorBillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    local procedure CreateAndPostSalesOrder(var NewSalesHeader: Record "Sales Header"; var NewSalesLine: Record "Sales Line"; SellToCustomerNo: Code[20]; ItemNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(NewSalesHeader, NewSalesHeader."Document Type"::Order, SellToCustomerNo);
        LibrarySales.CreateSalesLine(NewSalesLine, NewSalesHeader, NewSalesLine.Type::Item, ItemNo, LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(NewSalesHeader, true, true);
    end;

    local procedure CreateServiceCommitmentPackageWithTwoLines(ServiceCommitmentTemplate: Record "Service Commitment Template"; var ServiceCommitmentPackage: Record "Service Commitment Package"; ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, Item."No.");

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Vendor, Item."No.");
    end;

    [ModalPageHandler]
    procedure CreateCustomerBillingDocsContractPageHandler(var CreateCustomerBillingDocs: TestPage "Create Customer Billing Docs")
    begin
        CreateCustomerBillingDocs.GroupingType.SetValue(Enum::"Customer Rec. Billing Grouping"::"Sell-to Customer No.");
        CreateCustomerBillingDocs.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CreateVendorBillingDocsContractPageHandler(var CreateVendorBillingDocs: TestPage "Create Vendor Billing Docs")
    begin
        CreateVendorBillingDocs.GroupingType.SetValue(Enum::"Vendor Rec. Billing Grouping"::"Buy-from Vendor No.");
        CreateVendorBillingDocs.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;
}