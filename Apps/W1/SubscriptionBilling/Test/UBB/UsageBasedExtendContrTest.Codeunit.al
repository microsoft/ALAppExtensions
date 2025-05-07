namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

codeunit 148159 "Usage Based Extend Contr. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchDef: Record "Data Exch. Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        GenericImportSettings: Record "Generic Import Settings";
        ImportedServiceCommitment: Record "Imported Subscription Line";
        ImportedServiceObject: Record "Imported Subscription Header";
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
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        AssertThat: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CreateServiceCommitment: Codeunit "Create Subscription Line";
        LibraryRandom: Codeunit "Library - Random";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        RecordRef: RecordRef;
        i: Integer;
        ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
        FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        FileType: Option Xml,"Variable Text","Fixed Text",Json;
        UsageDataSubscriptionPage: TestPage "Usage Data Subscriptions";

    #region Tests

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure CreateAndProcessUsageDataBilling()
    begin
        Initialize();
        SetupUsageBasedBilling();
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Create Usage Data Billing";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Create Usage Data Billing", UsageDataImport);
        UsageDataImport."Processing Step" := Enum::"Processing Step"::"Process Usage Data Billing";
        UsageDataImport.Modify(false);
        Codeunit.Run(Codeunit::"Process Usage Data Billing", UsageDataImport);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateServiceCommitmentsFromImportedServiceCommitmentsForUsageBasedBilling()
    begin
        // [GIVEN] When Subscription is created from Imported Subscription (Customer and Vendor Subscription Contract prepared)
        // [GIVEN] Create Imported Subscription Lines for that Subscription and
        // [WHEN] Create Subscription Lines
        // [THEN] Check that Subscription Lines are created
        Initialize();

        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, Enum::"Contract Line Type"::Item);
        UpdateImportedServiceCommitment("Usage Based Pricing"::"Unit Cost Surcharge");
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, Enum::"Contract Line Type"::Item);
        UpdateImportedServiceCommitment("Usage Based Pricing"::"Usage Quantity");
        Commit(); // retain created Imported Subscription Lines

        ServiceCommitment.SetRange("Subscription Header No.", ImportedServiceObject."Subscription Header No.");
        AssertThat.IsTrue(ServiceCommitment.IsEmpty(), 'Service Commitment should be empty.');

        ImportedServiceCommitment.Reset();
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); // MessageHandler
        Commit(); // write data to database to be able to read updated values
        ImportedServiceCommitment.FindSet();
        ImportedServiceCommitment.SetRange("Subscription Line created", true);
        AssertThat.AreEqual(2, ImportedServiceCommitment.Count(), 'Not all Import Service Commitment lines are processed.');
        AssertThat.AreEqual(2, ServiceCommitment.Count(), 'Incorrect number of Service Commitment.');
        repeat
            ImportedServiceCommitment.TestField("Subscription Line Entry No.");
            ServiceCommitment.Get(ImportedServiceCommitment."Subscription Line Entry No.");
            ContractTestLibrary.TestServiceCommitmentAgainstImportedServiceCommitment(ServiceCommitment, ImportedServiceCommitment);
            ServiceCommitment.TestField("Usage Based Billing", ImportedServiceCommitment."Usage Based Billing");
            ServiceCommitment.TestField("Usage Based Pricing", ImportedServiceCommitment."Usage Based Pricing");
            ServiceCommitment.TestField("Pricing Unit Cost Surcharge %", ImportedServiceCommitment."Pricing Unit Cost Surcharge %");
            ServiceCommitment.TestField("Supplier Reference Entry No.", ImportedServiceCommitment."Supplier Reference Entry No.");
        until ImportedServiceCommitment.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure ExpectErrorOnExtendContractWithConnectedSubscriptionOnSelectSubscription()
    begin
        Initialize();
        SetupUsageBasedBilling();
        asserterror InvokeExtendContractFromSubscription();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateServiceCommitment()
    var
        InitialImportedServiceCommitment: Record "Imported Subscription Line";
    begin
        // [GIVEN] Create Imported Subscription Line with incorrect data and
        // [WHEN] run Create Subscription Line
        // [THEN] assert errors when running Create Subscription Line
        Initialize();
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, Enum::"Contract Line Type"::Item);
        ImportedServiceCommitment.SetRecFilter();
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Subscription Line

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

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler,AssignServiceCommPackagesModalPageHandler,MessageHandler')]
    procedure TestLinkServiceCommitmentWithUsageDataSubscription()
    begin
        Initialize();
        SetupUsageBasedBilling();
        UsageDataSupplierReference.SetRange("Supplier No.", UsageDataSupplier."No.");
        UsageDataSupplierReference.SetRange(Type, Enum::"Usage Data Reference Type"::Subscription);
        UsageDataSupplierReference.FindSet(false);
        repeat
            TestIsServiceCommitmentUpdated();
            FindUsageDataGenericImportUpdated();
            TestIsUsageDataSubscriptionUpdated();
        until UsageDataSupplierReference.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('TestExtendContractModalPageHandler')]
    procedure TestUsageBasedFieldsOnOpenExtendContractFromSubscription()
    begin
        Initialize();
        SetupUsageBasedBilling();
    end;

    [Test]
    [HandlerFunctions('ExtendContractModalPageHandler2,AssignServiceCommPackagesModalPageHandler,SendNotificationHandler')]
    procedure UT_CheckNotificationsInExtendContractPage()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataGenericImportPage: TestPage "Usage Data Generic Import";
    begin
        //[SCENARIO]: Setup item with service commitment packages; None of the packages will have lines marked as Usage Based Billing
        //[SCENARIO]: Expect that notification is sent when Extend contract is invoked from Usage Data Generic Import page
        ClearAll();
        LibraryVariableStorage.Clear();
        ContractTestLibrary.InitContractsApp();

        // [GIVEN] Create an item with service commitment option
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages(false);

        // [GIVEN] Setup Usage Data Supplier,Generic Import Settings, Usage Data Import, Usage Data Generic Import
        MockUsageDataSupplier();
        MockGenericImportSettings();
        MockUsageDataImport();
        MockUsageDataGenericImport(UsageDataGenericImport);

        // [WHEN] Open the Usage Data Generic Import page and invoke Extend Contract
        UsageDataGenericImportPage.OpenEdit();
        UsageDataGenericImportPage.GoToRecord(UsageDataGenericImport);

        //Test is performed inside the handler
        UsageDataGenericImportPage.ExtendContract.Invoke(); //ExtendContractModalPageHandler2,AssignServiceCommPackagesModalPageHandler,SendNotificationHandler
        LibraryVariableStorage.AssertEmpty();
    end;
    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();
        ImportedServiceObject.Reset();
        ImportedServiceObject.DeleteAll(false);
        ImportedServiceCommitment.Reset();
        ImportedServiceCommitment.DeleteAll(false);
        ContractTestLibrary.InitContractsApp();
    end;

    local procedure CreateCustomerAndVendorContracts()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    local procedure CreateMultipleUsageDataBlobFiles()
    begin
        for i := 1 to 5 do begin
            UsageDataBlob.InsertFromUsageDataImport(UsageDataImport);
            UsageBasedBTestLibrary.CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RecordRef, ServiceObject."No.", ServiceCommitment."Entry No.");
        end;
    end;

    local procedure FindUsageDataGenericImportUpdated()
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        UsageDataGenericImport.SetRange("Supp. Subscription ID", UsageDataSupplierReference."Supplier Reference");
        UsageDataGenericImport.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        UsageDataGenericImport.SetRange("Service Object Availability", UsageDataGenericImport."Service Object Availability"::Connected);
        UsageDataGenericImport.FindFirst();
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

    local procedure SetupDataExchangeDefinition()
    begin
        UsageBasedBTestLibrary.CreateDataExchDefinition(DataExchDef, FileType::"Variable Text", Enum::"Data Exchange Definition Type"::"Generic Import", FileEncoding::"UTF-8", ColumnSeparator::Semicolon, '', 1);
        UsageBasedBTestLibrary.CreateDataExchDefinitionLine(DataExchLineDef, DataExchDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchColumnDefinition(DataExchColumnDef, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeMapping(DataExchMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
        UsageBasedBTestLibrary.CreateDataExchangeFieldMapping(DataExchFieldMapping, DataExchDef.Code, DataExchLineDef.Code, RecordRef);
    end;

    local procedure SetupItemWithMultipleServiceCommitmentPackages(UsageBasedBilling: Boolean)
    begin
        ContractTestLibrary.CreateServiceCommitmentTemplate(ServiceCommitmentTemplate);
        ServiceCommitmentTemplate."Calculation Base %" := LibraryRandom.RandDec(100, 2);
        Evaluate(ServiceCommitmentTemplate."Billing Base Period", '<12M>');
        ServiceCommitmentTemplate."Invoicing via" := Enum::"Invoicing Via"::Contract;
        ServiceCommitmentTemplate."Usage Based Billing" := UsageBasedBilling;
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
    end;

    local procedure SetupImportedServiceObjectAndCreateServiceObject()
    begin
        SetupCustomerContract();
        SetupVendorContract();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer."No.", '');
        ImportedServiceObject.SetRecFilter();
        Commit(); // retain created Imported Subscriptions
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); // MessageHandler
    end;

    local procedure MockGenericImportSettings()
    begin
        GenericImportSettings.Init();
        GenericImportSettings."Usage Data Supplier No." := UsageDataSupplier."No.";
        GenericImportSettings."Process without UsageDataBlobs" := true;
        GenericImportSettings.Insert();
    end;

    local procedure MockUsageDataGenericImport(var UsageDataGenericImport: Record "Usage Data Generic Import")
    begin
        UsageDataGenericImport.InitFromUsageDataImport(UsageDataImport);
        UsageDataGenericImport."Product ID" := LibraryUtility.GenerateRandomText(80);
        UsageDataGenericImport."Supp. Subscription ID" := LibraryUtility.GenerateRandomText(80);
        UsageDataGenericImport.Insert();
    end;

    local procedure MockUsageDataImport()
    begin
        UsageDataImport.Init();
        UsageDataImport."Supplier No." := UsageDataSupplier."No.";
        UsageDataImport.Insert();
    end;

    local procedure MockUsageDataSupplier()
    begin
        UsageDataSupplier.Init();
        UsageDataSupplier."No." := LibraryUtility.GenerateRandomCode20(UsageDataSupplier.FieldNo("No."), Database::"Usage Data Supplier");
        UsageDataSupplier.Insert();
    end;

    local procedure SetupCustomerContract()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
    end;

    local procedure SetupUsageBasedBilling()
    begin
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item, Enum::"Item Service Commitment Type"::"Service Commitment Item");
        SetupItemWithMultipleServiceCommitmentPackages(true);
        CreateCustomerAndVendorContracts();
        SetupUsageDataForProcessingToGenericImport();
        InvokeExtendContractFromSubscription();
    end;

    local procedure SetupVendorContract()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
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

    local procedure TestAssertErrorOnCreateServiceCommitmentRun(var InitialImportedServiceCommitment: Record "Imported Subscription Line")
    begin
        ImportedServiceCommitment.Modify(false);
        asserterror CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
    end;

    local procedure TestIsUsageDataSubscriptionUpdated()
    begin
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        UsageDataSubscription.SetRange("Subscription Header No.", ServiceCommitment."Subscription Header No.");
        UsageDataSubscription.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        UsageDataSubscription.FindFirst();
    end;

    local procedure TestIsServiceCommitmentUpdated()
    begin
        ServiceCommitment.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        ServiceCommitment.FindFirst();
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

    #endregion Procedures

    #region Handlers

    [ModalPageHandler]
    procedure AssignServiceCommPackagesModalPageHandler(var AssignServiceCommPackages: TestPage "Assign Service Comm. Packages")
    begin
        AssignServiceCommPackages.First();
        AssignServiceCommPackages.Selected.SetValue(true);
        AssignServiceCommPackages.OK().Invoke();
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
    procedure ExtendContractModalPageHandler2(var ExtendContract: TestPage "Extend Contract")
    var
        NoUBBServiceCommitmentPackFound1Msg: Label 'No standard Subscription Package for usage-based billing is assigned to the item %1.', Locked = true;
        NoUBBServiceCommitmentPackFound2Msg: Label 'None of the selected Subscription Package are intended for usage-based billing.', Locked = true;
    begin
        Clear(LibraryVariableStorage); //clear previous messages; values are saved OnOpenPage
        ExtendContract.ItemNo.SetValue(Item."No.");
        AssertThat.AreEqual(StrSubstNo(NoUBBServiceCommitmentPackFound1Msg, ExtendContract.ItemNo.Value), LibraryVariableStorage.DequeueText(), 'Notification message is not correct.');
        ExtendContract.AdditionalServiceCommitments.AssistEdit();
        AssertThat.AreEqual(NoUBBServiceCommitmentPackFound2Msg, LibraryVariableStorage.DequeueText(), 'Notification message is not correct.');
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var Notification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(Notification.Message);
    end;

    [ModalPageHandler]
    procedure TestExtendContractModalPageHandler(var ExtendContract: TestPage "Extend Contract")
    begin
        AssertThat.AreEqual(UsageDataSubscription."Supplier No.", ExtendContract.UsageDataSupplierNo.Value, 'Extend Contract was not initialize properly.');
        AssertThat.AreEqual(UsageDataSubscription."Product Name", ExtendContract.SubscriptionDescription.Value, 'Extend Contract was not initialize properly.');
        ExtendContract.Cancel().Invoke();
    end;

    #endregion Handlers
}
