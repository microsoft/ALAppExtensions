namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

codeunit 139914 "Imp. Service And Contract Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        ImportedCustomerContract: Record "Imported Cust. Sub. Contract";
        ImportedServiceCommitment: Record "Imported Subscription Line";
        ImportedServiceObject: Record "Imported Subscription Header";
        Item: Record Item;
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceContractSetup: Record "Subscription Contract Setup";
        ServiceObject: Record "Subscription Header";
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        Assert: Codeunit Assert;
        ContractTestLibrary: Codeunit "Contract Test Library";
        CreateContractLine: Codeunit "Create Sub. Contract Line";
        CreateCustomerContract: Codeunit "Create Cust. Sub. Contract";
        CreateServiceCommitment: Codeunit "Create Subscription Line";
        CreateServiceObject: Codeunit "Create Subscription Header";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";

    #region Tests

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckCreateCustomerContractFromImportedCustomerContract()
    var
        BillToCustomer: Record Customer;
    begin
        Initialize();
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        LibrarySales.CreateCustomer(BillToCustomer);
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract, Customer."No.", BillToCustomer."No.");
        Commit(); // needed before Report.Run
        ImportedCustomerContract.Reset();
        Report.Run(Report::"Create Customer Contracts", false, false, ImportedCustomerContract); // MessageHandler

        ImportedCustomerContract.FindSet();
        ImportedCustomerContract.SetRange("Contract created", true);
        Assert.AreEqual(2, ImportedCustomerContract.Count(), 'Not all Imported Customer Subscription Contract lines are processed.');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckCreateServiceObjectFromImportedServiceObject()
    var
        Customer2: Record Customer;
        Customer3: Record Customer;
        Item2: Record Item;
        Item3: Record Item;
        Item4: Record Item;
        ServiceCommitment: Record "Subscription Line";
        UnexpectedServCommErr: Label 'Unexpected Subscription Line created on Create Subscription.', Locked = true;
        i: Integer;
    begin
        // [GIVEN] Fill Imported Subscription Table multiple times
        // [WHEN] Run Create Subscription functionality
        // [THEN] Expect that all multiple Subscriptions are created
        Initialize();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject);
        Item.Get(ImportedServiceObject."Item No.");
        LibrarySales.CreateCustomer(Customer2);
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer2."No.", '');
        Item2.Get(ImportedServiceObject."Item No.");
        LibrarySales.CreateCustomer(Customer3);
        ContractTestLibrary.CreateItemWithServiceCommitmentOption(Item3, "Item Service Commitment Type"::"Service Commitment Item");
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer3."No.", Item3."No.");
        // Item with Serial No Item Tracking
        LibraryItemTracking.CreateSerialItem(Item4);
        Item4.Validate("Subscription Option", "Item Service Commitment Type"::"Sales with Service Commitment");
        Item4.Modify(true);
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer3."No.", Item4."No.", true);
        Commit(); // retain created Imported Subscriptions

        ImportedServiceObject.Reset();
        Assert.AreEqual(4, ImportedServiceObject.Count(), 'Unexpected number of Imported Subscriptions.');
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); // MessageHandler
        ImportedServiceObject.SetRange("Subscription Header created", true);
        Assert.AreEqual(4, ImportedServiceObject.Count(), 'Unexpected number of Imported Subscriptions.');
        ImportedServiceObject.FindSet();
        i := 1;
        repeat
            ServiceObject.Get(ImportedServiceObject."Subscription Header No.");
            ServiceCommitment.SetRange("Subscription Header No.", ServiceObject."No.");
            if not ServiceCommitment.IsEmpty() then
                Error(UnexpectedServCommErr);
            ServiceObject.TestField(Type, ServiceObject.Type::Item);
            ServiceObject.TestField("Source No.", ImportedServiceObject."Item No.");
            ServiceObject.TestField(Description, ImportedServiceObject.Description);
            ServiceObject.TestField(Quantity, ImportedServiceObject."Quantity (Decimal)");
            ServiceObject.TestField("Unit of Measure", ImportedServiceObject."Unit of Measure");
            ServiceObject.TestField("Customer Reference", ImportedServiceObject."Customer Reference");
            ServiceObject.TestField("Serial No.", ImportedServiceObject."Serial No.");
            ServiceObject.TestField(Version, ImportedServiceObject.Version);
            ServiceObject.TestField("Key", ImportedServiceObject."Key");
            ServiceObject.TestField("Provision Start Date", ImportedServiceObject."Provision Start Date");
            ServiceObject.TestField("Provision End Date", ImportedServiceObject."Provision End Date");
            ServiceObject.TestField("End-User Customer No.", ImportedServiceObject."End-User Customer No.");
            if ImportedServiceObject."End-User Contact No." <> '' then
                ServiceObject.TestField("End-User Contact No.", ImportedServiceObject."End-User Contact No.");
            if ImportedServiceObject."Bill-to Customer No." <> '' then
                ServiceObject.TestField("Bill-to Customer No.", ImportedServiceObject."Bill-to Customer No.");
            if ImportedServiceObject."Bill-to Contact No." <> '' then
                ServiceObject.TestField("Bill-to Contact No.", ImportedServiceObject."Bill-to Contact No.");
            ServiceObject.TestField("Ship-to Code", ImportedServiceObject."Ship-to Code");
            case i of
                4:
                    begin
                        ServiceObject.TestField(Quantity, 1);
                        ServiceObject.TestField("Serial No.");
                    end;
            end;
            i += 1;
        until ImportedServiceObject.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateServiceCommitmentsAndContractLinesFromImportedServiceCommitments()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        // [GIVEN] When Subscription is created from Imported Subscription (Customer and Vendor Subscription Contract prepared)
        // [GIVEN] Create Imported Subscription Lines for that Subscription and
        // [WHEN] Create Subscription Lines
        // [THEN] Check that Subscription Lines are created
        Initialize();
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, Enum::"Contract Line Type"::Item);
        UpdateImportedServiceCommitment();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::Comment);
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, Enum::"Contract Line Type"::Item);
        UpdateImportedServiceCommitment();
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, "Contract Line Type"::Comment);

        ServiceCommitment.SetRange("Subscription Header No.", ImportedServiceObject."Subscription Header No.");
        Assert.IsTrue(ServiceCommitment.IsEmpty(), 'Service Commitment should be empty.');
        CustomerContractLine.SetRange("Subscription Contract No.", CustomerContract."No.");
        Assert.IsTrue(CustomerContractLine.IsEmpty(), 'Customer Subscription Contract Line should be empty.');
        VendorContractLine.SetRange("Subscription Contract No.", VendorContract."No.");
        Assert.IsTrue(VendorContractLine.IsEmpty(), 'Vendor Subscription Contract Line should be empty.');

        Commit(); // needed before Report.Run
        ImportedServiceCommitment.Reset();
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); // MessageHandler
        Commit(); // write data to database to be able to read updated values
        ImportedServiceCommitment.FindSet();
        ImportedServiceCommitment.SetRange("Subscription Line created", true);
        ImportedServiceCommitment.SetRange("Sub. Contract Line created", true);
        Assert.AreEqual(4, ImportedServiceCommitment.Count(), 'Not all Import Service Commitment lines are processed.');

        Assert.AreEqual(2, ServiceCommitment.Count(), 'Incorrect number of Service Commitment.');
        Assert.AreEqual(2, CustomerContractLine.Count(), 'Customer Subscription Contract Line not found.');
        Assert.AreEqual(2, VendorContractLine.Count(), 'Vendor Subscription Contract Line not found.');

        repeat
            // test Subscription Lines - comment lines are tested only on contracts
            if not ImportedServiceCommitment.IsContractCommentLine() then begin
                ImportedServiceCommitment.TestField("Subscription Line Entry No.");
                ServiceCommitment.Get(ImportedServiceCommitment."Subscription Line Entry No.");
                ContractTestLibrary.TestServiceCommitmentAgainstImportedServiceCommitment(ServiceCommitment, ImportedServiceCommitment);
            end;

            ImportedServiceCommitment.TestField("Subscription Contract Line No.");
            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    begin
                        CustomerContractLine.Get(ImportedServiceCommitment."Subscription Contract No.", ImportedServiceCommitment."Subscription Contract Line No.");
                        if ImportedServiceCommitment.IsContractCommentLine() then
                            CustomerContractLine.TestField("Subscription Description", ImportedServiceCommitment.Description)
                        else begin
                            CustomerContractLine.TestField("Subscription Header No.", ImportedServiceCommitment."Subscription Header No.");
                            CustomerContractLine.TestField("Subscription Line Entry No.", ImportedServiceCommitment."Subscription Line Entry No.");
                        end;
                    end;
                "Service Partner"::Vendor:
                    begin
                        VendorContractLine.Get(ImportedServiceCommitment."Subscription Contract No.", ImportedServiceCommitment."Subscription Contract Line No.");
                        if ImportedServiceCommitment.IsContractCommentLine() then
                            VendorContractLine.TestField("Subscription Description", ImportedServiceCommitment.Description)
                        else begin
                            VendorContractLine.TestField("Subscription Header No.", ImportedServiceCommitment."Subscription Header No.");
                            VendorContractLine.TestField("Subscription Line Entry No.", ImportedServiceCommitment."Subscription Line Entry No.");
                        end;
                    end;
            end;
        until ImportedServiceCommitment.Next() = 0;
        // test that no Archived Subscription Lines are created during import.
        ServiceObject.Get(ImportedServiceObject."Subscription Header No.");
        ServiceObject.CalcFields("Archived Sub. Lines exist");
        Assert.IsFalse(ServiceObject."Archived Sub. Lines exist", 'Archived Service Commitment should not be created during Import of Service Commitments.');
    end;

    [Test]
    procedure ExpectErrorIfCustomerContractSeriesNoCannotBeSetManually()
    var
        NoSeries: Record "No. Series";
    begin
        // [GIVEN] No Series for Customer Subscription Contract cannot create manual numbers
        // [WHEN] Create Customer Subscription Contract from Imported Customer Subscription Contract
        // [THEN] Expect error on No Series
        Initialize();
        ServiceContractSetup.TestField("Cust. Sub. Contract Nos.");
        NoSeries.Get(ServiceContractSetup."Cust. Sub. Contract Nos.");
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Modify(true);
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        ImportedServiceObject.SetRecFilter();
        asserterror CreateCustomerContract.Run(ImportedCustomerContract);
    end;

    [Test]
    procedure ExpectErrorIfServiceObjectSeriesNoCannotBeSetManually()
    var
        NoSeries: Record "No. Series";
    begin
        // [GIVEN] No Series for Subscription cannot create manual numbers
        // [WHEN] Create Subscription from Imported Subscription
        // [THEN] Expect error on No Series
        Initialize();
        ServiceContractSetup.TestField("Subscription Header No.");
        NoSeries.Get(ServiceContractSetup."Subscription Header No.");
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Modify(true);
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject);
        ImportedServiceObject.SetRecFilter();
        asserterror CreateServiceObject.Run(ImportedServiceObject);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateCustomerContractLine()
    var
        InitialCustomerContract: Record "Customer Subscription Contract";
        InitialImportedServiceCommitment: Record "Imported Subscription Line";
    begin
        // [GIVEN] Create Imported Subscription Line with incorrect data for Customer Subscription Contract Line and
        // [WHEN] run Create Contract Line
        // [THEN] assert errors when running Create Contract Line
        Initialize();
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, Enum::"Contract Line Type"::Item);
        ImportedServiceCommitment.SetRecFilter();
        CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Subscription Line

        ImportedServiceCommitment."Subscription Contract No." := '';

        ImportedServiceCommitment.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
        ImportedServiceCommitment.Modify(false);

        InitialCustomerContract := CustomerContract;
        CustomerContract."Sell-to Customer No." := '';
        TestAssertErrorOnCreateCustomerContractLine(InitialCustomerContract);

        CustomerContract."Currency Code" := '';
        TestAssertErrorOnCreateCustomerContractLine(InitialCustomerContract);
    end;

    [Test]
    procedure ExpectMultipleErrorsOnCreateCustomerContractsFromImportedCustomerContract()
    var
        InitialImportedCustomerContract: Record "Imported Cust. Sub. Contract";
    begin
        // [GIVEN] Create Imported Customer Subscription Contract with incorrect data and
        // [WHEN] run Create Customer Subscription Contract
        // [THEN] assert errors when running Create Customer Subscription Contract
        Initialize();
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        ImportedServiceObject.SetRecFilter();
        InitialImportedCustomerContract := ImportedCustomerContract;
        Commit(); // retain data after assert errors

        ImportedCustomerContract."Contract created" := true;
        TestAssertErrorOnCreateCustomerContractRun(InitialImportedCustomerContract);

        ImportedCustomerContract."Sell-to Customer No." := '';
        TestAssertErrorOnCreateCustomerContractRun(InitialImportedCustomerContract);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateServiceCommitment()
    var
        InitialImportedServiceCommitment: Record "Imported Subscription Line";
        EmptyDateFormula: DateFormula;
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

        ImportedServiceCommitment."Subscription Header No." := '';
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Subscription Header No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment."Subscription Header No.")), 1, MaxStrLen(ImportedServiceCommitment."Subscription Header No."));
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Subscription Line Start Date" := 0D;
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Calculation Base %" := LibraryRandom.RandDecInRange(-100, -1, 0);
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Calculation Base %" := LibraryRandom.RandDecInRange(101, 200, 0);
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Discount %" := LibraryRandom.RandDecInRange(-100, -1, 0);
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Discount %" := LibraryRandom.RandDecInRange(101, 200, 0);
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Billing Base Period" := EmptyDateFormula;
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        Evaluate(ImportedServiceCommitment."Billing Base Period", '<-1M>');
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        Evaluate(ImportedServiceCommitment."Notice Period", '<-1M>');
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        Evaluate(ImportedServiceCommitment."Initial Term", '<-1M>');
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        Evaluate(ImportedServiceCommitment."Extension Term", '<-1M>');
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Billing Rhythm" := EmptyDateFormula;
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        Evaluate(ImportedServiceCommitment."Billing Rhythm", '<-1M>');
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Subscription Package Code" := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment."Subscription Package Code")), 1, MaxStrLen(ImportedServiceCommitment."Subscription Package Code"));
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);
    end;

    [Test]
    procedure ExpectMultipleErrorsOnCreateServiceObjectFromImportedServiceObject()
    var
        InitialImportedServiceObject: Record "Imported Subscription Header";
    begin
        // [GIVEN] Create Imported Subscription with incorrect data and
        // [WHEN] run Create Subscription
        // [THEN] assert errors when running Create Subscription
        Initialize();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject);
        ImportedServiceObject.SetRecFilter();
        InitialImportedServiceObject := ImportedServiceObject;
        Item.Get(ImportedServiceObject."Item No.");
        Commit(); // retain created Imported Subscriptions

        ImportedServiceObject."Subscription Header created" := true;
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject."Item No." := '';
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject."Quantity (Decimal)" := LibraryRandom.RandDecInDecimalRange(-100, -1, 0);
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject.Modify(false);
        Item."Subscription Option" := Item."Subscription Option"::"Sales without Service Commitment";
        Item.Modify(false);
        asserterror CreateServiceObject.Run(ImportedServiceObject);
        Item."Subscription Option" := Item."Subscription Option"::"Service Commitment Item";
        Item.Modify(false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateVendorContractLine()
    var
        InitialImportedServiceCommitment: Record "Imported Subscription Line";
        InitialVendorContract: Record "Vendor Subscription Contract";
    begin
        // [GIVEN] Create Imported Subscription Line with incorrect data for Vendor Subscription Contract Line and
        // [WHEN] run Create Contract Line
        // [THEN] assert errors when running Create Contract Line
        Initialize();
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, Enum::"Contract Line Type"::Item);
        ImportedServiceCommitment.SetRecFilter();
        CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Subscription Line

        ImportedServiceCommitment."Subscription Contract No." := '';

        ImportedServiceCommitment.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
        ImportedServiceCommitment.Modify(false);

        InitialVendorContract := VendorContract;
        VendorContract."Currency Code" := '';
        TestAssertErrorOnCreateVendorContractLine(InitialVendorContract);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ImportServiceCommitmentWithEmptyInvoicingItemNo()
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        // [GIVEN] Subscription with Subscription Item
        // [GIVEN] Imported Subscription Lines without a value in "Invoicing Item No."
        Initialize();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer."No.", '');
        Commit(); // needed before If Codeunit.Run
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); // MessageHandler

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Subscription Header No." := ImportedServiceObject."Subscription Header No.";
        ImportedServiceCommitment."Sub. Contract Line Type" := Enum::"Contract Line Type"::Item;
        ImportedServiceCommitment.Partner := "Service Partner"::Customer;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := '';
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ContractTestLibrary.SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);

        // [WHEN] Creating Subscription Lines
        Commit(); // needed before If Codeunit.Run
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); // MessageHandler
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");

        // [THEN] Expect the Subscription Line Item to have the Item of the Subscription if it is a Subscription Item
        ImportedServiceCommitment.TestField("Subscription Line created", true);
        ImportedServiceCommitment.TestField("Invoicing Item No.", '');

        ServiceCommitment.Get(ImportedServiceCommitment."Subscription Line Entry No.");
        Assert.AreEqual(ImportedServiceObject."Item No.", ServiceCommitment."Invoicing Item No.", 'The Invoicing Item No. should be taken from the Service Object if it is empty in the source and if the item is a service commitment item');
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        ClearAll();
        ImportedCustomerContract.Reset();
        ImportedCustomerContract.DeleteAll(false);
        ImportedServiceObject.Reset();
        ImportedServiceObject.DeleteAll(false);
        ImportedServiceCommitment.Reset();
        ImportedServiceCommitment.DeleteAll(false);
        ContractTestLibrary.InitContractsApp();
        ServiceContractSetup.Get();
    end;

    local procedure SetupCustomerContract()
    begin
        ContractTestLibrary.CreateCustomer(Customer);
        ContractTestLibrary.CreateCustomerContract(CustomerContract, Customer."No.");
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

    local procedure SetupVendorContract()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
    end;

    local procedure TestAssertErrorOnCreateCustomerContractLine(var InitialCustomerContract: Record "Customer Subscription Contract")
    begin
        CustomerContract.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        CustomerContract := InitialCustomerContract;
    end;

    local procedure TestAssertErrorOnCreateCustomerContractRun(var InitialImportedCustomerContract: Record "Imported Cust. Sub. Contract")
    begin
        ImportedCustomerContract.Modify(false);
        asserterror CreateCustomerContract.Run(ImportedCustomerContract);
        ImportedCustomerContract := InitialImportedCustomerContract;
    end;

    local procedure TestAssertErrorOnCreateServiceCommitmentRun(var InitialImportedServiceCommitment: Record "Imported Subscription Line")
    begin
        ImportedServiceCommitment.Modify(false);
        asserterror CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
    end;

    local procedure TestAssertErrorOnCreateServiceObjectRun(var InitialImportedServiceObject: Record "Imported Subscription Header")
    begin
        ImportedServiceObject.Modify(false);
        asserterror CreateServiceObject.Run(ImportedServiceObject);
        ImportedServiceObject := InitialImportedServiceObject;
    end;

    local procedure TestAssertErrorOnCreateVendorContractLine(var InitialVendorContract: Record "Vendor Subscription Contract")
    begin
        VendorContract.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        VendorContract := InitialVendorContract;
    end;

    local procedure UpdateImportedServiceCommitment()
    begin
        ImportedServiceCommitment.Validate("Subscription Package Code", ServiceCommitmentPackage.Code);
        ImportedServiceCommitment.Modify(false);
    end;
    #endregion Procedures

    #region Handlers

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    #endregion Handlers
}
