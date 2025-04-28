namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

codeunit 139691 "Contract Price Update Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        PriceUpdateTemplate: Record "Price Update Template";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        Confirm: Boolean;

    #region Tests

    [Test]
    procedure ExpectErrorIfUpdateValueNotZeroInCaseOfRecentItemPrices()
    begin
        ContractTestLibrary.CreatePriceUpdateTemplate(PriceUpdateTemplate, "Service Partner"::Customer, "Price Update Method"::"Price by %", LibraryRandom.RandDec(100, 2), '12M', '12M', '12M');
        asserterror PriceUpdateTemplate.Validate("Price Update Method", "Price Update Method"::"Recent Item Prices");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestExcludeFromPriceUpdateInCustomerServiceCommitments()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No."); // ExchangeRateSelectionModalPageHandler, MessageHandler
        Confirm := true;
        CustomerContract.Validate(DefaultExcludeFromPriceUpdate, true); // ConfirmHandler
        CustomerContract.Modify(false);

        ServiceCommitment.Reset();
        ServiceCommitment.FilterOnContract("Service Partner"::Customer, CustomerContract."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Exclude from Price Update", true);
        until ServiceCommitment.Next() = 0;

        Confirm := false;
        CustomerContract.Validate(DefaultExcludeFromPriceUpdate, false); // ConfirmHandler
        CustomerContract.Modify(false);

        ServiceCommitment.Reset();
        ServiceCommitment.FilterOnContract("Service Partner"::Customer, CustomerContract."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Exclude from Price Update", true);
        until ServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestExcludeFromPriceUpdateInVendorServiceCommitments()
    begin
        ClearAll();
        ContractTestLibrary.DeleteAllContractRecords();
        SetupServiceObjectWithServiceCommitment(false);
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, Vendor."No.", true);        // ExchangeRateSelectionModalPageHandler, MessageHandler
        Confirm := true;
        VendorContract.Validate(DefaultExcludeFromPriceUpdate, true); // ConfirmHandler
        VendorContract.Modify(false);

        ServiceCommitment.Reset();
        ServiceCommitment.FilterOnContract("Service Partner"::Vendor, VendorContract."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Exclude from Price Update", true);
        until ServiceCommitment.Next() = 0;

        Confirm := false;
        VendorContract.Validate(DefaultExcludeFromPriceUpdate, false); // ConfirmHandler
        VendorContract.Modify(false);

        ServiceCommitment.Reset();
        ServiceCommitment.FilterOnContract("Service Partner"::Vendor, VendorContract."No.");
        ServiceCommitment.FindSet();
        repeat
            ServiceCommitment.TestField("Exclude from Price Update", true);
        until ServiceCommitment.Next() = 0;
    end;

    #endregion Tests

    #region Procedures

    local procedure SetupServiceObjectWithServiceCommitment(SNSpecificTracking: Boolean)
    begin
        ClearAll();
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, SNSpecificTracking);
        ServiceObject.Validate("End-User Customer Name", Customer.Name);
        ServiceObject.Modify(false);

        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate.Modify(false);

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

        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ServiceCommitmentPackage.SetFilter(Code, ItemServCommitmentPackage.GetPackageFilterForItem(ServiceObject."Source No."));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(WorkDate(), ServiceCommitmentPackage);
    end;

    #endregion Procedures

    #region Handlers

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := Confirm;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    #endregion Handlers
}
