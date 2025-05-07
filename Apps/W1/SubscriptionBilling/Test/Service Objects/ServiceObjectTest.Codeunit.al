namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Calendar;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Currency;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Pricing;
using Microsoft.CRM.Contact;
using Microsoft.Pricing.Calculation;
using Microsoft.Pricing.Source;
using Microsoft.Pricing.Asset;
using Microsoft.Pricing.PriceList;

codeunit 148157 "Service Object Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        NoStartDateErr: Label 'Start Date is not entered.', Locked = true;
        IsInitialized: Boolean;

    #region Tests

    [Test]
    procedure CheckArchivedServCommAmounts()
    var
        Item: Record Item;
        ServComm: Record "Subscription Line";
        TempServComm: Record "Subscription Line" temporary;
        ServCommArchive: Record "Subscription Line Archive";
        ServiceObject: Record "Subscription Header";
        OldQuantity: Decimal;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, true);

        // Save Subscription Lines before changing quantity
        ServComm.SetRange("Subscription Header No.", ServiceObject."No.");
        ServComm.FindSet();
        repeat
            TempServComm := ServComm;
            TempServComm.Insert(false);
        until ServComm.Next() = 0;

        // Change quantity to create entries in Subscription Line Archive
        OldQuantity := ServiceObject.Quantity;
        ServiceObject.Validate(Quantity, LibraryRandom.RandDecInRange(2, 10, 2));
        ServiceObject.Modify(false);

        // Check if archive has saved the correct (old) Amount
        ServCommArchive.SetRange("Subscription Header No.", ServiceObject."No.");
        ServCommArchive.SetRange("Quantity (Sub. Header)", OldQuantity);
        ServCommArchive.FindSet();
        repeat
            TempServComm.Get(ServCommArchive."Original Entry No.");
            Assert.AreEqual(TempServComm.Amount, ServCommArchive.Amount, 'Service Amount in Service Commitment Archive should be the value of the Service Commitment before the quantity change.');
        until ServCommArchive.Next() = 0;
    end;

    [Test]
    procedure CheckArchivedServCommVariantCode()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ServiceCommitmentArchive: Record "Subscription Line Archive";
        ServiceObject: Record "Subscription Header";
        PreviousVariantCode: Code[10];
    begin
        // [SCENARIO] Create Subscription with the Subscription Line, create Item Variant and create Sales Price
        // [SCENARIO] Change the Variant Code in Subscription and check the value in Subscription Line Archive
        // [SCENARIO] Variant Code in Subscription Line Archive should be the value of the Subscription before the Variant Code change
        Initialize();

        // [GIVEN] Setup
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, true, true);

        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Validate("Variant Code", ItemVariant.Code);
        ServiceObject.Modify(true);

        // [WHEN] Change the Variant Code to create entries in Subscription Line Archive
        PreviousVariantCode := ServiceObject."Variant Code";
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        ServiceObject.Validate("Variant Code", ItemVariant.Code);
        ServiceObject.Modify(false);

        // Check if archive has saved the correct (old) Variant Code
        ServiceCommitmentArchive.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitmentArchive.SetRange("Variant Code (Sub. Header)", PreviousVariantCode);
        Assert.RecordIsNotEmpty(ServiceCommitmentArchive);
    end;

    [Test]
    procedure CheckCalculationBaseAmountAssignment()
    var
        Customer: Record Customer;
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        EndingDate: Date;
        FutureReferenceDate: Date;
        CustomerPrice: array[4] of Decimal;
    begin
        Initialize();

        // Create Subscription and Subscription Lines - Unit Price from Item should be taken as Calculation Base Amount
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitmentPackage.SetRange(Code, ServiceCommitment."Subscription Package Code");
        ServiceCommitment.DeleteAll(false);

        // Assign End-User Customer No. Subscription with and create Subscription Lines - Unit Price from Item should be taken as Calculation Base Amount
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitment.DeleteAll(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        // Create different Sales Prices for Customer
        CustomerPrice[1] := LibraryRandom.RandDec(100, 2); // normal price
        CustomerPrice[2] := Round(CustomerPrice[1] * 0.9, 2); // discounted price for Qty = 10
        CustomerPrice[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        CustomerPrice[4] := Round(CustomerPrice[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        FutureReferenceDate := CalcDate('<1M>', WorkDate());
        EndingDate := CalcDate('<-1D>', FutureReferenceDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 0, CustomerPrice[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 10, CustomerPrice[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 0, CustomerPrice[3], PriceListLine);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 10, CustomerPrice[4], PriceListLine);
        // test - normal price
        TestCalculationBaseAmount(1, WorkDate(), CustomerPrice[1], ServiceObject, ServiceCommitmentPackage);
        // test - discounted price for Qty = 10
        TestCalculationBaseAmount(10, WorkDate(), CustomerPrice[2], ServiceObject, ServiceCommitmentPackage);
        // test - price used in future
        TestCalculationBaseAmount(1, FutureReferenceDate, CustomerPrice[3], ServiceObject, ServiceCommitmentPackage);
        // test - price used in future + discounted price for Qty = 10
        TestCalculationBaseAmount(10, FutureReferenceDate, CustomerPrice[4], ServiceObject, ServiceCommitmentPackage);
    end;

    [Test]
    procedure CheckCalculationBaseAmountAssignmentForCustomerWithBillToCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        EndingDate: Date;
        FutureReferenceDate: Date;
        Customer2Price: array[4] of Decimal;
        CustomerPrice: array[4] of Decimal;
    begin
        Initialize();

        // Create Subscription and Subscription Lines - Unit Price from Item should be taken as Calculation Base Amount
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitmentPackage.SetRange(Code, ServiceCommitment."Subscription Package Code");
        ServiceCommitment.DeleteAll(false);

        // Create Customer and Customer2 and assign Customer2 as "Bill-to Customer No."" to Customer
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        Customer.Validate("Bill-to Customer No.", Customer2."No.");
        Customer.Modify(false);

        // Assign End-User Customer No. to Subscription and create Subscription Lines - Unit Price from Item should be taken as Calculation Base Amount
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");
        ServiceCommitment.DeleteAll(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);

        // Create different Sales Prices for Customer
        CustomerPrice[1] := LibraryRandom.RandDec(100, 2); // normal price
        CustomerPrice[2] := Round(CustomerPrice[1] * 0.9, 2); // discounted price for Qty = 10
        CustomerPrice[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        CustomerPrice[4] := Round(CustomerPrice[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        Customer2Price[1] := LibraryRandom.RandDec(100, 2); // normal price
        Customer2Price[2] := Round(Customer2Price[1] * 0.9, 2); // discounted price for Qty = 10
        Customer2Price[3] := LibraryRandom.RandDecInRange(101, 200, 2); // price used in future
        Customer2Price[4] := Round(Customer2Price[3] * 0.9, 2); // price used in future + discounted price for Qty = 10
        FutureReferenceDate := CalcDate('<1M>', WorkDate());
        EndingDate := CalcDate('<-1D>', FutureReferenceDate);
        CreateCustomerSalesPrice(Item, Customer2, WorkDate(), 0, Customer2Price[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer2, WorkDate(), 10, Customer2Price[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer2, FutureReferenceDate, 0, Customer2Price[3], PriceListLine);
        CreateCustomerSalesPrice(Item, Customer2, FutureReferenceDate, 10, Customer2Price[4], PriceListLine);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 0, CustomerPrice[1], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, WorkDate(), 10, CustomerPrice[2], EndingDate);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 0, CustomerPrice[3], PriceListLine);
        CreateCustomerSalesPrice(Item, Customer, FutureReferenceDate, 10, CustomerPrice[4], PriceListLine);

        // test - normal price
        TestCalculationBaseAmount(1, WorkDate(), Customer2Price[1], ServiceObject, ServiceCommitmentPackage);
        // test - discounted price for Qty = 10
        TestCalculationBaseAmount(10, WorkDate(), Customer2Price[2], ServiceObject, ServiceCommitmentPackage);
        // test - price used in future
        TestCalculationBaseAmount(1, FutureReferenceDate, Customer2Price[3], ServiceObject, ServiceCommitmentPackage);
        // test - price used in future + discounted price for Qty = 10
        TestCalculationBaseAmount(10, FutureReferenceDate, Customer2Price[4], ServiceObject, ServiceCommitmentPackage);
    end;

    [Test]
    procedure CheckCalculationDateFormulaEntry()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        Commit();  // retain data after asserterror

        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<5D>', '<20D>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1W>', '<4W>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1M>', '<6Q>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1Q>', '<3Q>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1Y>', '<2Y>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<3M>', '<1Y>');
        ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<6M>', '<1Q>');
        ServiceCommitment.Modify(true);

        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1D>', '<1M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1W>', '<1M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2M>', '<7M>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2Q>', '<5Q>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<2Y>', '<3Y>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<CM>', '<1Y>');
        asserterror ServiceCommitment.Modify(true);
        ContractTestLibrary.ValidateBillingBasePeriodAndBillingRhythmOnServiceCommitment(ServiceCommitment, '<1M + 1Q>', '<1Y>');
        asserterror ServiceCommitment.Modify(true);
    end;

    [Test]
    procedure CheckChangeQuantityIfCustomerPostingGroupEmpty()
    var
        CustomerWithPostingGroup: Record Customer;
        EndUserCustomer: Record Customer;
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
        OldQuantity: Decimal;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);

        ContractTestLibrary.CreateCustomer(EndUserCustomer);
        ContractTestLibrary.CreateCustomer(CustomerWithPostingGroup);
        EndUserCustomer.Validate("Customer Posting Group", '');
        EndUserCustomer.Validate("Bill-to Customer No.", CustomerWithPostingGroup."No.");
        EndUserCustomer.Modify(false);

        ServiceObject.Validate("End-User Customer No.", EndUserCustomer."No.");
        ServiceObject.Modify(false);
        OldQuantity := ServiceObject.Quantity;
        ServiceObject.Validate(Quantity, ServiceObject.Quantity + 1);
        Assert.AreEqual(OldQuantity + 1, ServiceObject.Quantity, 'Service Object Quantity has to be changeable with "Customer Posting Group" filled for "Bill-to Customer No.".');
    end;

    [Test]
    procedure CheckChangeServiceObjectSN()
    var
        Item: Record Item;
        ServCommArchive: Record "Subscription Line Archive";
        ServiceObject: Record "Subscription Header";
        SN: Code[50];
        ServiceObjectPage: TestPage "Service Object";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, true, false);
        SN := ServiceObject."Serial No.";

        ServCommArchive.Reset();
        ServCommArchive.SetRange("Subscription Header No.", ServiceObject."No.");
        ServCommArchive.DeleteAll(false);

        ServiceObjectPage.OpenView();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage."Serial No.".SetValue(LibraryRandom.RandText(MaxStrLen(ServiceObject."Serial No.")));
        ServiceObjectPage.Close();

        ServCommArchive.Reset();
        ServCommArchive.SetRange("Subscription Header No.", ServiceObject."No.");
        ServCommArchive.FindFirst();
        Assert.AreEqual(SN, ServCommArchive."Serial No. (Sub. Header)", 'The original Serial No. should have been archived.');
        Assert.RecordCount(ServCommArchive, 1);
    end;

    [Test]
    procedure CheckClearTerminationPeriods()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        ServiceCommitmentTemplateCode: Code[20];
        ServiceAndCalculationStartDate: Date;
        ServiceEndDate: Date;
    begin
        Initialize();

        ServiceAndCalculationStartDate := CalcDate('<-1Y>', WorkDate());
        SetupServiceObjectTemplatePackageAndAssignItemToPackage(ServiceCommitmentTemplateCode, ServiceObject, ServiceCommitmentPackage, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>', ServiceCommPackageLine);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        Assert.AreEqual(0D, ServiceCommitment."Subscription Line End Date", '"Service End Date" is set.');
        Assert.AreNotEqual(0D, ServiceCommitment."Term Until", '"Term Until" not set.');
        Assert.AreNotEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not set.');

        ServiceEndDate := CalcDate('<-6M>', WorkDate());

        ServiceCommitment.Validate("Subscription Line End Date", ServiceEndDate);
        Assert.AreEqual(0D, ServiceCommitment."Term Until", '"Term Until" not cleared.');
        Assert.AreEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not cleared.');
    end;

    [Test]
    procedure CheckDeleteServiceObjectWithArchivedServComm()
    var
        Item: Record Item;
        ServComm: Record "Subscription Line";
        ServCommArchive: Record "Subscription Line Archive";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, true);

        // Change quantity to create entries in Subscription Line Archive
        ServiceObject.Validate(Quantity, LibraryRandom.RandDecInRange(2, 10, 2));
        ServiceObject.Modify(false);
        ServCommArchive.SetRange("Subscription Header No.", ServiceObject."No.");
        Assert.AreNotEqual(0, ServCommArchive.Count(), 'Entries in Service Commitment Archive should exist after changing quantity in Service Object.');

        // Delete Subscription Lines & Subscriptions to check if archive gets deleted
        ServComm.Reset();
        ServComm.SetRange("Subscription Header No.", ServiceObject."No.");
        ServComm.DeleteAll(false);

        ServiceObject.Delete(true);
        Assert.AreEqual(0, ServCommArchive.Count(), 'Entries in Service Commitment Archive should be deleted after deleting Service Object.');
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]

    procedure CheckInvoicingItemNoInServiceObjectWithServiceCommitmentItem()
    var
        Item: Record Item;
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        ServiceObjectPage: TestPage "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate, '<12M>', 10, "Invoicing Via"::Contract, "Calculation Base Type"::"Document Price", false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Extension Term", '<1M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1M>');
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<12M>');
        Evaluate(ServiceCommPackageLine."Price Binding Period", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();

        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        ServiceCommitment.TestField("Invoicing Item No.", Item."No.");
    end;

    [Test]
    [HandlerFunctions('ServiceObjectAttributeValueEditorModalPageHandlerTestValues')]
    procedure CheckLoadServiceObjectAttributes()
    var
        Item: Record Item;
        ItemAttribute: array[2] of Record "Item Attribute";
        ItemAttributeValue: array[2] of Record "Item Attribute Value";
        ServiceObject: Record "Subscription Header";
        ServiceObjectTestPage: TestPage "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute[1], ItemAttributeValue[1], false);
        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute[2], ItemAttributeValue[2], true);

        LibraryVariableStorage.Enqueue(ItemAttribute[1].ID);
        LibraryVariableStorage.Enqueue(ItemAttribute[2].ID);
        LibraryVariableStorage.Enqueue(ItemAttributeValue[1].ID);
        LibraryVariableStorage.Enqueue(ItemAttributeValue[2].ID);
        ServiceObjectTestPage.OpenEdit();
        ServiceObjectTestPage.GoToRecord(ServiceObject);
        ServiceObjectTestPage.Attributes.Invoke(); // ServiceObjectAttributeValueEditorModalPageHandlerTestValues
    end;

    [Test]
    procedure CheckServiceCommitmentBaseAmountAssignment()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, true, true);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price");

        ServiceCommitment.Next();
        ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Cost");
    end;

    [Test]
    procedure CheckServiceCommitmentCalculationBaseAmountIsNotRecalculatedOnServiceObjectQuantityChange()
    var
        Currency: Record Currency;
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ExpectedCalculationBaseAmount: Decimal;
        ExpectedServiceAmount: Decimal;
        Price: Decimal;
        Quantity2: Decimal;
    begin
        Initialize();

        // If Subscription Line field "Calculation Base Amount" is changed manually
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Calculation Base Amount");
        ExpectedCalculationBaseAmount := LibraryRandom.RandDec(100, 2);
        ServiceCommitment.Validate("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.Modify(false);

        Currency.InitRoundingPrecision();
        Price := Round(ExpectedCalculationBaseAmount * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject.Quantity * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        // [WHEN] Subscription Quantity is changed
        Quantity2 := LibraryRandom.RandDec(10, 2);
        while Quantity2 = ServiceObject.Quantity do
            Quantity2 := LibraryRandom.RandDec(10, 2);
        Price := Round(ExpectedCalculationBaseAmount * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(Quantity2 * Price, Currency."Amount Rounding Precision");
        ServiceObject.Validate(Quantity, Quantity2);

        // [THEN] "Calculation Base Amount" field should not be recalculated
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
    end;

    [Test]
    procedure CheckServiceCommitmentDiscountCalculation()
    var
        Currency: Record Currency;
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        DiscountAmount: Decimal;
        DiscountPercent: Decimal;
        ExpectedDiscountAmount: Decimal;
        ExpectedDiscountPercent: Decimal;
        ServiceAmountInt: Integer;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Discount %", 0);
        ServiceCommitment.TestField("Discount Amount", 0);
        Currency.InitRoundingPrecision();

        DiscountPercent := LibraryRandom.RandDec(50, 2);
        ExpectedDiscountAmount := Round(ServiceCommitment.Amount * DiscountPercent / 100, Currency."Amount Rounding Precision");
        ServiceCommitment.Validate("Discount %", DiscountPercent);
        ServiceCommitment.TestField("Discount Amount", ExpectedDiscountAmount);

        Evaluate(ServiceAmountInt, Format(ServiceCommitment.Amount, 0, '<Integer>'));
        DiscountAmount := LibraryRandom.RandDec(ServiceAmountInt, 2);
        ExpectedDiscountPercent := Round(DiscountAmount / Round((ServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision") * 100, 0.00001);
        ServiceCommitment.Validate("Discount Amount", DiscountAmount);
        ServiceCommitment.TestField("Discount %", ExpectedDiscountPercent);
    end;

    [Test]
    procedure CheckServiceCommitmentPriceCalculation()
    var
        Currency: Record Currency;
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ExpectedPrice: Decimal;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, true, true);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        Currency.InitRoundingPrecision();
        ExpectedPrice := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitment.TestField(Price, ExpectedPrice);

        ServiceCommitment.Next();
        ExpectedPrice := Round(Item."Unit Cost" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ServiceCommitment.TestField(Price, ExpectedPrice);
    end;

    [Test]
    procedure CheckServiceCommitmentUnitCostCalculation()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, true);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        VerifyUnitCost(ServiceCommitment, Item);
        ServiceCommitment.Next();
        VerifyUnitCost(ServiceCommitment, Item);
    end;

    [Test]
    procedure CheckServiceCommitmentServiceAmountCalculation()
    var
        Currency: Record Currency;
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ChangedCalculationBaseAmount: Decimal;
        DiscountPercent: Decimal;
        ExpectedServiceAmount: Decimal;
        MaxServiceAmount: Decimal;
        NegativeServiceAmount: Decimal;
        Price: Decimal;
        ServiceAmountBiggerThanPrice: Decimal;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        Currency.InitRoundingPrecision();
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject.Quantity * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        ChangedCalculationBaseAmount := LibraryRandom.RandDec(1000, 2);
        ServiceCommitment.Validate("Calculation Base Amount", ChangedCalculationBaseAmount);

        ExpectedServiceAmount := Round((ServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision");
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        DiscountPercent := LibraryRandom.RandDec(100, 2);
        ServiceCommitment.Validate("Discount %", DiscountPercent);

        ExpectedServiceAmount := Round((ServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision");
        ExpectedServiceAmount := ExpectedServiceAmount - Round((ExpectedServiceAmount * DiscountPercent / 100), Currency."Amount Rounding Precision");
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        Commit(); // retain data after asserterror

        ServiceAmountBiggerThanPrice := Round(ServiceCommitment.Price * (ServiceObject.Quantity + 1), Currency."Amount Rounding Precision");
        asserterror ServiceCommitment.Validate(Amount, ServiceAmountBiggerThanPrice);
        NegativeServiceAmount := -1 * LibraryRandom.RandDec(100, 2);
        asserterror ServiceCommitment.Validate(Amount, NegativeServiceAmount);
        MaxServiceAmount := Round((ServiceCommitment.Price * ServiceObject.Quantity), Currency."Amount Rounding Precision");
        asserterror ServiceCommitment.Validate("Discount Amount", MaxServiceAmount + LibraryRandom.RandDec(100, 2));
    end;

    [Test]
    procedure CheckServiceCommitmentServiceDates()
    var
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);

        ValidateServiceDateCombination(WorkDate(), WorkDate(), WorkDate(), ServiceObject."No.");
        ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<+3D>', WorkDate()), ServiceObject."No.");
        ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<+6D>', WorkDate()), ServiceObject."No."); // allow setting the Subscription Line End Date one day before Next Billing Date
        asserterror ValidateServiceDateCombination(WorkDate(), CalcDate('<+5D>', WorkDate()), CalcDate('<-3D>', WorkDate()), ServiceObject."No.");
        asserterror ValidateServiceDateCombination(WorkDate(), CalcDate('<+4D>', WorkDate()), CalcDate('<+6D>', WorkDate()), ServiceObject."No."); // do not allow setting the Subscription Line End Date two or more days before Next Billing Date - because Subscription Line was invoiced up to Next Billing Date
    end;

    [Test]
    procedure CheckServiceCommitmentServiceInitialEndDateCalculation()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        DateFormulaVariable: DateFormula;
        ExpectedServiceEndDate: Date;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        ServiceCommitment.Validate("Subscription Line Start Date", WorkDate());

        Evaluate(DateFormulaVariable, '<1M>');

        Clear(ServiceCommitment."Extension Term");
        ServiceCommitment.Validate("Initial Term", DateFormulaVariable);
        ExpectedServiceEndDate := CalcDate(ServiceCommitment."Initial Term", ServiceCommitment."Subscription Line Start Date");
        ExpectedServiceEndDate := CalcDate('<-1D>', ExpectedServiceEndDate);
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Subscription Line End Date", ExpectedServiceEndDate);

        Clear(ServiceCommitment."Subscription Line End Date");
        ServiceCommitment.Validate("Extension Term", DateFormulaVariable);
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Subscription Line End Date", 0D);

        Clear(ServiceCommitment."Subscription Line End Date");
        Clear(ServiceCommitment."Extension Term");
        Clear(ServiceCommitment."Initial Term");
        ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.TestField("Subscription Line End Date", 0D);
    end;

    [Test]
    procedure CheckServiceCommitmentServiceInitialTerminationDatesCalculation()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        ServiceCommitmentTemplateCode: Code[20];
        ServiceAndCalculationStartDate: Date;
    begin
        Initialize();

        ServiceAndCalculationStartDate := WorkDate();
        SetupServiceObjectTemplatePackageAndAssignItemToPackage(ServiceCommitmentTemplateCode, ServiceObject, ServiceCommitmentPackage, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine('<12M>', '<1M>', '<1M>', ServiceCommPackageLine);

        AddNewServiceCommPackageLine('<12M>', '<1M>', '', ServiceCommitmentTemplateCode, ServiceCommitmentPackage.Code, ServiceCommPackageLine);
        AddNewServiceCommPackageLine('<12M>', '', '', ServiceCommitmentTemplateCode, ServiceCommitmentPackage.Code, ServiceCommPackageLine);
        AddNewServiceCommPackageLine('', '<1M>', '<1M>', ServiceCommitmentTemplateCode, ServiceCommitmentPackage.Code, ServiceCommPackageLine);
        AddNewServiceCommPackageLine('', '<1M>', '', ServiceCommitmentTemplateCode, ServiceCommitmentPackage.Code, ServiceCommPackageLine);
        AddNewServiceCommPackageLine('', '', '', ServiceCommitmentTemplateCode, ServiceCommitmentPackage.Code, ServiceCommPackageLine);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");

        ServiceCommitment.FindFirst();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
        ServiceCommitment.Next();
        TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate, ServiceCommitment);
    end;

    [Test]
    procedure CheckServiceCommitmentUpdateTerminationDatesCalculation()
    var
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitment2: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        ServiceAndCalculationStartDate: Date;
    begin
        Initialize();

        ServiceAndCalculationStartDate := CalcDate('<-5Y>', WorkDate());
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Initial Term", '<12M>');
        Evaluate(ServiceCommPackageLine."Extension Term", '<12M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        repeat
            ServiceCommitment2 := ServiceCommitment;
            ServiceCommitment.UpdateTermUntilUsingExtensionTerm();
            ServiceCommitment.UpdateCancellationPossibleUntil();
            ServiceCommitment.Modify(false);
            TestServiceCommitmentUpdatedTerminationDates(ServiceCommitment2, ServiceCommitment, ServiceCommitment);
        until WorkDate() <= ServiceCommitment."Cancellation Possible Until";
    end;

    [Test]
    procedure CheckServiceObjectQtyRecalculation()
    var
        Currency: Record Currency;
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ExpectedCalculationBaseAmount: Decimal;
        ExpectedServiceAmount: Decimal;
        Price: Decimal;
        Quantity2: Decimal;
        Quantity3: Decimal;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        Currency.InitRoundingPrecision();
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(ServiceObject.Quantity * Price, Currency."Amount Rounding Precision");
        ServiceCommitment.TestField("Calculation Base Amount");
        ExpectedCalculationBaseAmount := ServiceCommitment."Calculation Base Amount";
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);

        Quantity2 := LibraryRandom.RandDec(10, 2);
        while Quantity2 = ServiceObject.Quantity do
            Quantity2 := LibraryRandom.RandDec(10, 2);
        Price := Round(Item."Unit Price" * ServiceCommitment."Calculation Base %" / 100, Currency."Unit-Amount Rounding Precision");
        ExpectedServiceAmount := Round(Quantity2 * Price, Currency."Amount Rounding Precision");
        ServiceObject.Validate(Quantity, Quantity2);

        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        Commit(); // retain data after asserterror
        Quantity3 := LibraryRandom.RandDec(10, 2);
        while Quantity3 = Quantity2 do
            Quantity3 := LibraryRandom.RandDec(10, 2);
        ServiceObject.SetHideValidationDialog(false);
        asserterror ServiceObject.Validate(Quantity, Quantity3);
        ServiceObject.TestField(Quantity, Quantity2);
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField(Amount, ExpectedServiceAmount);
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedCalculationBaseAmount);

        asserterror ServiceObject.Validate(Quantity, 0);
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure CheckServiceObjectsServiceCommitmentAssignment()
    var
        Item: Record Item;
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        ServiceObjectPage: TestPage "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);

        ServiceCommitmentTemplate.Description += ' Temp';
        ServiceCommitmentTemplate."Calculation Base Type" := Enum::"Calculation Base Type"::"Document Price";
        ServiceCommitmentTemplate."Calculation Base %" := 10;
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        Evaluate(ServiceCommPackageLine."Extension Term", '<1M>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1M>');
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<12M>');
        ServiceCommPackageLine.Modify(false);

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();

        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        ServiceCommitment.TestField("Subscription Package Code", ServiceCommPackageLine."Subscription Package Code");
        ServiceCommitment.TestField(Template, ServiceCommPackageLine.Template);
        ServiceCommitment.TestField(Description, ServiceCommPackageLine.Description);
        ServiceCommitment.TestField("Subscription Line Start Date", WorkDate());
        ServiceCommitment.TestField("Extension Term", ServiceCommPackageLine."Extension Term");
        ServiceCommitment.TestField("Notice Period", ServiceCommPackageLine."Notice Period");
        ServiceCommitment.TestField("Initial Term", ServiceCommPackageLine."Initial Term");
        ServiceCommitment.TestField(Partner, ServiceCommPackageLine.Partner);
        ServiceCommitment.TestField("Calculation Base %", ServiceCommPackageLine."Calculation Base %");
        ServiceCommitment.TestField("Billing Base Period", ServiceCommPackageLine."Billing Base Period");
        ServiceCommitment.TestField("Invoicing via", ServiceCommPackageLine."Invoicing via");
        ServiceCommitment.TestField("Invoicing Item No.", ServiceCommPackageLine."Invoicing Item No.");
        ServiceCommitment.TestField("Billing Rhythm", ServiceCommPackageLine."Billing Rhythm");
        ServiceCommitment.TestField("Price (LCY)", ServiceCommitment.Price);
        ServiceCommitment.TestField("Amount (LCY)", ServiceCommitment.Amount);
        ServiceCommitment.TestField("Discount Amount (LCY)", ServiceCommitment."Discount Amount");
        ServiceCommitment.TestField("Currency Code", '');
        ServiceCommitment.TestField("Currency Factor", 0);
        ServiceCommitment.TestField("Currency Factor Date", 0D);
        ServiceCommitment.TestField(Discount, false);
        ServiceCommitment.TestField("Price Binding Period", ServiceCommPackageLine."Price Binding Period");
        ServiceCommitment.TestField("Next Price Update", CalcDate(ServiceCommPackageLine."Price Binding Period", ServiceCommitment."Subscription Line Start Date"));
        ServiceCommitment.TestField("Create Contract Deferrals", ServiceCommPackageLine."Create Contract Deferrals");
    end;

    [Test]

    procedure CheckServiceObjectsServiceCommitmentStandardPackagesAssignment()
    var
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.CreateItemForServiceObject(Item, false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item."No.");

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Template, ServiceCommitmentTemplate.Code);
        Assert.RecordIsNotEmpty(ServiceCommitment);
    end;

    [Test]
    procedure CheckUpdatingProvisionEndDateOnAfterFinishContractLines()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        ServiceCommitmentTemplateCode: Code[20];
        i: Integer;
    begin
        Initialize();

        i := -1;
        SetupServiceObjectTemplatePackageAndAssignItemToPackage(ServiceCommitmentTemplateCode, ServiceObject, ServiceCommitmentPackage, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>', ServiceCommPackageLine);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        if ServiceCommitment.FindSet() then
            repeat
                ServiceCommitment."Subscription Line Start Date" := CalcDate('<-2D>', Today());
                ServiceCommitment."Subscription Line End Date" := Today() + i;
                ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
                ServiceCommitment.Modify(false);
                i -= 1;
            until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
        Assert.AreEqual(CalcDate('<-1D>', Today()), ServiceObject."Provision End Date", 'Provision End Date was not updated properly.');
    end;

    [Test]
    procedure CheckUpdatingTerminationDatesOnManualValidation()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceObject: Record "Subscription Header";
        DateTimeManagement: Codeunit "Date Time Management";
        NegativeDateFormula: DateFormula;
        ServiceCommitmentTemplateCode: Code[20];
        ServiceAndCalculationStartDate: Date;
        DateFormulaLbl: Label '-%1', Locked = true;
    begin
        Initialize();

        ServiceAndCalculationStartDate := WorkDate();
        SetupServiceObjectTemplatePackageAndAssignItemToPackage(ServiceCommitmentTemplateCode, ServiceObject, ServiceCommitmentPackage, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine('<12M>', '<12M>', '<1M>', ServiceCommPackageLine);

        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceAndCalculationStartDate, ServiceCommitmentPackage);

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindFirst();
        Assert.AreNotEqual(0D, ServiceCommitment."Term Until", '"Term Until" is not set.');
        Assert.AreNotEqual(0D, ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" is not set.');
        Assert.AreNotEqual('', ServiceCommitment."Notice Period", '"Notice Period" is not set.');

        ServiceCommitment.Validate("Cancellation Possible Until", CalcDate('<+5D>', ServiceCommitment."Cancellation Possible Until"));
        Assert.AreEqual(CalcDate(ServiceCommitment."Notice Period", ServiceCommitment."Cancellation Possible Until"), ServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');

        if DateTimeManagement.IsLastDayOfMonth(CalcDate('<-7D>', ServiceCommitment."Term Until")) then
            ServiceCommitment.Validate("Term Until", CalcDate('<-8D>', ServiceCommitment."Term Until"))
        else
            ServiceCommitment.Validate("Term Until", CalcDate('<-7D>', ServiceCommitment."Term Until"));
        Evaluate(NegativeDateFormula, StrSubstNo(DateFormulaLbl, ServiceCommitment."Notice Period"));
        Assert.AreEqual(CalcDate(NegativeDateFormula, ServiceCommitment."Term Until"), ServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
    end;

    [Test]
    procedure ExpectDocumentAttachmentsAreDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
        ServiceObject: Record "Subscription Header";
        i: Integer;
        RandomNoOfAttachments: Integer;
    begin
        Initialize();

        // Subscription has Document Attachments created
        // [WHEN] Subscription is deleted
        // expect that Document Attachments are deleted
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        ServiceObject.TestField("No.");
        RandomNoOfAttachments := LibraryRandom.RandInt(10);
        for i := 1 to RandomNoOfAttachments do
            ContractTestLibrary.InsertDocumentAttachment(Database::"Subscription Header", ServiceObject."No.");

        DocumentAttachment.SetRange("Table ID", Database::"Subscription Header");
        DocumentAttachment.SetRange("No.", ServiceObject."No.");
        Assert.AreEqual(RandomNoOfAttachments, DocumentAttachment.Count(), 'Actual number of Document Attachment(s) is incorrect.');

        ServiceObject.Delete(true);
        Assert.AreEqual(0, DocumentAttachment.Count(), 'Document Attachment(s) should be deleted.');
    end;

    [Test]
    procedure ExpectErrorForNegativeServiceCommitmentDateFormulaFields()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        NegativeDateFormula: DateFormula;
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        Commit(); // retain data after asserterror

        Evaluate(NegativeDateFormula, '<-1M>');
        asserterror ServiceCommitment.Validate("Billing Base Period", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Notice Period", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Initial Term", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Extension Term", NegativeDateFormula);
        asserterror ServiceCommitment.Validate("Billing Rhythm", NegativeDateFormula);
    end;

    [Test]
    procedure ExpectErrorOnChangeEndUserIfCustomerPostingGroupEmpty()
    var
        EndUserCustomer: Record Customer;
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        ContractTestLibrary.CreateCustomer(EndUserCustomer);
        EndUserCustomer.Validate("Customer Posting Group", '');
        EndUserCustomer.Modify(false);

        asserterror ServiceObject.Validate("End-User Customer No.", EndUserCustomer."No.");
    end;

    [Test]
    procedure ExpectErrorOnChangeEndUserIfServiceObjectIsLinkedToContract()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, false);
        ServiceObject.SetHideValidationDialog(false);
        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject."End-User Customer No." := Customer."No.";
        ServiceObject.Modify(false);
        ContractTestLibrary.CreateCustomer(Customer2);
        asserterror ServiceObject.Validate("End-User Customer No.", Customer2."No.");
    end;

    [Test]
    [HandlerFunctions('ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary')]
    procedure ExpectErrorOnDuplicatePrimaryServiceObjectAttribute()
    var
        Item: Record Item;
        ItemAttribute: array[2] of Record "Item Attribute";
        ItemAttributeValue: array[2] of Record "Item Attribute Value";
        ServiceObject: Record "Subscription Header";
        ServiceObjectTestPage: TestPage "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute[1], ItemAttributeValue[1], false);
        ContractTestLibrary.CreateItemAttributeMappedToServiceObject(ServiceObject."No.", ItemAttribute[2], ItemAttributeValue[2], true);

        ServiceObjectTestPage.OpenEdit();
        ServiceObjectTestPage.GoToRecord(ServiceObject);
        ServiceObjectTestPage.Attributes.Invoke(); // ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary
    end;

    [Test]
    procedure TestModifyCustomerAddress()
    var
        Customer: Record Customer;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        // Create Subscription with End-User
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.");

        // Change in address fields should be possible without error
        ServiceObject.Validate("End-User Address", LibraryRandom.RandText(MaxStrLen(ServiceObject."End-User Address")));
        ServiceObject.Validate("End-User Address 2", LibraryRandom.RandText(MaxStrLen(ServiceObject."End-User Address 2")));
        ServiceObject.Modify(false);
    end;

    [Test]
    [HandlerFunctions('AssignServiceCommitmentsModalPageHandler')]
    procedure TestPriceGroupFilterOnAssignServiceCommitments()
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommPackageLine2: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentPackage2: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        ServiceObjectPage: TestPage "Service Object";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine2);
        ServiceCommitmentPackage2."Price Group" := CustomerPriceGroup.Code;
        ServiceCommitmentPackage2.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage2.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        Customer."Customer Price Group" := CustomerPriceGroup.Code;
        Customer.Modify(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.DeleteAll(false); // Remove all Subscription Lines assigned on Validate Item No. in Subscription

        ServiceObjectPage.OpenEdit();
        ServiceObjectPage.GoToRecord(ServiceObject);
        ServiceObjectPage.AssignServices.Invoke();
        // ServiceObjectPage.Close();

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Subscription Package Code", ServiceCommitmentPackage2.Code); // Expect only Subscription Lines from Package 1 because of the Customer Price group
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure TestRecalculateServiceCommitmentsOnChangeBillToCustomer()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommPackageLine1: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentPackage2: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
        NewUnitPrice: Decimal;
    begin
        Initialize();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ContractTestLibrary.UpdateServiceCommitmentPackageLine(
                ServiceCommPackageLine, Format(ServiceCommPackageLine."Billing Base Period"), ServiceCommPackageLine."Calculation Base %",
                Format(ServiceCommPackageLine."Billing Rhythm"), Format(ServiceCommPackageLine."Extension Term"), "Service Partner"::Vendor, ServiceCommPackageLine."Invoicing Item No.");
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine1);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage2.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ContractTestLibrary.CreateCustomer(Customer2);
        NewUnitPrice := LibraryRandom.RandDec(1000, 2);
        CreatePriceListForCustomer(Customer2."No.", NewUnitPrice, Item."No.");
        ServiceObject.Validate("Bill-to Customer No.", Customer2."No.");
        ServiceObject.Modify(true);

        ContractsItemManagement.CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, ServiceObject."End-User Customer No.", ServiceObject."Bill-to Customer No.", WorkDate(), '');
        ContractsItemManagement.CreateTempSalesLine(TempSalesLine, TempSalesHeader, ServiceObject, WorkDate());

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            NewUnitPrice := ContractsItemManagement.CalculateUnitPrice(TempSalesHeader, TempSalesLine);
            ServiceCommitment.TestField("Calculation Base Amount", NewUnitPrice);
        until ServiceCommitment.Next() = 0;

        ServiceCommitment.SetRange(Partner, "Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Cost");
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure TestRecalculateServiceCommitmentsOnChangeServiceObjectQuantity()
    var
        Item: Record Item;
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, false, true);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        ServiceObject.Validate(Quantity, LibraryRandom.RandDecInRange(11, 100, 2)); // In the library init value for Quantity is in the range from 0 to 10
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Price")
        until ServiceCommitment.Next() = 0;

        ServiceCommitment.SetRange(Partner, "Service Partner"::Vendor);
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Calculation Base Amount", Item."Unit Cost")
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    procedure TestRecalculateServiceCommitmentsOnChangeVariantCode()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemVariant: array[2] of Record "Item Variant";
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        CustomerPrice: array[2] of Decimal;
    begin
        // [SCENARIO] Create Subscription with the Subscription Line, Create Item Variants and create Sales Prices
        // [SCENARIO] Change the Variant Code in Subscription and check the value of Calculation Base Amount in Subscription Line
        // [SCENARIO] Calculation Base Amount should be recalculated based on value of Variant Code that has been set in Sales Price
        Initialize();

        // [GIVEN] New pricing enabled
        LibraryPriceCalculation.EnableExtendedPriceCalculation();
        LibraryPriceCalculation.SetupDefaultHandler("Price Calculation Handler"::"Business Central (Version 16.0)");
        // [GIVEN] Setup
        SetupServiceObjectWithServiceCommitment(Item, ServiceObject, true, true);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        LibrarySales.CreateCustomer(Customer);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);
        CustomerPrice[1] := LibraryRandom.RandDec(100, 2);
        CustomerPrice[2] := LibraryRandom.RandDec(100, 2);
        LibraryInventory.CreateItemVariant(ItemVariant[1], Item."No.");
        LibraryInventory.CreateItemVariant(ItemVariant[2], Item."No.");
        CreateCustomerSalesPriceWithVariantCode(Item, Customer, WorkDate(), 0, CustomerPrice[1], (CalcDate('<1M>', WorkDate())), ItemVariant[1].Code);
        CreateCustomerSalesPriceWithVariantCode(Item, Customer, WorkDate(), 0, CustomerPrice[2], (CalcDate('<1M>', WorkDate())), ItemVariant[2].Code);

        // [WHEN] Change the Variant Code on Subscription
        ServiceObject.Validate("Variant Code", ItemVariant[1].Code);
        ServiceObject.Modify(false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        // [THEN] Calculation Base Amount on Subscription Line should be recalculated based on value related to changed Variant Code
        Assert.AreEqual(CustomerPrice[1], ServiceCommitment."Calculation Base Amount", 'Calculation Base Amount should be taken from Sales Price based on Variant Code');

        // [WHEN] Change the Variant Code on Subscription
        ServiceObject.Validate("Variant Code", ItemVariant[2].Code);
        ServiceObject.Modify(false);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");

        // [THEN] Calculation Base Amount on Subscription Line should be recalculated based on value related to changed Variant Code
        Assert.AreEqual(CustomerPrice[2], ServiceCommitment."Calculation Base Amount", 'Calculation Base Amount should be taken from Sales Price based on Variant Code');
    end;

    [Test]
    procedure TestRecreateServiceCommitmentsOnChangeEndUser()
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommPackageLine1: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentPackage2: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.SetupSalesServiceCommitmentItemAndAssignToServiceCommitmentPackage(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item", ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);

        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage2, ServiceCommPackageLine1);
        ServiceCommitmentPackage2."Price Group" := CustomerPriceGroup.Code;
        ServiceCommitmentPackage2.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage2.Code, true);

        ContractTestLibrary.CreateCustomer(Customer);
        Customer."Customer Price Group" := CustomerPriceGroup.Code;
        Customer.Modify(false);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(true);

        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Subscription Package Code", ServiceCommitmentPackage2.Code);
        until ServiceCommitment.Next() = 0;
    end;

    local procedure VerifyUnitCost(ServiceCommitment: Record "Subscription Line"; Item: Record Item)
    var
        ExpectedUnitCost: Decimal;
        ValueNotCorrectTok: Label '%1 value is not correct.', Locked = true;
    begin
        case ServiceCommitment.Partner of
            "Service Partner"::Customer:
                begin
                    ExpectedUnitCost := Item."Unit Cost" * ServiceCommitment."Calculation Base %" / 100;
                    Assert.AreEqual(ExpectedUnitCost, ServiceCommitment."Unit Cost", StrSubstNo(ValueNotCorrectTok, ServiceCommitment.FieldCaption("Unit Cost")));
                    Assert.AreEqual(ExpectedUnitCost, ServiceCommitment."Unit Cost (LCY)", StrSubstNo(ValueNotCorrectTok, ServiceCommitment.FieldCaption("Unit Cost (LCY)")));
                end;
            "Service Partner"::Vendor:
                begin
                    Assert.AreEqual(ServiceCommitment.Price, ServiceCommitment."Unit Cost", StrSubstNo(ValueNotCorrectTok, ServiceCommitment.FieldCaption("Unit Cost")));
                    Assert.AreEqual(ServiceCommitment.Price, ServiceCommitment."Unit Cost (LCY)", StrSubstNo(ValueNotCorrectTok, ServiceCommitment.FieldCaption("Unit Cost (LCY)")));
                end;
        end;

    end;

    [Test]
    procedure UT_CheckCreateServiceObject()
    var
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');

        ServiceObject.TestField("No.");
        ServiceObject.TestField(Quantity);
        asserterror ServiceObject.Validate(Quantity, -1);
    end;

    [Test]
    procedure UT_CheckCreateServiceObjectWithCustomerPriceGroup()
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        ServiceObject.TestField("Customer Price Group", '');
        ContractTestLibrary.CreateCustomer(Customer);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        Customer."Customer Price Group" := CustomerPriceGroup.Code;
        Customer.Modify(false);
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
        ServiceObject.TestField("Customer Price Group", Customer."Customer Price Group");
    end;

    [Test]
    procedure UT_CheckCreateServiceObjectWithItemNo()
    var
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        ServiceObject.TestField("Source No.", Item."No.");
        ServiceObject.TestField(Description, Item.Description);
    end;

    [Test]
    procedure CheckCreateServiceObjectWithGLAccountNo()
    var
        GLAccount: Record "G/L Account";
        ServiceObject: Record "Subscription Header";
    begin
        ClearAll();
        ContractTestLibrary.CreateServiceObjectForGLAccount(ServiceObject, GLAccount);
        ServiceObject.TestField(Type, ServiceObject.Type::"G/L Account");
        ServiceObject.TestField("Source No.", GLAccount."No.");
        ServiceObject.TestField(Description, GLAccount.Name);
        ServiceObject.TestField(Quantity, 1);
    end;

    [Test]
    procedure UT_CheckServiceObjectQtyCannotBeBlank()
    var
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        asserterror ServiceObject.Validate(Quantity, 0);
    end;

    [Test]
    procedure UT_CheckServiceObjectQtyForSerialNo()
    var
        Item: Record Item;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, true);

        ServiceObject.TestField(Quantity, 1);
        ServiceObject.Validate("Serial No.", 'S1');
        Commit(); // retain data after asserterror

        asserterror ServiceObject.Validate(Quantity, 2);
        ServiceObject.Validate("Serial No.", '');
        ServiceObject.Validate(Quantity, 2);
        asserterror ServiceObject.Validate("Serial No.", 'S2');
    end;

    [Test]
    procedure UT_CheckTransferDefaultsFromContactToServiceObject()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateContactsWithCustomerAndGetContactPerson(Contact, Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Validate("End-User Contact No.", Contact."No.");
        ServiceObject.TestField("End-User Customer No.", Customer."No.");
        ServiceObject.TestField("End-User Customer Name", Customer.Name);
    end;

    [Test]
    procedure UT_CheckTransferDefaultsFromCustomerToServiceObject()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        ServiceObject: Record "Subscription Header";
    begin
        Initialize();

        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, '');
        ServiceObject.SetHideValidationDialog(true);

        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.TestField("End-User Customer No.", Customer."No.");
        ServiceObject.Validate("Bill-to Name", Customer2.Name);
        ServiceObject.TestField("Bill-to Customer No.", Customer2."No.");
    end;

    [Test]
    procedure UT_ExpectItemDescriptionWhenCreateServiceObjectWithoutEndUser()
    var
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] When Create Subscription Without End User and add Item with translation, Item Description in Subscription should not be translated
        Initialize();

        // [GIVEN] Create: Language, Subscription Item with translation defined
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemTranslation(ItemTranslation, Item."No.", '');

        // [WHEN] Create Subscription without End User
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);

        // [THEN] Item Description should not be translated in Subscription
        Assert.AreEqual(Item.Description, ServiceObject.Description, 'Item description should not be translated in Service Object');
    end;

    [Test]
    procedure UT_ExpectTranslatedItemDescriptionBasedOnCustomerLanguageCodeWhenCreateServiceObjectWithEndUser()
    var
        Customer: Record Customer;
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        ServiceObject: Record "Subscription Header";
    begin
        // [SCENARIO] When Create Subscription With End User and add Item with translation defined that match Customer Language Code, Item Description in Subscription should be translated
        Initialize();

        // [GIVEN] Create: Language, Subscription Item with translation defined, Customer with Language Code, Subscription with End User
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemTranslation(ItemTranslation, Item."No.", '');
        LibrarySales.CreateCustomer(Customer);
        Customer."Language Code" := ItemTranslation."Language Code";
        Customer.Modify(false);
        MockServiceObjectWithEndUserCustomerNo(ServiceObject, Customer."No.");

        // [WHEN] add Item in Subscription
        ServiceObject.Validate(Type, Enum::"Service Object Type"::Item);
        ServiceObject.Validate("Source No.", Item."No.");
        ServiceObject.Modify(false);

        // [THEN] Item Description should be translated in Subscription
        Assert.AreEqual(ItemTranslation.Description, ServiceObject.Description, 'Item description should be translated in Service Object');
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Object Test");
        LibraryVariableStorage.AssertEmpty();

        if IsInitialized then
            exit;

        ContractTestLibrary.InitContractsApp();
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Object Test");
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        ContractTestLibrary.EnableNewPricingExperience();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Service Object Test");
    end;

    local procedure AddNewServiceCommPackageLine(InitialTermDateFormulaText: Text; ExtensionTermDateFormulaText: Text; NoticePeriodDateFormulaText: Text; ServiceCommitmentTemplateCode: Code[20]; ServiceCommitmentPackageCode: Code[20]; var ServiceCommPackageLine: Record "Subscription Package Line")
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackageCode, ServiceCommitmentTemplateCode, ServiceCommPackageLine);
        ModifyCurrentServiceCommPackageLine(InitialTermDateFormulaText, ExtensionTermDateFormulaText, NoticePeriodDateFormulaText, ServiceCommPackageLine);
    end;

    local procedure CreateCustomerSalesPrice(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; Quantity: Decimal; CustomerPrice: Decimal; var PriceListLine: Record "Price List Line")
    var
        PriceListHeader: Record "Price List Header";
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::Customer, SourceCustomer."No.");
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Allow Updating Defaults" := true;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);

        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, SourceItem."No.");
        PriceListLine.Validate("Starting Date", StartingDate);
        PriceListLine.Validate("Minimum Quantity", Quantity);
        PriceListLine."Currency Code" := '';
        PriceListLine.Validate("Unit Price", CustomerPrice);
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Modify(true);
    end;

    local procedure CreateCustomerSalesPrice(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; Quantity: Decimal; CustomerPrice: Decimal; EndingDate: Date)
    var
        PriceListLine: Record "Price List Line";
    begin
        CreateCustomerSalesPrice(SourceItem, SourceCustomer, StartingDate, Quantity, CustomerPrice, PriceListLine);
        PriceListLine.Status := "Price Status"::Draft;
        PriceListLine.Validate("Ending Date", EndingDate);
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Modify(true);
    end;

    local procedure CreateCustomerSalesPriceWithVariantCode(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; Quantity: Decimal; CustomerPrice: Decimal; EndingDate: Date; VariantCode: Code[10])
    begin
        CreateCustomerSalesPriceWithVariantCode(SourceItem, SourceCustomer, StartingDate, EndingDate, Quantity, CustomerPrice, VariantCode);
    end;

    local procedure CreateCustomerSalesPriceWithVariantCode(SourceItem: Record Item; SourceCustomer: Record Customer; StartingDate: Date; EndingDate: Date; Quantity: Decimal; CustomerPrice: Decimal; VariantCode: Code[10])
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::Customer, SourceCustomer."No.");
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Allow Updating Defaults" := true;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);

        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, SourceItem."No.");
        PriceListLine.Validate("Starting Date", StartingDate);
        PriceListLine.Validate("Ending Date", EndingDate);

        PriceListLine."Asset Type" := PriceListLine."Asset Type"::Item;
        PriceListLine."Product No." := SourceItem."No.";

        PriceListLine."Currency Code" := '';
        PriceListLine.Validate("Variant Code", VariantCode);
        PriceListLine.Validate("Unit Price", CustomerPrice);
        PriceListLine.Validate("Minimum Quantity", Quantity);
        PriceListLine.Status := "Price Status"::Active;
        PriceListLine.Modify(true);
    end;

    local procedure CreatePriceListForCustomer(CustomerNo: Code[20]; NewUnitPrice: Decimal; ItemNo: Code[20])
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::Customer, CustomerNo);
        PriceListHeader.Status := "Price Status"::Active;
        PriceListHeader."Currency Code" := '';
        PriceListHeader.Modify(true);
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, ItemNo);
        PriceListLine.Validate("Unit Price", NewUnitPrice);
        PriceListLine.Modify(true);
    end;

    local procedure FindServiceCommitment(var ServiceCommitmentLine: Record "Subscription Line"; ServiceObjectNo: Code[20])
    begin
        ServiceCommitmentLine.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitmentLine.FindFirst();
    end;

    local procedure GetCancellationPossibleUntilDate(StartDate: Date; InitialTermDateFormula: DateFormula; ExtensionTermDateFormula: DateFormula; NoticePeriodDateFormula: DateFormula) CancellationPossibleUntil: Date
    var
        NegativeDateFormula: DateFormula;
        DateFormulaLbl: Label '-%1', Locked = true;
    begin
        if Format(ExtensionTermDateFormula) = '' then
            exit;
        if Format(NoticePeriodDateFormula) = '' then
            exit;
        if Format(InitialTermDateFormula) = '' then
            exit;

        if StartDate = 0D then
            Error(NoStartDateErr);
        CancellationPossibleUntil := CalcDate(InitialTermDateFormula, StartDate);
        Evaluate(NegativeDateFormula, StrSubstNo(DateFormulaLbl, NoticePeriodDateFormula));
        CancellationPossibleUntil := CalcDate(NegativeDateFormula, CancellationPossibleUntil);
        CancellationPossibleUntil := CalcDate('<-1D>', CancellationPossibleUntil);
    end;

    local procedure GetTermUntilDate(StartDate: Date; EndDate: Date; InitialTermDateFormula: DateFormula; ExtensionTermDateFormula: DateFormula; NoticePeriodDateFormula: DateFormula) TermUntil: Date
    begin
        if EndDate <> 0D then begin
            TermUntil := EndDate;
            exit;
        end;

        if Format(ExtensionTermDateFormula) = '' then
            exit;
        if (Format(NoticePeriodDateFormula) = '') and (Format(InitialTermDateFormula) = '') then
            exit;

        if StartDate = 0D then
            Error(NoStartDateErr);
        if Format(InitialTermDateFormula) <> '' then begin
            TermUntil := CalcDate(InitialTermDateFormula, StartDate);
            TermUntil := CalcDate('<-1D>', TermUntil);
        end else begin
            TermUntil := CalcDate(NoticePeriodDateFormula, StartDate);
            TermUntil := CalcDate('<-1D>', TermUntil);
        end;
    end;

    local procedure GetUpdatedCancellationPossibleUntilDate(CalculationStartDate: Date; SourceServiceCommitment: Record "Subscription Line") CancellationPossibleUntil: Date
    var
        CalendarManagement: Codeunit "Calendar Management";
        DateTimeManagement: Codeunit "Date Time Management";
        NegativeDateFormula: DateFormula;
    begin
        if SourceServiceCommitment.IsNoticePeriodEmpty() then
            exit(0D);
        CalendarManagement.ReverseDateFormula(NegativeDateFormula, SourceServiceCommitment."Notice Period");
        CancellationPossibleUntil := CalcDate(NegativeDateFormula, CalculationStartDate);
        if DateTimeManagement.IsLastDayOfMonth(SourceServiceCommitment."Term Until") then
            DateTimeManagement.MoveDateToLastDayOfMonth(CancellationPossibleUntil);
    end;

    local procedure GetUpdatedTermUntilDate(CalculationStartDate: Date; SourceServiceCommitment: Record "Subscription Line") TermUntil: Date
    begin
        if (Format(SourceServiceCommitment."Extension Term") = '') or (CalculationStartDate = 0D) then
            exit(0D);
        TermUntil := CalcDate(SourceServiceCommitment."Extension Term", CalculationStartDate);
    end;

    local procedure MockServiceObjectWithEndUserCustomerNo(var ServiceObject: Record "Subscription Header"; CustomerNo: Code[20])
    begin
        ServiceObject.Init();
        ServiceObject.Validate("End-User Customer No.", CustomerNo);
        ServiceObject.Insert(true);
    end;

    local procedure ModifyCurrentServiceCommPackageLine(InitialTermDateFormulaText: Text; ExtensionTermDateFormulaText: Text; NoticePeriodDateFormulaText: Text; var ServiceCommPackageLine: Record "Subscription Package Line")
    begin
        if InitialTermDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Initial Term", InitialTermDateFormulaText);
        if ExtensionTermDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Extension Term", ExtensionTermDateFormulaText);
        if NoticePeriodDateFormulaText <> '' then
            Evaluate(ServiceCommPackageLine."Notice Period", NoticePeriodDateFormulaText);
        if (InitialTermDateFormulaText <> '') or (ExtensionTermDateFormulaText <> '') or (NoticePeriodDateFormulaText <> '') then
            ServiceCommPackageLine.Modify(false);
    end;

    local procedure SetupServiceObjectTemplatePackageAndAssignItemToPackage(var ServiceCommitmentTemplateCode: Code[20]; var ServiceObject: Record "Subscription Header"; var ServiceCommitmentPackage: Record "Subscription Package"; var ServiceCommPackageLine: Record "Subscription Package Line")
    var
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
    begin
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject.SetHideValidationDialog(true);
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplateCode, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentTemplateCode := ServiceCommitmentTemplate.Code;
    end;

    local procedure SetupServiceObjectWithServiceCommitment(var Item: Record Item; var ServiceObject: Record "Subscription Header"; SNSpecificTracking: Boolean; CreateWithAdditionalVendorServCommLine: Boolean)
    begin
        if CreateWithAdditionalVendorServCommLine then
            ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 1)
        else
            ContractTestLibrary.CreateServiceObjectForItemWithServiceCommitments(ServiceObject, Enum::"Invoicing Via"::Contract, SNSpecificTracking, Item, 1, 0);
        ServiceObject.SetHideValidationDialog(true);
    end;

    local procedure TestCalculationBaseAmount(ServiceObjectQuantity: Decimal; ReferenceDate: Date; ExpectedPrice: Decimal; var ServiceObject: Record "Subscription Header"; var ServiceCommitmentPackage: Record "Subscription Package")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceObject.Validate(Quantity, ServiceObjectQuantity);
        ServiceObject.Modify(false);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ReferenceDate, ServiceCommitmentPackage);
        FindServiceCommitment(ServiceCommitment, ServiceObject."No.");
        ServiceCommitment.FindFirst();
        ServiceCommitment.TestField("Calculation Base Amount", ExpectedPrice);
        ServiceCommitment.DeleteAll(false);
    end;

    local procedure TestServiceCommitmentTerminationDates(ServiceAndCalculationStartDate: Date; SourceServiceCommitment: Record "Subscription Line")
    var
        ExpectedDate: Date;
    begin
        if Format(SourceServiceCommitment."Initial Term") <> '' then
            ExpectedDate := GetCancellationPossibleUntilDate(ServiceAndCalculationStartDate, SourceServiceCommitment."Initial Term", SourceServiceCommitment."Extension Term", SourceServiceCommitment."Notice Period")
        else
            ExpectedDate := GetUpdatedCancellationPossibleUntilDate(SourceServiceCommitment."Term Until", SourceServiceCommitment);
        Assert.AreEqual(ExpectedDate, SourceServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
        ExpectedDate := GetTermUntilDate(ServiceAndCalculationStartDate, SourceServiceCommitment."Subscription Line End Date", SourceServiceCommitment."Initial Term", SourceServiceCommitment."Extension Term", SourceServiceCommitment."Notice Period");
        Assert.AreEqual(ExpectedDate, SourceServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');
    end;

    local procedure TestServiceCommitmentUpdatedTerminationDates(ServiceCommitment2: Record "Subscription Line"; SourceServiceCommitment: Record "Subscription Line"; ServiceCommitment: Record "Subscription Line")
    var
        ExpectedDate: Date;
    begin
        ExpectedDate := GetUpdatedTermUntilDate(ServiceCommitment2."Term Until", SourceServiceCommitment);
        Assert.AreEqual(ExpectedDate, SourceServiceCommitment."Term Until", '"Term Until" Date is not calculated correctly.');
        ExpectedDate := GetUpdatedCancellationPossibleUntilDate(SourceServiceCommitment."Term Until", ServiceCommitment);
        Assert.AreEqual(ExpectedDate, SourceServiceCommitment."Cancellation Possible Until", '"Cancellation Possible Until" Date is not calculated correctly.');
    end;

    local procedure ValidateServiceDateCombination(StartDate: Date; EndDate: Date; NextCalcDate: Date; ServiceObjectNo: Code[20])
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        FindServiceCommitment(ServiceCommitment, ServiceObjectNo);
        Clear(ServiceCommitment."Subscription Line Start Date");
        Clear(ServiceCommitment."Subscription Line End Date");
        Clear(ServiceCommitment."Next Billing Date");
        ServiceCommitment."Subscription Line Start Date" := StartDate;
        ServiceCommitment."Subscription Line End Date" := EndDate;
        ServiceCommitment."Next Billing Date" := NextCalcDate;
        ServiceCommitment.Validate("Subscription Line End Date");
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

    [ModalPageHandler]
    procedure ServiceObjectAttributeValueEditorModalPageHandlerExpectErrorOnPrimary(var ServiceObjectAttributeValueEditor: TestPage "Serv. Object Attr. Values")
    begin
        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.First();
        asserterror ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.SetValue(true);
    end;

    [ModalPageHandler]
    procedure ServiceObjectAttributeValueEditorModalPageHandlerTestValues(var ServiceObjectAttributeValueEditor: TestPage "Serv. Object Attr. Values")
    var
        ItemAttribute: array[2] of Record "Item Attribute";
        ItemAttributeValue: array[2] of Record "Item Attribute Value";
    begin
        ItemAttribute[1].Get(LibraryVariableStorage.DequeueInteger());
        ItemAttribute[2].Get(LibraryVariableStorage.DequeueInteger());
        ItemAttributeValue[1].Get(ItemAttribute[1].ID, LibraryVariableStorage.DequeueInteger());
        ItemAttributeValue[2].Get(ItemAttribute[2].ID, LibraryVariableStorage.DequeueInteger());

        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.First();
        Assert.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList."Attribute Name".Value, ItemAttribute[1].Name, 'Unexpected Service Object Attribute Name');
        Assert.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Value.Value, ItemAttributeValue[1].Value, 'Unexpected Service Object Attribute Value');
        Assert.IsFalse(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.AsBoolean(), 'Unexpected Service Object Attribute Primary value');
        ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Next();
        Assert.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList."Attribute Name".Value, ItemAttribute[2].Name, 'Unexpected Service Object Attribute Name');
        Assert.AreEqual(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Value.Value, ItemAttributeValue[2].Value, 'Unexpected Service Object Attribute Value');
        Assert.IsTrue(ServiceObjectAttributeValueEditor.ServiceObjectAttributeValueList.Primary.AsBoolean(), 'Unexpected Service Object Attribute Primary value');
    end;

    #endregion Handlers
}
