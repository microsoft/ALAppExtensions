codeunit 139681 "GP Settings Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GPTestHelperFunctions: Codeunit "GP Test Helper Functions";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestInitialSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [THEN] The settings are initialized with the correct default values
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 1');

        Assert.AreEqual('Company 1', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestAllSettingsEnabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [WHEN] All settings are enabled
        GPCompanyAdditionalSettings.Get('Company 2');

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestBankModuleAutoSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [WHEN] The Bank module setting is disabled
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 2');
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');

        // [WHEN] Inactive checkbooks is enabled, then the bank module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // [THEN] These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPayablesModuleAutoSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [WHEN] The Payables module setting is disabled
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 2');
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // [THEN] These settings should all be correct
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');

        // [WHEN] Inactive Vendors is enabled, then the Payables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');

        // [WHEN] Open POs is enabled, then the Payables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');

        // [WHEN] Vendor Classes is enabled, then the Payables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestReceivablesModuleAutoSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [WHEN] The Receivables module setting is disabled
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 2');
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');

        // [WHEN] Inactive Customers is enabled, then the Receivables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Customers", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');

        // [WHEN] Open POs is enabled, then the Receivables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');

        // [WHEN] Customer Classes is enabled, then the Receivables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect in value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestInventoryModuleAutoSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        // [WHEN] The Receivables module setting is disabled
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 2');
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value 1');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');

        // [WHEN] Item Classes is enabled, then the Inventory module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value 2');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Migrate  GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');

        // [WHEN] Open POs is enabled, then the Inventory, Payables, and Receivables modules must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 1", 'Global Dimension 1 - Incorrect value');
        Assert.AreEqual('', GPCompanyAdditionalSettings."Global Dimension 2", 'Global Dimension 2 - Incorrect value');
        Assert.AreEqual(0, GPCompanyAdditionalSettings."Oldest GL Year To Migrate", 'Oldest GL Year To Migrate - Incorrect value');

        // These settings should all be correct
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value 3');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPostMigrationChecks()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
    begin
        // [SCENARIO] Settings are created
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();

        // [WHEN] Fiscal Periods haven't been created yet, and all modules are turned off
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPConfiguration.Validate("Fiscal Periods Created", false);

        // [THEN] IsAllPostMigrationDataCreated will be false
        Assert.IsFalse(GPConfiguration.IsAllPostMigrationDataCreated(), 'Should return false');

        // [WHEN] Configured to migrate, and the entries have not yet been created
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPConfiguration.Validate("Fiscal Periods Created", true);

        // [THEN] IsAllPostMigrationDataCreated will be false
        Assert.IsFalse(GPConfiguration.IsAllPostMigrationDataCreated(), 'Should return false because the entries have not yet been created.');

        // [WHEN] Configured to migrate, and the entries have not yet been created
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPConfiguration.Validate("Fiscal Periods Created", true);
        GPConfiguration.Validate("CheckBooks Created", true);
        GPConfiguration.Validate("Open Purchase Orders Created", true);
        GPConfiguration.Validate("Vendor EFT Bank Acc. Created", true);
        GPConfiguration.Validate("Vendor Classes Created", true);
        GPConfiguration.Validate("Customer Classes Created", true);

        // [THEN] IsAllPostMigrationDataCreated will be true
        Assert.IsTrue(GPConfiguration.IsAllPostMigrationDataCreated(), 'Should return true because all of the entries should be created.');
    end;

    local procedure CreateSettingsTableEntries()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        CompanyNameText: Text[30];
    begin
        CompanyNameText := 'Company 1';
        GPCompanyAdditionalSettings.Name := CompanyNameText;
        GPCompanyAdditionalSettings.Insert();

        GPCompanyMigrationSettings.Init();
        GPCompanyMigrationSettings.Name := CompanyNameText;
        GPCompanyMigrationSettings.Insert();

        CompanyNameText := 'Company 2';
        GPCompanyAdditionalSettings.Init();
        GPCompanyAdditionalSettings.Name := CompanyNameText;
        GPCompanyAdditionalSettings.Insert();

        GPCompanyMigrationSettings.Init();
        GPCompanyMigrationSettings.Name := CompanyNameText;
        GPCompanyMigrationSettings.Insert();
        TurnOnAllSettings(GPCompanyAdditionalSettings);

        CompanyNameText := 'Company 3';
        GPCompanyAdditionalSettings.Init();
        GPCompanyAdditionalSettings.Name := CompanyNameText;
        GPCompanyAdditionalSettings.Insert();

        GPCompanyMigrationSettings.Init();
        GPCompanyMigrationSettings.Name := CompanyNameText;
        GPCompanyMigrationSettings.Insert();
    end;

    local procedure TurnOnAllSettings(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    begin
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Customers", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", true);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only GL Master", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", true);
        GPCompanyAdditionalSettings.Modify();
    end;
}