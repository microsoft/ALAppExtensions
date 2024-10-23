namespace Microsoft.SubscriptionBilling;

using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;

codeunit 148158 "Link Subscription To SO Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestConnectSubscriptiontoExistingServiceCommitment()
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetRange("Supplier Reference Entry No.", 0);
        asserterror ServiceCommitment.FindFirst();
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestConnectSubscriptiontoNewServiceCommitment()
    var
        PreviousNoOfContractLines: Integer;
        PreviousNoOfStandardContractLines: Integer;
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        //Update each Service Commitment to have Service End Date = Today()
        //In order to avoid missinterpretations in Closing of service commitments were Today() is used as reference date
        ServiceCommitment.Reset();
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.ModifyAll("Service End Date", CalcDate('<1D>', Today()), false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ContractTestLibrary.CreateVendorContractAndCreateContractLines(VendorContract, ServiceObject, '');
        ServiceCommitment.Reset();
        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Service End Date", '%1|>=%2', 0D, Today());//=UsageDataSubscription."Connect to SO at Date"
        PreviousNoOfContractLines := ServiceCommitment.Count();
        SetPreviousNoOfStandardContractLines(PreviousNoOfStandardContractLines);

        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");
        UsageBasedBillingMgmt.ConnectSubscriptionToServiceObjectWithNewServiceCommitments(UsageDataSubscription);

        Assert.AreEqual(PreviousNoOfContractLines, GetNumberOfCustomerContractLines(true), 'Contract Lines were not closed properly.');
        Assert.AreEqual(PreviousNoOfStandardContractLines, GetNumberOfCustomerContractLines(false), 'Contract Lines were not extended properly.');

        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange(Closed, false);
        CustomerContractLine.FindSet();
        repeat
            CustomerContractLine.GetServiceCommitment(ServiceCommitment);
            ServiceCommitment.TestField("Supplier Reference Entry No.");
        until CustomerContractLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ExpectErrorOnAssignServiceObjectWithoutCustomerToUsageDataSubscription()
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        asserterror ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestResetProcessingStatusOnUsageDataSubscription()
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.ResetProcessingStatus(UsageDataSubscription);

        TestUsageDataSubscriptionProcessingStatus(UsageDataImport."Supplier No.", Enum::"Processing Status"::None);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure ExpectErrorOnConnectSOToSubscriptionWithoutServiceObject()
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription."Connect to SO Method" := Enum::"Connect To SO Method"::"Existing Service Commitments";
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
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();
        Item.Blocked := true;
        Item.Modify(false);

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"New Service Commitments");

        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageBasedBillingMgmt.ConnectSubscriptionsToServiceObjects(UsageDataSubscription);

        TestUsageDataSubscriptionProcessingStatus(UsageDataImport."Supplier No.", Enum::"Processing Status"::Error);
    end;

    [Test]
    [HandlerFunctions('ExchangeRateSelectionModalPageHandler,MessageHandler,ConfirmHandler')]
    procedure TestDisconnectServiceCommitmentsFromUsageDataSubscription()
    var
        ReferenceToBeRemoved: Integer;
    begin
        ResetAll();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        SetupUsageDataForProcessingToGenericImport();

        ContractTestLibrary.CreateCustomer(Customer);
        CreateServiceObjectWithServiceCommitments();

        ContractTestLibrary.CreateCustomerContractAndCreateContractLines(CustomerContract, ServiceObject, Customer."No.");
        ValidateUsageDataSubscriptionConnectToServiceObject(Enum::"Connect To SO Method"::"Existing Service Commitments");
        UsageBasedBillingMgmt.ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(UsageDataSubscription);

        FilterServiceCommOnServiceObjectAndPartner(ServiceObject."No.", "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Supplier Reference Entry No.", '<>%1', 0);
        ServiceCommitment.FindFirst();
        ReferenceToBeRemoved := ServiceCommitment."Supplier Reference Entry No.";

        UsageBasedBillingMgmt.DisconnectServiceCommitmentFromSubscription(ServiceCommitment);
        Commit(); // retain data after asserterror
        ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
        ServiceCommitment.SetRange("Supplier Reference Entry No.", ReferenceToBeRemoved);
        asserterror ServiceCommitment.FindSet();

        UsageDataSubscription.Reset();
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ReferenceToBeRemoved);
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription.TestField("Service Object No.", '');
            UsageDataSubscription.TestField("Service Commitment Entry No.", 0);
        until UsageDataSubscription.Next() = 0;
    end;

    procedure SetupUsageDataForProcessingToGenericImport()
    begin
        UsageBasedBTestLibrary.ResetUsageBasedRecords();
        UsageBasedBTestLibrary.CreateUsageDataSupplier(UsageDataSupplier, Enum::"Usage Data Supplier Type"::Generic, true, Enum::"Vendor Invoice Per"::Import);
        UsageBasedBTestLibrary.CreateGenericImportSettings(GenericImportSettings, UsageDataSupplier."No.", true, true);
        UsageBasedBTestLibrary.CreateUsageDataImport(UsageDataImport, UsageDataSupplier."No.");
        RecordRef.GetTable(UsageDataGenericImport);
        SetupDataExchangeDefinition();
        UsageBasedBTestLibrary.ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDef.Code, GenericImportSettings);
        CreateMultipleUsageDataBlobFiles();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Imported Lines";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Process Imported Lines";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Generic Usage Data Import", UsageDataImport);
    end;

    local procedure SetupDataExchangeDefinition()
    begin
        UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UsageBasedBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
    end;

    local procedure CreateMultipleUsageDataBlobFiles()
    begin
        for i := 1 to 5 do begin
            UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
            UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RecordRef, ServiceObject."No.", ServiceCommitment."Entry No.");
        end;
    end;

    procedure SetupItemWithMultipleServiceCommitmentPackages()
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Usage Based Billing" := true;
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
        ContractTestLibrary.AssignItemToServiceCommitmentPackage(Item, ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Get(Item."No.", ServiceCommitmentPackage.Code);
        ItemServCommitmentPackage.Standard := true;
        ItemServCommitmentPackage.Modify(false);

        //Additional Service Commitment Package
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

    local procedure ValidateUsageDataSubscriptionConnectToServiceObject(ConnectToSOMethod: Enum "Connect To SO Method")
    begin
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, UsageDataImport."Supplier No.");
        UsageDataSubscription.FindSet();
        repeat
            UsageDataSubscription.Validate("Customer No.", Customer."No.");
            UsageDataSubscription.Validate("Connect to Service Object No.", ServiceObject."No.");
            UsageDataSubscription.Validate("Connect to SO Method", ConnectToSOMethod);
            UsageDataSubscription."Connect to SO at Date" := Today();
            UsageDataSubscription.Modify(false);
        until UsageDataSubscription.Next() = 0;
    end;

    local procedure FilterUsageDataSubscriptionOnSupplier(var SourceUsageDataSubscription: Record "Usage Data Subscription"; SupplierNo: Code[20])
    begin
        SourceUsageDataSubscription.Reset();
        SourceUsageDataSubscription.SetRange("Supplier No.", SupplierNo);
    end;

    local procedure TestUsageDataSubscriptionProcessingStatus(SupplierNo: Code[20]; NewProcessingStatus: Enum "Processing Status")
    begin
        FilterUsageDataSubscriptionOnSupplier(UsageDataSubscription, SupplierNo);
        if UsageDataSubscription.FindSet() then
            repeat
                UsageDataSubscription.TestField("Processing Status", NewProcessingStatus);
            until UsageDataSubscription.Next() = 0;
    end;

    local procedure GetNumberOfCustomerContractLines(FilterClosed: Boolean): Integer
    var
        CustContractLines: Record "Customer Contract Line";
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        CustomerContractLine.SetRange(Closed, FilterClosed);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                if ServiceCommitment."Usage Based Billing" then begin
                    CustContractLines.Get(CustomerContractLine."Contract No.", CustomerContractLine."Line No.");
                    CustContractLines.Mark(true);
                end;
            until CustomerContractLine.Next() = 0;
        CustContractLines.MarkedOnly(true);
        exit(CustContractLines.Count());
    end;

    local procedure CreateServiceObjectWithServiceCommitments()
    begin
        ContractTestLibrary.CreateServiceObjectWithItem(ServiceObject, Item, false);
        ServiceObject."Provision End Date" := 0D;
        ServiceObject.Validate("End-User Customer No.", Customer."No.");
        ServiceObject.Modify(false);
    end;

    local procedure FilterServiceCommOnServiceObjectAndPartner(ServiceObjectNo: Code[20]; ServicePartner: Enum "Service Partner")
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetRange("Usage Based Billing", true);
        ServiceCommitment.SetRange(Partner, ServicePartner);
    end;

    local procedure SetPreviousNoOfStandardContractLines(var PreviousNoOfStandardContractLines: Integer)
    begin
        ServiceCommitment.FindSet();
        repeat
            ItemServCommitmentPackage.Get(Item."No.", ServiceCommitment."Package Code");
            if ItemServCommitmentPackage.Standard then
                PreviousNoOfStandardContractLines += 1;
        until ServiceCommitment.Next() = 0;
    end;

    local procedure ResetAll()
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

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure ExchangeRateSelectionModalPageHandler(var ExchangeRateSelectionPage: TestPage "Exchange Rate Selection")
    begin
        ExchangeRateSelectionPage.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Contract";
        UsageDataSubscription: Record "Usage Data Subscription";
        UsageDataSupplier: Record "Usage Data Supplier";
        GenericImportSettings: Record "Generic Import Settings";
        UsageDataImport: Record "Usage Data Import";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        Item: Record Item;
        ServiceCommitmentTemplate: Record "Service Commitment Template";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        DataExchDef: Record "Data Exch. Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        CustomerContractLine: Record "Customer Contract Line";
        VendorContract: Record "Vendor Contract";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        UsageBasedBillingMgmt: Codeunit "Usage Based Billing Mgmt.";
        RecordRef: RecordRef;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        i: Integer;
}
