namespace Microsoft.Foundation.Address.IdealPostcodes.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.CRM.Contact;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Address.IdealPostcodes;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 148121 "Test IdealPostcodes Pages"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryHR: Codeunit "Library - Human Resource";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        PostcodeDummyService: Codeunit "Postcode Dummy Service";
        Initialized: Boolean;
        LookupTextTok: Label 'Lookup Text', Locked = true;
        RetrievedInvalidValueTok: Label 'Retrieved field value is incorrect.', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountLookupHiddenInViewMode()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [WHEN] customer card is viewed
        BankAccountCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(BankAccountCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountrLookupHidenInEditModeServiceNotConfigured()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service

        // [WHEN] customer card is opened
        BankAccountCard.OpenEdit();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(BankAccountCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
        Teardown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountLookupVisibleInEditModeGBCountry()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();

        // [WHEN] customer card is opened and country is set to GB
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(BankAccountCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountLookupVisibleInEditModeNonGBCountry()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();

        // [WHEN] customer card is opened and country is set to something other than GB
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(BankAccountCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestBankAccountScenarioSuccess()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at bank account page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();

        // [WHEN] we assume successful process, copying fields
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('');
        BankAccountCard."Post Code".Value('TESTPOSTCODE');
        BankAccountCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                                  // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', BankAccountCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', BankAccountCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', BankAccountCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', BankAccountCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', BankAccountCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestBankAccountScenarioCancel()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at bank account page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();

        // [GIVEN] ensure blank address fields
        BankAccountCard.OpenEdit();
        BankAccountCard.Address.Value('');
        BankAccountCard."Address 2".Value('');
        BankAccountCard.City.Value('');
        BankAccountCard."Country/Region Code".Value('');
        BankAccountCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        BankAccountCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', BankAccountCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', BankAccountCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerLookupHiddenInViewMode()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service

        // [WHEN] customer card is viewed
        CustomerCard.OpenView();

        // [THEN] Lookup address option is hidden
        Assert.IsFalse(CustomerCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerLookupHidenInEditModeServiceNotConfigured()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened
        CustomerCard.OpenEdit();

        // [THEN] Lookup address option is hidden
        Assert.IsFalse(CustomerCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerLookupVisibleInEditModeGBCountry()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to GB
        CustomerCard.OpenEdit();
        CustomerCard."Country/Region Code".Value('GB');

        // [THEN] Lookup address option is visible
        Assert.IsTrue(CustomerCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCustomerLookupVisibleInEditModeNonGBCountry()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        CustomerCard.OpenEdit();
        CustomerCard."Country/Region Code".Value('SI');

        // [THEN] lookup text is visible, postcode lookup field is visible
        Assert.IsFalse(CustomerCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestCustomerScenarioSuccess()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at customer page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] we assume successful process, copying fields
        CustomerCard.OpenEdit();
        CustomerCard."Country/Region Code".Value('');
        CustomerCard."Post Code".Value('TESTPOSTCODE');
        CustomerCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                               // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', CustomerCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', CustomerCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', CustomerCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', CustomerCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', CustomerCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestCustomerScenarioCancel()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at customer page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [GIVEN] ensure blank address fields
        CustomerCard.OpenEdit();
        CustomerCard.Address.Value('');
        CustomerCard."Address 2".Value('');
        CustomerCard.City.Value('');
        CustomerCard."Country/Region Code".Value('');
        CustomerCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        CustomerCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', CustomerCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CustomerCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', CustomerCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CustomerCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CustomerCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEmployeeLookupHiddenInViewMode()
    var
        EmployeeCard: TestPage "Employee Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365HRView();

        // [WHEN] customer card is viewed
        EmployeeCard.OpenView();

        // [THEN] Lookup address option is hidden
        Assert.IsFalse(EmployeeCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEmployeeLookupHidenInEditModeServiceNotConfigured()
    var
        EmployeeCard: TestPage "Employee Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365HREdit();

        // [WHEN] customer card is opened
        EmployeeCard.OpenEdit();

        // [THEN] Lookup address option is hidden
        Assert.IsFalse(EmployeeCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEmployeeLookupVisibleInEditModeGBCountry()
    var
        EmployeeCard: TestPage "Employee Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365HREdit();

        // [WHEN] customer card is opened and country is set to GB
        EmployeeCard.OpenEdit();
        EmployeeCard."Country/Region Code".Value('GB');

        // [THEN] Lookup address option is visible
        Assert.IsTrue(EmployeeCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEmployeeLookupVisibleInEditModeNonGBCountry()
    var
        EmployeeCard: TestPage "Employee Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365HREdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        EmployeeCard.OpenEdit();
        EmployeeCard."Country/Region Code".Value('SI');

        // [THEN] lookup text is visible, postcode lookup field is visible
        Assert.IsFalse(EmployeeCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestEmployeeScenarioSuccess()
    var
        PostCode: Record "Post Code";
        EmployeeCard: TestPage "Employee Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at customer page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365HREdit();

        // [WHEN] we assume successful process, copying fields
        EmployeeCard.OpenEdit();
        EmployeeCard."Country/Region Code".Value('');
        EmployeeCard."Post Code".Value('TESTPOSTCODE');
        EmployeeCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', EmployeeCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', EmployeeCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', EmployeeCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', EmployeeCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', EmployeeCard."Country/Region Code".Value, RetrievedInvalidValueTok);
        PostCode.SetRange(Code, 'TESTPOSTCODE');
        Assert.IsFalse(PostCode.IsEmpty(), 'Postcode record was not created.');

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestEmployeeScenarioCancel()
    var
        PostCode: Record "Post Code";
        EmployeeCard: TestPage "Employee Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at customer page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365HREdit();

        // [GIVEN] ensure blank address fields
        EmployeeCard.OpenEdit();
        EmployeeCard.Address.Value('');
        EmployeeCard."Address 2".Value('');
        EmployeeCard.City.Value('');
        EmployeeCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search via validate
        EmployeeCard."Post Code".Value('TESTPOSTCODE');
        EmployeeCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', EmployeeCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', EmployeeCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard."Country/Region Code".Value, RetrievedInvalidValueTok);
        PostCode.SetRange(Code, 'TESTPOSTCODE');
        Assert.IsTrue(PostCode.IsEmpty(), 'Postcode record was unexpectedly created.');

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        EmployeeCard.Close();
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupHiddenInViewMode()
    var
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerView();

        // [WHEN] customer card is viewed
        ShiptoAddress.OpenView();

        // [THEN] regular postcode fields are visible instead of lookup fields
        Assert.IsFalse(ShiptoAddress.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupHidenInEditModeServiceNotConfigured()
    var
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened
        ShiptoAddress.OpenEdit();
        ShiptoAddress.New();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ShiptoAddress.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupVisibleInEditModeGBCountry()
    var
        Customer: Record Customer;
        ShiptoAddressRec: Record "Ship-to Address";
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateShipToAddress(ShiptoAddressRec, Customer."No.");

        // [WHEN] customer card is opened and country is set to GB
        ShiptoAddress.OpenEdit();
        ShiptoAddress.GoToRecord(ShiptoAddressRec);
        ShiptoAddress."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ShiptoAddress.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupVisibleInEditModeNonGBCountry()
    var
        Customer: Record Customer;
        ShiptoAddressRec: Record "Ship-to Address";
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateShipToAddress(ShiptoAddressRec, Customer."No.");

        // [WHEN] customer card is opened and country is set to GB
        ShiptoAddress.OpenEdit();
        ShiptoAddress.GoToRecord(ShiptoAddressRec);
        ShiptoAddress."Country/Region Code".Value('GB');
        ShiptoAddress."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ShiptoAddress.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestShipToAddressScenarioSuccess()
    var
        Customer: Record Customer;
        ShipToAddressRec: Record "Ship-to Address";
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [SCENARIO] Postcode auto complete is initiated at ship to address page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateShipToAddress(ShipToAddressRec, Customer."No.");

        // [WHEN] we assume successful process, copying fields
        ShiptoAddress.OpenEdit();
        ShiptoAddress.GoToRecord(ShipToAddressRec);
        ShiptoAddress."Country/Region Code".Value('');
        ShiptoAddress."Post Code".Value('TESTPOSTCODE');
        ShiptoAddress.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                                // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ShiptoAddress.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ShiptoAddress."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ShiptoAddress."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ShiptoAddress.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', ShiptoAddress."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestShipToAddressScenarioCancel()
    var
        Customer: Record Customer;
        ShiptoAddressRec: Record "Ship-to Address";
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [SCENARIO] Postcode auto complete is initiated at ship to address page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateShipToAddress(ShiptoAddressRec, Customer."No.");

        // [GIVEN] ensure blank address fields
        ShiptoAddress.OpenEdit();
        ShiptoAddress.GoToRecord(ShiptoAddressRec);
        ShiptoAddress.Address.Value('');
        ShiptoAddress."Address 2".Value('');
        ShiptoAddress.City.Value('');
        ShiptoAddress."Country/Region Code".Value('');
        ShiptoAddress."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        ShiptoAddress.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ShiptoAddress.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ShiptoAddress."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestLocationLookupHiddenInViewMode()
    var
        LocationCard: TestPage "Location Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is viewed
        LocationCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(LocationCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestLocationLookupHidenInEditModeServiceNotConfigured()
    var
        LocationCard: TestPage "Location Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened
        LocationCard.OpenEdit();
        LocationCard.New();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(LocationCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestLocationLookupVisibleInEditModeGBCountry()
    var
        LocationCard: TestPage "Location Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to GB
        LocationCard.OpenEdit();
        LocationCard.New();
        LocationCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(LocationCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestLocationLookupVisibleInEditModeNonGBCountry()
    var
        LocationCard: TestPage "Location Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to something other than GB
        LocationCard.OpenEdit();
        LocationCard.New();
        LocationCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(LocationCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestLocationScenarioSuccess()
    var
        Location: Record Location;
        LocationCard: TestPage "Location Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at location page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] we assume successful process, copying fields
        LocationCard.OpenEdit();
        LocationCard.New();
        LocationCard.Code.Value(LibraryRandom.RandText(10));
        LocationCard."Country/Region Code".Value('');
        LocationCard."Post Code".Value('TESTPOSTCODE');
        LocationCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                               // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', LocationCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', LocationCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', LocationCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', LocationCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', LocationCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        Location.Get(LocationCard.Code.Value);
        LocationCard.Close();
        Location.Delete();
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestLocationScenarioCancel()
    var
        LocationCard: TestPage "Location Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at location page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [GIVEN] ensure blank address fields
        LocationCard.OpenEdit();
        LocationCard.New();
        LocationCard.Code.Value(LibraryRandom.RandText(10));
        LocationCard.Address.Value('');
        LocationCard."Address 2".Value('');
        LocationCard.City.Value('');
        LocationCard."Country/Region Code".Value('');
        LocationCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        LocationCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', LocationCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', LocationCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        LocationCard.Close();
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestResourceLookupHiddenInViewMode()
    var
        ResourceCard: TestPage "Resource Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is viewed
        ResourceCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ResourceCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestResourceLookupHidenInEditModeServiceNotConfigured()
    var
        ResourceCard: TestPage "Resource Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened
        ResourceCard.OpenEdit();
        ResourceCard.New();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ResourceCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestResourceLookupVisibleInEditModeServiceConfigured()
    var
        ResourceCard: TestPage "Resource Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened
        ResourceCard.OpenEdit();
        ResourceCard.New();

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ResourceCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TesResourceScenarioSuccess()
    var
        Resource: Record Resource;
        ResourceCard: TestPage "Resource Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at resource page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] we assume successful process, copying fields
        ResourceCard.OpenEdit();
        ResourceCard.New();
        ResourceCard."Country/Region Code".Value('');
        ResourceCard."Post Code".Value('TESTPOSTCODE');
        ResourceCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                               // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ResourceCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ResourceCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ResourceCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ResourceCard.City.Value, RetrievedInvalidValueTok);

        Resource.Get(ResourceCard."No.".Value);
        ResourceCard.Close();
        Resource.Delete();
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestResourceScenarioCancel()
    var
        Resource: Record Resource;
        ResourceCard: TestPage "Resource Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at resource page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [GIVEN] ensure blank address fields
        ResourceCard.OpenEdit();
        ResourceCard.New();
        ResourceCard.Address.Value('');
        ResourceCard."Address 2".Value('');
        ResourceCard.City.Value('');
        ResourceCard."Country/Region Code".Value('');
        ResourceCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        ResourceCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ResourceCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ResourceCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ResourceCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ResourceCard.City.Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        Resource.Get(ResourceCard."No.".Value);
        ResourceCard.Close();
        Resource.Delete();
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactLookupHiddenInViewMode()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is viewed
        ContactCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactLookupHidenInEditModeServiceNotConfigured()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened
        ContactCard.OpenEdit();
        ContactCard.New();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactLookupVisibleInEditModeGBCountry()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to GB
        ContactCard.OpenEdit();
        ContactCard.New();
        ContactCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ContactCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactLookupVisibleInEditModeNonGBCountry()
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();

        // [WHEN] customer card is opened and country is set to something other than GB
        ContactCard.OpenEdit();
        ContactCard.New();
        ContactCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        Contact.Get(ContactCard."No.".Value);
        ContactCard.Close();
        Contact.Delete();
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestContactScenarioSuccess()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at contact page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();

        // [WHEN] we assume successful process, copying fields
        ContactCard.OpenEdit();
        ContactCard.New();
        ContactCard."Country/Region Code".Value('');
        ContactCard."Post Code".Value('TESTPOSTCODE');
        ContactCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                              // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ContactCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ContactCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ContactCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ContactCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', ContactCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        ContactCard.Close();
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestContactScenarioCancel()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at contact page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();

        // [GIVEN] ensure blank address fields
        ContactCard.OpenEdit();
        ContactCard.New();
        ContactCard.Address.Value('');
        ContactCard."Address 2".Value('');
        ContactCard.City.Value('');
        ContactCard."Country/Region Code".Value('');
        ContactCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        ContactCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ContactCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ContactCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        ContactCard.Close();
        Teardown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactAltAddrLookupHiddenInViewMode()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is viewed
        ContactAltAddressCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactAltAddrLookupHidenInEditModeServiceNotConfigured()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened
        ContactAltAddressCard.OpenEdit();
        ContactAltAddressCard.New();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactAltAddrLookupVisibleInEditModeGBCountry()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to GB
        ContactAltAddressCard.OpenEdit();
        ContactAltAddressCard.New();
        ContactAltAddressCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ContactAltAddressCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactAltAddrLookupVisibleInEditModeNonGBCountry()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        ContactAltAddressCard.OpenEdit();
        ContactAltAddressCard.New();
        ContactAltAddressCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestContactAltAddrScenarioSuccess()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at contact alternative address page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] we assume successful process, copying fields
        ContactAltAddressCard.OpenEdit();
        ContactAltAddressCard.New();
        ContactAltAddressCard.Code.Value(LibraryRandom.RandText(10));
        ContactAltAddressCard."Country/Region Code".Value('');
        ContactAltAddressCard."Post Code".Value('TESTPOSTCODE');
        ContactAltAddressCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                                        // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ContactAltAddressCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ContactAltAddressCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ContactAltAddressCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ContactAltAddressCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', ContactAltAddressCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestContactAltAddrScenarioCancel()
    var
        ContactAltAddressCard: TestPage "Contact Alt. Address Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at contact alternative address page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [GIVEN] ensure blank address fields
        ContactAltAddressCard.OpenEdit();
        ContactAltAddressCard.Code.Value(LibraryRandom.RandText(10));
        ContactAltAddressCard.Address.Value('');
        ContactAltAddressCard."Address 2".Value('');
        ContactAltAddressCard.City.Value('');
        ContactAltAddressCard."Country/Region Code".Value('');
        ContactAltAddressCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        ContactAltAddressCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ContactAltAddressCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactAltAddressCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', ContactAltAddressCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactAltAddressCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactAltAddressCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationLookupHiddenInViewMode()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is viewed
        CompanyInformation.OpenView();

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationLookupHidenInEditModeServiceNotConfigured()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened
        CompanyInformation.OpenEdit();

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationLookupVisibleInEditModeGBCountry()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to GB
        CompanyInformation.OpenEdit();
        CompanyInformation."Country/Region Code".Value('GB');

        // [THEN] lookup link should be visible
        Assert.IsTrue(CompanyInformation.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationLookupVisibleInEditModeNonGBCountry()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to something other than GB
        CompanyInformation.OpenEdit();
        CompanyInformation."Country/Region Code".Value('SI');

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToLookupHiddenInViewMode()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is viewed
        CompanyInformation.OpenView();

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupShipToAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToLookupHidenInEditModeServiceNotConfigured()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened
        CompanyInformation.OpenEdit();

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupShipToAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToLookupVisibleInEditModeBlankCountry()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to blank
        CompanyInformation.OpenEdit();
        CompanyInformation."Ship-to Country/Region Code".Value('');

        // [THEN] lookup link should be visible
        Assert.IsTrue(CompanyInformation.LookupShipToAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToLookupVisibleInEditModeNonGBCountry()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to something other than GB
        CompanyInformation.OpenEdit();
        CompanyInformation."Ship-to Country/Region Code".Value('SI');

        // [THEN] lookup link should be visible
        Assert.IsFalse(CompanyInformation.LookupShipToAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToScenarioSuccess()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [SCENARIO] Postcode auto complete is initiated at company infromation (ship to) page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] we assume successful process, copying fields
        CompanyInformation.OpenEdit();
        CompanyInformation."Ship-to Country/Region Code".Value('');
        CompanyInformation."Ship-to Post Code".Value('TESTPOSTCODE');
        CompanyInformation.LookupShipToAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                                           // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', CompanyInformation."Ship-to Address".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', CompanyInformation."Ship-to Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', CompanyInformation."Ship-to Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', CompanyInformation."Ship-to City".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', CompanyInformation."Ship-to Country/Region Code".Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToScenarioCancel()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [SCENARIO] Postcode auto complete is initiated at company infromation (ship to) page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [GIVEN] ensure blank address fields
        CompanyInformation.OpenEdit();
        CompanyInformation."Ship-to Address".Value('');
        CompanyInformation."Ship-to Address 2".Value('');
        CompanyInformation."Ship-to City".Value('');
        CompanyInformation."Ship-to Country/Region Code".Value('');
        CompanyInformation."Ship-to Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        CompanyInformation.LookupShipToAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', CompanyInformation."Ship-to Address".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', CompanyInformation."Ship-to Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to City".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to Country/Region Code".Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorLookupHiddenInViewMode()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service

        // [WHEN] customer card is viewed
        VendorCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(VendorCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorLookupHidenInEditModeServiceNotConfigured()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [GIVEN] postcode service is not configured
        // - Unbind dummy service so it won't raise an error
        Initialize();
        TearDown(); // unbind dummy service
        LibraryLowerPermissions.SetVendorEdit();

        // [WHEN] customer card is opened
        VendorCard.OpenEdit();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(VendorCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorLookupVisibleInEditModeGBCountry()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetVendorEdit();

        // [WHEN] customer card is opened and country is set to GB
        VendorCard.OpenEdit();
        VendorCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(VendorCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestVendorLookupVisibleInEditModeNonGBCountry()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetVendorEdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        VendorCard.OpenEdit();
        VendorCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(VendorCard.LookupAddress_IdealPostcodes.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestVendorScenarioSuccess()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at vendor page and successful:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Selects 3rd
        // 4. Values are populated

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetVendorEdit();

        // [WHEN] we assume successful process, copying fields
        VendorCard.OpenEdit();
        VendorCard."Country/Region Code".Value('');
        VendorCard."Post Code".Value('TESTPOSTCODE');
        VendorCard.LookupAddress_IdealPostcodes.DrillDown(); // trigger postcode search
                                                             // PostcodeSearchScenario page handler takes over and inputs postcode

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', VendorCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', VendorCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', VendorCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', VendorCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('GB', VendorCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler,IdealPostCodesHttpClientHandler')]
    [Scope('OnPrem')]
    procedure TestVendorScenarioCancel()
    var
        VendorCard: TestPage "Vendor Card";
    begin
        // [SCENARIO] Postcode auto complete is initiated at vendor page but canceled:
        // 1. User clicks postcode lookup
        // 2. Enters a valid postcode with multiple results
        // 3. Cancel the window
        // 4. Values are left empty

        // [GIVEN]
        // - Service is configured
        // - Retrieve a result with one address, so that values are
        // automatically set
        Initialize();
        LibraryLowerPermissions.SetVendorEdit();

        // [GIVEN] ensure blank address fields
        VendorCard.OpenEdit();
        VendorCard.Address.Value('');
        VendorCard."Address 2".Value('');
        VendorCard.City.Value('');
        VendorCard."Country/Region Code".Value('');
        VendorCard."Post Code".Value('TESTPOSTCODE');

        // [WHEN] trigger postcode search
        VendorCard.LookupAddress_IdealPostcodes.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', VendorCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('TESTPOSTCODE', VendorCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    local procedure Initialize()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
        CountryRegion: Record "Country/Region";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        IPCConfig: Record "IPC Config";
        PostCode: Record "Post Code";
        BankAccount: Record "Bank Account";
        LibraryERM: Codeunit "Library - ERM";
        APIKeyGuid: Guid;
        MyServiceKeyTok: Label 'IDEAL_POSTCODE_POSTCODE_SERVICE', Locked = true;
    begin
        UnbindSubscription(PostcodeDummyService);
        BindSubscription(PostcodeDummyService);

        PostCode.SetRange(Code, 'TESTPOSTCODE');
        PostCode.DeleteAll();

        if BankAccount.IsEmpty() then
            LibraryERM.CreateBankAccount(BankAccount);

        if Customer.IsEmpty() then
            LibrarySales.CreateCustomer(Customer);

        if Vendor.IsEmpty() then
            LibraryPurchase.CreateVendor(Vendor);

        if Employee.IsEmpty() then
            LibraryHR.CreateEmployee(Employee);

        if not CountryRegion.Get('GB') then begin
            CountryRegion.Init();
            CountryRegion.Code := 'GB';
            CountryRegion.Name := 'Great Britain';
            CountryRegion.Insert();
        end;

        if not CountryRegion.Get('SI') then begin
            CountryRegion.Init();
            CountryRegion.Code := 'SI';
            CountryRegion.Name := 'Slovenia';
            CountryRegion.Insert();
        end;

        PostcodeServiceConfig.DeleteAll();

        PostcodeServiceConfig.Init();
        PostcodeServiceConfig.Insert();
        PostcodeServiceConfig.SaveServiceKey(MyServiceKeyTok);
        if not IPCConfig.Get() then begin
            IPCConfig.Init();
            IPCConfig.Enabled := true;
            ApiKeyGuid := CreateGuid();
            IPCConfig."API Key" := ApiKeyGuid;
            IPCConfig.Insert();
            IPCConfig.SaveAPIKeyAsSecret(ApiKeyGuid, SecretStrSubstNo('apikey'));
        end else begin
            IPCConfig.Enabled := true;
            ApiKeyGuid := CreateGuid();
            IPCConfig."API Key" := ApiKeyGuid;
            IPCConfig.Modify();
            IPCConfig.SaveAPIKeyAsSecret(ApiKeyGuid, SecretStrSubstNo('apikey'));
        end;
        Commit();
        Initialized := true;
    end;

    [Scope('OnPrem')]
    procedure Teardown()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
        IPCConfig: Record "IPC Config";
    begin
        UnbindSubscription(PostcodeDummyService);
        PostcodeServiceConfig.DeleteAll();
        IPCConfig.DeleteAll();
        Commit();
        Initialized := false;
    end;

    local procedure ErrorMsgGenerator(Visible: Boolean; FieldName: Text): Text
    var
        ErrorMsg: Text;
        ServiceConfigured: Boolean;
    begin
        ErrorMsg := FieldName + ' should be ';
        ServiceConfigured := Initialized; // Bound indirectly indicates if the service is configured

        if Visible then
            ErrorMsg := ErrorMsg + 'VISIBLE'
        else
            ErrorMsg := ErrorMsg + 'HIDDEN';

        ErrorMsg := ErrorMsg + ' if service is ';

        if ServiceConfigured then
            ErrorMsg := ErrorMsg + 'configured'
        else
            ErrorMsg := ErrorMsg + 'NOT configured';

        ErrorMsg := ErrorMsg + '.';
        exit(ErrorMsg);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeSearchScenarioModalPageHandler(var IPCAddressLookup: TestPage "IPC Address Lookup")
    begin
        IPCAddressLookup."Post Code".Value('TESTPOSTCODE');
        IPCAddressLookup.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeSearchCancelModalPageHandler(var IPCAddressLookup: TestPage "IPC Address Lookup")
    begin
        IPCAddressLookup.Cancel().Invoke();
    end;

    [HttpClientHandler]
    procedure IdealPostCodesHttpClientHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        IPCConfig: Record "IPC Config";
        URLTxt: Text;
        InStream: InStream;
        ResourceName: Text;
    begin
        URLTxt := IPCConfig.APIEndpoint();
        case Request.Path of
            URLTxt + '/postcodes/TESTPOSTCODE':
                ResourceName := 'SearchAddress_TESTPOSTCODE.json';
            else
                exit(true);
        end;

        NavApp.GetResource(ResourceName, InStream);
        Response.Content.WriteFrom(InStream);
        Response.HttpStatusCode := 200;
        exit(false);
    end;

}
