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
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        DimMgt: Codeunit DimensionManagement;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryJob: Codeunit "Library - Job";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        DimensionSetEntryValueErr: Label 'Service Commitment should have Dimension "%1" with value "%2".', Locked = true;

    #region Tests

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckBillingLineUpdateRequiredForVendContractOnAfterUpdateServiceCommitmentDimension()
    var
        BillingLine: Record "Billing Line";
        VendorBillingTemplate: Record "Billing Template";
        DimensionValue: Record "Dimension Value";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
    begin
        Initialize();

        ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, '', VendorBillingTemplate);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");

        LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        ServiceCommitment.ModifyAll("Shortcut Dimension 1 Code", DimensionValue.Code, true);

        BillingLine.SetRange("Contract No.", VendorContract."No.");
        BillingLine.FindFirst();
        BillingLine.TestField("Update Required", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckBillingLineUpdateRequiredForCustContractOnAfterUpdateServiceCommDimension()
    var
        BillingLine: Record "Billing Line";
        CustomerBillingTemplate: Record "Billing Template";
        CustomerContract: Record "Customer Contract";
        DimensionValue: Record "Dimension Value";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, '', CustomerBillingTemplate);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        ServiceCommitment.ModifyAll("Shortcut Dimension 1 Code", DimensionValue.Code, true);

        BillingLine.SetRange("Contract No.", CustomerContract."No.");
        BillingLine.FindFirst();
        BillingLine.TestField("Update Required", true);
    end;

    [Test]
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckCustomerContractDeferralsDimension()
    var
        BillingLine: Record "Billing Line";
        CustomerContract: Record "Customer Contract";
        CustomerContractDeferral: Record "Customer Contract Deferral";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        Initialize();

        CreateSalesBillingDocuments(BillingLine, ServiceObject, CustomerContract);
        BillingLine.FindLast();

        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, BillingLine."Document No.");
        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange("Line No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        CustomerContractDeferral.Reset();
        CustomerContractDeferral.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        CustomerContractDeferral.FindFirst();
        CustomerContractDeferral.TestField("Dimension Set ID", SalesLine."Dimension Set ID");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(ServiceCommitment."Dimension Set ID");
        ServiceCommitment.Modify(false);
        CustomerContract.UpdateDimensionsInDeferrals();
        CustomerContractDeferral.FindFirst();
        CustomerContractDeferral.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure CheckVendorContractDeferralsDimension()
    var
        BillingLine: Record "Billing Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        VendorContractDeferral: Record "Vendor Contract Deferral";
    begin
        Initialize();

        CreatePurchaseBillingDocuments(BillingLine, ServiceObject, VendorContract);
        BillingLine.FindLast();

        PurchaseHeader.Get(Enum::"Purchase Document Type"::Invoice, BillingLine."Document No.");
        PurchaseHeader."Vendor Invoice No." := PurchaseHeader."No.";
        PurchaseHeader.Modify(false);
        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");

        VendorContractDeferral.Reset();
        VendorContractDeferral.SetRange("Document No.", LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        VendorContractDeferral.FindFirst();
        VendorContractDeferral.TestField("Dimension Set ID", PurchaseLine."Dimension Set ID");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(ServiceCommitment."Dimension Set ID");
        ServiceCommitment.Modify(false);
        VendorContract.UpdateDimensionsInDeferrals();
        VendorContractDeferral.FindFirst();
        VendorContractDeferral.TestField("Dimension Set ID", ServiceCommitment."Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectCustContractDimensionSyncOnContractsIfEqualServiceTemplate()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        DimensionSetEntry: Record "Dimension Set Entry";
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        DimSetEntryNotExpectedErr: Label 'Dimension set entry is not expected.', Locked = true;
    begin
        Initialize();

        // [WHEN] Auto Insert Customer Contract Dimension Value is enabled
        ContractTestLibrary.SetAutomaticDimensions(true);

        // [WHEN] Customer Contract dimension value is created
        ContractTestLibrary.InsertCustomerContractDimensionCode();

        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");

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
                Error(DimSetEntryNotExpectedErr);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure ExpectEqualServiceCommitmentAndItemDimensionSetIDOnCreateServiceObject()
    var
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        ItemDimSetID: Integer;
    begin
        Initialize();

        CreateServiceObjectItemWithDimensions(ItemDimSetID, Item);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", ItemDimSetID);
    end;

    [Test]
    procedure ExpectEqualSalesLineAndServiceCommitmentDimensionSetIDOnShipSalesOrder()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        Initialize();

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
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualItemAndServiceCommitmentDimensionSetIDOnDeleteCustomerContractLine()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        ItemDimSetID: Integer;
    begin
        Initialize();

        CreateServiceObjectItemWithDimensions(ItemDimSetID, Item);
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
    procedure ExpectEqualItemAndServiceCommitmentDimensionSetIDOnDeleteVendorContractLine()
    var
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        VendorContractLine: Record "Vendor Contract Line";
        ItemDimSetID: Integer;
    begin
        Initialize();

        CreateServiceObjectItemWithDimensions(ItemDimSetID, Item);
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
    [HandlerFunctions('CreateCustomerBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualDimensionSetIDSalesLineAndCustContractLine()
    var
        BillingLine: Record "Billing Line";
        CustomerContract: Record "Customer Contract";
        SalesLine: Record "Sales Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        DimSetIDArray: array[10] of Integer;
        NewDimSetID: Integer;
    begin
        Initialize();

        CreateSalesBillingDocuments(BillingLine, ServiceObject, CustomerContract);
        BillingLine.FindLast();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", BillingLine."Contract No.");
        ServiceCommitment.SetRange("Contract Line No.", BillingLine."Contract Line No.");
        ServiceCommitment.FindFirst();
        DimSetIDArray[2] := ServiceCommitment."Dimension Set ID";

        SalesLine.SetRange("Document Type", BillingLine.GetSalesDocumentTypeFromBillingDocumentType());
        SalesLine.SetRange("Document No.", BillingLine."Document No.");
        SalesLine.SetRange("Line No.", BillingLine."Document Line No.");
        SalesLine.FindFirst();
        DimSetIDArray[1] := SalesLine."Dimension Set ID";

        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArray, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");
        SalesLine.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('CreateVendorBillingDocsContractPageHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectEqualDimensionSetIDPurchaseLineAndVendContractLine()
    var
        BillingLine: Record "Billing Line";
        PurchaseLine: Record "Purchase Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        DimSetIDArray: array[10] of Integer;
        NewDimSetID: Integer;
    begin
        Initialize();

        CreatePurchaseBillingDocuments(BillingLine, ServiceObject, VendorContract);
        BillingLine.FindLast();

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", BillingLine."Contract No.");
        ServiceCommitment.SetRange("Contract Line No.", BillingLine."Contract Line No.");
        ServiceCommitment.FindFirst();
        DimSetIDArray[2] := ServiceCommitment."Dimension Set ID";

        PurchaseLine.Get(BillingLine.GetPurchaseDocumentTypeFromBillingDocumentType(), BillingLine."Document No.", BillingLine."Document Line No.");
        DimSetIDArray[1] := PurchaseLine."Dimension Set ID";

        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArray, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");
        PurchaseLine.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure ExpectErrorOnMergeCustomerContractLineWithDifferentServiceCommitments()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContractLine: Record "Customer Contract Line";
        Item: Record Item;
        ServiceObject: Record "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        CustomerContractLine.Reset();
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    procedure ExpectMergedDimensionsForServiceWithInvoicingItemOnShipSalesOrder()
    var
        DefaultDimension: Record "Default Dimension";
        DimSetEntry: Record "Dimension Set Entry";
        DimensionValueA1: Record "Dimension Value";
        DimensionValueA2: Record "Dimension Value";
        DimensionValueB1: Record "Dimension Value";
        DimensionValueC1: Record "Dimension Value";
        InvoicingItem: Record Item;
        Item: Record Item;
        ServiceObjectItem: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceObject: Record "Service Object";
    begin
        // Test: When using a Invoicing Item, Dimensions on the Service commitment should be merged between Service Object Item and Invoicing Item.
        // Invoicing Item Dimensions should be prioritized
        Initialize();

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
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure ServiceCommitmentDimensionsAreTakenFromSalesLineAndInvoicingItemWhenShipmentPosted()
    var
        DefaultDimension: Record "Default Dimension";
        InvoicingItemDimension: Record Dimension;
        SSCDimension: Record Dimension;
        DimensionSetEntry: Record "Dimension Set Entry";
        InvoicingItemDimensionValue: Record "Dimension Value";
        SSCDimensionValues: array[2] of Record "Dimension Value";
        InvoicingItem: Record Item;
        SalesWithServiceCommitmentItem: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        Index: Integer;
    begin
        // [SCENARIO] When Service Commitment is created by shipping a Sales Order with "Sales with Service Commitment" type Item,
        // Service Commitment Dimensions should be assigned first from Invoicing item and then from Sales Line.
        Initialize();

        // Dimensions with Values created:
        //
        // | Dimension | Dimension Values | Record        |
        // |-----------|------------------|---------------|
        // | Dim1      | A, B             | Item          |
        // | Dim2      | X                | InvoicingItem |

        // [GIVEN] Dimension "Dim1" with two values "A" and "B"
        LibraryDimension.CreateDimension(SSCDimension);
        for Index := 1 to ArrayLen(SSCDimensionValues) do
            LibraryDimension.CreateDimensionValue(SSCDimensionValues[Index], SSCDimension."Code");

        // [GIVEN] Dimension "Dim2" with value "X"
        LibraryDimension.CreateDimension(InvoicingItemDimension);
        LibraryDimension.CreateDimensionValue(InvoicingItemDimensionValue, InvoicingItemDimension."Code");

        // [GIVEN] "SalesWithServiceCommitmentItem" has Dimension "Dim1" with Value "A"
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(SalesWithServiceCommitmentItem, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, SalesWithServiceCommitmentItem."No.", SSCDimension.Code, SSCDimensionValues[1].Code);

        // [GIVEN] "InvoicingItem" has Dimension "Dim2" and Value "X"
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(InvoicingItem, Enum::"Item Service Commitment Type"::"Invoicing Item");
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, InvoicingItem."No.", InvoicingItemDimension.Code, InvoicingItemDimensionValue.Code);

        // [GIVEN] Service Commitment Package with "InvoicingItem" item
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', Enum::"Service Partner"::Customer, InvoicingItem."No.", Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(SalesWithServiceCommitmentItem, ServiceCommitmentPackage.Code);

        // [GIVEN] Sales Order with "SalesWithServiceCommitmentItem"
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, SalesWithServiceCommitmentItem."No.", 1);

        // [GIVEN] Dimension "Dim1" has changed to value "B" for the Sales Line
        UpdateSalesLineDimension(SalesLine, SSCDimension.Code, SSCDimensionValues[2].Code);

        // [WHEN] Sales Order is shipped
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Service Object is created with Dimension "Dim1" with value "B"
        // [THEN] Service Commitment created with Dimension "Dim1" and value "B"
        FindServiceCommitment(SalesHeader."Sell-to Customer No.", ServiceCommitment);
        DimensionSetEntry.Get(ServiceCommitment."Dimension Set ID", SSCDimension.Code);
        Assert.AreEqual(SSCDimensionValues[2].Code, DimensionSetEntry."Dimension Value Code", 'Service Commitment should have Dimension "Dim1" with value "B" inherited from Sales Line.');

        // Expected Dimensions and Values for Service Commitment:
        //
        // | Dimension | Dimension Value |
        // |-----------|-----------------|
        // | Dim1      | B               |
        // | Dim2      | X               |

        // [THEN] Service Commitment created with Dimension "Dim2" and value "X"
        DimensionSetEntry.Get(ServiceCommitment."Dimension Set ID", InvoicingItemDimension.Code);
        Assert.AreEqual(InvoicingItemDimensionValue.Code, DimensionSetEntry."Dimension Value Code", 'Service Commitment should have Dimension "Dim2" with value "X" from Invoicing Item.');
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure ServiceCommitmentDimensionsAreTakenFromItemAndSalesLineWhenShipmentPosted()
    var
        DefaultDimension: Record "Default Dimension";
        ItemDimensions: array[2] of Record Dimension;
        SalesLineDimension: Record Dimension;
        ItemDimensionValues: array[3] of Record "Dimension Value";
        SalesLineDimensionValue: Record "Dimension Value";
        ServiceCommitmentItem: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        Index: Integer;
    begin
        // [SCENARIO] When Service Commitment is created by shipping a Sales Order with "Service Commitment" type Item,
        // Service Commitment Dimensions should be taken first from Sales Line Item and then from Sales Line.
        Initialize();

        // Dimensions with Values created:
        //
        // | Dimension | Dimension Values | Record     |
        // |-----------|------------------|------------|
        // | Dim1      | A, X             | Item       |
        // | Dim2      | B                | Item       |
        // | Dim3      | C                | Sales Line |

        // [GIVEN] Dimensions "Dim1" with value "A" and "Dim2" with value "B"
        for Index := 1 to ArrayLen(ItemDimensions) do begin
            LibraryDimension.CreateDimension(ItemDimensions[Index]);
            LibraryDimension.CreateDimensionValue(ItemDimensionValues[Index], ItemDimensions[Index].Code);
        end;

        // [GIVEN] Dimensions "Dim3" with value "C"
        LibraryDimension.CreateDimension(SalesLineDimension);
        LibraryDimension.CreateDimensionValue(SalesLineDimensionValue, SalesLineDimension.Code);

        // [GIVEN] Additional dimension Value "X" for "Dim1"
        LibraryDimension.CreateDimensionValue(ItemDimensionValues[3], ItemDimensions[1].Code);

        // [GIVEN] "ServiceCommitmentItem" with default Dimensions "Dim1" with Value "A" and "Dim2" with value "B"
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(ServiceCommitmentItem, Enum::"Item Service Commitment Type"::"Service Commitment Item");

        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, ServiceCommitmentItem."No.", ItemDimensions[1].Code, ItemDimensionValues[1].Code);
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, ServiceCommitmentItem."No.", ItemDimensions[2].Code, ItemDimensionValues[2].Code);

        // [GIVEN] Service Commitment Package with "ServiceCommitmentItem" item
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '', 100, '', Enum::"Service Partner"::Customer, '', Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(ServiceCommitmentItem, ServiceCommitmentPackage.Code);

        // [GIVEN] Sales Order with "ServiceCommitmentItem"
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, ServiceCommitmentItem."No.", 1);

        // [GIVEN] Dimension "Dim1" value changed to "X" for the Sales Line
        UpdateSalesLineDimension(SalesLine, ItemDimensions[1].Code, ItemDimensionValues[3].Code);

        // [GIVEN] Dimension "Dim3" with value "C" added to the Sales Line
        AddDimensionToSalesLine(SalesLine, SalesLineDimension.Code, SalesLineDimensionValue.Code);

        // [WHEN] Sales Order is shipped
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Expected Dimensions and Values for Service Commitment:
        //
        // | Dimension | Dimension Values |
        // |-----------|------------------|
        // | Dim1      | A                |
        // | Dim2      | B                |
        // | Dim3      | C                |

        // [THEN] Service Commitment created with Dimension "Dim1" and value "A" and Dimension "Dim2" and value "B"
        FindServiceCommitment(SalesHeader."Sell-to Customer No.", ServiceCommitment);
        for Index := 1 to ArrayLen(ItemDimensions) do
            VerifyDimensionSetValue(ServiceCommitment."Dimension Set ID", ItemDimensions[Index].Code, ItemDimensionValues[Index].Code);

        // [THEN] Service Commitment created with Dimension "Dim3" and value "C"
        VerifyDimensionSetValue(ServiceCommitment."Dimension Set ID", SalesLineDimension.Code, SalesLineDimensionValue.Code);
    end;

    [Test]
    procedure ServiceCommitmentDimensionsAreTakenFromInvoicingItemAndItemWhenCreatedManually()
    var
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
        InvoicingItemDimension: Record Dimension;
        DimensionValues: array[2] of Record "Dimension Value";
        InvoicingItemDimensionValue: Record "Dimension Value";
        InvoicingItem: Record Item;
        Item: Record Item;
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceObject: Record "Service Object";
        Index: Integer;
    begin
        // [SCENARIO] When Service Commitment is created manually, Service Commitment dimensions are taken from Invoicing Item of the Service Commitment Package and then from Item
        Initialize();

        // Dimensions with Values created:
        //
        // | Dimension | Dimension Values | Record         |
        // |-----------|------------------|----------------|
        // | Dim1      | A                | Item           |
        // | Dim1      | B                | Invoicing Item |
        // | Dim2      | X                | Invoicing Item |

        // [GIVEN] Dimension "Dim1" with two values "A" and "B"
        LibraryDimension.CreateDimension(Dimension);
        for Index := 1 to ArrayLen(DimensionValues) do
            LibraryDimension.CreateDimensionValue(DimensionValues[Index], Dimension."Code");

        // [GIVEN] Dimension "Dim2" with value "X"
        LibraryDimension.CreateDimension(InvoicingItemDimension);
        LibraryDimension.CreateDimensionValue(InvoicingItemDimensionValue, InvoicingItemDimension."Code");

        // [GIVEN] Default Dimensions assigned for Item = "Dim1" with value "A" and for Invoicing Item = "Dim1" with value "B" and "Dim2" with value "X"
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, Item."No.", Dimension.Code, DimensionValues[1].Code);

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(InvoicingItem, Enum::"Item Service Commitment Type"::"Invoicing Item");
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, InvoicingItem."No.", Dimension.Code, DimensionValues[2].Code);
        LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, InvoicingItem."No.", InvoicingItemDimension.Code, InvoicingItemDimensionValue.Code);

        // [GIVEN] Service Commitment Package with "Item" and "Invoicing Item" in package line
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommitmentPackage.SetRecFilter();
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(
                ServiceCommPackageLine, '', 100, '', Enum::"Service Partner"::Customer, InvoicingItem."No.",
                Enum::"Invoicing Via"::Contract, Enum::"Calculation Base Type"::"Item Price", '', '<1M>', false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        // [WHEN] Assign Service Commitment Package to Service Object
        ContractTestLibrary.CreateServiceObject(ServiceObject, Item."No.", false);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        // [THEN] Service Commitment created with Dimension "Dim1" and value "B" from Invoicing Item and "Dim2" and value "X" from Invoicing Item
        // | Dimension | Dimension Values |
        // |-----------|------------------|
        // | Dim1      | B                |
        // | Dim2      | X                |

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        VerifyDimensionSetValue(ServiceCommitment."Dimension Set ID", Dimension.Code, DimensionValues[2].Code);
        VerifyDimensionSetValue(ServiceCommitment."Dimension Set ID", InvoicingItemDimension.Code, InvoicingItemDimensionValue.Code);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromCustContractHeaderToServiceCommitment()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        DimSetIDArray: array[10] of Integer;
        ItemDimSetID: Integer;
        NewDimSetID: Integer;
    begin
        Initialize();

        CreateServiceObjectItemWithDimensions(ItemDimSetID, Item);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);
        DimSetIDArray[2] := ItemDimSetID;

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        DimSetIDArray[1] := CustomerContract."Dimension Set ID";
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArray, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromJobToCustContractHeader()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        Item: Record Item;
        Job: Record Job;
        ServiceObject: Record "Service Object";
        DimSetIDArray: array[10] of Integer;
        NewDimSetID: Integer;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 0);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        DimSetIDArray[1] := CustomerContract."Dimension Set ID";

        LibraryJob.CreateJob(Job);
        Job.Validate("Bill-to Customer No.", Customer."No.");
        Job.Modify(false);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Job, Job."No.");
        CustomerContract.Validate("Dimension from Job No.", Job."No.");
        CustomerContract.Modify(false);

        DimMgt.AddDimSource(DefaultDimSource, Database::Job, Job."No.");
        DimSetIDArray[2] := DimMgt.GetDefaultDimID(DefaultDimSource, '', Job."Global Dimension 1 Code", Job."Global Dimension 2 Code", 0, Database::Job);
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArray, CustomerContract."Shortcut Dimension 1 Code", CustomerContract."Shortcut Dimension 2 Code");

        CustomerContract.TestField("Dimension Set ID", NewDimSetID);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromServiceCommPackageToVendorServiceComm()
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        CustomerContract2: Record "Customer Contract";
        DimensionSetEntry: Record "Dimension Set Entry";
        Item: Record Item;
        ServiceObjectItem: Record Item;
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceObject: Record "Service Object";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Contract";
    begin
        Initialize();

        // [WHEN] Auto Insert Customer Contract Dimension Value is enabled
        ContractTestLibrary.SetAutomaticDimensions(true);

        // [WHEN] Customer Contract dimension value is created
        ContractTestLibrary.InsertCustomerContractDimensionCode();

        // Create Service Commitment Template with two packages
        // Assign packages to different customer and vendor contracts
        // Expect the customer contract dimension to be assigned only to vendor service commitment from the same package

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

        // Assign first service commitment to customer contract
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.FindFirst();
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract."No.");

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.AssignServiceObjectToVendorContract(VendorContract, ServiceObject, false);

        // Assign second service commitment to separate contract
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        ServiceCommitment.SetFilter("Contract No.", '%1', '');
        ServiceCommitment.FindFirst();
        ContractTestLibrary.CreateCustomerContract(CustomerContract2, Customer."No.");
        ServiceCommitment."Contract No." := CustomerContract."No.";
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract2."No.");

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

    [Test]
    [HandlerFunctions('MessageHandler,ExchangeRateSelectionModalPageHandler')]
    procedure TestTransferDimensionsFromVendContractHeaderToServiceCommitment()
    var
        Item: Record Item;
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Contract";
        DimSetIDArray: array[10] of Integer;
        NewDimSetID: Integer;
    begin
        Initialize();

        CreateServiceObjectItemWithDimensions(DimSetIDArray[2], Item);
        ContractTestLibrary.CreateServiceObjectWithItemAndWithServiceCommitment(ServiceObject, Enum::"Invoicing Via"::Contract, false, Item, 1, 1);

        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
        ContractTestLibrary.AppendRandomDimensionValueToDimensionSetID(VendorContract."Dimension Set ID");
        VendorContract.Modify(false);
        ContractTestLibrary.AssignServiceObjectToVendorContract(VendorContract, ServiceObject, false);
        DimSetIDArray[1] := VendorContract."Dimension Set ID";
        NewDimSetID := DimMgt.GetCombinedDimensionSetID(DimSetIDArray, ServiceCommitment."Shortcut Dimension 1 Code", ServiceCommitment."Shortcut Dimension 2 Code");

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Dimension Set ID", NewDimSetID);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Comm. Dimensions");
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.InsertCustomerContractDimensionCode();

        GeneralLedgerSetup.Get();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Comm. Dimensions");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.CreateVATData();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Service Comm. Dimensions");
    end;

    local procedure AddDimensionToSalesLine(var SalesLine: Record "Sales Line"; NewDimensionCode: Code[20]; NewDimensionValueCode: Code[20])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, SalesLine."Dimension Set ID");
        TempDimensionSetEntry.Init();
        TempDimensionSetEntry."Dimension Set ID" := SalesLine."Dimension Set ID";
        TempDimensionSetEntry.Validate("Dimension Code", NewDimensionCode);
        TempDimensionSetEntry.Validate("Dimension Value Code", NewDimensionValueCode);
        TempDimensionSetEntry.Insert(false);
        SalesLine.Validate("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        SalesLine.Modify(true);
    end;

    local procedure CreateAndPostSalesOrder(var NewSalesHeader: Record "Sales Header"; var NewSalesLine: Record "Sales Line"; SellToCustomerNo: Code[20]; ItemNo: Code[20])
    begin
        LibrarySales.CreateSalesHeader(NewSalesHeader, NewSalesHeader."Document Type"::Order, SellToCustomerNo);
        LibrarySales.CreateSalesLine(NewSalesLine, NewSalesHeader, NewSalesLine.Type::Item, ItemNo, LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(NewSalesHeader, true, true);
    end;

    local procedure CreatePurchaseBillingDocuments(var BillingLine: Record "Billing Line"; var ServiceObject: Record "Service Object"; var VendorContract: Record "Vendor Contract")
    var
        VendorBillingTemplate: Record "Billing Template";
        Vendor: Record Vendor;
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesAndBillingProposal(VendorContract, ServiceObject, Vendor."No.", VendorBillingTemplate);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Vendor, Vendor."No.");
        BillingLine.SetRange("Billing Template Code", VendorBillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Vendor);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    local procedure CreateServiceObjectItemWithDimensions(var ItemDimSetID: Integer; var Item: Record Item)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        ContractTestLibrary.CreateServiceObjectItem(Item, false);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Item, Item."No.");
        DimMgt.AddDimSource(DefaultDimSource, Database::Item, Item."No.");
        ItemDimSetID := DimMgt.GetDefaultDimID(DefaultDimSource, '', Item."Global Dimension 1 Code", Item."Global Dimension 2 Code", 0, Database::Item);
    end;

    local procedure CreateSalesBillingDocuments(var BillingLine: Record "Billing Line"; var ServiceObject: Record "Service Object"; var CustomerContract: Record "Customer Contract")
    var
        CustomerBillingTemplate: Record "Billing Template";
        Customer: Record Customer;
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesAndBillingProposal(CustomerContract, ServiceObject, Customer."No.", CustomerBillingTemplate);
        ContractTestLibrary.CreateDefaultDimensionValueForTable(Database::Customer, Customer."No.");
        BillingLine.SetRange("Billing Template Code", CustomerBillingTemplate.Code);
        BillingLine.SetRange(Partner, BillingLine.Partner::Customer);
        Codeunit.Run(Codeunit::"Create Billing Documents", BillingLine);
    end;

    local procedure CreateServiceCommitmentPackageWithTwoLines(ServiceCommitmentTemplate: Record "Service Commitment Template"; var ServiceCommitmentPackage: Record "Service Commitment Package"; ServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Customer, '');

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(ServiceCommPackageLine, '<12M>', 10, '12M', '<1M>', Enum::"Service Partner"::Vendor, '');
    end;

    local procedure FindServiceCommitment(CustomerNo: Code[20]; var ServiceCommitment: Record "Service Commitment")
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.SetRange("End-User Customer No.", CustomerNo);
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
    end;

    local procedure UpdateSalesLineDimension(var SalesLine: Record "Sales Line"; DimensionCode: Code[20]; NewDimensionValueCode: Code[20])
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, SalesLine."Dimension Set ID");
        TempDimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        TempDimensionSetEntry.FindFirst();
        TempDimensionSetEntry.Validate("Dimension Value Code", NewDimensionValueCode);
        TempDimensionSetEntry.Modify(false);
        SalesLine.Validate("Dimension Set ID", DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
        SalesLine.Modify(true);
    end;

    local procedure VerifyDimensionSetValue(DimensionSetID: Integer; DimensionCode: Code[20]; ExpectedDimensionValueCode: Code[20])
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.Get(DimensionSetID, DimensionCode);
        Assert.AreEqual(
            ExpectedDimensionValueCode, DimensionSetEntry."Dimension Value Code",
            StrSubstNo(DimensionSetEntryValueErr, DimensionCode, ExpectedDimensionValueCode));
    end;

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.FieldServiceAndCalculationStartDate.SetValue(WorkDate());
        AssignServiceCommitments.First();
        AssignServiceCommitments.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
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
