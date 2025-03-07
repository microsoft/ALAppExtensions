namespace Microsoft.SubscriptionBilling;

using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;

codeunit 148158 "Link Subscription To SO Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchDef: Record "Data Exch. Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        GenericImportSettings: Record "Generic Import Settings";
        Item: Record Item;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommPackageLine: Record "Subscription Package Line";
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentTemplate: Record "Sub. Package Line Template";
        ServiceObject: Record "Subscription Header";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataImport: Record "Usage Data Import";
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplier: Record "Usage Data Supplier";
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        UsageBasedBillingMgmt: Codeunit "Usage Based Billing Mgmt.";
        RecordRef: RecordRef;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;

    #region Tests

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ExpectErrorOnAssignServiceObjectWithoutCustomerToUsageDataSubscription()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        asserterror ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure ExpectErrorOnConnectSOToSubscriptionWithoutServiceObject()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription."Connect to Sub. Header Method" := Enum::"Connect To SO Method"::"Existing Service Commitments";
            UsageDataSubscription.Modify(false);
        until UsageDataSubscription.Next() = 0;

        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        TestUsageDataSubscriptionProcessingStatus(UsageDataImport."Supplier No.", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure ExpectErrorOnConnectSOToSubscriptionWithBlockedSOItem()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();
        Item.Blocked := true;
        Item.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");

        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        TestUsageDataSubscriptionProcessingStatus(UsageDataImport."Supplier No.", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestConnectSubscriptionToExistingServiceCommitment()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);
        FindUsageDataGenericImportUpdated();

        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetRange("Supplier Reference Entry No.", 0);
        Assert.RecordIsEmpty(ServiceCommitment);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestConnectSubscriptionToNewServiceCommitment()
    var
        PreviousNoOfContractLines: Integer;
        PreviousNoOfStandardContractLines: Integer;
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        // Update each Subscription Line to have Subscription Line End Date = Today()
        // In order to avoid misinterpretations in Closing of Subscription Lines were Today() is used as reference date
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.ModifyAll("Subscription Line End Date", CalcDate('<1D>', Today()), false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ContractTestLibrary.CreateVendorContractAndCreateContractLinesForItems(VendorContract, ServiceObject, '');
        ServiceCommitment.Reset();
        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Subscription Line End Date", '%1|>=%2', 0D, Today()); // =UsageDataSubscription."Connect to SO at Date"
        PreviousNoOfContractLines := ServiceCommitment.Count();
        SetPreviousNoOfStandardContractLines(PreviousNoOfStandardContractLines);

        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");
        UsageBasedBillingMgmt.ConnectSubscriptionToServiceObjectWithNewServiceCommitments(UsageDataSubscription);
        FindUsageDataGenericImportUpdated();

        Assert.AreEqual(PreviousNoOfContractLines, GetNumberOfCustomerContractLines(true), 'Contract Lines were not closed properly.');
        Assert.AreEqual(PreviousNoOfStandardContractLines, GetNumberOfCustomerContractLines(false), 'Contract Lines were not extended properly.');

        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange(Closed, false);
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.GetServiceCommitment(ServiceCommitment);
            ServiceCommitment.TestField("Supplier Reference Entry No.");
        until CustomerContractLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestDisconnectServiceCommitmentsFromUsageDataSubscription()
    var
        ReferenceToBeRemoved: Integer;
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
        UsageBasedBillingMgmt.ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(UsageDataSubscription);

        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Supplier Reference Entry No.", '<>%1', 0);
        ServiceCommitment.FindFirst();
        ReferenceToBeRemoved := ServiceCommitment."Supplier Reference Entry No.";

        UsageBasedBillingMgmt.DisconnectServiceCommitmentFromSubscription(ServiceCommitment);
        Commit(); // retain data after asserterror
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Supplier Reference Entry No.", ReferenceToBeRemoved);
        Assert.RecordIsEmpty(ServiceCommitment);

        UsageDataSubscription.Reset();
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ReferenceToBeRemoved);
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription.TestField("Subscription Header No.", '');
            UsageDataSubscription.TestField("Subscription Line Entry No.", 0);
        until UsageDataSubscription.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestResetProcessingStatusOnUsageDataSubscription()
    begin
        Initialize();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLinesForItems(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.ResetProcessingStatus(UsageDataSubscription);

        TestUsageDataSubscriptionProcessingStatus(UsageDataImport."Supplier No.", Enum::"Processing Status"::None);
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();
        ServiceCommitmentTemplate.Reset();
        ServiceCommitmentTemplate.DeleteAll(false);
        ServiceCommitmentPackage.Reset();
        ServiceCommitmentPackage.DeleteAll(false);
        ServiceCommPackageLine.Reset();
        ServiceCommPackageLine.DeleteAll(false);
        ItemServCommitmentPackage.Reset();
        ItemServCommitmentPackage.DeleteAll(false);
        ContractTestLibrary.InitContractsApp();
    end;

    local procedure CreateMultipleUsageDataBlobFiles()
    var
        i: Integer;
    begin
        for i := 1 to 5 do begin
            UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
            UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RecordRef, ServiceObject."No.", ServiceCommitment."Entry No.");
        end;
    end;

    local procedure CreateServiceObjectWithServiceCommitments()
    begin
        ContractTestLibrary.CreateServiceObjectForItem(ServiceObject, Item, false);
        ServiceObject."Provision End Date" := 0D;
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
    end;

    local procedure FilterUsageDataSubscriptionOnSupplier(var SourceUsageDataSubscription: Record "Usage Data Supp. Subscription"; SupplierNo: Code[20])
    begin
        SourceUsageDataSubscription.Reset();
        SourceUsageDataSubscription.SetRange("Supplier No.", SupplierNo);
    end;

    local procedure FilterServiceCommOnServiceObjectAndPartner(ServiceObjectNo: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Usage Based Billing", true);
        ServiceCommitment.SetRange(Partner, ServicePartner);
    end;

    local procedure FindUsageDataGenericImportUpdated()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        UsageDataGenericImport.SetRange("Supp. Subscription ID", UsageDataSubscription."Supplier Reference");
        UsageDataGenericImport.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        UsageDataGenericImport.SetRange("Service Object Availability", UsageDataGenericImport."Service Object Availability"::Connected);
        UsageDataGenericImport.FindFirst();
    end;

    local procedure GetNumberOfCustomerContractLines(FilterClosed: Boolean): Integer
    var
        CustContractLines: Record "Cust. Sub. Contract Line";
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange(Closed, FilterClosed);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                if ServiceCommitment."Usage Based Billing" then begin
                    CustContractLines.Get(CustomerContractLine."Subscription Contract No.", CustomerContractLine."Line No.");
                    CustContractLines.Mark(true);
                end;
            until CustomerContractLine.Next() = 0;
        CustContractLines.MarkedOnly(true);
        exit(CustContractLines.Count());
    end;

    local procedure SetupUsageDataForProcessingToGenericImport()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        UsageBasedBTestLibrary.DeleteAllUsageBasedRecords();
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, true, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RecordRef.GetTable(UsageDataGenericImport);
        SetupDataExchangeDefinition();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        CreateMultipleUsageDataBlobFiles();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Imported Lines";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Process Imported Lines";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Import And Process Usage Data", UsageDataImport);
    end;

    local procedure SetupDataExchangeDefinition()
    begin
        UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UsageBasedBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
    end;

    local procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Usage Based Billing" := true;
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
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);

        // Additional Subscription Package
        ContractTestLibrary.CreateServiceCommitmentPackageWithLine(ServiceCommitmentTemplate.Code, ServiceCommitmentPackage, ServiceCommPackageLine);
        ServiceCommPackageLine.Partner := Enum::"Service Partner"::Customer;
        Evaluate(ServiceCommPackageLine."Extension Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Notice Period", '<1M>');
        Evaluate(ServiceCommPackageLine."Initial Term", '<1Y>');
        Evaluate(ServiceCommPackageLine."Billing Rhythm", '<1M>');
        ServiceCommPackageLine.Modify(false);
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);
    end;

    local procedure SetPreviousNoOfStandardContractLines(var PreviousNoOfStandardContractLines: Integer)
    begin
        ServiceCommitment.FindSet();
        repeat
            ItemServCommitmentPackage.Get(Item."No.", ServiceCommitment."Subscription Package Code");
            if ItemServCommitmentPackage.Standard then
                PreviousNoOfStandardContractLines += 1;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure TestUsageDataSubscriptionProcessingStatus(SupplierNo: Code[20]; NewProcessingStatus: Enum "Processing Status")
    begin
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, SupplierNo);
        if UsageDataSubscription.FindSet() then
            repeat
                UsageDataSubscription.TestField("Processing Status", NewProcessingStatus);
            until UsageDataSubscription.Next() = 0;
    end;

    local procedure ValidateUsageDataSubscriptionConnectToServiceObject(ConnectToSOMethod: Enum "Connect To SO Method")
    begin
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription.Validate("Customer No.", Customer."No.");
            UsageDataSubscription.Validate("Connect to Sub. Header No.", ServiceObject."No.");
            UsageDataSubscription.Validate("Connect to Sub. Header Method", ConnectToSOMethod);
            UsageDataSubscription."Connect to Sub. Header at Date" := Today();
            UsageDataSubscription.Modify(false);
        until UsageDataSubscription.Next() = 0;
    end;

    #endregion Procedures

    #region Handlers

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

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    #endregion Handlers
}
