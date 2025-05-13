namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Request;
using Microsoft.Warehouse.Setup;

codeunit 139915 "Sales Service Commitment Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Currency: Record Currency;
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesServiceCommitment: Record "Sales Subscription Line";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryERM: Codeunit "Library - ERM";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryPlanning: Codeunit "Library - Planning";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        SerialNo: array[10] of Code[50];
        NoOfServiceObjects: Integer;
        NotCreatedProperlyErr: Label 'Subscription Lines are not created properly.';
        SalesServiceCommitmentCannotBeDeletedErr: Label 'The Sales Subscription Line cannot be deleted, because it is the last line with Process Contract Renewal. Please delete the Sales line in order to delete the Sales Subscription Line.', Locked = true;

    #region Tests

    [Test]
    procedure CheckCopySalesServiceCommitmentFromSalesDocument()
    var
        SalesHeader2: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        SalesServiceCommitment2: Record "Sales Subscription Line";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        LibrarySales.CreateSalesHeader(SalesHeader2, SalesHeader."Document Type"::Quote, Customer."No.");
        CopyDocMgt.CopySalesDoc(Enum::"Sales Document Type From"::Quote, SalesHeader."No.", SalesHeader2);
        SalesLine2.SetRange("Document Type", SalesHeader2."Document Type");
        SalesLine2.SetRange("Document No.", SalesHeader2."No.");
        SalesLine2.FindSet();
        repeat
            SalesServiceCommitment2.FilterOnSalesLine(SalesLine2);
            SalesServiceCommitment2.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment2, SalesServiceCommitment);
                SalesServiceCommitment.Next();
            until SalesServiceCommitment2.Next() = 0;
        until SalesLine2.Next() = 0;
    end;

    [Test]
    procedure CheckCreateServCommitmentsFromSalesServiceCommitment()
    var
        TempSalesServiceCommitment: Record "Sales Subscription Line" temporary;
        i: Integer;
        MaxAdditionalServiceCommitmentPackageLine: Integer;
        SalesServiceCommCount: Integer;
    begin
        Initialize();
        MaxAdditionalServiceCommitmentPackageLine := Random(10);
        for i := 1 to MaxAdditionalServiceCommitmentPackageLine do
            SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommCount := SalesServiceCommitment.Count();
        SalesServiceCommitment.FindSet();
        repeat
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.RecordCount(ServiceCommitment, SalesServiceCommCount);
        ServiceCommitment.FindSet();
        TempSalesServiceCommitment.FindSet();
        repeat
            TestServiceCommitmentValues(ServiceCommitment, TempSalesServiceCommitment);
            TestServiceCommitmentPriceCalculation(ServiceCommitment);
            VerifyServiceCommitmentUnitCostFromSalesServiceCommitment(ServiceCommitment, TempSalesServiceCommitment);
            TempSalesServiceCommitment.Next();
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure CheckCreateServiceObjectFromSales()
    var
        CustomerPriceGroup: Record "Customer Price Group";
        FetchSalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        InitServiceObjectCount: Integer;
        CustomerReference: Text;
    begin
        // Create Item as Sales with Subscription
        // Ship Item -  Subscription created
        // Invoice Item - nothing happens
        Initialize();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        Customer.Validate("Customer Price Group", CustomerPriceGroup.Code);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesHeader."Your Reference")), 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader."Your Reference" := CopyStr(CustomerReference, 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader.Modify(false);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesLine."Qty. to Invoice" := 0;
        SalesLine."Variant Code" := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesLine."Variant Code")), 1, MaxStrLen(SalesLine."Variant Code"));
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.FilterOnItemNo(Item."No.");
        InitServiceObjectCount := ServiceObject.Count;
        ServiceObject.FindFirst();
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        ServiceObject.TestField("Source No.", Item."No.");
        ServiceObject.TestField(Description, SalesLine.Description);
        ServiceObject.TestField(Quantity, Abs(SalesLine."Qty. to Ship"));
        ServiceObject.TestField("Unit of Measure", SalesLine."Unit of Measure Code");
        ServiceObject.TestField("Provision Start Date", SalesLine."Shipment Date");
        ServiceObject.TestField("End-User Contact No.", SalesHeader."Sell-to Contact No.");
        ServiceObject.TestField("End-User Customer No.", SalesHeader."Sell-to Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        ServiceObject.TestField("Customer Price Group", CustomerPriceGroup.Code);
        ServiceObject.TestField("Customer Reference", CustomerReference);
        ServiceObject.TestField("Variant Code", SalesLine."Variant Code");

        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", WorkDate()); // set shipment date for next delivery
        FetchSalesLine.Validate("Qty. to Invoice", 1);
        FetchSalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        Assert.RecordCount(ServiceObject, InitServiceObjectCount);
    end;

    [Test]
    procedure CheckCreateServiceObjectWithSerialNoOnDropShipment()
    var
        PurchaseHeader: Record "Purchase Header";
        RequisitionLine: Record "Requisition Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        CreateAndReleaseSalesDocumentWithSerialNoForDropShipment();

        LibraryPurchase.CreateVendor(Vendor);
        Item."Vendor No." := Vendor."No.";
        Item.Modify(false);

        RunGetSalesOrders(RequisitionLine, SalesHeader);
        ReqWkshCarryOutActionMessage(RequisitionLine);
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.FindLast();
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        TestServiceObjectWithSerialNoExpectedCount();
        TestServiceObjectWithSerialNoExists();
    end;

    [Test]
    procedure CheckCreateServiceObjectWithSerialNoOnShipSalesOrder()
    begin
        Initialize();
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        TestServiceObjectWithSerialNoExpectedCount();
        TestServiceObjectWithSerialNoExists();
    end;

    [Test]
    procedure CheckDeleteSalesServiceCommitmentWhenTypeOrNoChangedForSalesLine()
    var
        Item2: Record Item;
    begin
        Initialize();
        // Sales Subscription Lines created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        // no Sales Subscription Lines for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item2, Enum::"Item Service Commitment Type"::"Sales without Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        // change Sales Line Type
        SalesLine.Validate(Type, Enum::"Sales Line Type"::" ");
        SalesLine.Modify(false);

        Assert.RecordIsEmpty(SalesServiceCommitment);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        // change Sales Line Item No. to one without Subscription Lines
        SalesLine.Validate("No.", Item2."No.");
        SalesLine.Modify(false);

        Assert.RecordIsEmpty(SalesServiceCommitment);
    end;

    [Test]
    procedure CheckEqualServiceStartDateAndAgreedServCommStartDateAfterInsertServCommFromSalesServComm()
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        Clear(SalesServiceCommitment."Sub. Line Start Formula");
        SalesServiceCommitment.ModifyAll("Agreed Sub. Line Start Date", WorkDate(), false);
        SalesServiceCommitment.FindFirst();
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        Assert.AreEqual(SalesServiceCommitment."Agreed Sub. Line Start Date", ServiceCommitment."Subscription Line Start Date", NotCreatedProperlyErr);
    end;

    [Test]
    procedure CheckEqualServiceStartDateAndSalesLineShipmentDateAfterInsertServCommFromSalesLine()
    begin
        Initialize();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.ModifyAll(SalesServiceCommitment."Agreed Sub. Line Start Date", 0D, false);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Sub. Line Start Formula", '');
        SalesServiceCommitment.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        Assert.AreEqual(SalesLine."Shipment Date", ServiceCommitment."Subscription Line Start Date", NotCreatedProperlyErr);
    end;

    [Test]
    procedure CheckEqualShipmentDateForPartialSalesShipment()
    var
        FetchSalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        OldShipmentDate: Date;
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        OldShipmentDate := SalesLine."Shipment Date";
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(1, FetchSalesLine."Quantity Shipped", NotCreatedProperlyErr);
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", CalcDate('<1D>', OldShipmentDate));
        FetchSalesLine.Validate("Qty. to Ship", 1);
        FetchSalesLine.Modify(false);
        OldShipmentDate := FetchSalesLine."Shipment Date";
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(OldShipmentDate, FetchSalesLine."Shipment Date", NotCreatedProperlyErr); // After posting last line shipment date must be the same
    end;

    [Test]
    procedure CheckExcludeFromDocumentTotals()
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        Initialize();
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, '', 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(false);
        Assert.AreEqual(false, SalesLine."Exclude from Doc. Total", 'Setup-Failure: Exclude from Doc. Total should be false by default');
        Assert.AreNotEqual(0, SalesLine."Line Amount", 'Setup-Failure: Sales Line "Line Amount" should have a value.');

        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        SalesQuote.SalesLines."Total Amount Excl. VAT".AssertEquals(100);
        SalesQuote.Close();

        SalesLine."Exclude from Doc. Total" := true;
        SalesLine.Modify(false);
        SalesQuote.OpenView();
        SalesQuote.GoToRecord(SalesHeader);
        SalesQuote.SalesLines."Total Amount Excl. VAT".AssertEquals(0);
        SalesQuote.Close();
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedOnDifferentPriceGroupOnHeader()
    var
        CustomerPriceGroup1: Record "Customer Price Group";
        CustomerPriceGroup2: Record "Customer Price Group";
        ServiceCommPackageLine2: Record "Subscription Package Line";
        ServiceCommitmentPackage2: Record "Subscription Package";
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine2);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine2);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage2.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup1);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup2);
        ServiceCommitmentPackage2."Price Group" := CustomerPriceGroup1.Code;
        ServiceCommitmentPackage2.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroup2.Code, CustomerPriceGroup1.Code + '|' + '');
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedOnEmptyPriceGroupOnHeader()
    var
        CustomerPriceGroup: Record "Customer Price Group";
        ServiceCommPackageLine2: Record "Subscription Package Line";
        ServiceCommitmentPackage2: Record "Subscription Package";
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine2);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine2);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage2.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        ServiceCommitmentPackage2."Price Group" := CustomerPriceGroup.Code;
        ServiceCommitmentPackage2.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup('', '');
    end;

    [Test]
    procedure CheckInsertSalesServiceCommitmentsBasedSameOnPriceGroupOnHeader()
    var
        CustomerPriceGroup: Record "Customer Price Group";
        ServiceCommPackageLine2: Record "Subscription Package Line";
        ServiceCommitmentPackage2: Record "Subscription Package";
    begin
        Initialize();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine2);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine2);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage2.Code);
        ServiceCommitmentPackage."Price Group" := '';
        ServiceCommitmentPackage.Modify(false);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        ServiceCommitmentPackage2."Price Group" := CustomerPriceGroup.Code;
        ServiceCommitmentPackage2.Modify(false);

        TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroup.Code, CustomerPriceGroup.Code);
    end;

    [Test]
    [HandlerFunctions('SalesOrderConfRequestPageHandler')]
    procedure CheckIsServiceItemExcludedFromTotalsInReports()
    var
        Item2: Record Item;
        Item3: Record Item;
        XmlParameters: Text;
    begin
        Initialize();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SetupSalesLineForTotalAndVatCalculation(Item, true, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(false);
        SetupSalesLineForTotalAndVatCalculation(Item2, false, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(false);
        SetupSalesLineForTotalAndVatCalculation(Item3, false, 19);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Line Discount %", 50);
        SalesLine.Modify(false);
        Commit(); // Commit Data prior to calling the report

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        // Exclude Subscription Item from expected Totals
        SalesLine.SetFilter("No.", '<>%1', Item."No.");
        SalesLine.CalcSums("Line Amount", "Inv. Discount Amount", Amount, "Amount Including VAT");

        // Filter to only print one document
        SalesHeader.SetRange(SystemId, SalesHeader.SystemId);
        // Run the Report
        XmlParameters := Report.RunRequestPage(Report::"Standard Sales - Order Conf."); // SalesOrderConfRequestPageHandler
        LibraryReportDataset.RunReportAndLoad(Report::"Standard Sales - Order Conf.", SalesHeader, XmlParameters);

        // Verifying totals on report
        LibraryReportDataset.AssertElementWithValueExists('TotalNetAmount', SalesLine.Amount); // TotalAmount
        LibraryReportDataset.AssertElementWithValueExists('TotalSubTotal', SalesLine."Line Amount"); // TotalSubTotal
        LibraryReportDataset.AssertElementWithValueExists('TotalInvoiceDiscountAmount', SalesLine."Inv. Discount Amount"); // TotalInvDiscAmount
        LibraryReportDataset.AssertElementWithValueExists('TotalVATAmount', SalesLine."Amount Including VAT" - SalesLine.Amount); // TotalAmountVAT
        LibraryReportDataset.AssertElementWithValueExists('TotalAmountIncludingVAT', SalesLine."Amount Including VAT"); // TotalAmountInclVAT
    end;

    [Test]
    procedure CheckLedgerEntryValues()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
        Item2: Record Item;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedDocumentNo: Code[20];
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocumentNo);
        SalesInvoiceHeader.CalcFields(Amount);
        Assert.AreEqual(SalesLine.Amount, SalesInvoiceHeader.Amount, 'Amounts in Posted Sales Invoice is not correct');
        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.SetRange("Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
        GLEntry.CalcSums(Amount);
        Assert.AreEqual(SalesLine.Amount, -GLEntry.Amount, 'Amount in GL Entry is not correct');
        DetailedCustLedgEntry.SetRange("Document No.", PostedDocumentNo);
        DetailedCustLedgEntry.CalcSums(Amount);
        Assert.AreEqual(SalesLine."Amount Including VAT", DetailedCustLedgEntry.Amount, 'Amount in Customer Ledger Entry is not correct');
    end;

    [Test]
    procedure CheckNoGetSalesShipmentLinesAvailableForInvoiceForServiceCommitmentItem()
    var
        SalesShptLine: Record "Sales Shipment Line";
    begin
        // [WHEN] posting Sales Order with Item which is Subscription Item
        // it should not be possible to Get Shipment Lines in Sales Invoice
        Initialize();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');

        // Post
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Test that no Sales Shipment Line is found
        // filter code taken from codeunit 64 "Sales-Get Shipment"
        SalesShptLine.SetCurrentKey("Bill-to Customer No.");
        SalesShptLine.SetRange("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
        SalesShptLine.SetRange("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesShptLine.SetFilter("Qty. Shipped Not Invoiced", '<>0');
        SalesShptLine.SetRange("Currency Code", SalesHeader."Currency Code");
        SalesShptLine.SetRange("Authorized for Credit Card", false);
        Assert.RecordIsEmpty(SalesShptLine);
    end;

    [Test]
    procedure CheckPartiallyShippedSalesOrder()
    var
        FetchSalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ServiceObjectCount: Integer;
    begin
        // For each shipment of one sales line new Subscription is created
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        // Quantity=2; Qty. to Ship=1; Quantity Shipped=Quantity Invoiced=1
        // Post
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 2);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(1, FetchSalesLine."Quantity Shipped", NotCreatedProperlyErr);
        Assert.AreEqual(1, FetchSalesLine."Quantity Invoiced", NotCreatedProperlyErr);
        // Quantity=2; Qty. to Ship=1; Quantity Shipped=Quantity Invoiced=2
        // Post
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        FetchSalesLine.Validate("Shipment Date", WorkDate()); // set shipment date for next delivery
        FetchSalesLine.Validate("Qty. to Ship", 1);
        FetchSalesLine.Modify(false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FetchSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(2, FetchSalesLine."Quantity Shipped", NotCreatedProperlyErr);
        Assert.AreEqual(2, FetchSalesLine."Quantity Invoiced", NotCreatedProperlyErr);
        // Number of Subscriptions = initial quantity on order
        ServiceObject.FilterOnItemNo(SalesLine."No.");
        ServiceObjectCount := ServiceObject.Count();
        Assert.AreEqual(2, ServiceObjectCount, NotCreatedProperlyErr);

        SalesServiceCommitment.FilterOnSalesLine(FetchSalesLine);
        SalesServiceCommitment.FindFirst();
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField(Amount);
        Assert.AreEqual(ServiceCommitment.Amount, SalesServiceCommitment.Amount * ServiceObject.Quantity / FetchSalesLine.Quantity, NotCreatedProperlyErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure CheckRestoreSalesServiceCommitmentFromArchive()
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);
        FindSalesHeaderArchive(SalesHeaderArchive, SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.DeleteAll(true);

        ArchiveManagement.RestoreSalesDocument(SalesHeaderArchive);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesLineQtyToInvoiceAfterSalesQuoteToOrder()
    var
        SalesOrder: Record "Sales Header";
        SalesQuoteToOrder: Codeunit "Sales-Quote to Order";
    begin
        Initialize();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));

        SalesQuoteToOrder.SetHideValidationDialog(true);
        SalesQuoteToOrder.Run(SalesHeader);
        SalesQuoteToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindFirst();
        repeat
            SalesLine.TestField(SalesLine."Qty. to Invoice", 0);
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesLineQtyToInvoiceOnCreateSalesOrder()
    var
        Item2: Record Item;
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandInt(100));

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange(Type, SalesLine.Type::Item);

        SalesLine.SetRange("No.", Item."No.");
        SalesLine.SetRange("Qty. to Invoice", 0);
        Assert.RecordIsNotEmpty(SalesLine);

        SalesLine.SetRange("No.", Item2."No.");
        SalesLine.SetRange("Qty. to Invoice", SalesLine.Quantity);
        Assert.RecordIsNotEmpty(SalesLine);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentArchive()
    var
        SalesServiceCommArchive: Record "Sales Sub. Line Archive";
        ArchiveManagement: Codeunit ArchiveManagement;
        FirstArchiveLineFound: Boolean;
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();

        ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                if not FirstArchiveLineFound then begin
                    SalesServiceCommArchive.SetRange("Document Type", SalesLine."Document Type");
                    SalesServiceCommArchive.SetRange("Document No.", SalesLine."Document No.");
                    SalesServiceCommArchive.SetRange("Document Line No.", SalesLine."Line No.");
                    SalesServiceCommArchive.SetRange("Doc. No. Occurrence", 1);
                    SalesServiceCommArchive.SetRange("Version No.", 1);
                    SalesServiceCommArchive.FindSet();
                    FirstArchiveLineFound := true;
                end else
                    SalesServiceCommArchive.Next();
                SalesServiceCommArchive.TestField("Item No.", SalesServiceCommitment."Item No.");
                SalesServiceCommArchive.TestField("Package Code", SalesServiceCommitment."Subscription Package Code");
                SalesServiceCommArchive.TestField(Template, SalesServiceCommitment.Template);
                SalesServiceCommArchive.TestField(Description, SalesServiceCommitment.Description);
                SalesServiceCommArchive.TestField("Invoicing via", SalesServiceCommitment."Invoicing via");
                SalesServiceCommArchive.TestField("Extension Term", SalesServiceCommitment."Extension Term");
                SalesServiceCommArchive.TestField("Notice Period", SalesServiceCommitment."Notice Period");
                SalesServiceCommArchive.TestField("Initial Term", SalesServiceCommitment."Initial Term");
                SalesServiceCommArchive.TestField(Partner, SalesServiceCommitment.Partner);
                SalesServiceCommArchive.TestField("Calculation Base Type", SalesServiceCommitment."Calculation Base Type");
                SalesServiceCommArchive.TestField("Billing Base Period", SalesServiceCommitment."Billing Base Period");
                SalesServiceCommArchive.TestField("Calculation Base %", SalesServiceCommitment."Calculation Base %");
                SalesServiceCommArchive.TestField("Sub. Line Start Formula", SalesServiceCommitment."Sub. Line Start Formula");
                SalesServiceCommArchive.TestField("Billing Rhythm", SalesServiceCommitment."Billing Rhythm");
                SalesServiceCommArchive.TestField("Customer Price Group", SalesServiceCommitment."Customer Price Group");
                SalesServiceCommArchive.TestField("Unit Cost", SalesServiceCommitment."Unit Cost");
                SalesServiceCommArchive.TestField("Unit Cost (LCY)", SalesServiceCommitment."Unit Cost (LCY)");
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentAssignmentPerItemServiceCommitmentOption()
    var
        Item2: Record Item;
        Item3: Record Item;
        Item4: Record Item;
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        // no Sales Subscription Lines for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales without Service Commitment", ServiceCommitmentPackage.Code);
        // Sales Subscription Lines created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        // Sales Subscription Lines created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item3, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        // no sales line for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item4, Enum::"Item Service Commitment Type"::"Invoicing Item", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandDec(100, 2));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);

        Assert.RecordIsEmpty(SalesServiceCommitment);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        CheckAssignedSalesServiceCommitmentValues(SalesServiceCommitment, SalesLine);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item3."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        CheckAssignedSalesServiceCommitmentValues(SalesServiceCommitment, SalesLine);

        Commit(); // retain data after asserterror
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item4."No.", LibraryRandom.RandIntInRange(1, 100));

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item4."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure CheckSalesServiceCommitmentAssignmentPerSalesDocumentType()
    var
        i: Integer;
    begin
        Initialize();

        for i := 0 to 5 do begin
            ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
            LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type".FromInteger(i), '');
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            case SalesHeader."Document Type" of
                Enum::"Sales Document Type"::Quote,
                Enum::"Sales Document Type"::Order,
                Enum::"Sales Document Type"::"Blanket Order":
                    Assert.RecordIsNotEmpty(SalesServiceCommitment);
                Enum::"Sales Document Type"::Invoice, Enum::"Sales Document Type"::"Credit Memo":
                    Assert.RecordIsEmpty(SalesServiceCommitment);
            end;
        end;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentBaseAmountCalculation()
    var
        ExpectedCalculationBaseAmount: Decimal;
        UnexpectedValueTok: Label 'Unexpected value of %1 for %2. Partner: %3, Calculation Base Type: %4', Locked = true;
    begin
        // Creates Subscription Packages with Subscription Package Lines with combinations of Customer/Vendor and Calculation Base Type
        // Customer - Item Price
        // Customer - Document Price
        // Customer - Document Price and Discount
        // Vendor - Item Price
        // Vendor - Document Price

        Initialize(); // Customer - Item Price
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Customer, Enum::"Calculation Base Type"::"Document Price");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Customer, Enum::"Calculation Base Type"::"Document Price And Discount");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor, Enum::"Calculation Base Type"::"Item Price");
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor, Enum::"Calculation Base Type"::"Document Price");
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);

        // Customer
        ExpectedCalculationBaseAmount := Item."Unit Price";
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Customer);
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Item Price");
        SalesServiceCommitment.FindFirst();
        Assert.AreEqual(ExpectedCalculationBaseAmount, SalesServiceCommitment."Calculation Base Amount", StrSubstNo(UnexpectedValueTok, SalesServiceCommitment.FieldCaption("Calculation Base Amount"), SalesServiceCommitment.TableCaption(), SalesServiceCommitment.Partner, SalesServiceCommitment."Calculation Base Type"));

        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Price";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");
        SalesServiceCommitment.FindFirst();
        Assert.AreEqual(ExpectedCalculationBaseAmount, SalesServiceCommitment."Calculation Base Amount", StrSubstNo(UnexpectedValueTok, SalesServiceCommitment.FieldCaption("Calculation Base Amount"), SalesServiceCommitment.TableCaption(), SalesServiceCommitment.Partner, SalesServiceCommitment."Calculation Base Type"));

        SalesLine.Validate("Line Discount %", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Price";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price And Discount");
        SalesServiceCommitment.FindFirst();
        Assert.AreEqual(ExpectedCalculationBaseAmount, SalesServiceCommitment."Calculation Base Amount", StrSubstNo(UnexpectedValueTok, SalesServiceCommitment.FieldCaption("Calculation Base Amount"), SalesServiceCommitment.TableCaption(), SalesServiceCommitment.Partner, SalesServiceCommitment."Calculation Base Type"));
        SalesServiceCommitment.TestField("Discount %", SalesLine."Line Discount %");

        // Vendor
        ExpectedCalculationBaseAmount := Item."Unit Cost";
        SalesServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Item Price");
        SalesServiceCommitment.FindFirst();
        Assert.AreEqual(ExpectedCalculationBaseAmount, SalesServiceCommitment."Calculation Base Amount", StrSubstNo(UnexpectedValueTok, SalesServiceCommitment.FieldCaption("Calculation Base Amount"), SalesServiceCommitment.TableCaption(), SalesServiceCommitment.Partner, SalesServiceCommitment."Calculation Base Type"));

        SalesLine.Validate("Unit Cost (LCY)", LibraryRandom.RandDec(10000, 2));
        SalesLine.Modify(false);
        ExpectedCalculationBaseAmount := SalesLine."Unit Cost";
        SalesServiceCommitment.SetRange("Calculation Base Type", Enum::"Calculation Base Type"::"Document Price");
        SalesServiceCommitment.FindFirst();
        Assert.AreEqual(ExpectedCalculationBaseAmount, SalesServiceCommitment."Calculation Base Amount", StrSubstNo(UnexpectedValueTok, SalesServiceCommitment.FieldCaption("Calculation Base Amount"), SalesServiceCommitment.TableCaption(), SalesServiceCommitment.Partner, SalesServiceCommitment."Calculation Base Type"));
    end;

    [Test]
    procedure CheckSalesServiceCommitmentDiscountCalculation()
    var
        DiscountAmount: Decimal;
        DiscountPercent: Decimal;
        ExpectedDiscountAmount: Decimal;
        ExpectedDiscountPercent: Decimal;
        ServiceAmountInt: Integer;
    begin
        Initialize();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        SalesServiceCommitment.TestField("Discount %", 0);
        SalesServiceCommitment.TestField("Discount Amount", 0);
        Currency.InitRoundingPrecision();

        DiscountPercent := LibraryRandom.RandDec(50, 2);
        ExpectedDiscountAmount := Round(SalesServiceCommitment.Amount * DiscountPercent / 100, Currency."Amount Rounding Precision");
        SalesServiceCommitment.Validate("Discount %", DiscountPercent);
        SalesServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);

        Evaluate(ServiceAmountInt, Format(SalesServiceCommitment.Amount, 0, '<Integer>'));
        DiscountAmount := LibraryRandom.RandDec(ServiceAmountInt, 2);
        ExpectedDiscountPercent := Round(DiscountAmount / Round((SalesServiceCommitment.Price * SalesLine.Quantity), Currency."Amount Rounding Precision") * 100, 0.00001);
        SalesServiceCommitment.Validate("Discount Amount", DiscountAmount);
        SalesServiceCommitment.TestField("Discount %", ExpectedDiscountPercent);
    end;

    [Test]
    procedure NegativeValuesAreExpectedWhenSalesServiceCommitmentWithDiscountIsChanged()
    begin
        // [SCENARIO] When Calculation Base % on Sales Service Commitment with Discount is changed, negative values in Calculation Base amount, Price and Service Amount are expected

        // [GIVEN] Create Sales Service Commitment for Service Commitment Item with Discount
        ClearAll();
        ContractTestLibrary.CreateServiceCommitmentTemplateWithDiscount(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        SetupSalesLineWithSalesServiceCommitments(LibraryRandom.RandDec(10, 0));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        // [WHEN] Change Calculation Base % on Sales Service Commitment
        SalesServiceCommitment.Validate("Calculation Base %", LibraryRandom.RandDec(100, 0));

        // [THEN] Calculation Base Amount, Price and Service Amount are recalculated and have negative values
        Assert.IsTrue(SalesServiceCommitment."Calculation Base Amount" < 0, 'Calculation Base Amount in Sales Service Commitment should be negative');
        Assert.IsTrue(SalesServiceCommitment.Price < 0, 'Price in Sales Service Commitment should be negative');
        Assert.IsTrue(SalesServiceCommitment.Amount < 0, 'Service Amount in Sales Service Commitment should be negative');
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure CheckSalesServiceCommitmentPackageFilterForSalesLine()
    begin
        // Create three Subscription Packages and assign them to one Item. First Serv. Comm. Package is set as Standard
        Initialize();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        SetupAdditionalServiceCommPackageAndAssignToItem();
        SetupAdditionalServiceCommPackageAndAssignToItem();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        TestSalesServiceCommitmentPackageFilterForSalesLine(SalesLine, true);
        TestSalesServiceCommitmentPackageFilterForSalesLine(SalesLine, false);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentPartialMakeOrderFromBlanketOrder()
    var
        SalesOrder: Record "Sales Header";
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(2, 100));
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                SalesServiceCommitment.TestField(Amount, Round(SalesServiceCommitment.Price, 0.01));
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckSalesServiceCommitmentPriceCalculation()
    var
        ExpectedPrice: Decimal;
    begin
        Initialize();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Currency.InitRoundingPrecision();
        ExpectedPrice := Round(SalesServiceCommitment."Calculation Base Amount" * SalesServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        SalesServiceCommitment.TestField(Price, ExpectedPrice);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentServiceAmountCalculation()
    var
        ChangedCalculationBaseAmount: Decimal;
        DiscountPercent: Decimal;
        ExpectedServiceAmount: Decimal;
        Price: Decimal;
        ServiceAmountBiggerThanPrice: Decimal;
    begin
        Initialize();
        SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(Item);

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        Currency.InitRoundingPrecision();
        Price := Round(SalesServiceCommitment."Calculation Base Amount" * SalesServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(SalesLine.Quantity * Price, Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        ChangedCalculationBaseAmount := LibraryRandom.RandDec(1000, 2);
        SalesServiceCommitment.Validate("Calculation Base Amount", ChangedCalculationBaseAmount);

        ExpectedServiceAmount := Round((SalesServiceCommitment.Price * SalesLine.Quantity), Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        DiscountPercent := LibraryRandom.RandDec(100, 2);
        SalesServiceCommitment.Validate("Discount %", DiscountPercent);

        ExpectedServiceAmount := ExpectedServiceAmount - Round(ExpectedServiceAmount * DiscountPercent / 100, Currency."Amount Rounding Precision");
        SalesServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        ServiceAmountBiggerThanPrice := SalesServiceCommitment.Price * (SalesLine.Quantity + 1);
        asserterror SalesServiceCommitment.Validate(Amount, ServiceAmountBiggerThanPrice);
    end;

    [Test]
    procedure CheckSalesServiceCommitmentsInBlanketOrderOnAfterMakeOrder()
    var
        SalesOrder: Record "Sales Header";
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(2, 100));
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure CheckServiceStartDateCalculationFromDateFormulaAfterInsertServCommFromSalesLine()
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        Evaluate(SalesServiceCommitment."Sub. Line Start Formula", '<1M>');
        SalesServiceCommitment.ModifyAll(SalesServiceCommitment."Agreed Sub. Line Start Date", 0D, false);
        SalesServiceCommitment.FindFirst();
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.FindFirst();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        Assert.AreEqual(ServiceCommitment."Subscription Line Start Date", CalcDate(SalesServiceCommitment."Sub. Line Start Formula", SalesLine."Shipment Date"), NotCreatedProperlyErr);
    end;

    [Test]
    procedure CheckShippedNotInvoicedIsZeroForServiceCommitmentItemAfterPostingSalesOrder()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(10));
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
        SalesHeader.Get(Enum::"Sales Document Type"::Order, SalesHeader."No.");
        SalesHeader.TestField("Shipped Not Invoiced", false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.TestField("Qty. Shipped Not Invoiced", 0);
        SalesLine.TestField("Qty. Shipped Not Invd. (Base)", 0);
        SalesLine.TestField("Shipped Not Invoiced", 0);
        SalesLine.TestField("Shipped Not Invoiced (LCY)", 0);
        SalesLine.TestField("Shipped Not Inv. (LCY) No VAT", 0);
    end;

    [Test]
    procedure CheckVatCalculationForServiceCommitmentRhythmInReports()
    var
        Item2: Record Item;
        Item3: Record Item;
        Item4: Record Item;
        TempSalesServiceCommitmentBuff: Record "Sales Service Commitment Buff." temporary;
        ExpectedVATAmount: Decimal;
        UniqueRhythmDictionary: Dictionary of [Code[20], Text];
    begin
        Initialize();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(SalesHeader."Currency Code");
        ExpectedVATAmount := 0;

        // "Billing Rhythm" = '<1M>', "Billing Base Period" = '<12M>'
        SetupSalesLineForTotalAndVatCalculation(Item, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        ExpectedVATAmount += Round((SalesServiceCommitment.Amount / 12 * 1) * SalesLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        // Item with different VAT for same Billing Rhythm
        SetupSalesLineForTotalAndVatCalculation(Item4, true, SalesLine."VAT %");
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        ExpectedVATAmount += Round((SalesServiceCommitment.Amount / 12 * 1) * SalesLine."VAT %" / 100, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        // "Billing Rhythm" = '<3M>', "Billing Base Period" = '<12M>'
        SetupSalesLineForTotalAndVatCalculation(Item2, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Billing Rhythm", '3M');
        SalesServiceCommitment.Modify(false);
        ExpectedVATAmount += (SalesServiceCommitment.Amount / 12 * 3) * SalesLine."VAT %" / 100;

        // "Billing Rhythm" = '<3M>', "Billing Base Period" = '<2Y>'
        SetupSalesLineForTotalAndVatCalculation(Item3, true, 0);
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        Evaluate(SalesServiceCommitment."Billing Base Period", '<2Y>');
        Evaluate(SalesServiceCommitment."Billing Rhythm", '<3M>');
        SalesServiceCommitment.Modify(false);
        ExpectedVATAmount += (SalesServiceCommitment.Amount / 24 * 3) * SalesLine."VAT %" / 100;
        ExpectedVATAmount := Round(ExpectedVATAmount, Currency."Amount Rounding Precision", Currency.VATRoundingDirection());

        SalesServiceCommitment.CalcVATAmountLines(SalesHeader, TempSalesServiceCommitmentBuff, UniqueRhythmDictionary);

        Assert.RecordCount(TempSalesServiceCommitmentBuff, UniqueRhythmDictionary.Count + 1);
        TempSalesServiceCommitmentBuff.CalcSums("VAT Amount");
        Assert.AreEqual(ExpectedVATAmount, TempSalesServiceCommitmentBuff."VAT Amount", 'Service Items VAT Amount not calculated properly.');
    end;

    [Test]
    procedure CreateServiceObjectWithItemTrackingCodeWithoutSNSpecificFlag()
    begin
        // Check that Subscription is created with Item with Item Tracking Code without SNSpecific flag
        Initialize();
        CreateSalesServiceCommitmentItemWithSNSpecificTracking(false, false);
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ServiceObject.FilterOnItemNo(Item."No.");

        Assert.RecordCount(ServiceObject, 1);
        ServiceObject.FindFirst();
        ServiceObject.TestField("Serial No.", '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DoNotCreateServiceObjectFromSalesWhenShippingWithNegativeQuantity()
    var
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerReference: Text;
    begin
        // Create Item as Sales with Subscription
        // Assign negative value to Quantity
        // Ship Item -  Subscription should not be created
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        Customer.Validate("Customer Price Group", CustomerPriceGroup.Code);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        CustomerReference := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesHeader."Your Reference")), 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader."Your Reference" := CopyStr(CustomerReference, 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader.Modify(false);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", -LibraryRandom.RandInt(100));
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.SetRange("Customer Reference", CustomerReference);
        Assert.RecordIsEmpty(ServiceObject);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DoNotCreateServiceObjectWithSerialNoOnShipSalesOrderWithNegativeQuantity()
    begin
        Initialize();
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        CheckThatOnlyOneServiceObjectWithSerialNoExists();

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", -NoOfServiceObjects);
        CreateSalesLineItemTrackingAndPostSalesDocument(-1, true, false);

        CheckThatOnlyOneServiceObjectWithSerialNoExists();
    end;

    [Test]
    procedure ExpectErrorOnAssignServiceCommitmentWithInvoicingViaContract()
    begin
        // Expect error if Invoicing Via No. is empty
        Initialize();
        ServiceCommPackageLine."Invoicing Item No." := '';
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');

        asserterror LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
    end;

    [Test]
    procedure ExpectErrorOnInsertSalesServiceCommitmentWithoutBillingRhythm()
    begin
        Initialize();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);        // Sales Subscription Lines created for this item
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure ExpectErrorOnInsertSalesServiceCommitmentWithoutInvoicingItemNo()
    begin
        Initialize();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);        // Sales Subscription Lines created for this item
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        asserterror LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure ExpectErrorOnMergeContractLinesWithDifferentSerialNo()
    var
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        Initialize();
        CreateAndPostSalesDocumentWithSerialNo(true, true);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        ServiceObject.Reset();
        ServiceObject.SetFilter("Serial No.", '<>%1', '');
        ServiceObject.FindFirst();
        repeat
            ContractTestLibrary.AssignServiceObjectForItemToCustomerContract(CustomerContract, ServiceObject, false);
        until ServiceObject.Next() = 0;

        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        asserterror CustomerContractLine.MergeContractLines(CustomerContractLine);
    end;

    [Test]
    procedure ExpectErrorOnModifySalesServiceCommitmentIfSalesOrderIsReleased()
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), LibraryRandom.RandInt(100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();

        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesServiceCommitment.Price := LibraryRandom.RandDec(1000, 2);
        asserterror SalesServiceCommitment.Modify(true);
    end;

    [Test]
    procedure InsertSalesServiceCommitmentWithInvoiceViaSalesWithoutInvoicingItemNo()
    begin
        Initialize();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := ServiceCommitmentTemplate."Invoicing via"::Sales;
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
    end;

    [Test]
    procedure RunNormalSalesServiceCommitmentDeletion()
    begin
        // [SCENARIO] Manual deletion of simple Sales Subscription Line Line should run with no error.

        // [GIVEN] Setup a new Subscription Item
        Initialize();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        // [WHEN] A sales line has been created for a Subscription Item
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));

        // [THEN] Make sure that Sales Subscription Line Line has been created and can be deleted with no errors
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.Delete(true);
    end;

    [Test]
    procedure RunSalesServiceCommitmentDeletionForContractRenewal()
    var
        SalesLine2: Record "Sales Line";
        SalesServiceCommitment2: Record "Sales Subscription Line";
    begin
        // [SCENARIO] Manual deletion of Sales Subscription Line Line with Contract Renewal should hit an error when the only remaining Line For Contract Renewal is left in the document

        // [GIVEN] Setup a new Subscription Item
        Initialize();
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);

        // [WHEN] Two sales lines has been created for a Subscription Item, both of them for Contract Renewal
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindFirst();
        SalesServiceCommitment.Process := SalesServiceCommitment.Process::"Contract Renewal";
        SalesServiceCommitment.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment2.FilterOnSalesLine(SalesLine2);
        SalesServiceCommitment2.FindFirst();
        SalesServiceCommitment2.Process := SalesServiceCommitment.Process::"Contract Renewal";
        SalesServiceCommitment2.Modify(false);

        // [THEN] Make sure that first Sales Subscription Line Line can be deleted with no errors
        SalesServiceCommitment.Delete(true);

        // [THEN] Make sure that second Sales Subscription Line Line can not be deleted
        asserterror SalesServiceCommitment2.Delete(true);
        Assert.ExpectedError(SalesServiceCommitmentCannotBeDeletedErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SalesLineWithServiceCommitmentItemRevertedOnUndoPostedSalesShipmentLine()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        // [SCENARIO] Post Sales order with Subscription Item. Only Posted sales shipment will be created and Quantity Invoiced will be automatically set to shipped quantity
        // [SCENARIO] Test if Invoiced quantity will be reverted automatically when shipment is canceled

        // [GIVEN] Create Subscription Item, Create Sales Order and post it
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandDecInRange(1, 8, 0));
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [WHEN] Run Undo Shipment action
        SalesShipmentLine.SetRange("Order No.", SalesHeader."No.");
        SalesShipmentLine.FindFirst();
        Codeunit.Run(Codeunit::"Undo Sales Shipment Line", SalesShipmentLine); // ConfirmHandlerYes

        // [THEN] Correction line is added in the sales shipment
        SalesShipmentLine.SetRange("Order No.");
        SalesShipmentLine.SetRange("Document No.", SalesShipmentLine."Document No.");
        SalesShipmentLine.SetRange(Correction, true);
        Assert.RecordIsNotEmpty(SalesShipmentLine);

        // [THEN] In Sales Order Invoiced Quantity is reverted automatically
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(SalesLine."Quantity Shipped", SalesLine."Quantity Invoiced", 'Quantity Invoiced was not reverted correctly');
        Assert.AreEqual(SalesLine."Qty. Shipped (Base)", SalesLine."Qty. Invoiced (Base)", 'Qty. Invoiced (Base) was not reverted correctly');

        Assert.AreEqual(0, SalesLine."Quantity Invoiced", 'Quantity Invoiced was not reverted correctly');
        Assert.AreEqual(0, SalesLine."Qty. Invoiced (Base)", 'Qty. Invoiced (Base) was not reverted correctly');

        // Additionally check if sales order can be posted again, to make sure everything is reverted properly
        LibrarySales.PostSalesDocument(SalesHeader, true, true); // Expect no errors
    end;

    [Test]
    procedure SalesServiceCommitmentMakeOrderFromBlanketOrder()
    var
        SalesOrder: Record "Sales Header";
        TempSalesServiceCommitment: Record "Sales Subscription Line" temporary;
        BlanketSalesOrderToOrder: Codeunit "Blanket Sales Order to Order";
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Blanket Order", '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        repeat
            ModifyServiceCommitmentCalculationBaseAmountAndDiscountPercent();
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;

        Clear(BlanketSalesOrderToOrder);
        BlanketSalesOrderToOrder.SetHideValidationDialog(true);
        BlanketSalesOrderToOrder.Run(SalesHeader);
        BlanketSalesOrderToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            TempSalesServiceCommitment.FindSet();
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment, TempSalesServiceCommitment);
                TempSalesServiceCommitment.Next();
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure SalesServiceCommitmentMakeOrderFromQuote()
    var
        SalesOrder: Record "Sales Header";
        TempSalesServiceCommitment: Record "Sales Subscription Line" temporary;
        SalesQuoteToOrder: Codeunit "Sales-Quote to Order";
    begin
        Initialize();
        SetupAdditionalServiceCommPackageLine(Enum::"Service Partner"::Vendor);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.FindSet();
        repeat
            ModifyServiceCommitmentCalculationBaseAmountAndDiscountPercent();
            TempSalesServiceCommitment := SalesServiceCommitment;
            TempSalesServiceCommitment.Insert(false);
        until SalesServiceCommitment.Next() = 0;

        SalesQuoteToOrder.SetHideValidationDialog(true);
        SalesQuoteToOrder.Run(SalesHeader);
        SalesQuoteToOrder.GetSalesOrderHeader(SalesOrder);

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesOrder."Document Type");
        SalesLine.SetRange("Document No.", SalesOrder."No.");
        SalesLine.FindSet();
        repeat
            TempSalesServiceCommitment.FindSet();
            SalesServiceCommitment.FilterOnSalesLine(SalesLine);
            SalesServiceCommitment.FindSet();
            repeat
                TestSalesServiceCommitmentValues(SalesServiceCommitment, TempSalesServiceCommitment);
                TempSalesServiceCommitment.Next();
            until SalesServiceCommitment.Next() = 0;
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure TestSalesInvoiceLineOnPostSalesOrder()
    var
        Item2: Record Item;
        SalesInvoiceLine: Record "Sales Invoice Line";
        PostedDocumentNo: Code[20];
        MainSalesLineLineNo: Integer;
    begin
        Initialize();
        // Setup a Subscription Item with attributed extended text & a "normal" sales item with Subscription Line
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item2, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandInt(100));
        MainSalesLineLineNo := SalesLine."Line No.";
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        SalesLine.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(SalesLine.Description)), 1, MaxStrLen(SalesLine.Description));
        SalesLine."Attached to Line No." := MainSalesLineLineNo;
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", LibraryRandom.RandInt(100));

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        Assert.RecordCount(SalesLine, 3);

        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceLine.SetRange("Document No.", PostedDocumentNo);
        Assert.RecordCount(SalesInvoiceLine, 1);
    end;

    [Test]
    [HandlerFunctions('StrMenuHandler')]
    procedure TestTransferSalesServiceCommitmentsOnExplodeBOM()
    var
        Item2: Record Item;
    begin
        Initialize();
        LibraryAssembly.CreateItem(Item2, Item."Costing Method"::Standard, Item."Replenishment System"::Assembly, '', '');
        CreateComponentItemWithSalesServiceCommitments(Item2."No.");

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item2."No.", WorkDate(), LibraryRandom.RandInt(100));
        Codeunit.Run(Codeunit::"Sales-Explode BOM", SalesLine);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, Enum::"Sales Line Type"::Item);
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindLast();
        SalesLine.CalcFields("Subscription Lines");
        SalesLine.TestField("Subscription Lines");
    end;

    [Test]
    procedure UnitPriceOnSalesLineForServiceCommitmentItemShouldRemainAfterPosting()
    var
        SalesWithSubscription: Record Item;
        SubscriptionItem: Record Item;
    begin
        // [SCENARIO] Create Sales Order with two Sales Lines, one with Sales with Service Commitment Item and one Service Commitment Item.
        // [SCENARIO] Sales line with Sales with Service Commitment Item should be set for Qty. to Ship = 1 and Sales line with Service Commitment Item should be set for Qty. to Ship = 0.
        // [SCENARIO] Post (ship) the Sales Order and check that the Unit Price on the Service Commitment Item is not changed.

        // [GIVEN] Create Service Commitment Item and assign to Service Commitment Package
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(SubscriptionItem, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Validate("Invoicing via", Enum::"Invoicing Via"::Sales);
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(SubscriptionItem, ServiceCommitmentPackage.Code, true);

        // [GIVEN] Create Sales with Service Commitment Item and assign to Service Commitment Package
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(SalesWithSubscription, Enum::"Item Service Commitment Type"::"Sales with Service Commitment");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine('', ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLineWithInvoicingItem(ServiceCommPackageLine, '');
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(SalesWithSubscription, ServiceCommitmentPackage.Code, true);

        // [GIVEN] Create Sales Order and add two Sales Lines with created items and check unit prices
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, SalesWithSubscription."No.", LibraryRandom.RandDecInRange(1, 8, 0));
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, SubscriptionItem."No.", LibraryRandom.RandDecInRange(1, 8, 0));
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Validate("Qty. to Ship", 0);
        SalesLine.Modify(false);

        // [WHEN] Post Sales Order
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [THEN] Sales Line with Service Commitment Item should have the same Unit Price as before posting
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(100, SalesLine."Unit Price", 'Unit Price on Service Commitment Item was changed after posting');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure UsePostingDateFromInventoryPickWhenPostingSalesOrder()
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        CreateInvtPutAwayPickMvmt: Report "Create Invt Put-away/Pick/Mvmt";
        InventoryPickPostingDate: Date;
    begin
        Initialize();
        // [WHEN] using Inventory Pick to post Sales Order if "Posting Date" option has been used in Subscription Contract Setup (Subscription Line Start Date for Inventory Pick)
        // [THEN] Posting Date is set as Subscription Line Start Date in Subscription Lines and Provision Start Date in Subscription
        LibrarySetupStorage.Save(Database::"Subscription Contract Setup");
        LibrarySetupStorage.Save(Database::"Inventory Setup");
        SetupForInventoryPick();
        PurchaseHardwareItemForLocation();
        CreateAndReleaseSalesOrder();
        CreateInvtPutAwayPickMvmt.InitializeRequest(false, true, false, false, false);
        CreateInvtPutAwayPickMvmt.UseRequestPage(false);
        CreateInvtPutAwayPickMvmt.Run();

        InventoryPickPostingDate := SalesLine."Shipment Date" + 10;
        FindAndUpdateWhseActivityPostingDate(
          WarehouseActivityHeader, WarehouseActivityLine,
          Database::"Sales Line", SalesHeader."No.",
          WarehouseActivityHeader.Type::"Invt. Pick", InventoryPickPostingDate);

        LibraryWarehouse.SetQtyToHandleWhseActivity(WarehouseActivityHeader, WarehouseActivityLine.Quantity);
        LibraryWarehouse.PostInventoryActivity(WarehouseActivityHeader, false);

        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.SetRange("Provision Start Date", InventoryPickPostingDate);
        ServiceObject.FindFirst();

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Subscription Line Start Date", InventoryPickPostingDate);
        until ServiceCommitment.Next() = 0;

        LibrarySetupStorage.Restore();
        Clear(LibrarySetupStorage);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SalesLineWithServiceCommitmentItemCanBeDeletedAfterUndoPostedSalesShipmentLine()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        // [SCENARIO] After Undo Sales Shipment Line, "Qty. Shipped Not Invoiced" on Sales Line will be reverted automatically and Sales Line will be deletable

        // [GIVEN] Create Service Commitment Item, Create Sales Order and post (ship)
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandDecInRange(1, 8, 0));
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] Run Undo Shipment action
        SalesShipmentLine.SetRange("Order No.", SalesHeader."No.");
        SalesShipmentLine.FindFirst();
        Codeunit.Run(Codeunit::"Undo Sales Shipment Line", SalesShipmentLine); // ConfirmHandlerYes

        // [THEN] In Sales Order "Qty. Shipped Not Invoiced" is reverted and Sales Line is deletable
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(0, SalesLine."Qty. Shipped Not Invoiced", 'Qty. Shipped Not Invoiced was not reverted correctly');
        Assert.AreEqual(0, SalesLine."Qty. Shipped Not Invd. (Base)", 'Qty. Shipped Not Invd. (Base) was not reverted correctly');
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        SalesLine.Delete(true);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Invoicing Item");
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
    end;

    local procedure CheckAssignedSalesServiceCommitmentValues(var SalesServiceCommitmentToTest: Record "Sales Subscription Line"; SourceSalesLine: Record "Sales Line")
    var
        SalesServiceCommMgmt: Codeunit "Sales Subscription Line Mgmt.";
    begin
        ServiceCommPackageLine.SetRange("Subscription Package Code", ServiceCommitmentPackage.Code);
        ServiceCommPackageLine.FindSet();
        repeat
            SalesServiceCommitmentToTest.SetRange("Subscription Package Code", ServiceCommPackageLine."Subscription Package Code");
            SalesServiceCommitmentToTest.SetRange(Partner, ServiceCommPackageLine.Partner);
            SalesServiceCommitmentToTest.FindFirst();
            SalesServiceCommitmentToTest.TestField("Item No.", SalesServiceCommMgmt.GetItemNoForSalesServiceCommitment(SourceSalesLine, ServiceCommPackageLine));
            SalesServiceCommitmentToTest.TestField("Subscription Package Code", ServiceCommPackageLine."Subscription Package Code");
            SalesServiceCommitmentToTest.TestField(Template, ServiceCommPackageLine.Template);
            SalesServiceCommitmentToTest.TestField(Description, ServiceCommPackageLine.Description);
            SalesServiceCommitmentToTest.TestField("Invoicing via", ServiceCommPackageLine."Invoicing via");
            SalesServiceCommitmentToTest.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
            SalesServiceCommitmentToTest.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
            SalesServiceCommitmentToTest.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
            SalesServiceCommitmentToTest.TestField(Partner, ServiceCommPackageLine.Partner);
            SalesServiceCommitmentToTest.TestField("Calculation Base Type", ServiceCommPackageLine."Calculation Base Type");
            SalesServiceCommitmentToTest.TestField("Billing Base Period", ServiceCommPackageLine."Billing Base Period");
            SalesServiceCommitmentToTest.TestField("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
            SalesServiceCommitmentToTest.TestField("Sub. Line Start Formula", ServiceCommPackageLine."Sub. Line Start Formula");
            SalesServiceCommitmentToTest.TestField("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
            SalesServiceCommitmentToTest.TestField("Customer Price Group", SourceSalesLine."Customer Price Group");
            SalesServiceCommitmentToTest.TestField("Create Contract Deferrals", ServiceCommPackageLine."Create Contract Deferrals");
        until ServiceCommPackageLine.Next() = 0;
    end;

    local procedure CheckThatOnlyOneServiceObjectWithSerialNoExists()
    var
        i: Integer;
    begin
        for i := 1 to NoOfServiceObjects do begin
            ServiceObject.Reset();
            ServiceObject.FilterOnItemNo(Item."No.");
            ServiceObject.SetRange("Serial No.", SerialNo[i]);
            Assert.RecordCount(ServiceObject, 1);
        end;
    end;

    local procedure CreateAndPostSalesDocumentWithSerialNo(Ship: Boolean; Invoice: Boolean)
    begin
        CreateSalesServiceCommitmentItemWithSNSpecificTracking();
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);

        PopulateSerialNo();
        CreateAndReceivePurchaseOrderWithItemWithSerialNo();
        CreateSalesLineItemTrackingAndPostSalesDocument(1, Ship, Invoice);
    end;

    local procedure CreateAndReceivePurchaseOrderWithItemWithSerialNo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        i: Integer;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, '');
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", NoOfServiceObjects);
        for i := 1 to NoOfServiceObjects do
            LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, SerialNo[i], '', 1);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    local procedure CreateAndReleaseSalesDocumentWithSerialNoForDropShipment()
    var
        Purchasing: Record Purchasing;
    begin
        LibraryPurchase.CreateDropShipmentPurchasingCode(Purchasing);
        CreateSalesServiceCommitmentItemWithSNSpecificTracking();
        CreateSalesDocumentAndLineWithRandomQuantity("Sales Document Type"::Order);
        SalesLine.Validate("Purchasing Code", Purchasing.Code);
        SalesLine.Modify(true);

        PopulateSerialNo();
        CreateSalesLineItemTracking(1);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
    end;

    local procedure CreateAndReleaseSalesOrder()
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SalesHeader.Validate("Location Code", Location.Code);
        SalesHeader.Modify(false);
        LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", WorkDate(), 1);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
    end;

    local procedure CreateComponentItemWithSalesServiceCommitments(Item2No: Code[20])
    begin
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateBOMComponentForItem(Item2No, Item."No.", 0, '');
    end;

    local procedure CreateNoSeriesWithLine(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(
            NoSeriesLine,
            NoSeries.Code,
            CopyStr(NoSeries.Code + '000', 1, MaxStrLen(NoSeries.Code)),
            CopyStr(NoSeries.Code + '999', 1, MaxStrLen(NoSeries.Code)));
        exit(NoSeries.Code);
    end;

    local procedure CreateSalesDocumentAndLineWithRandomQuantity(SalesDocumentType: Enum "Sales Document Type")
    var
        Quantity: Decimal;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesDocumentType, Customer."No.");
        Quantity := LibraryRandom.RandInt(10);
        NoOfServiceObjects := Quantity;
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Quantity);
    end;

    local procedure CreateSalesLineItemTracking(Sign: Integer)
    var
        ReservationEntry: Record "Reservation Entry";
        i: Integer;
    begin
        for i := 1 to NoOfServiceObjects do
            LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, SerialNo[i], '', 1 * Sign);
    end;

    local procedure CreateSalesLineItemTrackingAndPostSalesDocument(Sign: Integer; Ship: Boolean; Invoice: Boolean)
    begin
        CreateSalesLineItemTracking(Sign);
        LibrarySales.PostSalesDocument(SalesHeader, Ship, Invoice);
    end;

    local procedure CreateSalesServiceCommitmentItemWithSNSpecificTracking()
    begin
        CreateSalesServiceCommitmentItemWithSNSpecificTracking(true, false);
    end;

    local procedure CreateSalesServiceCommitmentItemWithSNSpecificTracking(SNSpecific: Boolean; LNSpecific: Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, SNSpecific, LNSpecific);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);
        Item."Subscription Option" := Enum::"Item Service Commitment Type"::"Sales with Service Commitment";
        Item.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    local procedure FindAndUpdateWhseActivityPostingDate(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceType: Integer; SourceNo: Code[20]; ActivityType: Enum "Warehouse Activity Type"; PostingDate: Date)
    begin
        FindWarehouseActivityLine(WarehouseActivityLine, SourceType, SourceNo, ActivityType);
        WarehouseActivityHeader.Get(ActivityType, WarehouseActivityLine."No.");
        WarehouseActivityHeader.Validate("Posting Date", PostingDate);
        WarehouseActivityHeader.Modify(true);
    end;

    local procedure FindSalesHeaderArchive(var SalesHeaderArchive: Record "Sales Header Archive"; SourceSalesHeader: Record "Sales Header")
    begin
        SalesHeaderArchive.SetRange("Document Type", SourceSalesHeader."Document Type");
        SalesHeaderArchive.SetRange("No.", SourceSalesHeader."No.");
        SalesHeaderArchive.FindFirst();
    end;

    local procedure FindWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; SourceType: Integer; SourceNo: Code[20]; ActivityType: Enum "Warehouse Activity Type")
    begin
        WarehouseActivityLine.SetRange("Source Type", SourceType);
        WarehouseActivityLine.SetRange("Source No.", SourceNo);
        WarehouseActivityLine.SetRange("Activity Type", ActivityType);
        WarehouseActivityLine.FindFirst();
    end;

    local procedure ModifyServiceCommitmentCalculationBaseAmountAndDiscountPercent()
    begin
        SalesServiceCommitment.Validate("Calculation Base Amount", LibraryRandom.RandDec(10, 2));
        SalesServiceCommitment.Validate("Discount %", LibraryRandom.RandDecInRange(5, 10, 2));
        SalesServiceCommitment.Modify(false);
    end;

    local procedure PopulateSerialNo()
    var
        i: Integer;
    begin
        for i := 1 to NoOfServiceObjects do
            SerialNo[i] := CopyStr(LibraryRandom.RandText(50), 1, MaxStrLen(SerialNo[i]));
    end;

    local procedure PurchaseHardwareItemForLocation()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, '', Location.Code);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", LibraryRandom.RandDecInRange(1, 100, 0));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    local procedure ReqWkshCarryOutActionMessage(var SourceRequisitionLine: Record "Requisition Line")
    var
        CarryOutActionMessage: Report "Carry Out Action Msg. - Req.";
    begin
        CarryOutActionMessage.SetReqWkshLine(SourceRequisitionLine);
        CarryOutActionMessage.SetHideDialog(true);

        CarryOutActionMessage.UseRequestPage(false);
        CarryOutActionMessage.RunModal();
    end;

    local procedure RunGetSalesOrders(var NewRequisitionLine: Record "Requisition Line"; SourceSalesHeader: Record "Sales Header")
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
        ReqWkshName: Record "Requisition Wksh. Name";
        GetSalesOrders: Report "Get Sales Orders";

        RetrieveDimensions: Option "Sales Line",Item;
    begin
        ReqWkshTemplate.SetRange(Type, ReqWkshName."Template Type"::"Req.");
        ReqWkshTemplate.FindFirst();

        LibraryPlanning.CreateRequisitionWkshName(ReqWkshName, ReqWkshTemplate.Name);
        NewRequisitionLine.Init();
        NewRequisitionLine.Validate("Worksheet Template Name", ReqWkshName."Worksheet Template Name");
        NewRequisitionLine.Validate("Journal Batch Name", ReqWkshName.Name);

        SalesLine.SetRange("Document Type", SourceSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SourceSalesHeader."No.");
        Clear(GetSalesOrders);
        GetSalesOrders.SetTableView(SalesLine);
        GetSalesOrders.InitializeRequest(RetrieveDimensions::"Sales Line");
        GetSalesOrders.SetReqWkshLine(NewRequisitionLine, 0);
        GetSalesOrders.UseRequestPage(false);
        GetSalesOrders.Run();

        NewRequisitionLine.SetRange("Journal Batch Name", ReqWkshName.Name);
        NewRequisitionLine.FindFirst();
    end;

    local procedure SetupAdditionalServiceCommPackageAndAssignToItem()
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, false);
    end;

    local procedure SetupAdditionalServiceCommPackageLine(ServicePartner: Enum "Service Partner")
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := ServicePartner;
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
    end;

    local procedure SetupAdditionalServiceCommPackageLine(ServicePartner: Enum "Service Partner"; CalculationBaseType: Enum "Calculation Base Type")
    begin
        SetupAdditionalServiceCommPackageLine(ServicePartner);
        ServiceCommPackageLine."Calculation Base Type" := CalculationBaseType;
        ServiceCommPackageLine.Modify(false);
    end;

    local procedure SetupForInventoryPick()
    begin
        SetupInventorySetupForInventoryPick();
        SetupServiceContractSetupForInventoryPick();
        SetupHardwareItemWithServiceCommitment("Item Service Commitment Type"::"Sales with Service Commitment");
        SetupLocationForInventoryPick();
        SetupWarehouseEmployee();
    end;

    local procedure SetupHardwareItemWithServiceCommitment(ServiceCommitmentType: Enum "Item Service Commitment Type")
    var
        EmptyDateFormula: DateFormula;
    begin
        ContractTestLibrary.CreateInventoryItem(Item);
        Item."Subscription Option" := ServiceCommitmentType;
        Item.Modify(false);
        SetupServiceCommitmentTemplate();
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.InitServiceCommitmentPackageLineFields(ServiceCommPackageLine);
        ServiceCommPackageLine."Sub. Line Start Formula" := EmptyDateFormula;
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
    end;

    local procedure SetupInventorySetupForInventoryPick()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if InventorySetup."Inventory Pick Nos." = '' then begin
            InventorySetup."Inventory Pick Nos." := CreateNoSeriesWithLine();
            InventorySetup.Modify(false);
        end;
        if InventorySetup."Posted Invt. Pick Nos." = '' then begin
            InventorySetup."Posted Invt. Pick Nos." := CreateNoSeriesWithLine();
            InventorySetup.Modify(false);
        end;
    end;

    local procedure SetupLocationForInventoryPick()
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Location.Validate("Require Pick", true);
        Location.Modify(true);
    end;

    local procedure SetupSalesLineForTotalAndVatCalculation(var NewItem: Record Item; SetupServiceItemWithPackage: Boolean; ReferentVatPercent: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";

    begin
        if SetupServiceItemWithPackage then
            ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(NewItem, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code)
        else
            ContractTestLibrary.CreateInventoryItem(NewItem);
        if ReferentVatPercent <> 0 then begin
            LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
            VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', NewItem."VAT Prod. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', ReferentVatPercent);
            VATPostingSetup.FindFirst();
            NewItem.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        end;
        ContractTestLibrary.UpdateItemUnitCostAndPrice(NewItem, LibraryRandom.RandDec(10000, 2), LibraryRandom.RandDec(10000, 2), false);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, NewItem."No.", LibraryRandom.RandInt(100));
    end;

    local procedure SetupSalesLineWithSalesServiceCommitments(NewCurrentQty: Decimal)
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, '');
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", NewCurrentQty);
    end;

    local procedure SetupServiceCommitmentItem(var NewItem: Record Item)
    begin
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(NewItem, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", ServiceCommitmentPackage.Code);
        ContractTestLibrary.UpdateItemUnitCostAndPrice(NewItem, LibraryRandom.RandDec(10000, 2), LibraryRandom.RandDec(10000, 2), false);
    end;

    local procedure SetupServiceCommitmentItemAndSalesLineWithServiceCommitments(var NewItem: Record Item)
    var
        CurrentQty: Decimal;
    begin
        SetupServiceCommitmentItem(NewItem);
        CurrentQty := Random(100);
        SetupSalesLineWithSalesServiceCommitments(CurrentQty);
    end;

    local procedure SetupServiceCommitmentTemplate()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Invoicing Item No." := Item."No.";
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDecInRange(0, 100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
    end;

    local procedure SetupServiceContractSetupForInventoryPick()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup."Sub. Line Start Date Inv. Pick" := ServiceContractSetup."Sub. Line Start Date Inv. Pick"::"Posting Date";
        ServiceContractSetup.Modify(false);
    end;

    local procedure SetupWarehouseEmployee()
    var
        WarehouseEmployee: Record "Warehouse Employee";
    begin
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, true);
    end;

    local procedure TestSalesServiceCommitmentCustomerPriceGroup(CustomerPriceGroupCode: Code[20]; CustomerPriceGroupFilter: Text)
    var
        SalesServiceCommPriceGroupFilter: Text;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Customer Price Group", CustomerPriceGroupCode);
        Customer.Modify(false);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", LibraryRandom.RandIntInRange(1, 100));
        SalesServiceCommitment.SetRange("Document No.", SalesLine."Document No.");
        SalesServiceCommPriceGroupFilter := CustomerPriceGroupFilter; // SalesServiceCommitment.GetCustomerPriceGroupFilter(SalesServiceCommitment);
        SalesServiceCommitment.FindSet();
        repeat
            Assert.AreEqual(SalesServiceCommPriceGroupFilter, CustomerPriceGroupFilter, 'Sales Service Commitments not created properly.');
        until SalesServiceCommitment.Next() = 0;
    end;

    local procedure TestSalesServiceCommitmentPackageFilterForSalesLine(SourceSalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean)
    var
        ItemServiceCommitmentPackage: Record "Item Subscription Package";
        StandardItemSrvCommPackageNotFoundErr: Label 'Item Subscription Package with Standard=true not found.', Locked = true;
        StandardServCommPackageFound: Boolean;
        PackageFilter: Text;
    begin
        PackageFilter := ItemServiceCommitmentPackage.GetPackageFilterForItem(SourceSalesLine, RemoveExistingPackageFromFilter);
        ServiceCommitmentPackage.SetFilter(Code, PackageFilter);
        ServiceCommitmentPackage.FindSet();
        repeat
            ItemServiceCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
            if RemoveExistingPackageFromFilter then
                ItemServiceCommitmentPackage.TestField(Standard, false);
            if ItemServiceCommitmentPackage.Standard then
                StandardServCommPackageFound := true;
        until ServiceCommitmentPackage.Next() = 0;

        if not RemoveExistingPackageFromFilter then
            if not StandardServCommPackageFound then
                Error(StandardItemSrvCommPackageNotFoundErr);
    end;

    local procedure TestSalesServiceCommitmentValues(var SalesServiceCommitmentToTest: Record "Sales Subscription Line"; var SalesServiceCommitmentToTestWith: Record "Sales Subscription Line")
    begin
        SalesServiceCommitmentToTest.TestField("Item No.", SalesServiceCommitmentToTestWith."Item No.");
        SalesServiceCommitmentToTest.TestField("Subscription Package Code", SalesServiceCommitmentToTestWith."Subscription Package Code");
        SalesServiceCommitmentToTest.TestField(Template, SalesServiceCommitmentToTestWith.Template);
        SalesServiceCommitmentToTest.TestField(Description, SalesServiceCommitmentToTestWith.Description);
        SalesServiceCommitmentToTest.TestField("Invoicing via", SalesServiceCommitmentToTestWith."Invoicing via");
        SalesServiceCommitmentToTest.TestField("Extension Term", SalesServiceCommitmentToTestWith."Extension Term");
        SalesServiceCommitmentToTest.TestField("Notice Period", SalesServiceCommitmentToTestWith."Notice Period");
        SalesServiceCommitmentToTest.TestField("Initial Term", SalesServiceCommitmentToTestWith."Initial Term");
        SalesServiceCommitmentToTest.TestField(Partner, SalesServiceCommitmentToTestWith.Partner);
        SalesServiceCommitmentToTest.TestField("Calculation Base Type", SalesServiceCommitmentToTestWith."Calculation Base Type");
        SalesServiceCommitmentToTest.TestField("Billing Base Period", SalesServiceCommitmentToTestWith."Billing Base Period");
        SalesServiceCommitmentToTest.TestField("Calculation Base %", SalesServiceCommitmentToTestWith."Calculation Base %");
        SalesServiceCommitmentToTest.TestField("Sub. Line Start Formula", SalesServiceCommitmentToTestWith."Sub. Line Start Formula");
        SalesServiceCommitmentToTest.TestField("Billing Rhythm", SalesServiceCommitmentToTestWith."Billing Rhythm");
        SalesServiceCommitmentToTest.TestField("Calculation Base Amount", SalesServiceCommitmentToTestWith."Calculation Base Amount");
        SalesServiceCommitmentToTest.TestField(Price, SalesServiceCommitmentToTestWith.Price);
        SalesServiceCommitmentToTest.TestField("Discount %", SalesServiceCommitmentToTestWith."Discount %");
        SalesServiceCommitmentToTest.TestField(Amount, SalesServiceCommitmentToTestWith.Amount);
    end;

    local procedure TestServiceCommitmentPriceCalculation(ServiceCommitmentToTest: Record "Subscription Line")
    var
        ExpectedPrice: Decimal;
    begin
        Currency.InitRoundingPrecision();
        ServiceCommitmentToTest.Validate("Calculation Base Amount", LibraryRandom.RandDec(1000, 2));
        ExpectedPrice := Round(ServiceCommitmentToTest."Calculation Base Amount" * ServiceCommitmentToTest."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitmentToTest.TestField(Price, ExpectedPrice);
    end;

    local procedure TestServiceCommitmentValues(var ServiceCommitmentToTest: Record "Subscription Line"; var SalesServiceCommitmentToTestWith: Record "Sales Subscription Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        ServiceCommitmentToTest.TestField("Subscription Package Code", SalesServiceCommitmentToTestWith."Subscription Package Code");
        ServiceCommitmentToTest.TestField(Template, SalesServiceCommitmentToTestWith.Template);
        ServiceCommitmentToTest.TestField(Description, SalesServiceCommitmentToTestWith.Description);
        ServiceCommitmentToTest.TestField("Invoicing via", SalesServiceCommitmentToTestWith."Invoicing via");
        ServiceCommitmentToTest.TestField("Extension Term", SalesServiceCommitmentToTestWith."Extension Term");
        ServiceCommitmentToTest.TestField("Notice Period", SalesServiceCommitmentToTestWith."Notice Period");
        ServiceCommitmentToTest.TestField("Initial Term", SalesServiceCommitmentToTestWith."Initial Term");
        ServiceCommitmentToTest.TestField("Billing Base Period", SalesServiceCommitmentToTestWith."Billing Base Period");
        ServiceCommitmentToTest.TestField("Calculation Base %", SalesServiceCommitmentToTestWith."Calculation Base %");
        ServiceCommitmentToTest.TestField("Billing Rhythm", SalesServiceCommitmentToTestWith."Billing Rhythm");
        ServiceCommitmentToTest.TestField("Currency Code", Customer."Currency Code");
        ServiceCommitmentToTest.TestField(Price, SalesServiceCommitmentToTestWith.Price);
        ServiceCommitmentToTest.TestField(Amount, SalesServiceCommitmentToTestWith.Amount);
        ServiceCommitmentToTest.TestField("Discount Amount", SalesServiceCommitmentToTestWith."Discount Amount");
        ServiceCommitmentToTest.TestField("Price (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith.Price, ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Amount (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith.Amount, ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Discount Amount (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith."Discount Amount", ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Unit Cost", SalesServiceCommitmentToTestWith."Unit Cost");
        ServiceCommitmentToTest.TestField("Unit Cost (LCY)",
                    CurrExchRate.ExchangeAmtFCYToLCY(WorkDate(), Customer."Currency Code", SalesServiceCommitmentToTestWith."Unit Cost", ServiceCommitmentToTest."Currency Factor"));
        ServiceCommitmentToTest.TestField("Price Binding Period", SalesServiceCommitmentToTestWith."Price Binding Period");
        ServiceCommitmentToTest.TestField("Next Price Update", CalcDate(SalesServiceCommitmentToTestWith."Price Binding Period", ServiceCommitmentToTest."Subscription Line Start Date"));
        ServiceCommitmentToTest.TestField("Create Contract Deferrals", SalesServiceCommitmentToTestWith."Create Contract Deferrals");
    end;

    local procedure TestServiceObjectWithSerialNoExists()
    var
        i: Integer;
    begin
        ServiceObject.Reset();
        ServiceObject.FilterOnItemNo(Item."No.");
        for i := 1 to NoOfServiceObjects do begin
            ServiceObject.SetRange("Serial No.", SerialNo[i]); // check if Serial Object with specific Serial No. is created
            ServiceObject.FindFirst();
            ServiceObject.TestField(Quantity, 1);
        end;
    end;

    local procedure TestServiceObjectWithSerialNoExpectedCount()
    begin
        ServiceObject.Reset();
        ServiceObject.FilterOnItemNo(Item."No.");
        ServiceObject.SetFilter("Serial No.", '<>%1', '');
        Assert.RecordCount(ServiceObject, NoOfServiceObjects);
    end;

    local procedure VerifyServiceCommitmentUnitCostFromSalesServiceCommitment(ServiceCommitmentParam: Record "Subscription Line"; var TempSalesServiceCommitment: Record "Sales Subscription Line" temporary)
    var
        ValueNotCorrectTok: Label '%1 value is not correct.', Locked = true;
    begin
        ServiceCommitmentParam.TestField("Unit Cost");
        ServiceCommitmentParam.TestField("Unit Cost (LCY)");
        Assert.AreEqual(ServiceCommitmentParam."Unit Cost", TempSalesServiceCommitment."Unit Cost", StrSubstNo(ValueNotCorrectTok, ServiceCommitmentParam.FieldCaption("Unit Cost")));
        Assert.AreEqual(ServiceCommitmentParam."Unit Cost (LCY)", TempSalesServiceCommitment."Unit Cost (LCY)", StrSubstNo(ValueNotCorrectTok, ServiceCommitmentParam.FieldCaption("Unit Cost (LCY)")));
    end;
    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure AssignServiceCommitmentsModalPageHandler(var AssignServiceCommitments: TestPage "Assign Service Commitments")
    begin
        AssignServiceCommitments.Cancel().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
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

    [RequestPageHandler]
    procedure SalesOrderConfRequestPageHandler(var StandardSalesOrderConf: TestRequestPage "Standard Sales - Order Conf.")
    begin
    end;

    [PageHandler]
    procedure ServCommWOCustContractPageHandler(var ServCommWOCustContractPage: TestPage "Serv. Comm. WO Cust. Contract")
    begin
        ServCommWOCustContractPage.AssignAllServiceCommitmentsAction.Invoke();
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2;
    end;

    #endregion Handlers
}
