namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Pricing;
using Microsoft.Purchases.Vendor;

codeunit 148152 "Extend Contract Test"
{
    Subtype = Test;
    Access = Internal;

    [Test]
    [HandlerFunctions('TestExtendContractModalPageHandler')]
    procedure TestContractFieldsOnOpenExtendContractFromCard()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        Item."Last Direct Cost" := LibraryRandom.RandDec(100, 2);
        Item."Unit Cost" := LibraryRandom.RandDec(100, 2);
        Item.Modify(false);
        CreateCustomerAndVendorContracts();
        InvokeExtendContractFromCustContractCard();
        CustomerContractCard.Close();
    end;

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
    procedure TestServiceObjectOnAfterExtendContractStandardPackage()
    begin
        ResetGlobals();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();
        SetupItemWithMultipleServiceCommitmentPackages();
        ServiceObjectQty := LibraryRandom.RandDec(10, 2);
        ServiceObject.InsertFromItemNoAndSelltoCustomerNo(ServiceObject, Item."No.", ServiceObjectQty, CustomerContract."Sell-to Customer No.", WorkDate());
        CheckCreatedServiceObject();

        ServiceObject.InsertServiceCommitmentsFromStandardServCommPackages(ServiceObject."Provision Start Date");
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.SetRange(Standard, true);
        ItemServCommitmentPackage.FindSet();
        repeat
            ServiceCommPackageLine.SetRange("Package Code", ItemServCommitmentPackage.Code);
            if ServiceCommPackageLine.FindFirst() then
                CheckAssignedSalesServiceCommitmentValues(ServiceCommitment, ServiceCommPackageLine);
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

        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.FindSet();
        repeat
            ServiceCommPackageLine.SetRange("Package Code", ItemServCommitmentPackage.Code);
            if ServiceCommPackageLine.FindFirst() then
                CheckAssignedSalesServiceCommitmentValues(ServiceCommitment, ServiceCommPackageLine);
        until ItemServCommitmentPackage.Next() = 0;
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
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetFilter("Contract No.", '<>%1', '');
        Assert.AreEqual(3, ServiceCommitment.Count, 'Service commitments are not assigned to contracts.');

        ItemServCommitmentPackage.Reset();
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        ItemServCommitmentPackage.SetFilter("Price Group", '<>%1', CustomerPriceGroup.Code);
        ItemServCommitmentPackage.FindFirst();
        repeat
            ServiceCommPackageLine.SetRange("Package Code", ItemServCommitmentPackage.Code);
            ServiceCommPackageLine.FindFirst();
            ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
            ServiceCommitment.SetRange(Template, ServiceCommPackageLine.Template);
            ServiceCommitment.SetRange("Package Code", ServiceCommPackageLine."Package Code");
            ServiceCommitment.FindFirst(); //Checks if Customer contract lines are created
            if ServiceCommitment.IsPartnerCustomer() then
                ServiceCommitment.TestField("Contract No.", CustomerContract."No.")
            else
                ServiceCommitment.TestField("Contract No.", VendorContract."No.");
        until ItemServCommitmentPackage.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,MessageHandler')]
    procedure ExpectNoneOfTheServiceCommitmentsToBeInContractExtension()
    begin
        //Create service commitment without standard package, only additional one
        //Extend contract without selecting any additional packages
        //Contract should not have any new lines
        ResetGlobals();
        SkipAssignAdditionalServiceCommitments := true;
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        CreateCustomerAndVendorContracts();

        //Additional Service Commitment Package
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
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Contract No.", CustomerContract."No.");
        Assert.RecordCount(ServiceCommitment, 0);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

        //Standard Service Comm. Package with two Service Comm. Package Lines
        //1. for Customer
        //2. for Vendor
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

        //Additional Service Commitment Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
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

    local procedure CheckAssignedSalesServiceCommitmentValues(var ServiceCommitmentToTest: Record "Service Commitment"; var SourceServiceCommPackageLine: Record "Service Comm. Package Line")
    begin
        ServiceCommitmentToTest.SetRange("Package Code", ItemServCommitmentPackage.Code);
        if ServiceCommitmentToTest.FindFirst() then
            repeat
                ServiceCommitmentToTest.TestField("Package Code", SourceServiceCommPackageLine."Package Code");
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
        ServiceObject.TestField("Item No.", Item."No.");
        ServiceObject.TestField("End-User Customer No.", CustomerContract."Sell-to Customer No.");
        ServiceObject.TestField("Provision Start Date", WorkDate());
        ServiceObject.TestField("Quantity Decimal", ServiceObjectQty);
        ServiceObject.TestField("Unit of Measure", Item."Base Unit of Measure");
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

    local procedure CreateCustomerAndVendorContracts()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    local procedure InvokeExtendContractFromCustContractCard()
    begin
        CustomerContractCard.OpenEdit();
        CustomerContractCard.GoToRecord(CustomerContract);
        CustomerContractCard.ExtendContract.Invoke();
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
        Assert.AreEqual(ExtendContract.UnitCostLCY.Value, Format(Item."Last Direct Cost"), 'Unit Cost was not calculated properly');
        ExtendContract.Cancel().Invoke();
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
    procedure AssignServiceCommPackagesModalPageHandler(var AssignServiceCommPackages: TestPage "Assign Service Comm. Packages")
    begin
        AssignServiceCommPackages.First();
        AssignServiceCommPackages.Selected.SetValue(true);
        AssignServiceCommPackages.OK().Invoke();
    end;

    var
        CustomerContract: Record "Customer Contract";
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        Item: Record Item;
        Customer: Record Customer;
        ServiceCommitment: Record "Service Commitment";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ServiceObject: Record "Service Object";
        VendorContract: Record "Vendor Contract";
        Vendor: Record Vendor;
        CustomerPriceGroup: Record "Customer Price Group";
        ContractTestLibrary: Codeunit "Contract Test Library";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        ServiceObjectQty: Decimal;
        CustomerContractCard: TestPage "Customer Contract";
        SkipAssignAdditionalServiceCommitments: Boolean;
}
