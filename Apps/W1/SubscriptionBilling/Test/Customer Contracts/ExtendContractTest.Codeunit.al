namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Pricing;
using Microsoft.Purchases.Vendor;

codeunit 148152 "Extend Contract Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerPriceGroup: Record "Customer Price Group";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        SkipAssignAdditionalServiceCommitments: Boolean;
        ServiceObjectQty: Decimal;
        CustomerContractCard: TestPage "Customer Contract";

    #region Tests

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler')]
    procedure ExpectErrorIfItemNoIsEmpty()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        CreateCustomerAndVendorContracts();
        asserterror InvokeExtendContractFromCustContractCard();
        CustomerContractCard.Close();
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,MessageHandler')]
    procedure ExpectNoneOfTheServiceCommitmentsToBeInContractExtension()
    begin
        // Create Subscription Line without standard package, only additional one
        // Extend contract without selecting any additional packages
        // Contract should not have any new lines
        ResetGlobals();
        SkipAssignAdditionalServiceCommitments := true;
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();

        // Additional Subscription Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);

        ServiceObjectQty := LibraryRandom.RandDec(10, 2);

        InvokeExtendContractFromCustContractCard();
        ServiceObject.FindLast();
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Subscription Contract No.", CustomerContract."No.");
        Assert.RecordCount(ServiceCommitment, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ExtendContractWithDifferentBillToCustomerNoAndShipToCode()
    var
        Customer2: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        // [SCENARIO] Create Customer Subscription Contract with different Bill to Customer No. and Ship-to Code
        // [SCENARIO] Run Extend Contract action and expect that the data from the Customer Subscription Contract will be transferred to newly Subscription
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN] Create two customers, additional Ship to Address and assign it to a Customer Subscription Contract
        // [GIVEN] Create Subscription Item
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateCustomer(Customer);
        LibrarySales.CreateShipToAddress(ShipToAddress, Customer."No.");

        ContractTestLibrary.CreateCustomer(Customer2);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        CustomerContract.Validate("Bill-to Customer No.", Customer2."No.");
        CustomerContract.Validate("Ship-to Code", ShipToAddress.Code);
        CustomerContract.Modify(false);
        Assert.AreEqual(Customer2."No.", CustomerContract."Bill-to Customer No.", 'Unexpected Bill-to Customer No. in Customer Subscription Contract.');
        Assert.AreEqual(ShipToAddress.Code, CustomerContract."Ship-to Code", 'Unexpected Ship-to Code in Customer Subscription Contract.');
        SetupItemWithMultipleServiceCommitmentPackages();

        // [WHEN] Call InsertFromItemNoAndCustomerContract
        ServiceObjectQty := LibraryRandom.RandDec(10, 2);
        ServiceObject.InsertFromItemNoAndCustomerContract(ServiceObject, Item."No.", ServiceObjectQty, WorkDate(), CustomerContract);

        // [THEN] Check if the data in Subscription is transferred from Customer Subscription Contract
        ServiceObject.TestField("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        ServiceObject.TestField("Ship-to Code", CustomerContract."Ship-to Code");
    end;

    [Test]
    procedure ServiceCommitmentCurrencyFactorUpdatedFromCustomerContractLineWithDifferentCurrencyCode()
    var
        Currency: Record Currency;
        MockCustomerContract: Record "Customer Subscription Contract";
        MockServiceCommitment: Record "Subscription Line";
        MockServiceObject: Record "Subscription Header";
        LibraryERM: Codeunit "Library - ERM";
        ProvisionStartDate: Date;
        ExchangeRateAmount: Decimal;
    begin
        // [SCENARIO] Check if currency factor is updated in Subscription Line, when Customer Subscription Contract Line with Different Currency Code is Created from serv. Subscription Line
        // [GIVEN] Create Dummy Subscription, Customer Subscription Contract (Currency2), Subscription Line (LCY)
        LibraryERM.CreateCurrency(Currency);
        ExchangeRateAmount := LibraryRandom.RandDec(1000, 2);
        ProvisionStartDate := LibraryRandom.RandDateFrom(WorkDate(), 12);
        LibraryERM.CreateExchangeRate(Currency.Code, ProvisionStartDate, ExchangeRateAmount, LibraryRandom.RandDec(10, 2));

        MockServiceObject.Init();
        MockServiceObject."Provision Start Date" := ProvisionStartDate;
        MockServiceObject.Insert(false);

        MockCustomerContract.Init();
        MockCustomerContract."Currency Code" := Currency.Code;
        MockCustomerContract.Insert(false);

        MockServiceCommitment.Init();
        MockServiceCommitment."Subscription Header No." := MockServiceObject."No.";
        MockServiceCommitment."Subscription Line Start Date" := MockServiceObject."Provision Start Date";
        MockServiceCommitment.Insert(false);

        // [WHEN] Create Customer Subscription Contract Line from Subscription Line
        MockCustomerContract.CreateCustomerContractLineFromServiceCommitment(MockServiceCommitment, MockCustomerContract."No.");

        // [THEN] Test if currency data is updated in Subscription Line
        MockServiceCommitment.Get(MockServiceCommitment."Entry No.");
        MockServiceCommitment.TestField("Currency Code", Currency.Code);
        MockServiceCommitment.TestField("Currency Factor", ExchangeRateAmount);
        MockServiceCommitment.TestField("Currency Factor Date", MockServiceObject."Provision Start Date");
    end;

    [Test]
    [HandlerFunctions('TestExtendContractModalPageHandler')]
    procedure TestContractFieldsOnOpenExtendContractFromCard()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Unit Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        CreateCustomerAndVendorContracts();
        InvokeExtendContractFromCustContractCard();
        CustomerContractCard.Close();
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure TestExtendCustomerContract()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();

        SetupItemWithMultipleServiceCommitmentPackages();
        SetupItemWithAdditionalServiceCommitmentPackageWithCustomerPricingGroup();
        ServiceObjectQty := LibraryRandom.RandDec(10, 2);

        InvokeExtendContractFromCustContractCard();
        ServiceObject.FindLast();
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetFilter("Subscription Contract No.", '<>%1', '');
        Assert.AreEqual(3, ServiceCommitment.Count, 'Service commitments are not assigned to contracts.');

        ItemServCommitmentPackage.Reset();
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.SetFilter("Price Group", '<>%1', CustomerPriceGroup.Code);
        ItemServCommitmentPackage.FindFirst();
        repeat
            ServiceCommPackageLine.SetRange("Subscription Package Code", ItemServCommitmentPackage.Code);
            ServiceCommPackageLine.FindFirst();
            ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
            ServiceCommitment.SetRange(Template, ServiceCommPackageLine.Template);
            ServiceCommitment.SetRange("Subscription Package Code", ServiceCommPackageLine."Subscription Package Code");
            ServiceCommitment.FindFirst(); // Checks if Customer Subscription Contract lines are created
            if ServiceCommitment.IsPartnerCustomer() then
                ServiceCommitment.TestField("Subscription Contract No.", CustomerContract."No.")
            else
                ServiceCommitment.TestField("Subscription Contract No.", VendorContract."No.");
        until ItemServCommitmentPackage.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure TestServiceObjectOnAfterExtendContractStandardAllPackages()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();
        SetupItemWithMultipleServiceCommitmentPackages();
        ServiceObjectQty := LibraryRandom.RandDec(10, 2);

        InvokeExtendContractFromCustContractCard();
        CheckCreatedServiceObject();

        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.FindSet();
        repeat
            ServiceCommPackageLine.SetRange("Subscription Package Code", ItemServCommitmentPackage.Code);
            if ServiceCommPackageLine.FindFirst() then
                CheckAssignedSalesServiceCommitmentValues(ServiceCommitment, ServiceCommPackageLine);
        until ItemServCommitmentPackage.Next() = 0;
    end;

    [Test]
    procedure TestServiceObjectOnAfterExtendContractStandardPackage()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();
        SetupItemWithMultipleServiceCommitmentPackages();
        ServiceObjectQty := LibraryRandom.RandDec(10, 2);
        ServiceObject.InsertFromItemNoAndCustomerContract(ServiceObject, Item."No.", ServiceObjectQty, WorkDate(), CustomerContract);
        CheckCreatedServiceObject();

        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(ServiceObject."Provision Start Date");
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.SetRange(Standard, true);
        ItemServCommitmentPackage.FindSet();
        repeat
            ServiceCommPackageLine.SetRange("Subscription Package Code", ItemServCommitmentPackage.Code);
            if ServiceCommPackageLine.FindFirst() then
                CheckAssignedSalesServiceCommitmentValues(ServiceCommitment, ServiceCommPackageLine);
        until ItemServCommitmentPackage.Next() = 0;
    end;

    [Test]
    procedure TranslateItemDescriptionBasedOnCustomerLanguageCodeWhenExtendContract()
    var
        ItemTranslation: Record "Item Translation";
    begin
        // [SCENARIO] When Extend Contract action is run for Item with translation defined that match Customer Language Code, Item Description in Subscription should be translated

        // [GIVEN] Create: Language, Subscription Item with translation defined, Customer with Language Code, Customer Subscription Contract
        ClearAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateItemTranslation(ItemTranslation, Item."No.", '');
        CreateCustomerWithLanguageCode(ItemTranslation."Language Code");
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        // [WHEN] Extend Contract with Item
        ServiceObject.InsertFromItemNoAndCustomerContract(ServiceObject, Item."No.", LibraryRandom.RandDec(10, 2), WorkDate(), CustomerContract);

        // [THEN] Item Description should be translated in Subscription
        Assert.AreEqual(ItemTranslation.Description, ServiceObject.Description, 'Item description should be translated in Service Object');
    end;

    [Test]
    procedure UT_GetItemTranslationFunctionReturnsBlankWhenItemNoIsBlank()
    var
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
        Result: Text[100];
    begin
        // [SCENARIO] GetItemTranslation function returns blank value whenever the Item No. is blank

        // [GIVEN]
        ResetGlobals();

        // [WHEN] GetItemTranslation function is called with blank Item No
        Result := ContractsItemManagement.GetItemTranslation('', '', '');

        // [THEN] Return value of the function GetItemTranslation is blank
        Assert.AreEqual('', Result, 'GetItemTranslation should return a blank value when Item No. is blank.');
    end;

    [Test]
    procedure UT_UpdateExistingItemDescriptionWhenSetCustomerOnExtendContract()
    var
        ItemTranslation: Record "Item Translation";
        ExtendContract: TestPage "Extend Contract";
    begin
        // [SCENARIO] When set Customer on Extend Contract with existing Item, Item Description is updated based on Customer Language Code

        // [GIVEN] Create: Language, Subscription Item with translation defined, Customer with Language Code, Customer Subscription Contract, Set Item on Extend Contract page
        ResetGlobals();

        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ContractTestLibrary.CreateItemTranslation(ItemTranslation, Item."No.", '');
        CreateCustomerWithLanguageCode(ItemTranslation."Language Code");
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");

        // [GIVEN] Setting Item on Extend Contract page first
        ExtendContract.OpenEdit();
        ExtendContract.ExtendCustomerContract.SetValue(false);
        ExtendContract.ItemNo.SetValue(Item."No.");
        ExtendContract.ItemDescription.AssertEquals(Item.Description);
        ExtendContract.Close();

        // [WHEN] Customer with Language Code is set on Extend Contract page
        ExtendContract.OpenEdit();
        ExtendContract.ExtendCustomerContract.SetValue(true);
        ExtendContract.CustomerContractNo.SetValue(CustomerContract."No.");

        // [THEN] Item Description should be updated based on Customer Language Code if exist
        ExtendContract.ItemDescription.AssertEquals(ItemTranslation.Description);
    end;

    #endregion Tests

    #region Procedures

    local procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        // Standard Subscription Package with two Subscription Package Lines
        // 1. for Customer
        // 2. for Vendor
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentPackageLine(ServiceCommitmentPackage.Code, ServiceCommitmentTemplate.Code, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Vendor;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);

        // Additional Subscription Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
    end;

    local procedure CheckAssignedSalesServiceCommitmentValues(var ServiceCommitmentToTest: Record "Subscription Line"; var SourceServiceCommPackageLine: Record "Subscription Package Line")
    begin
        ServiceCommitmentToTest.SetRange("Subscription Package Code", ItemServCommitmentPackage.Code);
        if ServiceCommitmentToTest.FindFirst() then
            repeat
                ServiceCommitmentToTest.TestField("Subscription Package Code", SourceServiceCommPackageLine."Subscription Package Code");
                ServiceCommitmentToTest.TestField(Template, SourceServiceCommPackageLine.Template);
                ServiceCommitmentToTest.TestField(Description, SourceServiceCommPackageLine.Description);
                ServiceCommitmentToTest.TestField("Invoicing via", SourceServiceCommPackageLine."Invoicing via");
                ServiceCommitmentToTest.TestField("Invoicing Item No.", Item."No.");
                ServiceCommitmentToTest.TestField("Customer Price Group", ServiceCommitmentPackage."Price Group");
                ServiceCommitmentToTest.TestField("Extension Term", SourceServiceCommPackageLine."Extension Term");
                ServiceCommitmentToTest.TestField("Notice Period", SourceServiceCommPackageLine."Notice Period");
                ServiceCommitmentToTest.TestField("Initial Term", SourceServiceCommPackageLine."Initial Term");
                ServiceCommitmentToTest.TestField("Billing Base Period", SourceServiceCommPackageLine."Billing Base Period");
                ServiceCommitmentToTest.TestField("Calculation Base %", SourceServiceCommPackageLine."Calculation Base %");
                ServiceCommitmentToTest.TestField("Billing Rhythm", SourceServiceCommPackageLine."Billing Rhythm");
            until ((ServiceCommitmentToTest.Next() = 0) and (SourceServiceCommPackageLine.Next() = 0));
    end;

    local procedure CheckCreatedServiceObject()
    begin
        ServiceObject.FindLast();
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        ServiceObject.TestField("Source No.", Item."No.");
        ServiceObject.TestField("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.TestField("Provision Start Date", WorkDate());
        ServiceObject.TestField(Quantity, ServiceObjectQty);
        ServiceObject.TestField("Unit of Measure", Item."Base Unit of Measure");
    end;

    local procedure CreateCustomerAndVendorContracts()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    local procedure CreateCustomerWithLanguageCode(LanguageCode: Text[10])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Modify(true);
    end;

    local procedure InvokeExtendContractFromCustContractCard()
    begin
        CustomerContractCard.OpenEdit();
        CustomerContractCard.GoToRecord(CustomerContract);
        CustomerContractCard.ExtendContract.Invoke();
    end;

    local procedure ResetGlobals()
    begin
        ClearAll();
        ServiceCommPackageLine.Reset();
        ServiceCommPackageLine.DeleteAll(false);
        ServiceCommitmentPackage.Reset();
        ServiceCommitmentPackage.DeleteAll(false);
        ServiceCommitmentTemplate.Reset();
        ServiceCommitmentTemplate.DeleteAll(false);
        ItemServCommitmentPackage.Reset();
        ItemServCommitmentPackage.DeleteAll(false);
    end;

    local procedure SetupItemWithAdditionalServiceCommitmentPackageWithCustomerPricingGroup()
    begin
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code, true);
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Validate("Price Group", CustomerPriceGroup.Code);
        ItemServCommitmentPackage.Modify(false);
    end;
    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure AssignServiceCommPackagesModalPageHandler(var AssignServiceCommPackages: TestPage "Assign Service Comm. Packages")
    begin
        AssignServiceCommPackages.First();
        AssignServiceCommPackages.Selected.SetValue(true);
        AssignServiceCommPackages.OK().Invoke();
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
    procedure ExtendContractModalPageHandler(var ExtendContract: TestPage "Extend Contract")
    begin
        ExtendContract.ExtendVendorContract.SetValue(true);
        ExtendContract.VendorContractNo.SetValue(VendorContract."No.");
        ExtendContract.ItemNo.SetValue(Item."No.");
        ExtendContract.Quantity.SetValue(ServiceObjectQty);
        ExtendContract.ProvisionStartDate.SetValue(WorkDate());
        if not SkipAssignAdditionalServiceCommitments then
            ExtendContract.AdditionalServiceCommitments.AssistEdit();
        ExtendContract."Perform Extension".Invoke();
    end;

    [ModalPageHandler]
    procedure TestExtendContractModalPageHandler(var ExtendContract: TestPage "Extend Contract")
    var
        PageExtendCustomerContractValue: Boolean;
        PageProvisionStartDate: Date;
    begin
        ExtendContract.ExtendVendorContract.SetValue(true);
        ExtendContract.VendorContractNo.SetValue(VendorContract."No.");
        ExtendContract.ItemNo.SetValue(Item."No.");

        Evaluate(PageExtendCustomerContractValue, ExtendContract.ExtendCustomerContract.Value);
        Evaluate(PageProvisionStartDate, ExtendContract.ProvisionStartDate.Value);
        Assert.IsTrue(PageExtendCustomerContractValue, 'Extend Contract was not initialize properly.');
        Assert.AreEqual(CustomerContract."No.", ExtendContract.CustomerContractNo.Value, 'Extend Contract was not initialize properly.');
        Assert.AreEqual(WorkDate(), PageProvisionStartDate, 'Extend Contract was not initialize properly.');
        Assert.AreEqual(CustomerContract."Sell-to Customer Name", ExtendContract."Sell-to Customer Name".Value, 'Extend Contract was not initialize properly.');
        Assert.AreEqual(ExtendContract.UnitCostLCY.Value, Format(Item."Unit Cost"), 'Unit Cost was not calculated properly');
        ExtendContract.Cancel().Invoke();
    end;

    #endregion Handlers
}
