codeunit 139530 "MigrationQBO Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
        MigrationQBConfig: Record "MigrationQB Config";
        MigrationQBAccount: Record "MigrationQB Account";
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBItem: Record "MigrationQB Item";
        MigrationQBVendor: Record "MigrationQB Vendor";
        MigrationQBOMigrationTests: Codeunit "MigrationQBO Tests";
        AccountFacade: Codeunit "GL Acc. Data Migration Facade";
        AccountMigrator: Codeunit "MigrationQB Account Migrator";
        CustomerFacade: Codeunit "Customer Data Migration Facade";
        CustomerMigrator: Codeunit "MigrationQB Customer Migrator";
        ItemFacade: Codeunit "Item Data Migration Facade";
        ItemMigrator: Codeunit "MigrationQB Item Migrator";
        VendorFacade: Codeunit "Vendor Data Migration Facade";
        VendorMigrator: Codeunit "MigrationQB Vendor Migrator";
        Assert: Codeunit Assert;
        JsonErr: Label 'Should have no data from JSON file.';

    trigger OnRun();
    begin
        // [FEATURE] [QuickBooks Data Migration]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBIsOnlineData()
    begin
        // [SCENARIO] The extension returns correctly, whether it is set up for online data migration or not
        // [GIVEN] A newly installed QB Data Migration extension
        MigrationQBConfig.DeleteAll();
        MigrationQBConfig.Init();
        MigrationQBConfig.Insert();

        // [WHEN] The extension is asked whether or not it is set up for online data migration
        // [then] It returns that it is not
        Assert.IsFalse(MigrationQBConfig.IsOnlineData(), 'The extension returned that it is migrating Online Data, even if it is not.');

        // [GIVEN] A configured QB Data Migration extension
        Initialize();

        // [WHEN] The extension is asked whether or not it is set up for online data migration
        // [then] It returns that it is
        Assert.IsTrue(MigrationQBConfig.IsOnlineData(), 'The extension returned that it is not set up for online data migration, even if it is.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOAccountImport()
    var
        GLAccount: Record "G/L Account";
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are pulled from JSON file
        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('Account', GetGetAllAccountsResponse(), JArray);

        // [WHEN] Data is imported
        AccountMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Accounts are imported
        Assert.AreEqual(89, MigrationQBAccount.Count(), 'Wrong number of accounts read');

        // [then] Should have no empty AcctNum values
        Assert.AreEqual(true, AccountMigrator.PreDataIsValid(), 'Should have no empty AcctNum values');

        // [then] Then fields for Account 10 are correctly imported to temporary table
        MigrationQBAccount.Reset();
        MigrationQBAccount.SetRange(Id, '10');
        MigrationQBAccount.FindFirst();
        Assert.AreEqual('Dues & Subscriptions', MigrationQBAccount.Name, 'Name of Account for Id 10 is wrong');
        Assert.AreEqual(false, MigrationQBAccount.SubAccount, 'SubAccount of Account for Id 10 is wrong');
        Assert.AreEqual('Dues & Subscriptions', MigrationQBAccount.FullyQualifiedName, 'FullyQualifiedName of Account for Id 10 is wrong');
        Assert.AreEqual(true, MigrationQBAccount.Active, 'Active of Account for Id 10 is wrong');
        Assert.AreEqual('Expense', MigrationQBAccount.Classification, 'Classification of Account for Id 10 is wrong');
        Assert.AreEqual('Expense', MigrationQBAccount.AccountType, 'AccountType of Account for Id 10 is wrong');
        Assert.AreEqual('DuesSubscriptions', MigrationQBAccount.AccountSubType, 'AccountSubType of Account for Id 10 is wrong');
        Assert.AreEqual(0, MigrationQBAccount.CurrentBalance, 'CurrentBalance of Account for Id 10 is wrong');
        Assert.AreEqual(0, MigrationQBAccount.CurrentBalanceWithSubAccounts, 'CurrentBalanceWithSubAccounts of Account for Id 10 is wrong');
        Assert.AreEqual('47', MigrationQBAccount.AcctNum, 'AcctNum of Account for Id 10 is wrong');

        // [WHEN] Data is pushed to database
        MigrationQBAccount.Reset();
        GLAccount.DeleteAll();
        MigrateAccounts(MigrationQBAccount);

        // [then] Then the correct number of Accounts are applied
        Assert.AreEqual(89, GLAccount.Count(), 'Wrong number of accounts applied.');

        // [then] Then fields for Account 47 are correctly applied
        GLAccount.SetRange("No.", '47');
        GLAccount.FindFirst();
        Assert.AreEqual('Dues & Subscriptions', GLAccount.Name, 'Name of Account for No. 47 is wrong');
        Assert.AreEqual('DUES & SUBSCRIPTIONS', GLAccount."Search Name", 'Search Name of Account for No. 47 is wrong');
        Assert.AreEqual(GLAccount."Account Type"::Posting, GLAccount."Account Type", 'Account Type of Account for No. 47 is wrong');
        Assert.AreEqual(true, GLAccount."Direct Posting", 'Direct Posting of Account for No. 47 is wrong');
        Assert.AreEqual(false, GLAccount.Blocked, 'Blocked of Account for No. 47 is wrong');
        Assert.AreEqual(GLAccount."Account Category"::Expense, GLAccount."Account Category"
          , 'Account Category of Account for No. 47 is wrong');
        Assert.AreEqual(GLAccount."Income/Balance"::"Income Statement", GLAccount."Income/Balance"
          , 'Income/Balance of Account for No. 47 is wrong');
        Assert.AreEqual(GLAccount."Debit/Credit"::Debit, GLAccount."Debit/Credit", 'Debit/Credit of Account for No. 47 is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOAccountImportWhenNoneExistOnQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from QBO where no accounts actually exist
        Initialize();

        // [GIVEN] Default QBO Setup
        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Account', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOAccountImportWhenBadResponseFromQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for QBO accounts leads to a bad response which is handled gracefully.
        Initialize();

        // [GIVEN] A default QBO Setup
        // [WHEN] reading a bad response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Account', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    /*[Test]
    procedure TestQBOAccountsImportPaging()
    var
        //MSQBOTableManagement: Codeunit "MS - QBO Table Management";
        //WriteFromToUse: DotNet WriteFrom;
    begin
        // [SCENARIO] QBO contains more accounts than the size of a single request. All acounnts are queried from QBO, and make sure the paging was handled correctly.
        Initialize();
        

        // [WHEN] The codeunit is initialized
        InitConsumerKeySecret(MSQBOTableManagement);
        MSQBOTableManagement.Initialize();

        WriteFromToUse := HttpMessageHandler.WriteFrom('');
        WriteFromToUse.AddUriResponseFileMapping(
          'https://quickbooks.api.intuit.com/v3/company/realmid/query' +
          '?query=Select+*+from+Account+STARTPOSITION+1+MAXRESULTS+50&minorversion=4',
          GetInetroot + GetGetFirstPageOfAccountsResponse);
        WriteFromToUse.AddUriResponseFileMapping(
          'https://quickbooks.api.intuit.com/v3/company/realmid/query' +
          '?query=Select+*+from+Account+STARTPOSITION+101+MAXRESULTS+50&minorversion=4',
          GetInetroot + GetGetRemainingPageOfAccountsResponse);
        MSQBOTableManagement.SetMessageHandler(WriteFromToUse);

        // MigrationQBAccount.GetAll(MSQBOTableManagement);

        // [then] Then the correct number of accounts are imported
        // one page of 50 and one page of 39
        // Assert.AreEqual(89,MigrationQBAccount.Count(),'Wrong number of accounts read');

        // [then] Then Name of the Account with Id 10 is correct
        // MigrationQBAccount.SetRange(AcctNum,'350');
        // MigrationQBAccount.FindFirst();
        // Assert.AreEqual('Dues & Subscriptions',MigrationQBAccount.Name,'Name of Account is wrong');
    end; */

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOAccountImportWithEmptyAcctNum()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from QBO where no accounts actually exist

        // [GIVEN] Default QBO Setup
        // [WHEN] The codeunit is initialized
        Initialize();
        GetDataFromFile('Account', GetGetEmtpyAcctNumResponse(), JArray);
        AccountMigrator.PopulateStagingTable(JArray);
        Assert.AreEqual(false, AccountMigrator.PreDataIsValid(), 'Should have errored on empty AcctNum.');
    end;

    [Test]
    procedure TestQBOCustomerImport()
    var
        Customer: Record "Customer";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Customers are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('Customer', GetGetAllCustomersResponse(), JArray);

        // [WHEN] Data is imported
        CustomerMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(29, MigrationQBCustomer.Count(), 'Wrong number of Customers read');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        MigrationQBCustomer.SetRange(Id, '1');
        MigrationQBCustomer.FindFirst();
        Assert.AreEqual('Amy''s Bird Sanctuary', MigrationQBCustomer.DisplayName, 'Display Name of Customer is wrong');
        Assert.AreEqual('Amy', MigrationQBCustomer.GivenName, 'Given Name of Customer is wrong');
        Assert.AreEqual('Lauterbach', MigrationQBCustomer.FamilyName, 'Family Name of Customer is wrong');
        Assert.AreEqual('4581 Finch St.', MigrationQBCustomer.BillAddrLine1, 'BillAddr1 of Customer is wrong');
        Assert.AreEqual('Apt. 2', MigrationQBCustomer.BillAddrLine2, 'BillAddr2 of Customer is wrong');
        Assert.AreEqual('Bayshore', MigrationQBCustomer.BillAddrCity, 'BillAddrCity of Customer is wrong');
        Assert.AreEqual('(650) 555-3311', MigrationQBCustomer.PrimaryPhone, 'Primary Phone of Customer is wrong');
        Assert.AreEqual('(701) 444-8585', MigrationQBCustomer.Fax, 'Fax of Customer is wrong');
        Assert.AreEqual('94326', MigrationQBCustomer.BillAddrPostalCode, 'BillAddrPostalCode of Customer is wrong');
        Assert.AreEqual('USA', MigrationQBCustomer.BillAddrCountry, 'BillAddrCountry of Customer is wrong');
        Assert.AreEqual('CA', MigrationQBCustomer.BillAddrCountrySubDivCode, 'BillAddrCountrySubDivCode of Customer is wrong');
        Assert.AreEqual('Birds@Intuit.com', MigrationQBCustomer.PrimaryEmailAddr, 'PrimaryEmailAddr of Customer is wrong');
        Assert.AreEqual('http://crazybirds.com', MigrationQBCustomer.WebAddr, 'WebAddr of Customer is wrong');

        // [WHEN] data is migrated
        Customer.DeleteAll();
        MigrationQBCustomer.Reset();
        MigrateCustomers(MigrationQBCustomer);

        // [then] Then the correct number of Customers are applied
        Assert.AreEqual(29, Customer.Count(), 'Wrong number of Migrated Customers read');

        // [then] Then fields for Customer 1 are correctly applied
        Customer.SetRange("No.", '1');
        Customer.FindFirst();
        Assert.AreEqual('Amy''s Bird Sanctuary', Customer.Name, 'Name of Migrated Customer is wrong');
        Assert.AreEqual('Amy Lauterbach', Customer.Contact, 'Contact Name of Migrated Customer is wrong');
        Assert.AreEqual('AMY''S BIRD SANCTUARY', Customer."Search Name", 'Search Name of Migrated Customer is wrong');
        Assert.AreEqual('4581 Finch St.', Customer.Address, 'Address of Migrated Customer is wrong');
        Assert.AreEqual('Apt. 2', Customer."Address 2", 'Address2 of Migrated Customer is wrong');
        Assert.AreEqual('Bayshore', Customer.City, 'City of Migrated Customer is wrong');
        Assert.AreEqual('(650) 555-3311', Customer."Phone No.", 'Phone No. of Migrated Customer is wrong');
        Assert.AreEqual('(701) 444-8585', Customer."Fax No.", 'Fax No. of Migrated Customer is wrong');
        Assert.AreEqual('94326', Customer."Post Code", 'Post Code of Migrated Customer is wrong');
        // Assert.AreEqual('USA',Customer."Country/Region Code",'Country/Region of Migrated Customer is wrong');
        Assert.AreEqual('CA', Customer.County, 'County of Migrated Customer is wrong');
        Assert.AreEqual('Birds@Intuit.com', Customer."E-Mail", 'E-Mail of Migrated Customer is wrong');
        Assert.AreEqual('http://crazybirds.com', Customer."Home Page", 'Home Page of Migrated Customer is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOCustomerImportWhenNoneExistOnQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from QBO where no accounts actually exist

        // [GIVEN] Default QBO Setup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationQBCustomer.Init();

        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Customer', GetGetAllEmptyResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOCustomerImportWhenBadResponseFromQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for QBO accounts leads to a bad response which is handled gracefully.

        // [GIVEN] A default QBO Setup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationQBCustomer.Init();

        // [WHEN] reading a bad response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Customer', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOItemsImport()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record "Item";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Items are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('Item', GetGetAllItemsResponse(), JArray);

        // [WHEN] data is imported
        ItemMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Items are imported
        Assert.AreEqual(19, MigrationQBItem.Count(), 'Wrong number of Items read');

        // [then] Then fields for Items 16 are correctly imported to temporary table
        MigrationQBItem.SetRange(Id, '16');
        MigrationQBItem.FindFirst();
        Assert.AreEqual('Sprinkler Heads', MigrationQBItem.Name, 'Name of Item is wrong');
        Assert.AreEqual('Sprinkler Heads', MigrationQBItem.Description, 'Description of Item is wrong');
        Assert.AreEqual('Inventory', MigrationQBItem.Type, 'Type of Item is wrong');
        Assert.AreEqual(2.0, MigrationQBItem.UnitPrice, 'Unit Price of Item is wrong');
        Assert.AreEqual(0.75, MigrationQBItem.PurchaseCost, 'Purchase Cost of Item is wrong');

        // [then] Then fields for Items 15 are correctly imported to temporary table
        MigrationQBItem.SetRange(Id, '15');
        MigrationQBItem.FindFirst();
        Assert.AreEqual('Soil', MigrationQBItem.Name, 'Name of Item is wrong');
        Assert.AreEqual('2 cubic ft. bag', MigrationQBItem.Description, 'Description of Item is wrong');
        Assert.AreEqual('NonInventory', MigrationQBItem.Type, 'Type of Item is wrong');
        Assert.AreEqual(10.0, MigrationQBItem.UnitPrice, 'Unit Price of Item is wrong');
        Assert.AreEqual(6.5, MigrationQBItem.PurchaseCost, 'Purchase Cost of Item is wrong');

        // [then] Then fields for Items 18 are correctly imported to temporary table
        MigrationQBItem.SetRange(Id, '18');
        MigrationQBItem.FindFirst();
        Assert.AreEqual('Trimming', MigrationQBItem.Name, 'Name of Item is wrong');
        Assert.AreEqual('Tree and Shrub Trimming', MigrationQBItem.Description, 'Description of Item is wrong');
        Assert.AreEqual('Service', MigrationQBItem.Type, 'Type of Item is wrong');
        Assert.AreEqual(35.0, MigrationQBItem.UnitPrice, 'Unit Price of Item is wrong');
        Assert.AreEqual(0.0, MigrationQBItem.PurchaseCost, 'Purchase Cost of Item is wrong');

        // [WHEN] data is migrated
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
        MigrationQBItem.Reset();
        MigrateItems(MigrationQBItem, false);

        // [then] Then the correct number of Items are applied
        Assert.AreEqual(19, Item.Count(), 'Wrong number of Migrated Items read');

        // [then] Then check Setfilter to only show Inventory, Non-Inventory, and Service Type Items
        Assert.AreNotEqual('Category', Item.Type, 'Setfilter is not working for Items');

        // [then] Then fields for Item 16 are correctly applied
        Item.SetRange("No.", '16');
        Item.FindFirst();
        Assert.AreEqual('Sprinkler Heads', Item.Description, 'Description of Migrated Item is wrong');
        Assert.AreEqual('Sprinkler Heads', Item."Description 2", 'Description 2 of Migrated Item is wrong');
        Assert.AreEqual(Item.Type::Inventory, Item.Type, 'Type of Migrated Item is wrong');
        Assert.AreEqual(2.0, Item."Unit Price", 'Unit Price of Migrated Item is wrong');
        Assert.AreEqual(0.75, Item."Unit Cost", 'Unit Cost of Migrated Item is wrong');
        // Assert.AreEqual('QB',Item."Inventory Posting Group",'Inventory Posting Group not set to QB');

        // [then] Then fields for Item 15 are correctly applied
        Item.SetRange("No.", '15');
        Item.FindFirst();
        Assert.AreEqual('Soil', Item.Description, 'Description of Migrated Item is wrong');
        Assert.AreEqual('2 cubic ft. bag', Item."Description 2", 'Description 2 of Migrated Item is wrong');
        Assert.AreEqual(Item.Type::Service, Item.Type, 'Type of Migrated Item is wrong');
        Assert.AreEqual(10.0, Item."Unit Price", 'Unit Price of Migrated Item is wrong');
        Assert.AreEqual(6.5, Item."Unit Cost", 'Unit Cost of Migrated Item is wrong');
        Assert.AreEqual('', Item."Inventory Posting Group", 'Inventory Posting Group should not be set for Service items');

        // [then] Then fields for Item 18 are correctly applied
        Item.SetRange("No.", '18');
        Item.FindFirst();
        Assert.AreEqual('Trimming', Item.Description, 'Description of Migrated Item is wrong');
        Assert.AreEqual('Tree and Shrub Trimming', Item."Description 2", 'Description 2 of Migrated Item is wrong');
        Assert.AreEqual(Item.Type::Service, Item.Type, 'Type of Migrated Item is wrong');
        Assert.AreEqual(35.0, Item."Unit Price", 'Unit Price of Migrated Item is wrong');
        Assert.AreEqual(0.0, Item."Unit Cost", 'Unit Cost of Migrated Item is wrong');
        Assert.AreEqual('', Item."Inventory Posting Group", 'Inventory Posting Group should not be set for Service items');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOItemsImportWhenNoneExistOnQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All Items are queried from QBO where no accounts actually exist
        Initialize();

        // [GIVEN] Default QBO Setup
        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Item', GetGetAllEmptyResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOItemImportWhenBadResponseFromQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for QBO Items leads to a bad response which is handled gracefully.
        Initialize();

        // [GIVEN] A default QBO Setup
        // [WHEN] reading a bad response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Item', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOItemsImportAverageCost()
    var
        Item: Record "Item";
        ItemLedgerEntry: Record "Item Ledger Entry";
        InventorySetup: Record "Inventory Setup";
        JArray: JsonArray;
    begin
        // [SCENARIO] Costing Method is set for all items, based on the Inventory Setup value.

        // [GIVEN] QBO data
        Initialize();
        if InventorySetup.Get() then begin
            InventorySetup."Default Costing Method" := InventorySetup."Default Costing Method"::Average;
            InventorySetup.Modify();
        end else begin
            InventorySetup.Init();
            InventorySetup."Default Costing Method" := InventorySetup."Default Costing Method"::Average;
            InventorySetup.Insert();
        end;

        GetDataFromFile('Item', GetGetAllItemsResponse(), JArray);

        // [WHEN] data is imported
        ItemMigrator.PopulateStagingTable(JArray);

        // [WHEN] data is pushed to database
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
        MigrationQBItem.Reset();
        MigrateItems(MigrationQBItem, false);

        // [then] Then the correct number of Items are applied
        Assert.AreEqual(19, Item.Count(), 'Wrong number of Migrated Items read');

        // [then] Then Costing Method for Item 16 was set correctly
        Item.SetRange("No.", '16');
        Item.FindFirst();
        Assert.AreEqual(Item."Costing Method", Item."Costing Method"::Average, 'Costing Method of Migrated Item is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOItemPostingSetup()
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record "Item";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Items are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('Item', GetGetAllItemsResponse(), JArray);
        ItemMigrator.PopulateStagingTable(JArray);

        // [WHEN] data is imported
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
        MigrationQBItem.Reset();
        MigrateItems(MigrationQBItem, false);

        // [THEN] Inventory Posting Account is setup
        if InventoryPostingSetup.Get('', 'QBO') then
            Assert.AreEqual('1', InventoryPostingSetup."Inventory Account", 'Inventory Posting Group not setup.')
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOVendorImport()
    var
        Vendor: Record "Vendor";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Vendors are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('Vendor', GetGetAllVendorsResponse(), JArray);

        // [WHEN] data is imported
        VendorMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Vendors are imported
        Assert.AreEqual(26, MigrationQBVendor.Count(), 'Wrong number of Vendors read');

        // [then] Then fields for Vendor 30 are correctly imported to temporary table
        MigrationQBVendor.SetRange(Id, '30');
        MigrationQBVendor.FindFirst();
        Assert.AreEqual('Books by Bessie', MigrationQBVendor.DisplayName, 'Display Name of Vendor is wrong');
        Assert.AreEqual('Bessie', MigrationQBVendor.GivenName, 'Given Name of Vendor is wrong');
        Assert.AreEqual('Williams', MigrationQBVendor.FamilyName, 'Family Name of Vendor is wrong');
        Assert.AreEqual('15 Main St.', MigrationQBVendor.BillAddrLine1, 'BillAddr1 of Vendor is wrong');
        Assert.AreEqual('Apt. 2', MigrationQBVendor.BillAddrLine2, 'BillAddr2 of Vendor is wrong');
        Assert.AreEqual('Palo Alto', MigrationQBVendor.BillAddrCity, 'BillAddrCity of Vendor is wrong');
        Assert.AreEqual('(650) 555-7745', MigrationQBVendor.PrimaryPhone, 'Primary Phone of Vendor is wrong');
        Assert.AreEqual('(701) 444-8585', MigrationQBVendor.Fax, 'Fax of Vendor is wrong');
        Assert.AreEqual('94303', MigrationQBVendor.BillAddrPostalCode, 'BillAddrPostalCode of Vendor is wrong');
        Assert.AreEqual('USA', MigrationQBVendor.BillAddrCountry, 'BillAddrCountry of Vendor is wrong');
        Assert.AreEqual('Books@Intuit.com', MigrationQBVendor.PrimaryEmailAddr, 'PrimaryEmailAddr of Vendor is wrong');
        Assert.AreEqual('CA', MigrationQBVendor.BillAddrCountrySubDivCode, 'BillAddrCountrySubDivCode of Vendor is wrong');
        Assert.AreEqual('http://www.booksbybessie.com', MigrationQBVendor.WebAddr, 'WebAddr of Vendor is wrong');

        // Remove invalid email address record for this test
        MigrationQBVendor.SetRange(Id, '45');
        MigrationQBVendor.FindFirst();
        MigrationQBVendor.Delete();

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        MigrationQBVendor.Reset();
        MigrateVendors(MigrationQBVendor);

        // [then] Then the correct number of Vendors are applied
        Assert.AreEqual(25, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [then] Then fields for Vendor 30 are correctly applied
        Vendor.SetRange("No.", '30');
        Vendor.FindFirst();
        Assert.AreEqual('Books by Bessie', Vendor.Name, 'Name of Migrated Vendor is wrong');
        Assert.AreEqual('Bessie Williams', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('BOOKS BY BESSIE', Vendor."Search Name", 'Search Name of Migrated Vendor is wrong');
        Assert.AreEqual('15 Main St.', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('Apt. 2', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Palo Alto', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('(650) 555-7745', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('(701) 444-8585', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');
        Assert.AreEqual('94303', Vendor."Post Code", 'Post Code of Migrated Vendor is wrong');
        // Assert.AreEqual('USA',Vendor."Country/Region Code",'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('Books@Intuit.com', Vendor."E-Mail", 'E-Mail of Migrated Vendor is wrong');
        Assert.AreEqual('CA', Vendor.County, 'County of Migrated Vendor is wrong');
        Assert.AreEqual('http://www.booksbybessie.com', Vendor."Home Page", 'Home Page of Migrated Vendor is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOVendorImportWhenNoneExistOnQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from QBO where no accounts actually exist
        Initialize();

        // [GIVEN] Default QBO Setup
        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Vendor', GetGetAllEmptyResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBOVendorImportWhenBadResponseFromQBO()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for QBO accounts leads to a bad response which is handled gracefully.
        Initialize();

        // [GIVEN] A default QBO Setup
        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Vendor', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    local procedure GetInetroot(): Text[170]
    begin
        exit(ApplicationPath() + '\..\..\');
    end;

    local procedure GetGetEmtpyAcctNumResponse(): Text[250]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllAccountsEmptyAcctNumResponse.txt');
    end;

    local procedure GetGetAllAccountsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllAccountsResponse.txt');
    end;

    local procedure GetGetAllEmptyResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllEmptyResponse.txt');
    end;

    local procedure GetGetAllBadResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllBadResponse.txt');
    end;

    local procedure GetGetAllCustomersResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllCustomersResponse.txt');
    end;

    local procedure GetGetAllItemsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllItemsResponse.txt');
    end;

    local procedure GetGetAllVendorsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\QBMigration\test\resources\QBOResponse\GetAllVendorsResponse.txt');
    end;

    [Normal]
    local procedure Initialize()
    var
        DummyAccessToken: Text;
    begin
        if not BindSubscription(MigrationQBOMigrationTests) then
            exit;

        MigrationQBAccount.DeleteAll();
        MigrationQBCustomer.DeleteAll();
        MigrationQBItem.DeleteAll();
        MigrationQBVendor.DeleteAll();

        MigrationQBConfig.DeleteAll();
        DummyAccessToken := 'accesstokey';
        MigrationQBConfig.InitializeOnlineConfig(DummyAccessToken, 'realmid');
        SetPostingAccounts();

        if UnbindSubscription(MigrationQBOMigrationTests) then
            exit;
    end;

    local procedure GetDataFromFile(EntityName: Text; TestDataFile: Text; var JArray: JsonArray): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(GetFileContent(GetInetroot() + TestDataFile)) then
            if JObject.SelectToken('QueryResponse.' + EntityName, JToken) then
                if JToken.IsArray() then begin
                    JArray := JToken.AsArray();
                    exit(true);
                end;

        exit(false);
    end;

    /* [Test]
    [HandlerFunctions('DataMigratorsPageHandler')]
    procedure TestQBOGivesWarningIfUsingSpecificValuation()
    var
        InventorySetup: Record "Inventory Setup";
        DataMigrationWizard: TestPage "Data Migration Wizard";
        CostingMethod: Option FIFO,LIFO,Specific,"Average",Standard;
    begin
        // [SCENARIO] The extension returns correctly, whether it is set up or not
        // [GIVEN] A newly installed QBO Data Migration extension
        // [GIVEN] Inventory Setup has a Default Costing Method of 'Specific'
        Initialize();
        if InventorySetup.Get then begin
          InventorySetup."Default Costing Method" := CostingMethod::Specific;
          InventorySetup.Modify;
        end else begin
          InventorySetup.Init;
          InventorySetup."Default Costing Method" := CostingMethod::Specific;
          InventorySetup.Insert;
        end;

        DataMigrationWizard.TRAP;
        PAGE.RUN(PAGE::"Data Migration Wizard");

        WITH DataMigrationWizard DO begin
          ActionNext.INVOKE; // Choose Data Source page
          // [WHEN] User chooses the Quickbooks Online Data Migrator
          Description.LOOKUP;
          // [then] Warning about this migrator not supporting the 'Specific' costing method is given
          ASSERTERROR ActionNext.INVOKE; // Go to the instructions page, should give a warning about 'Specific' costing method
        end;
    end;

    [ModalPageHandler]
    procedure DataMigratorsPageHandler(var DataMigrators: TestPage "Data Migrators")
    begin
        DataMigrators.GOTOKEY(CODEUNIT::"MS - QBO Data Migrator");
        DataMigrators.OK.INVOKE;
    end; */

    local procedure GetFileContent(FileName: Text): Text
    var
        TempFile: File;
        FileContent: Text;
        Line: Text;
    begin
        if FileName <> '' then begin
            TempFile.TextMode(true);
            TempFile.WriteMode(false);
            TempFile.Open(FileName);
            repeat
                TempFile.Read(Line);
                FileContent := FileContent + Line;
            until (TempFile.Pos() = TempFile.Len());
            exit(FileContent);
        end;
    end;

    local procedure MigrateAccounts(Accounts: Record "MigrationQB Account")
    begin
        if Accounts.FindSet() then
            repeat
                AccountMigrator.MigrateAccountDetails(Accounts, AccountFacade);
                AccountMigrator.MigratePostingGroups(AccountFacade, Accounts.RecordId());
            until Accounts.Next() = 0;
    end;

    local procedure SetupAccounts(): Boolean
    var
        JArray: JsonArray;
    begin
        if GetDataFromFile('Account', GetGetAllAccountsResponse(), JArray) then begin
            AccountMigrator.PopulateStagingTable(JArray);
            MigrateAccounts(MigrationQBAccount);
            exit(true);
        end;
        exit(false);
    end;

    local procedure MigrateCustomers(Customers: Record "MigrationQB Customer")
    begin
        if SetupAccounts() then
            if Customers.FindSet() then
                repeat
                    CustomerMigrator.MigrateCustomerDetails(Customers, CustomerFacade);
                    CustomerMigrator.MigrateCustomerPostingGroups(CustomerFacade, Customers.RecordId(), true);
                until Customers.Next() = 0;
    end;

    local procedure MigrateVendors(Vendors: Record "MigrationQB Vendor")
    begin
        if SetupAccounts() then
            if Vendors.FindSet() then
                repeat
                    VendorMigrator.MigrateVendorDetails(Vendors, VendorFacade);
                    VendorMigrator.MigrateVendorPostingGroups(VendorFacade, Vendors.RecordId(), true);
                until Vendors.Next() = 0;
    end;

    local procedure MigrateItems(Items: Record "MigrationQB Item"; IncludeTransactions: Boolean)
    begin
        if SetupAccounts() then
            if Items.FindSet() then
                repeat
                    ItemMigrator.MigrateItemDetails(Items, ItemFacade);
                    ItemMigrator.MigrateItemPostingGroups(ItemFacade, Items.RecordId(), true);
                    if IncludeTransactions then
                        ItemMigrator.MigrateInventoryTransactions(ItemFacade, Items.RecordId(), true);
                until Items.Next() = 0;
    end;

    local procedure SetPostingAccounts()
    var
        AccountNumber: Code[20];
    begin
        MigrationQBAccountSetup.DeleteAll();
        AccountNumber := '1';
        MigrationQBAccountSetup.Init();
        MigrationQBAccountSetup.SalesAccount := AccountNumber;
        MigrationQBAccountSetup.SalesCreditMemoAccount := AccountNumber;
        MigrationQBAccountSetup.SalesLineDiscAccount := AccountNumber;
        MigrationQBAccountSetup.SalesInvDiscAccount := AccountNumber;
        MigrationQBAccountSetup.PurchAccount := AccountNumber;
        MigrationQBAccountSetup.PurchCreditMemoAccount := AccountNumber;
        MigrationQBAccountSetup.PurchInvDiscAccount := AccountNumber;
        MigrationQBAccountSetup.COGSAccount := AccountNumber;
        MigrationQBAccountSetup.InventoryAdjmtAccount := AccountNumber;
        MigrationQBAccountSetup.InventoryAccount := AccountNumber;
        MigrationQBAccountSetup.ReceivablesAccount := AccountNumber;
        MigrationQBAccountSetup.ServiceChargeAccount := AccountNumber;
        MigrationQBAccountSetup.PayablesAccount := AccountNumber;
        MigrationQBAccountSetup.PurchServiceChargeAccount := AccountNumber;
        MigrationQBAccountSetup.Insert();
    end;
}


