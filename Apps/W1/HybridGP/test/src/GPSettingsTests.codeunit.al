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
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Kit Items", 'Migrate Kit Items - Incorrect value.');
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
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Temporary Vendors", 'Migrate Temporary Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Checkbooks", 'Migrate Inactive Checkbooks - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value');
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
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Temporary Vendors", 'Migrate Temporary Vendors - Incorrect value');
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

        // [WHEN] Open POs is enabled, then the Payables module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Temporary Vendors", true);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] Payables Module should be reactivated
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
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
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Kit Items", 'Migrate Kit Items - Incorrect value');

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
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value (from enabling Item Classes)');
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

        // [WHEN] Inactive Items is enabled, then the Inventory module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", true);
        GPCompanyAdditionalSettings.Modify();
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value (from enabling Inactive items).');

        // [WHEN] Kit Items is enabled, then the Inventory module must be enabled
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", true);
        GPCompanyAdditionalSettings.Modify();
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value (from enabling Kit items).');
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

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGLModuleAutoSettings()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // [SCENARIO] Settings are initiated for each company to be migrated from GP

        // [GIVEN] Some records are created in the settings table
        CreateSettingsTableEntries();

        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Get('Company 2');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Initial value for Migrate GL Module is incorrect.');

        // Reset master data to default values
        GPCompanyAdditionalSettings."Migrate Only GL Master" := false;
        GPCompanyAdditionalSettings."Migrate Only Bank Master" := false;
        GPCompanyAdditionalSettings."Migrate Only Inventory Master" := false;
        GPCompanyAdditionalSettings."Migrate Only Payables Master" := false;
        GPCompanyAdditionalSettings."Migrate Only Rec. Master" := false;

        // [WHEN] The GL module setting is disabled
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // [THEN] The record will have the correct values
        Assert.AreEqual('Company 2', GPCompanyAdditionalSettings.Name, 'Incorrect company settings found');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Customers", 'Migrate Inactive Customers - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inactive Vendors", 'Migrate Inactive Vendors - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Payables Module", 'Migrate Payables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Receivables Module", 'Migrate Receivables Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Inventory Module", 'Migrate Inventory Module - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Bank Module", 'Migrate Bank Module - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Open POs", 'Migrate Open POs - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Vendor Classes", 'Migrate Vendor Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Customer Classes", 'Migrate Customer Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Item Classes", 'Migrate Item Classes - Incorrect value');
        Assert.AreEqual(false, GPCompanyAdditionalSettings."Migrate Only GL Master", 'Migrate Only GL Master - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Only Bank Master", 'Migrate Only Bank Master - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Only Inventory Master", 'Migrate Only Inventory Master - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Only Payables Master", 'Migrate Only Payables Master - Incorrect value');
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate Only Rec. Master", 'Migrate Only Rec. Master - Incorrect value');

        // [WHEN] Settings are re-enabled, the GL Module is also re-enabled

        // Open POs
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Open POs)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Customer Classes
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Customer Classes)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Item Classes
        GPCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Item Classes)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Vendor Classes
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Vendor Classes)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // GL Master
        GPCompanyAdditionalSettings.Validate("Migrate Only GL Master", true);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from GL Master)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Bank Master
        GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", false);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Bank Master)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Inventory Master
        GPCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", false);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Inventory Master)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Payables Master
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", false);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Payables Master)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);

        // Rec. Master
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", false);
        Assert.AreEqual(true, GPCompanyAdditionalSettings."Migrate GL Module", 'Migrate GL Module - Incorrect value (from Rec. Master)');
        GPCompanyAdditionalSettings.Validate("Migrate GL Module", false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicNotMasterGLOnly()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPGLTransactions: Record "GP GLTransactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Not migrating only GL master
        GPCompanyAdditionalSettings.Validate("Migrate Only GL Master", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] Records should be created in the GP GLTransactions combined staging table
        Assert.AreEqual(1, GPGLTransactions.Count(), 'Transaction records should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicMasterGLOnly()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPGLTransactions: Record "GP GLTransactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Migrating only GL master
        GPCompanyAdditionalSettings.Validate("Migrate Only GL Master", true);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] No records should be created in the GP GLTransactions combined staging table
        Assert.AreEqual(0, GPGLTransactions.Count(), 'Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicReceivablesModuleEnabledMasterDataOnlyDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPCustomer: Record "GP Customer";
        GPCustomerTransactions: Record "GP Customer Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Receivables module enabled, and not migrating only Receivables master data
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] Both GP Customer and GP Customer Transaction records will be created
        Assert.AreEqual(1, GPCustomer.Count(), 'Customer records should have been created.');
        Assert.AreEqual(1, GPCustomerTransactions.Count(), 'Customer Transaction records should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicReceivablesModuleEnabledMasterDataOnlyEnabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPCustomer: Record "GP Customer";
        GPCustomerTransactions: Record "GP Customer Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Migrating only Receivables master data
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", true);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] GP Customer will be created, but not GP Customer Transactions
        Assert.AreEqual(1, GPCustomer.Count(), 'Customer records should have been created.');
        Assert.AreEqual(0, GPCustomerTransactions.Count(), 'Customer Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicReceivablesModuleDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPCustomer: Record "GP Customer";
        GPCustomerTransactions: Record "GP Customer Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Receivables module disabled
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] No GP Customer or GP Customer Transaction records will be created
        Assert.AreEqual(0, GPCustomer.Count(), 'Customer records should not have been created.');
        Assert.AreEqual(0, GPCustomerTransactions.Count(), 'Customer Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicPayablesModuleEnabledMasterDataOnlyDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPVendor: Record "GP Vendor";
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Payables module enabled, and not migrating only Payables master data
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] Both GP Vendor and GP Vendor Transaction records will be created
        Assert.AreEqual(1, GPVendor.Count(), 'Vendor records should have been created.');
        Assert.AreEqual(1, GPVendorTransactions.Count(), 'Vendor Transaction records should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicPayablesModuleEnabledMasterDataOnlyEnabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPVendor: Record "GP Vendor";
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Migrating only Payables master data
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", true);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] GP Vendor will be created, but not GP Vendor Transactions
        Assert.AreEqual(1, GPVendor.Count(), 'Vendor records should have been created.');
        Assert.AreEqual(0, GPVendorTransactions.Count(), 'Vendor Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicPayablesModuleDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPVendor: Record "GP Vendor";
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Payables module disabled
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] No GP Vendor or GP Vendor Transaction records will be created
        Assert.AreEqual(0, GPVendor.Count(), 'Vendor records should not have been created.');
        Assert.AreEqual(0, GPVendorTransactions.Count(), 'Vendor Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicInventoryModuleEnabledMasterDataOnlyDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPItem: Record "GP Item";
        GPItemTransactions: Record "GP Item Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Inventory module enabled, and not migrating only Inventory master data
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] Both GP Item and GP Item Transaction records will be created
        Assert.AreEqual(1, GPItem.Count(), 'Item records should have been created.');
        Assert.AreEqual(1, GPItemTransactions.Count(), 'Item Transaction records should have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicInventoryModuleEnabledMasterDataOnlyEnabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPItem: Record "GP Item";
        GPItemTransactions: Record "GP Item Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Migrating only Inventory master data
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", true);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] GP Items will be created, but not GP Item Transactions
        Assert.AreEqual(1, GPItem.Count(), 'Item records should have been created.');
        Assert.AreEqual(0, GPItemTransactions.Count(), 'Item Transaction records should not have been created.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPopulateCombineStagingLogicInventoryModuleDisabled()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPConfiguration: Record "GP Configuration";
        GPItem: Record "GP Item";
        GPItemTransactions: Record "GP Item Transactions";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
    begin
        // [SCENARIO] Settings are created and data has been replicated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPConfiguration.GetSingleInstance();
        CreateReplicatedData();

        // [WHEN] Inventory module disabled
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Modify();
        GPPopulateCombinedTables.PopulateAllMappedTables();

        // [THEN] No GP Item or GP Item Transaction records will be created
        Assert.AreEqual(0, GPItem.Count(), 'Item records should not have been created.');
        Assert.AreEqual(0, GPItemTransactions.Count(), 'Item Transaction records should not have been created.');
    end;

    local procedure CreateReplicatedData()
    var
        GPGL00100: Record "GP GL00100";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
        GPGL10110: Record "GP GL10110";
        GPGL10111: Record "GP GL10111";
        GPSY40100: Record "GP SY40100";
        GPSY40101: Record "GP SY40101";
        GPRM00101: Record "GP RM00101";
        GPRM20101: Record "GP RM20101";
        GPPM00200: Record "GP PM00200";
        GPPM20000: Record "GP PM20000";
        GPIV00101: Record "GP IV00101";
        GPIV10200: Record "GP IV10200";
    begin
        if not GPSY00300.IsEmpty() then
            GPSY00300.DeleteAll();

        if not GPGL10110.IsEmpty() then
            GPGL10110.DeleteAll();

        if not GPGL10111.IsEmpty() then
            GPGL10111.DeleteAll();

        if not GPGL00100.IsEmpty() then
            GPGL00100.DeleteAll();

        if not GPSY40100.IsEmpty() then
            GPSY40100.DeleteAll();

        if not GPSY40101.IsEmpty() then
            GPSY40101.DeleteAll();

        if not GPGL40200.IsEmpty() then
            GPGL40200.DeleteAll();

        if not GPRM00101.IsEmpty() then
            GPRM00101.DeleteAll();

        if not GPRM20101.IsEmpty() then
            GPRM20101.DeleteAll();

        if not GPPM00200.IsEmpty() then
            GPPM00200.DeleteAll();

        if not GPPM20000.IsEmpty() then
            GPPM20000.DeleteAll();

        if not GPIV00101.IsEmpty() then
            GPIV00101.DeleteAll();

        if not GPIV10200.IsEmpty() then
            GPIV10200.DeleteAll();

        // GL
        GPSY00300.MNSEGIND := true;
        GPSY00300.SGMTNUMB := 1;
        GPSY00300.Insert();

        GPGL00100.ACTINDX := 1;
        GPGL00100.ACTNUMBR_1 := '1200';
        GPGL00100.ACCTTYPE := 1;
        GPGL00100.ACTDESCR := 'Test account';
        GPGL00100.Insert();

        GPGL10110.PERDBLNC := 1;
        GPGL10110.GL00100ACCTYPE1Exist := true;
        GPGL10110.YEAR1 := 2023;
        GPGL10110.PERIODID := 1;
        GPGL10110.ACTNUMBR_1 := GPGL00100.ACTNUMBR_1;
        GPGL10110.ACTINDX := 1;
        GPGL10110.CRDTAMNT := 100;
        GPGL10110.Insert();

        GPSY40101.YEAR1 := 2023;
        GPSY40101.Insert();

        GPSY40100.PERIODID := 1;
        GPSY40100.SERIES := 0;
        GPSY40100.YEAR1 := 2023;
        GPSY40100.PERIODDT := CurrentDateTime();
        GPSY40100.PERDENDT := CurrentDateTime();
        GPSY40100.Insert();

        // Receivables
        GPRM00101.CUSTNMBR := 'CUST1';
        GPRM00101.CUSTNAME := 'Customer name';
        GPRM00101.CITY := 'Fargo';
        GPRM00101.STATE := 'ND';
        GPRM00101.ZIP := '58103-3342';
        GPRM00101.TAXSCHID := 'S-T-NO-%AD%S';
        GPRM00101.UPSZONE := 'P3';
        GPRM00101.Insert();

        GPRM20101.RMDTYPAL := 1;
        GPRM20101.CURTRXAM := 100;
        GPRM20101.VOIDSTTS := 0;
        GPRM20101.CUSTNMBR := GPRM00101.CUSTNMBR;
        GPRM20101.DOCNUMBR := 'DOC123';
        GPRM20101.DOCDATE := Today();
        GPRM20101.SLPRSNID := 'Somebody';
        GPRM20101.PYMTRMID := '2.5% EOM/EOM';
        GPRM20101.Insert();

        // Payables
        GPPM00200.VENDORID := 'V3130';
        GPPM00200.VENDSTTS := 1;
        GPPM00200.VENDNAME := 'Lmd Telecom, Inc.';
        GPPM00200.VNDCHKNM := 'Lmd Telecom, Inc.';
        GPPM00200.ADDRESS1 := 'P.O. Box10158';
        GPPM00200.CITY := 'Fort Worth';
        GPPM00200.PYMTRMID := '3% 15th/Net 30';
        GPPM00200.SHIPMTHD := 'UPS BLUE';
        GPPM00200.ZIPCODE := '76114';
        GPPM00200.STATE := 'TX';
        GPPM00200.TAXSCHID := 'P-T-TXB-%PT%P*4';
        GPPM00200.UPSZONE := 'F4';
        GPPM00200.TXIDNMBR := '45-0029728';
        GPPM00200.Insert();

        GPPM20000.VENDORID := GPPM00200.VENDORID;
        GPPM20000.DOCNUMBR := 'DOC01';
        GPPM20000.DOCTYPE := 1;
        GPPM20000.DOCDATE := Today();
        GPPM20000.DUEDATE := Today();
        GPPM20000.CURTRXAM := 100;
        GPPM20000.PYMTRMID := GPPM00200.PYMTRMID;
        GPPM20000.Insert();

        // Inventory
        GPIV00101.ITEMTYPE := 1;
        GPIV00101.ITEMNMBR := 'Item1';
        GPIV00101.ITEMDESC := 'Item description';
        GPIV00101.VCTNMTHD := 1;
        GPIV00101.CURRCOST := 1;
        GPIV00101.STNDCOST := 1;
        GPIV00101.SELNGUOM := 'EACH';
        GPIV00101.PRCHSUOM := 'EACH';
        GPIV00101.ITMTRKOP := 2;
        GPIV00101.ITEMSHWT := 500;
        GPIV00101.ITMTRKOP := 1;
        GPIV00101.Insert();

        GPIV10200.ITEMNMBR := GPIV00101.ITEMNMBR;
        GPIV10200.TRXLOCTN := 'WAREHOUSE';
        GPIV10200.UNITCOST := 1;
        GPIV10200.RCTSEQNM := 1;
        GPIV10200.RCPTNMBR := 'R101';
        GPIV10200.DATERECD := Today();
        GPIV10200.RCPTSOLD := false;
        GPIV10200.QTYRECVD := 1;
        GPIV10200.QTYTYPE := 1;
        GPIV10200.Insert();
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
        GPCompanyAdditionalSettings.Validate("Skip Posting Account Batches", true);
        GPCompanyAdditionalSettings.Validate("Skip Posting Customer Batches", true);
        GPCompanyAdditionalSettings.Validate("Skip Posting Vendor Batches", true);
        GPCompanyAdditionalSettings.Validate("Skip Posting Bank Batches", true);
        GPCompanyAdditionalSettings.Modify();
    end;
}