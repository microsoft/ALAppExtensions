#if CLEAN27
codeunit 139501 "Test UK Postcode Pages"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        PostcodeDummyService: Codeunit "Postcode Dummy Service";
        Initialized: Boolean;
        LookupTextTok: Label 'Lookup Text', Locked = true;
        RetrievedInvalidValueTok: Label 'Retrieved field value is incorrect.', Locked = true;

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
        LibraryLowerPermissions.SetCustomerView();

        // [WHEN] customer card is viewed
        CustomerCard.OpenView();

        // [THEN] Lookup address option is hidden
        Assert.IsFalse(CustomerCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsFalse(CustomerCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsTrue(CustomerCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        Assert.IsFalse(CustomerCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        CustomerCard."Country/Region Code".SetValue('');
        CustomerCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', CustomerCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', CustomerCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', CustomerCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', CustomerCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', CustomerCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        CustomerCard."Post Code".Value('');
        CustomerCard.City.Value('');
        CustomerCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        CustomerCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', CustomerCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CustomerCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CustomerCard."Post Code".Value, RetrievedInvalidValueTok);
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
        Assert.IsFalse(EmployeeCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsFalse(EmployeeCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsTrue(EmployeeCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        Assert.IsFalse(EmployeeCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmployeeScenarioSuccess()
    var
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
        EmployeeCard."Country/Region Code".SetValue('');
        EmployeeCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', EmployeeCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', EmployeeCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', EmployeeCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', EmployeeCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', EmployeeCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmployeeScenarioCancel()
    var
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
        EmployeeCard."Post Code".Value('');
        EmployeeCard.City.Value('');
        EmployeeCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        EmployeeCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', EmployeeCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', EmployeeCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
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
        Assert.IsFalse(ShiptoAddress.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ShiptoAddress.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupVisibleInEditModeGBCountry()
    var
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to GB
        ShiptoAddress.OpenEdit();
        ShiptoAddress."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ShiptoAddress.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShipToAddressLookupVisibleInEditModeNonGBCountry()
    var
        ShiptoAddress: TestPage "Ship-to Address";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        ShiptoAddress.OpenEdit();
        ShiptoAddress."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ShiptoAddress.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
    [Scope('OnPrem')]
    procedure TestShipToAddressScenarioSuccess()
    var
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
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] we assume successful process, copying fields
        ShiptoAddress.OpenEdit();
        ShiptoAddress."Country/Region Code".Value('GB');
        ShiptoAddress.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ShiptoAddress.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ShiptoAddress."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', ShiptoAddress."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ShiptoAddress.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', ShiptoAddress."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestShipToAddressScenarioCancel()
    var
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
        LibraryLowerPermissions.SetCustomerEdit();

        // [GIVEN] ensure blank address fields
        ShiptoAddress.OpenEdit();
        ShiptoAddress.Address.Value('');
        ShiptoAddress."Address 2".Value('');
        ShiptoAddress."Post Code".Value('');
        ShiptoAddress.City.Value('');
        ShiptoAddress."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        ShiptoAddress.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ShiptoAddress.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ShiptoAddress."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
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
        LibraryLowerPermissions.SetVendorView();

        // [WHEN] customer card is viewed
        VendorCard.OpenView();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(VendorCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsFalse(VendorCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsTrue(VendorCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        Assert.IsFalse(VendorCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        VendorCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', VendorCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', VendorCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', VendorCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', VendorCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', VendorCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        VendorCard."Post Code".Value('');
        VendorCard.City.Value('');
        VendorCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        VendorCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', VendorCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', VendorCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

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
        Assert.IsFalse(BankAccountCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [WHEN] customer card is opened
        BankAccountCard.OpenEdit();

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(BankAccountCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountLookupVisibleInEditModeGBCountry()
    var
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [WHEN] customer card is opened and country is set to GB
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(BankAccountCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [WHEN] customer card is opened and country is set to something other than GB
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(BankAccountCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [WHEN] we assume successful process, copying fields
        BankAccountCard.OpenEdit();
        BankAccountCard."Country/Region Code".Value('');
        BankAccountCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', BankAccountCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', BankAccountCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', BankAccountCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', BankAccountCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', BankAccountCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        LibraryLowerPermissions.SetSalesDocsCreate();

        // [GIVEN] ensure blank address fields
        BankAccountCard.OpenEdit();
        BankAccountCard.Address.Value('');
        BankAccountCard."Address 2".Value('');
        BankAccountCard."Post Code".Value('');
        BankAccountCard.City.Value('');
        BankAccountCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        BankAccountCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', BankAccountCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', BankAccountCard."Country/Region Code".Value, RetrievedInvalidValueTok);

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
        Assert.IsFalse(LocationCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(LocationCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        LocationCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(LocationCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        LocationCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(LocationCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
    [Scope('OnPrem')]
    procedure TestLocationScenarioSuccess()
    var
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
        LocationCard."Country/Region Code".Value('GB');
        LocationCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', LocationCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', LocationCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', LocationCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', LocationCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', LocationCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        LocationCard.Address.Value('');
        LocationCard."Address 2".Value('');
        LocationCard."Post Code".Value('');
        LocationCard.City.Value('');
        LocationCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        LocationCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', LocationCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', LocationCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
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
        Assert.IsFalse(ResourceCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ResourceCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ResourceCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
    [Scope('OnPrem')]
    procedure TesResourceScenarioSuccess()
    var
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
        ResourceCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ResourceCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ResourceCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', ResourceCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ResourceCard.City.Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestResourceScenarioCancel()
    var
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
        ResourceCard.Address.Value('');
        ResourceCard."Address 2".Value('');
        ResourceCard."Post Code".Value('');
        ResourceCard.City.Value('');

        // [WHEN] trigger postcode search
        ResourceCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ResourceCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ResourceCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ResourceCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ResourceCard.City.Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
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
        Assert.IsFalse(ContactCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        ContactCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ContactCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestContactLookupVisibleInEditModeNonGBCountry()
    var
        ContactCard: TestPage "Contact Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] customer card is opened and country is set to something other than GB
        ContactCard.OpenEdit();
        ContactCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] we assume successful process, copying fields
        ContactCard.OpenEdit();
        ContactCard."Country/Region Code".Value('GB');
        ContactCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ContactCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ContactCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', ContactCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ContactCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', ContactCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        LibraryLowerPermissions.SetCustomerEdit();

        // [GIVEN] ensure blank address fields
        ContactCard.OpenEdit();
        ContactCard.Address.Value('');
        ContactCard."Address 2".Value('');
        ContactCard."Post Code".Value('');
        ContactCard.City.Value('');
        ContactCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        ContactCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ContactCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
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
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        ContactAltAddressCard."Country/Region Code".Value('GB');

        // [THEN] postcode lookup action is visible
        Assert.IsTrue(ContactAltAddressCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        ContactAltAddressCard."Country/Region Code".Value('SI');

        // [THEN] postcode lookup action is visible
        Assert.IsFalse(ContactAltAddressCard.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        ContactAltAddressCard."Country/Region Code".Value('');
        ContactAltAddressCard.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', ContactAltAddressCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', ContactAltAddressCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', ContactAltAddressCard."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', ContactAltAddressCard.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', ContactAltAddressCard."Country/Region Code".Value, RetrievedInvalidValueTok);

        LibraryLowerPermissions.SetO365BusFull(); // for cleanup
        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        ContactAltAddressCard.Address.Value('');
        ContactAltAddressCard."Address 2".Value('');
        ContactAltAddressCard."Post Code".Value('');
        ContactAltAddressCard.City.Value('');
        ContactAltAddressCard."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        ContactAltAddressCard.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', ContactAltAddressCard.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactAltAddressCard."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', ContactAltAddressCard."Post Code".Value, RetrievedInvalidValueTok);
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
        Assert.IsFalse(CompanyInformation.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsFalse(CompanyInformation.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsTrue(CompanyInformation.LookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        Assert.IsFalse(CompanyInformation.LookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
    [Scope('OnPrem')]
    procedure TestCompanyInformationScenarioSuccess()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [SCENARIO] Postcode auto complete is initiated at company infromation page and successful:
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
        CompanyInformation."Country/Region Code".Value('GB');
        CompanyInformation.LookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', CompanyInformation.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', CompanyInformation."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', CompanyInformation."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', CompanyInformation.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', CompanyInformation."Country/Region Code".Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCompanyInformationScenarioCancel()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [SCENARIO] Postcode auto complete is initiated at company infromation page but canceled:
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
        CompanyInformation.Address.Value('');
        CompanyInformation."Address 2".Value('');
        CompanyInformation."Post Code".Value('');
        CompanyInformation.City.Value('');
        CompanyInformation."Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        CompanyInformation.LookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', CompanyInformation.Address.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation.City.Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Country/Region Code".Value, RetrievedInvalidValueTok);

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
        Assert.IsFalse(CompanyInformation.ShipToLookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
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
        Assert.IsFalse(CompanyInformation.ShipToLookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCompanyInformationShipToLookupVisibleInEditModeGBCountry()
    var
        CompanyInformation: TestPage "Company Information";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] customer card is opened and country is set to GB
        CompanyInformation.OpenEdit();
        CompanyInformation."Ship-to Country/Region Code".Value('GB');

        // [THEN] lookup link should be visible
        Assert.IsTrue(CompanyInformation.ShipToLookupAddress_GB.Visible(), ErrorMsgGenerator(true, LookupTextTok));

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
        Assert.IsFalse(CompanyInformation.ShipToLookupAddress_GB.Visible(), ErrorMsgGenerator(false, LookupTextTok));

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchScenarioModalPageHandler,PostcodeAddressPickerScenarioPageHandler')]
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
        CompanyInformation."Country/Region Code".Value('');
        CompanyInformation.ShipToLookupAddress_GB.DrillDown(); // trigger postcode search
        // PostcodeSearchScenario page handler takes over and inputs postcode
        // PostcodeAddressPickerScenario page handler takes over and selects address

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', CompanyInformation."Ship-to Address".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('ADDRESS 2', CompanyInformation."Ship-to Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('POSTCODE', CompanyInformation."Ship-to Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('CITY', CompanyInformation."Ship-to City".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('COUNTRY', CompanyInformation."Ship-to Country/Region Code".Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchCancelModalPageHandler')]
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
        CompanyInformation."Ship-to Post Code".Value('');
        CompanyInformation."Ship-to City".Value('');
        CompanyInformation."Ship-to Country/Region Code".Value('');

        // [WHEN] trigger postcode search
        CompanyInformation.ShipToLookupAddress_GB.DrillDown();
        // PostcodeSearch cancel page handler takes over and cancels the process

        // [THEN] address fields should stay blank
        Assert.AreEqual('', CompanyInformation."Ship-to Address".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to Address 2".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to Post Code".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to City".Value, RetrievedInvalidValueTok);
        Assert.AreEqual('', CompanyInformation."Ship-to Country/Region Code".Value, RetrievedInvalidValueTok);

        TearDown();
    end;

    local procedure Initialize()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
    begin
        BindSubscription(PostcodeDummyService);

        if Initialized then
            exit;

        PostcodeServiceConfig.DeleteAll();

        PostcodeServiceConfig.Init();
        PostcodeServiceConfig.Insert();
        PostcodeServiceConfig.SaveServiceKey('Dummy Service');

        PostcodeNotificationMemory.DeleteAll();
        PostcodeNotificationMemory.Init();
        PostcodeNotificationMemory.UserId := UserId;
        PostcodeNotificationMemory.Insert();

        Initialized := true;
    end;

    [Scope('OnPrem')]
    procedure Teardown()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        UnbindSubscription(PostcodeDummyService);
        PostcodeServiceConfig.DeleteAll();
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
    procedure PostcodeSearchScenarioModalPageHandler(var PostcodeSearch: TestPage "Postcode Search")
    begin
        PostcodeSearch.PostcodeField.Value('POSTCODE');
        PostcodeSearch.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeSearchCancelModalPageHandler(var PostcodeSearch: TestPage "Postcode Search")
    begin
        PostcodeSearch.Cancel().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeAddressPickerScenarioPageHandler(var PostcodeSelectAddress: TestPage "Postcode Select Address")
    begin
        PostcodeSelectAddress.GotoKey(3);
        PostcodeSelectAddress.OK().Invoke();
    end;
}
#endif