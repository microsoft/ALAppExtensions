namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;

codeunit 139914 "Imp. Service And Contract Test"
{
    Subtype = Test;
    Access = Internal;

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

    local procedure SetupVendorContract()
    begin
        ContractTestLibrary.CreateVendor(Vendor);
        ContractTestLibrary.CreateVendorContract(VendorContract, Vendor."No.");
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
        ServiceCommitment: Record "Service Commitment";
        i: Integer;
    begin
        // [GIVEN] Fill Imported Service Object Table multiple times
        // [WHEN] Run Create Service Object functionality
        // [THEN] Expect that all multiple Service Objects are created
        ClearTestData();
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
        Item4.Validate("Service Commitment Option", "Item Service Commitment Type"::"Sales with Service Commitment");
        Item4.Modify(true);
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer3."No.", Item4."No.", true);
        Commit(); //retain created Imported Service Objects

        ImportedServiceObject.Reset();
        AssertThat.AreEqual(4, ImportedServiceObject.Count(), 'Unexpected number of Imported Service Objects.');
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); //MessageHandler
        ImportedServiceObject.SetRange("Service Object created", true);
        AssertThat.AreEqual(4, ImportedServiceObject.Count(), 'Unexpected number of Imported Service Objects.');
        ImportedServiceObject.FindSet();
        i := 1;
        repeat
            ServiceObject.Get(ImportedServiceObject."Service Object No.");
            ServiceCommitment.SetRange("Service Object No.", ServiceObject."No.");
            if not ServiceCommitment.IsEmpty() then
                Error('Unexpected Service Commitment created on Create Service Object.');
            ServiceObject.TestField("Item No.", ImportedServiceObject."Item No.");
            ServiceObject.TestField(Description, ImportedServiceObject.Description);
            ServiceObject.TestField("Quantity Decimal", ImportedServiceObject."Quantity (Decimal)");
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
                        ServiceObject.TestField("Quantity Decimal", 1);
                        ServiceObject.TestField("Serial No.");
                    end;
            end;
            i += 1;
        until ImportedServiceObject.Next() = 0;
    end;

    [Test]
    procedure ExpectErrorIfServiceObjectSeriesNoCannotBeSetManually()
    var
        NoSeries: Record "No. Series";
    begin
        // [GIVEN] No Series for Service Object cannot create manual numbers
        // [WHEN] Create Service Object from Imported Service Object
        // [THEN] Expect error on No Series
        ClearTestData();
        ServiceContractSetup.TestField("Service Object Nos.");
        NoSeries.Get(ServiceContractSetup."Service Object Nos.");
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Modify(true);
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject);
        ImportedServiceObject.SetRecFilter();
        asserterror CreateServiceObject.Run(ImportedServiceObject);
    end;

    [Test]
    procedure ExpectMultipleErrorsOnCreateServiceObjectFromImportedServiceObject()
    var
        InitialImportedServiceObject: Record "Imported Service Object";
    begin
        // [GIVEN] Create Imported Service Object with incorrect data and
        // [WHEN] run Create Service Object
        // [THEN] assert errors when running Create Service Object
        ClearTestData();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject);
        ImportedServiceObject.SetRecFilter();
        InitialImportedServiceObject := ImportedServiceObject;
        Item.Get(ImportedServiceObject."Item No.");
        Commit(); //retain created Imported Service Objects

        ImportedServiceObject."Service Object created" := true;
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject."Item No." := '';
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject."Quantity (Decimal)" := LibraryRandom.RandDecInDecimalRange(-100, -1, 0);
        TestAssertErrorOnCreateServiceObjectRun(InitialImportedServiceObject);

        ImportedServiceObject.Modify(false);
        Item."Service Commitment Option" := Item."Service Commitment Option"::"Sales without Service Commitment";
        Item.Modify(false);
        asserterror CreateServiceObject.Run(ImportedServiceObject);
        Item."Service Commitment Option" := Item."Service Commitment Option"::"Service Commitment Item";
        Item.Modify(false);
    end;

    local procedure TestAssertErrorOnCreateServiceObjectRun(var InitialImportedServiceObject: Record "Imported Service Object")
    begin
        ImportedServiceObject.Modify(false);
        asserterror CreateServiceObject.Run(ImportedServiceObject);
        ImportedServiceObject := InitialImportedServiceObject;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CreateServiceCommitmentsAndContractLinesFromImportedServiceCommitments()
    var
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        // [GIVEN] When Service Object is created from Imported Service Object (Customer and Vendor Contract prepared)
        // [GIVEN] Create Imported Service Commitments for that Service Object and
        // [WHEN] Create Service Commitments
        // [THEN] Check that Service Commitments are created
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateServiceCommitmentPackage(ServiceCommitmentPackage);
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::"Service Commitment");
        UpdateImportedServiceCommitment();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::Comment);
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, "Contract Line Type"::"Service Commitment");
        UpdateImportedServiceCommitment();
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, "Contract Line Type"::Comment);

        ServiceCommitment.SetRange("Service Object No.", ImportedServiceObject."Service Object No.");
        AssertThat.IsTrue(ServiceCommitment.IsEmpty(), 'Service Commitment should be empty.');
        CustomerContractLine.SetRange("Contract No.", CustomerContract."No.");
        AssertThat.IsTrue(CustomerContractLine.IsEmpty(), 'Customer Contract Line should be empty.');
        VendorContractLine.SetRange("Contract No.", VendorContract."No.");
        AssertThat.IsTrue(VendorContractLine.IsEmpty(), 'Vendor Contract Line should be empty.');

        Commit(); // needed before Report.Run
        ImportedServiceCommitment.Reset();
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); //MessageHandler
        Commit(); //write data to database to be able to read updated values
        ImportedServiceCommitment.FindSet();
        ImportedServiceCommitment.SetRange("Service Commitment created", true);
        ImportedServiceCommitment.SetRange("Contract Line created", true);
        AssertThat.AreEqual(4, ImportedServiceCommitment.Count(), 'Not all Import Service Commitment lines are processed.');

        AssertThat.AreEqual(2, ServiceCommitment.Count(), 'Incorrect number of Service Commitment.');
        AssertThat.AreEqual(2, CustomerContractLine.Count(), 'Customer Contract Line not found.');
        AssertThat.AreEqual(2, VendorContractLine.Count(), 'Vendor Contract Line not found.');

        repeat
            // test service commitments - comment lines are tested only on contracts
            if not ImportedServiceCommitment.IsContractCommentLine() then begin
                ImportedServiceCommitment.TestField("Service Commitment Entry No.");
                ServiceCommitment.Get(ImportedServiceCommitment."Service Commitment Entry No.");
                ContractTestLibrary.TestServiceCommitmentAgainstImportedServiceCommitment(ServiceCommitment, ImportedServiceCommitment);
            end;

            ImportedServiceCommitment.TestField("Contract Line No.");
            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    begin
                        CustomerContractLine.Get(ImportedServiceCommitment."Contract No.", ImportedServiceCommitment."Contract Line No.");
                        if ImportedServiceCommitment.IsContractCommentLine() then
                            CustomerContractLine.TestField("Service Object Description", ImportedServiceCommitment.Description)
                        else begin
                            CustomerContractLine.TestField("Service Object No.", ImportedServiceCommitment."Service Object No.");
                            CustomerContractLine.TestField("Service Commitment Entry No.", ImportedServiceCommitment."Service Commitment Entry No.");
                        end;
                    end;
                "Service Partner"::Vendor:
                    begin
                        VendorContractLine.Get(ImportedServiceCommitment."Contract No.", ImportedServiceCommitment."Contract Line No.");
                        if ImportedServiceCommitment.IsContractCommentLine() then
                            VendorContractLine.TestField("Service Object Description", ImportedServiceCommitment.Description)
                        else begin
                            VendorContractLine.TestField("Service Object No.", ImportedServiceCommitment."Service Object No.");
                            VendorContractLine.TestField("Service Commitment Entry No.", ImportedServiceCommitment."Service Commitment Entry No.");
                        end;
                    end;
            end;
        until ImportedServiceCommitment.Next() = 0;
        // test that no Archived Service Commitments are created during import.
        ServiceObject.Get(ImportedServiceObject."Service Object No.");
        ServiceObject.CalcFields("Archived Service Commitments");
        AssertThat.IsFalse(ServiceObject."Archived Service Commitments", 'Archived Service Commitment should not be created during Import of Service Commitments.');
    end;

    local procedure UpdateImportedServiceCommitment()
    begin
        ImportedServiceCommitment.Validate("Package Code", ServiceCommitmentPackage.Code);
        ImportedServiceCommitment.Modify(false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateServiceCommitment()
    var
        InitialImportedServiceCommitment: Record "Imported Service Commitment";
        EmptyDateFormula: DateFormula;
    begin
        // [GIVEN] Create Imported Service Commitment with incorrect data and
        // [WHEN] run Create Service Commitment
        // [THEN] assert errors when running Create Service Commitment
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::"Service Commitment");
        ImportedServiceCommitment.SetRecFilter();
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Service Commitment

        ImportedServiceCommitment."Service Object No." := '';
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Service Object No." := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment."Service Object No.")), 1, MaxStrLen(ImportedServiceCommitment."Service Object No."));
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);

        ImportedServiceCommitment."Service Start Date" := 0D;
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

        ImportedServiceCommitment."Package Code" := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment."Package Code")), 1, MaxStrLen(ImportedServiceCommitment."Package Code"));
        TestAssertErrorOnCreateServiceCommitmentRun(InitialImportedServiceCommitment);
    end;

    local procedure TestAssertErrorOnCreateServiceCommitmentRun(var InitialImportedServiceCommitment: Record "Imported Service Commitment")
    begin
        ImportedServiceCommitment.Modify(false);
        asserterror CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateCustomerContractLine()
    var
        InitialImportedServiceCommitment: Record "Imported Service Commitment";
        InitialCustomerContract: Record "Customer Contract";
    begin
        // [GIVEN] Create Imported Service Commitment with incorrect data for Customer Contract Line and
        // [WHEN] run Create Contract Line
        // [THEN] assert errors when running Create Contract Line
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentCustomer(ImportedServiceCommitment, ImportedServiceObject, CustomerContract, "Contract Line Type"::"Service Commitment");
        ImportedServiceCommitment.SetRecFilter();
        CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Service Commitment

        ImportedServiceCommitment."Contract No." := '';

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

    local procedure TestAssertErrorOnCreateCustomerContractLine(var InitialCustomerContract: Record "Customer Contract")
    begin
        CustomerContract.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        CustomerContract := InitialCustomerContract;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ExpectMultipleErrorsOnCreateVendorContractLine()
    var
        InitialImportedServiceCommitment: Record "Imported Service Commitment";
        InitialVendorContract: Record "Vendor Contract";
    begin
        // [GIVEN] Create Imported Service Commitment with incorrect data for Vendor Contract Line and
        // [WHEN] run Create Contract Line
        // [THEN] assert errors when running Create Contract Line
        SetupImportedServiceObjectAndCreateServiceObject();
        ContractTestLibrary.CreateImportedServiceCommitmentVendor(ImportedServiceCommitment, ImportedServiceObject, VendorContract, "Contract Line Type"::"Service Commitment");
        ImportedServiceCommitment.SetRecFilter();
        CreateServiceCommitment.Run(ImportedServiceCommitment);
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");
        InitialImportedServiceCommitment := ImportedServiceCommitment;
        Commit(); // retain Imported Service Commitment

        ImportedServiceCommitment."Contract No." := '';

        ImportedServiceCommitment.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        ImportedServiceCommitment := InitialImportedServiceCommitment;
        ImportedServiceCommitment.Modify(false);

        InitialVendorContract := VendorContract;
        VendorContract."Currency Code" := '';
        TestAssertErrorOnCreateVendorContractLine(InitialVendorContract);
    end;

    local procedure TestAssertErrorOnCreateVendorContractLine(var InitialVendorContract: Record "Vendor Contract")
    begin
        VendorContract.Modify(false);
        asserterror CreateContractLine.Run(ImportedServiceCommitment);
        VendorContract := InitialVendorContract;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure CheckCreateCustomerContractFromImportedCustomerContract()
    var
        BillToCustomer: Record Customer;
    begin
        ClearTestData();
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        LibrarySales.CreateCustomer(BillToCustomer);
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract, Customer."No.", BillToCustomer."No.");
        Commit(); // needed before Report.Run
        ImportedCustomerContract.Reset();
        Report.Run(Report::"Create Customer Contracts", false, false, ImportedCustomerContract); //MessageHandler

        ImportedCustomerContract.FindSet();
        ImportedCustomerContract.SetRange("Contract created", true);
        AssertThat.AreEqual(2, ImportedCustomerContract.Count(), 'Not all Imported Customer Contract lines are processed.');
    end;

    [Test]
    procedure ExpectErrorIfCustomerContractSeriesNoCannotBeSetManually()
    var
        NoSeries: Record "No. Series";
    begin
        // [GIVEN] No Series for Customer Contract cannot create manual numbers
        // [WHEN] Create Customer Contract from Imported Customer Contract
        // [THEN] Expect error on No Series
        ClearTestData();
        ServiceContractSetup.TestField("Customer Contract Nos.");
        NoSeries.Get(ServiceContractSetup."Customer Contract Nos.");
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Modify(true);
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        ImportedServiceObject.SetRecFilter();
        asserterror CreateCustomerContract.Run(ImportedCustomerContract);
    end;

    [Test]
    procedure ExpectMultipleErrorsOnCreateCustomerContractsFromImportedCustomerContract()
    var
        InitialImportedCustomerContract: Record "Imported Customer Contract";
    begin
        // [GIVEN] Create Imported Customer Contract with incorrect data and
        // [WHEN] run Create Customer Contract
        // [THEN] assert errors when running Create Customer Contract
        ClearTestData();
        ContractTestLibrary.CreateImportedCustomerContract(ImportedCustomerContract);
        ImportedServiceObject.SetRecFilter();
        InitialImportedCustomerContract := ImportedCustomerContract;
        Commit(); //retain data after assert errors

        ImportedCustomerContract."Contract created" := true;
        TestAssertErrorOnCreateCustomerContractRun(InitialImportedCustomerContract);

        ImportedCustomerContract."Sell-to Customer No." := '';
        TestAssertErrorOnCreateCustomerContractRun(InitialImportedCustomerContract);
    end;

    local procedure TestAssertErrorOnCreateCustomerContractRun(var InitialImportedCustomerContract: Record "Imported Customer Contract")
    begin
        ImportedCustomerContract.Modify(false);
        asserterror CreateCustomerContract.Run(ImportedCustomerContract);
        ImportedCustomerContract := InitialImportedCustomerContract;
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ImportServiceCommitmentWithEmptyInvoicingItemNo()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        // [GIVEN] Service Object with Service Commitment Item
        // [GIVEN] Imported Service Commitments without a value in "Invoicing Item No."
        ClearTestData();
        ContractTestLibrary.CreateImportedServiceObject(ImportedServiceObject, Customer."No.", '');
        Commit(); // needed before If Codeunit.Run
        Report.Run(Report::"Create Service Objects", false, false, ImportedServiceObject); //MessageHandler

        ImportedServiceCommitment.Init();
        ImportedServiceCommitment."Entry No." := 0;
        ImportedServiceCommitment."Service Object No." := ImportedServiceObject."Service Object No.";
        ImportedServiceCommitment."Contract Line Type" := Enum::"Contract Line Type"::"Service Commitment";
        ImportedServiceCommitment.Partner := "Service Partner"::Customer;
        ImportedServiceCommitment."Invoicing via" := "Invoicing Via"::Contract;
        ImportedServiceCommitment."Invoicing Item No." := '';
        ImportedServiceCommitment.Description := CopyStr(LibraryRandom.RandText(MaxStrLen(ImportedServiceCommitment.Description)), 1, MaxStrLen(ImportedServiceCommitment.Description));
        ContractTestLibrary.SetImportedServiceCommitmentData(ImportedServiceCommitment);
        ImportedServiceCommitment.Insert(false);

        // [WHEN] Creating Service Commitments
        Commit(); // needed before If Codeunit.Run
        Report.Run(Report::"Cr. Serv. Comm. And Contr. L.", false, false, ImportedServiceCommitment); //MessageHandler
        ImportedServiceCommitment.Get(ImportedServiceCommitment."Entry No.");

        // [THEN] Expect the Service Commitment Item to have the Item of the Service Object if it is a service commitment item
        ImportedServiceCommitment.TestField("Service Commitment created", true);
        ImportedServiceCommitment.TestField("Invoicing Item No.", '');

        ServiceCommitment.Get(ImportedServiceCommitment."Service Commitment Entry No.");
        AssertThat.AreEqual(ImportedServiceObject."Item No.", ServiceCommitment."Invoicing Item No.", 'The Invoicing Item No. should be taken from the Service Object if it is empty in the source and if the item is a service commitment item');
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ImportedCustomerContract: Record "Imported Customer Contract";
        ImportedServiceObject: Record "Imported Service Object";
        ImportedServiceCommitment: Record "Imported Service Commitment";
        ServiceContractSetup: Record "Service Contract Setup";
        Item: Record Item;
        ServiceObject: Record "Service Object";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ContractTestLibrary: Codeunit "Contract Test Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        AssertThat: Codeunit Assert;
        CreateServiceObject: Codeunit "Create Service Object";
        CreateCustomerContract: Codeunit "Create Customer Contract";
        CreateServiceCommitment: Codeunit "Create Service Commitment";
        CreateContractLine: Codeunit "Create Contract Line";
}