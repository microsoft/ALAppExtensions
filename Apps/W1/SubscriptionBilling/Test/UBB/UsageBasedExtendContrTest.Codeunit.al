namespace Microsoft.SubscriptionBilling;

using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

codeunit 148159 "Usage Based Extend Contr. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    [Test]
    [HandlerFunctions('TestExtendContractModalPageHandler')]
    procedure TestUsageBasedFieldsOnOpenExtendContractFromSubscription()
    begin
        SetupUsageBasedBilling();
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure TestLinkServiceCommitmentWithUsageDataSubscription()
    begin
        SetupUsageBasedBilling();
        UsageDataSupplierReference.SetRange("Supplier No.", UsageDataSupplier."No.");
        UsageDataSupplierReference.SetRange(Type, Enum::"Usage Data Reference Type"::Subscription);
        UsageDataSupplierReference.FindSet();
        repeat
            TestIsServiceCommitmentUpdated();
            TestIsUsageDataSubscriptionUpdated();
        until UsageDataSupplierReference.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure CreateAndProcessUsageDataBilling()
    begin
        SetupUsageBasedBilling();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Usage Data Billing";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Create Usage Data Billing", UsageDataImport);
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Process Usage Data Billing";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Process Usage Data Billing", UsageDataImport);
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnExtendContractWithConnectedSubscriptionOnSelectSubscription()
    begin
        SetupUsageBasedBilling();
        asserterror InvokeExtendContractFromSubscription();
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

    local procedure CreateCustomerAndVendorContracts()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    local procedure InvokeExtendContractFromSubscription()
    begin
        UsageDataSubscription.FindFirst();
        repeat
            UsageDataSubscriptionPage.OpenEdit();
            UsageDataSubscriptionPage.GoToRecord(UsageDataSubscription);
            UsageDataSubscriptionPage.ExtendContract.Invoke();
            UsageDataSubscriptionPage.Close();
        until UsageDataSubscription.Next() = 0;
    end;

    local procedure SetupUsageBasedBilling()
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages();
        CreateCustomerAndVendorContracts();
        SetupUsageDataForProcessingToGenericImport();
        InvokeExtendContractFromSubscription();
    end;

    local procedure TestIsUsageDataSubscriptionUpdated()
    begin
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        UsageDataSubscription.SetRange("Service Object No.", ServiceCommitment."Service Object No.");
        UsageDataSubscription.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        UsageDataSubscription.FindFirst();
    end;

    local procedure CreateMultipleUsageDataBlobFiles()
    begin
        for i := 1 to 5 do begin
            UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
            UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RecordRef, ServiceObject."No.", ServiceCommitment."Entry No.");
        end;
    end;

    local procedure TestIsServiceCommitmentUpdated()
    begin
        ServiceCommitment.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        ServiceCommitment.FindFirst();
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
    end;

    [ModalPageHandler]
    procedure TestExtendContractModalPageHandler(var ExtendContract: TestPage "Extend Contract")
    begin
        AssertThat.AreEqual(UsageDataSubscription."Supplier No.", ExtendContract.UsageDataSupplierNo.Value, 'Extend Contract was not initialize properly.');
        AssertThat.AreEqual(UsageDataSubscription."Product Name", ExtendContract.SubscriptionDescription.Value, 'Extend Contract was not initialize properly.');
        ExtendContract.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure ExtendContractModalPageHandler(var ExtendContract: TestPage "Extend Contract")
    begin
        ExtendContract.ExtendCustomerContract.SetValue(true);
        ExtendContract.CustomerContractNo.SetValue(CustomerContract."No.");
        ExtendContract.ExtendVendorContract.SetValue(true);
        ExtendContract.VendorContractNo.SetValue(VendorContract."No.");
        ExtendContract.ItemNo.SetValue(Item."No.");
        ExtendContract.Quantity.SetValue(LibraryRandom.RandInt(10));
        ExtendContract.ProvisionStartDate.SetValue(WorkDate());
        ExtendContract.AdditionalServiceCommitments.AssistEdit();
        ExtendContract."Perform Extension".Invoke();
    end;

    [ModalPageHandler]
    procedure AssignServiceCommPackagesModalPageHandler(var AssignServiceCommPackages: TestPage "Assign Service Comm. Packages")
    begin
        AssignServiceCommPackages.First();
        AssignServiceCommPackages.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure SetupImportedServiceObjectAndCreateServiceObject()
    begin
        ClearTestData();
        SetupCustomerContract();
        SetupVendorContract();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer."No.", '');
        ImportedServiceObject.SetRecFilter();
        Commit(); //retain created Imported Service Objects
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); //MessageHandler
    end;

    local procedure ClearTestData()
    begin
        ClearAll();
        ImportedServiceObject.Reset();
        ImportedServiceObject.DeleteAll(false);
        ImportedServiceCommitment.Reset();
        ImportedServiceCommitment.DeleteAll(false);
        ContractTestLibrary.InitContractsApp();
    end;

    local procedure SetupCustomerContract()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
    end;

    local procedure SetupVendorContract()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateServiceCommitmentsFromImportedServiceCommitmentsForUsageBasedBilling()
    begin
        // [GIVEN] When Service Object is created from Imported Service Object (Customer and Vendor Contract prepared)
        // [GIVEN] Create Imported Service Commitments for that Service Object and
        // [WHEN] Create Service Commitments
        // [THEN] Check that Service Commitments are created
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::"Service Commitment");
        UpdateImportedServiceCommitment("Usage Based Pricing"::"Unit Cost Surcharge");
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, "Contract Line Type"::"Service Commitment");
        UpdateImportedServiceCommitment("Usage Based Pricing"::"Usage Quantity");
        Commit(); //retain created Imported Service Commitments

        ServiceCommitment.SetRange("Service Object No.", ImportedServiceObject."Service Object No.");
        AssertThat.IsTrue(ServiceCommitment.IsEmpty(), 'Service Commitment should be empty.');

        ImportedServiceCommitment.Reset();
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); //MessageHandler
        Commit(); //write data to database to be able to read updated values
        ImportedServiceCommitment.FindSet();
        ImportedServiceCommitment.SetRange("Service Commitment created", true);
        AssertThat.AreEqual(2, ImportedServiceCommitment.Count(), 'Not all Import Service Commitment lines are processed.');
        AssertThat.AreEqual(2, ServiceCommitment.Count(), 'Incorrect number of Service Commitment.');
        repeat
            ImportedServiceCommitment.TestField("Service Commitment Entry No.");
            ServiceCommitment.Get(ImportedServiceCommitment."Service Commitment Entry No.");
            ContractTestLibrary.TestServiceCommitmentAgainstImportedServiceCommitment(ServiceCommitment, ImportedServiceCommitment);
            ServiceCommitment.TestField("Usage Based Billing", ImportedServiceCommitment."Usage Based Billing");
            ServiceCommitment.TestField("Usage Based Pricing", ImportedServiceCommitment."Usage Based Pricing");
            ServiceCommitment.TestField("Pricing Unit Cost Surcharge %", ImportedServiceCommitment."Pricing Unit Cost Surcharge %");
            ServiceCommitment.TestField("Supplier Reference Entry No.", ImportedServiceCommitment."Supplier Reference Entry No.");
        until ImportedServiceCommitment.Next() = 0;
    end;

    local procedure UpdateImportedServiceCommitment(NewUsageBasedPricing: Enum "Usage Based Pricing")
    begin
        ImportedServiceCommitment.Validate("Usage Based Pricing", NewUsageBasedPricing);
        if NewUsageBasedPricing <> "Usage Based Pricing"::None then
            ImportedServiceCommitment.Validate("Usage Based Billing", true);
        if ImportedServiceCommitment."Usage Based Pricing" = "Usage Based Pricing"::"Unit Cost Surcharge" then
            ImportedServiceCommitment.Validate("Pricing Unit Cost Surcharge %", LibraryRandom.RandDec(50, 2));
        ImportedServiceCommitment.Validate("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        ImportedServiceCommitment.Modify(false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateServiceCommitment()
    var
        InitialImportedServiceCommitment: Record "Imported Service Commitment";
    begin
        // [GIVEN] Create Imported Service Commitment with incorrect data and
        // [WHEN] run Create Service Commitment
        // [THEN] assert errors when running Create Service Commitment
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::"Service Commitment");
        ImportedServiceCommitment.SetRecFilter();
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Service Commitment

        ImportedServiceCommitment."Usage Based Pricing" := "Usage Based Pricing"::"Usage Quantity";
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Usage Based Pricing" := "Usage Based Pricing"::"Usage Quantity";
        ImportedServiceCommitment."Usage Based Billing" := true;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Sales;
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Usage Based Pricing" := "Usage Based Pricing"::"Usage Quantity";
        ImportedServiceCommitment."Usage Based Billing" := true;
        ImportedServiceCommitment."Pricing Unit Cost Surcharge %" := LibraryRandom.RandDec(50, 2);
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);
    end;

    local procedure TestAssertErrorOnCreateServiceCommitmentRun(var InitialImportedServiceCommitment: Record "Imported Service Commitment")
    begin
        ImportedServiceCommitment.Modify(false);
        asserterror CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
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
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        ImportedServiceObject: Record "Imported Service Object";
        ImportedServiceCommitment: Record "Imported Service Commitment";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        AssertThat: Codeunit Assert;
        CreateServiceCommitment: Codeunit "Create Service Commitment";
        RecordRef: RecordRef;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        UsageDataSubscriptionPage: TestPage "Usage Data Subscriptions";
        i: Integer;
}
