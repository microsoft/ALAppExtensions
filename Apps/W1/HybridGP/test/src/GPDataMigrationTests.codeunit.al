codeunit 139664 "GP Data Migration Tests"
{
    // version Test,W1,US,CA,GB

    // // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPCustomer: Record "GP Customer";
        GPVendor: Record "GP Vendor";
        GPVendorAddress: Record "GP Vendor Address";
        GPCustomerAddress: Record "GP Customer Address";
        GPSY06000: Record "GP SY06000";
        GPMC40200: Record "GP MC40200";
        GPPM00100: Record "GP PM00100";
        GPPM00200: Record "GP PM00200";
        GPRM00101: Record "GP RM00101";
        GPRM00201: Record "GP RM00201";
        GPPOP10100: Record "GP POP10100";
        GPPOP10110: Record "GP POP10110";
        GPSY01200: Record "GP SY01200";
        Item: Record Item;
        GPTestHelperFunctions: Codeunit "GP Test Helper Functions";
        CustomerFacade: Codeunit "Customer Data Migration Facade";
        CustomerMigrator: Codeunit "GP Customer Migrator";
        VendorMigrator: Codeunit "GP Vendor Migrator";
        VendorFacade: Codeunit "Vendor Data Migration Facade";
        Assert: Codeunit Assert;
        HelperFunctions: Codeunit "Helper Functions";
        GPDataMigrationTests: Codeunit "GP Data Migration Tests";
        VendorIdWithBankStr1Txt: Label 'VENDOR001', Comment = 'Vendor Id with bank account information', Locked = true;
        VendorIdWithBankStr2Txt: Label 'VENDOR002', Comment = 'Vendor Id with bank account information', Locked = true;
        VendorIdWithBankStr3Txt: Label 'VENDOR003', Comment = 'Vendor Id with bank account information', Locked = true;
        VendorIdWithBankStr4Txt: Label 'VENDOR004', Comment = 'Vendor Id with bank account information', Locked = true;
        VendorIdWithBankStr5Txt: Label 'VENDOR005', Comment = 'Vendor Id with bank account information', Locked = true;
        ValidSwiftCodeStrTxt: Label 'BOFAUS3N', Comment = 'Valid SWIFT Code', Locked = true;
#pragma warning disable AA0240
        ValidIBANStrTxt: Label 'GB33BUKB20201555555555', Comment = 'Valid IBAN code', Locked = true;
#pragma warning restore AA0240
        InvalidIBANStr1Txt: Label 'GB33555559', Comment = 'Invalid IBAN code', Locked = true;
        InvalidIBANStr2Txt: Label '`', Comment = 'Invalid IBAN code', Locked = true;
        AddressCodeRemitToTxt: Label 'REMIT TO', Comment = 'GP ADRSCODE', Locked = true;
        AddressCodePrimaryTxt: Label 'PRIMARY', Comment = 'GP ADRSCODE', Locked = true;
        AddressCodeWarehouseTxt: Label 'WAREHOUSE', Comment = 'GP ADRSCODE', Locked = true;
        AddressCodeOtherTxt: Label 'OTHER', Comment = 'Dummy GP ADRSCODE', Locked = true;
        AddressCodeOther2Txt: Label 'OTHER2', Comment = 'Dummy GP ADRSCODE', Locked = true;
        CurrencyCodeUSTxt: Label 'Z-US$', Comment = 'GP US Currency Code', Locked = true;
        PONumberTxt: Label 'PO001', Comment = 'PO number for Migrate Open POs setting tests', Locked = true;
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        TestMoneyCurrencyCodeTxt: Label 'TESTMONEY', Locked = true;

    [Test]
    procedure TestKnownCountries()
    var
        GPKnownCountries: Record "GP Known Countries";
        FoundKnownCountry: Boolean;
        CountryCodeISO2: Code[2];
        CountryName: Text[50];
    begin
        GPKnownCountries.SearchKnownCountry('UniteD STATES', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('US', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('United States', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('USA', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('US', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('United States', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('US', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('US', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('United States', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('CaNAda', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('CA', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('Canada', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('CAN', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('CA', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('Canada', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('CA', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(true, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('CA', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('Canada', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(false, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('', CountryName, 'Found country name is incorrect.');

        GPKnownCountries.SearchKnownCountry('SATURN', FoundKnownCountry, CountryCodeISO2, CountryName);
        Assert.AreEqual(false, FoundKnownCountry, 'Country was not found.');
        Assert.AreEqual('', CountryCodeISO2, 'ISO2 code is incorrect.');
        Assert.AreEqual('', CountryName, 'Found country name is incorrect.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerImport()
    var
        Customer: Record "Customer";
        GenJournalLine: Record "Gen. Journal Line";
        ShipToAddress: Record "Ship-to Address";
        InitialGenJournalLineCount: Integer;
        CustomerCount: Integer;
    begin
        // [SCENARIO] All Customers are queried from GP

        // [GIVEN] GP data
        Initialize();
        InitialGenJournalLineCount := GenJournalLine.Count();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Receivables Module and Customer classes settings
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPCompanyAdditionalSettings.Modify();

        // When adding Customers, update the expected count here
        CustomerCount := 3;

        // [WHEN] Data is imported
        CreateCustomerData();
        CreateCustomerClassData();
        CreateCustomerTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(CustomerCount, GPCustomer.Count(), 'Wrong number of Customers read');
        Assert.AreEqual(CustomerCount, HelperFunctions.GetNumberOfCustomers(), 'Wrong number of Customers calculated');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        GPCustomer.SetRange(CUSTNMBR, '!WOW!');
        GPCustomer.FindFirst();
        Assert.AreEqual('Oh! What a feeling!', GPCustomer.CUSTNAME, 'CUSTNAME of Customer is wrong');
        Assert.AreEqual('Oh! What a feeling!', GPCustomer.STMTNAME, 'STMTNAME of Customer is wrong');
        Assert.AreEqual('', GPCustomer.ADDRESS1, 'ADDRESS1 of Customer is wrong');
        Assert.AreEqual('Toyota Land', GPCustomer.ADDRESS2, 'ADDRESS2 of Customer is wrong');
        Assert.AreEqual('!What a city!', GPCustomer.CITY, 'CITY of Customer is wrong');
        Assert.AreEqual('Todd Scott', GPCustomer.CNTCPRSN, 'CNTCPRSN of Customer is wrong');
        Assert.AreEqual('00000000000000', GPCustomer.PHONE1, 'PHONE1 Phone of Customer is wrong');
        Assert.AreEqual('MIDWEST', GPCustomer.SALSTERR, 'SALSTERR of Customer is wrong');
        Assert.AreEqual(1000, GPCustomer.CRLMTAMT, 'CRLMTAMT of Customer is wrong');
        Assert.AreEqual('2% EOM/Net 15th', GPCustomer.PYMTRMID, 'PYMTRMID of Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', GPCustomer.SLPRSNID, 'SLPRSNID of Customer is wrong');
        Assert.AreEqual('MAIL', GPCustomer.SHIPMTHD, 'SHIPMTHD of Customer is wrong');
        Assert.AreEqual('USA', GPCustomer.COUNTRY, 'COUNTRY of Customer is wrong');
        Assert.AreEqual(3970.61, GPCustomer.AMOUNT, 'AMOUNT of Customer is wrong');
        Assert.IsTrue(GPCustomer.STMTCYCL, 'STMTCYCL of Customer is wrong');
        Assert.AreEqual('00000000000000', GPCustomer.FAX, 'FAX of Customer is wrong');
        Assert.AreEqual('84953', GPCustomer.ZIPCODE, 'ZIPCODE of Customer is wrong');
        Assert.AreEqual('OH', GPCustomer.STATE, 'WebAdSTATEdr of Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', GPCustomer.TAXSCHID, 'TAXSCHID of Customer is wrong');
        Assert.AreEqual('O4', GPCustomer.UPSZONE, 'UPSZONE of Customer is wrong');

        // [WHEN] data is migrated
        Customer.DeleteAll();
        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);

        // [then] Then the correct number of Customers are applied
        Assert.AreEqual(CustomerCount, Customer.Count(), 'Wrong number of Migrated Customers read');

        // [then] Then fields for Customer 1 are correctly applied
        Customer.SetRange("No.", '!WOW!');
        Customer.FindFirst();
        Assert.AreEqual('Oh! What a feeling!', Customer.Name, 'Name of Migrated Customer is wrong');
        Assert.AreEqual('Oh! What a feeling!', Customer."Name 2", 'Name2 of Migrated Customer is wrong');
        Assert.AreEqual('Todd Scott', Customer.Contact, 'Contact Name of Migrated Customer is wrong');
        Assert.AreEqual('OH! WHAT A FEELING!', Customer."Search Name", 'Search Name of Migrated Customer is wrong');
        Assert.AreEqual('', Customer.Address, 'Address of Migrated Customer is wrong');
        Assert.AreEqual('Toyota Land', Customer."Address 2", 'Address2 of Migrated Customer is wrong');
        Assert.AreEqual('!What a city!', Customer.City, 'City of Migrated Customer is wrong');
        Assert.AreEqual('84953', Customer."Post Code", 'Post Code of Migrated Customer is wrong');
        Assert.AreEqual('US', Customer."Country/Region Code", 'Country/Region of Migrated Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', Customer."Salesperson Code", 'Salesperson Code of Migrated Customer is wrong');
        Assert.AreEqual('MAIL', Customer."Shipment Method Code", 'Shipment Method Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Print Statements", 'Print Statements of Migrated Customer is wrong');
        Assert.AreEqual('MIDWEST', Customer."Territory Code", 'Territory Code of Migrated Customer is wrong');
        Assert.AreEqual(1000, Customer."Credit Limit (LCY)", 'Credit Limit (LCY) of Migrated Customer is wrong');
        Assert.AreEqual('2% EOM/NET', Customer."Payment Terms Code", 'Payment Terms Code of Migrated Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', Customer."Tax Area Code", 'Tax Area Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Tax Liable", 'Tax Liable of Migrated Customer is wrong');

        // [WHEN] the Customer phone and/or fax were default (00000000000000)
        // [then] The phone and/or fax values are empty 
        Assert.AreEqual('', Customer."Phone No.", 'Phone No. of Migrated Customer should be empty');
        Assert.AreEqual('', Customer."Fax No.", 'Fax No. of Migrated Customer should be empty');

        // [WHEN] the Customer phone and/or fax were not default (00000000000000)
        Customer.Reset();
        Customer.SetRange("No.", '"AMERICAN"');
        Customer.FindFirst();

        // [then] The phone and/or fax values will be set to the migrated value
        Assert.AreEqual('31847240170000', Customer."Phone No.", 'Phone No. of Migrated Customer is wrong');
        Assert.AreEqual('31847240200000', Customer."Fax No.", 'Fax No. of Migrated Customer is wrong');

        // [THEN] Transactions will be created
        Assert.RecordCount(GenJournalLine, 2 + InitialGenJournalLineCount);

        // [WHEN] Customer classes are migrated
        Assert.AreEqual('100', HelperFunctions.GetPostingAccountNumber('ReceivablesAccount'), 'Default Receivables account is incorrect.');

        // [THEN] The class Receivables account will be used for transactions when an account is configured for the class with an account number
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", '!WOW!');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual('TEST987', GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [THEN] The default account will be set for the Bal. Account No. where class has no account configured
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", '#1');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual(HelperFunctions.GetPostingAccountNumber('ReceivablesAccount'), GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [WHEN] Customer addresses are migrated
        // [THEN] Email addresses are included with the addresses when they are valid
        Customer.SetRange("No.", '#1');
        Customer.FindFirst();
        Assert.AreEqual('GoodEmailAddress@testing.tst;support@testing.tst', Customer."E-Mail", 'E-Mail of Migrated Customer is wrong');

        Assert.IsTrue(ShipToAddress.Get('#1', 'PRIMARY'), 'Customer primary address does not exist.');
        Assert.AreEqual('GoodEmailAddress@testing.tst', ShipToAddress."E-Mail", 'Customer primary address email was not set correctly.');

        Assert.IsTrue(ShipToAddress.Get('#1', 'BILLING'), 'Customer billing address does not exist.');
        Assert.AreEqual('GoodEmailAddress2@testing.tst', ShipToAddress."E-Mail", 'Customer billing address email was not set correctly.');

        Assert.IsTrue(ShipToAddress.Get('#1', 'WAREHOUSE'), 'Customer warehouse address does not exist.');
        Assert.AreEqual('', ShipToAddress."E-Mail", 'Customer warehouse address email should be empty.');

        Assert.IsTrue(ShipToAddress.Get('#1', 'OTHER'), 'Customer other address does not exist.');
        Assert.AreEqual('', ShipToAddress."E-Mail", 'Customer other address email should be empty.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestEmailAddressSelection()
    begin
        // [SCENARIO] Data migrated from GP contains records and email info in SY01200

        Clear(GPSY01200);
        GPSY01200.EmailToAddress := 'longeremailaddressshouldnotbeselected@test.net';
        GPSY01200.EmailCcAddress := 'ANOTHEREMAILADDRESS@test.net';
        GPSY01200.EmailBccAddress := 'anotheremailaddress@test.net';
        GPSY01200.INET1 := 'shortemail@test.net';

        // [WHEN] 20 is the max length
        // [THEN] The shorter email in INET1 will be selected
        Assert.AreEqual('shortemail@test.net', GPSY01200.GetSingleEmailAddress(20), 'Incorrect email address. (20 max length)');
        Assert.AreEqual('shortemail@test.net', GPSY01200.GetAllEmailAddressesText(20), 'Incorrect multiple email text. (20 max length)');

        // [WHEN] 50 is the max length
        // [THEN] Only the EmailToAddress will be selected
        Assert.AreEqual('longeremailaddressshouldnotbeselected@test.net', GPSY01200.GetSingleEmailAddress(50), 'Incorrect email address. (50 max length)');
        Assert.AreEqual('longeremailaddressshouldnotbeselected@test.net', GPSY01200.GetAllEmailAddressesText(50), 'Incorrect multiple email text. (50 max length)');

        // [WHEN] 100 is the max length
        // [THEN] The EmailToAddress will be selected since the max is large enough
        Assert.AreEqual('longeremailaddressshouldnotbeselected@test.net', GPSY01200.GetSingleEmailAddress(100), 'Incorrect email address. (100 max length)');

        // [THEN] All non-duplicate email addresses will be selected
        Assert.AreEqual('longeremailaddressshouldnotbeselected@test.net;ANOTHEREMAILADDRESS@test.net;shortemail@test.net', GPSY01200.GetAllEmailAddressesText(100), 'Incorrect multiple email text. (100 max length)');

        // [WHEN] The only valid email address is INET1, and it's within the max length boundary
        Clear(GPSY01200);
        GPSY01200.EmailToAddress := '';
        GPSY01200.EmailCcAddress := 'bad data;';
        GPSY01200.EmailBccAddress := '';
        GPSY01200.INET1 := 'OnlyEmailAddress@test.net';

        // [THEN] The correct email address will be selected
        Assert.AreEqual('OnlyEmailAddress@test.net', GPSY01200.GetSingleEmailAddress(80), 'Incorrect email address. (80 max length)');
        Assert.AreEqual('OnlyEmailAddress@test.net', GPSY01200.GetAllEmailAddressesText(80), 'Incorrect email address. (80 max length)');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestReceivablesMasterDataOnly()
    var
        Customer: Record "Customer";
        GenJournalLine: Record "Gen. Journal Line";
        InitialGenJournalLineCount: Integer;
        CustomerCount: Integer;
    begin
        // [SCENARIO] All Customers are queried from GP

        // [GIVEN] GP data
        Initialize();
        InitialGenJournalLineCount := GenJournalLine.Count();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Receivables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", true);
        GPCompanyAdditionalSettings.Modify();

        // When adding Customers, update the expected count here
        CustomerCount := 3;

        // [WHEN] Data is imported
        CreateCustomerData();
        CreateCustomerClassData();
        CreateCustomerTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(CustomerCount, GPCustomer.Count(), 'Wrong number of Customers read');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        GPCustomer.SetRange(CUSTNMBR, '!WOW!');
        GPCustomer.FindFirst();
        Assert.AreEqual('Oh! What a feeling!', GPCustomer.CUSTNAME, 'CUSTNAME of Customer is wrong');
        Assert.AreEqual('Oh! What a feeling!', GPCustomer.STMTNAME, 'STMTNAME of Customer is wrong');
        Assert.AreEqual('', GPCustomer.ADDRESS1, 'ADDRESS1 of Customer is wrong');
        Assert.AreEqual('Toyota Land', GPCustomer.ADDRESS2, 'ADDRESS2 of Customer is wrong');
        Assert.AreEqual('!What a city!', GPCustomer.CITY, 'CITY of Customer is wrong');
        Assert.AreEqual('Todd Scott', GPCustomer.CNTCPRSN, 'CNTCPRSN of Customer is wrong');
        Assert.AreEqual('00000000000000', GPCustomer.PHONE1, 'PHONE1 Phone of Customer is wrong');
        Assert.AreEqual('MIDWEST', GPCustomer.SALSTERR, 'SALSTERR of Customer is wrong');
        Assert.AreEqual(1000, GPCustomer.CRLMTAMT, 'CRLMTAMT of Customer is wrong');
        Assert.AreEqual('2% EOM/Net 15th', GPCustomer.PYMTRMID, 'PYMTRMID of Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', GPCustomer.SLPRSNID, 'SLPRSNID of Customer is wrong');
        Assert.AreEqual('MAIL', GPCustomer.SHIPMTHD, 'SHIPMTHD of Customer is wrong');
        Assert.AreEqual('USA', GPCustomer.COUNTRY, 'COUNTRY of Customer is wrong');
        Assert.AreEqual(3970.61, GPCustomer.AMOUNT, 'AMOUNT of Customer is wrong');
        Assert.IsTrue(GPCustomer.STMTCYCL, 'STMTCYCL of Customer is wrong');
        Assert.AreEqual('00000000000000', GPCustomer.FAX, 'FAX of Customer is wrong');
        Assert.AreEqual('84953', GPCustomer.ZIPCODE, 'ZIPCODE of Customer is wrong');
        Assert.AreEqual('OH', GPCustomer.STATE, 'WebAdSTATEdr of Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', GPCustomer.TAXSCHID, 'TAXSCHID of Customer is wrong');
        Assert.AreEqual('O4', GPCustomer.UPSZONE, 'UPSZONE of Customer is wrong');

        // [WHEN] data is migrated
        Customer.DeleteAll();
        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);

        // [then] Then the correct number of Customers are applied
        Assert.AreEqual(CustomerCount, Customer.Count(), 'Wrong number of Migrated Customers read');

        // [then] Then fields for Customer 1 are correctly applied
        Customer.SetRange("No.", '!WOW!');
        Customer.FindFirst();
        Assert.AreEqual('Oh! What a feeling!', Customer.Name, 'Name of Migrated Customer is wrong');
        Assert.AreEqual('Oh! What a feeling!', Customer."Name 2", 'Name2 of Migrated Customer is wrong');
        Assert.AreEqual('Todd Scott', Customer.Contact, 'Contact Name of Migrated Customer is wrong');
        Assert.AreEqual('OH! WHAT A FEELING!', Customer."Search Name", 'Search Name of Migrated Customer is wrong');
        Assert.AreEqual('', Customer.Address, 'Address of Migrated Customer is wrong');
        Assert.AreEqual('Toyota Land', Customer."Address 2", 'Address2 of Migrated Customer is wrong');
        Assert.AreEqual('!What a city!', Customer.City, 'City of Migrated Customer is wrong');
        Assert.AreEqual('84953', Customer."Post Code", 'Post Code of Migrated Customer is wrong');
        Assert.AreEqual('US', Customer."Country/Region Code", 'Country/Region of Migrated Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', Customer."Salesperson Code", 'Salesperson Code of Migrated Customer is wrong');
        Assert.AreEqual('MAIL', Customer."Shipment Method Code", 'Shipment Method Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Print Statements", 'Print Statements of Migrated Customer is wrong');
        Assert.AreEqual('MIDWEST', Customer."Territory Code", 'Territory Code of Migrated Customer is wrong');
        Assert.AreEqual(1000, Customer."Credit Limit (LCY)", 'Credit Limit (LCY) of Migrated Customer is wrong');
        Assert.AreEqual('2% EOM/NET', Customer."Payment Terms Code", 'Payment Terms Code of Migrated Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', Customer."Tax Area Code", 'Tax Area Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Tax Liable", 'Tax Liable of Migrated Customer is wrong');

        // [WHEN] the Customer phone and/or fax were default (00000000000000)
        // [then] The phone and/or fax values are empty 
        Assert.AreEqual('', Customer."Phone No.", 'Phone No. of Migrated Customer should be empty');
        Assert.AreEqual('', Customer."Fax No.", 'Fax No. of Migrated Customer should be empty');

        // [WHEN] the Customer phone and/or fax were not default (00000000000000)
        Customer.Reset();
        Customer.SetRange("No.", '"AMERICAN"');
        Customer.FindFirst();

        // [then] The phone and/or fax values will be set to the migrated value
        Assert.AreEqual('31847240170000', Customer."Phone No.", 'Phone No. of Migrated Customer is wrong');
        Assert.AreEqual('31847240200000', Customer."Fax No.", 'Fax No. of Migrated Customer is wrong');

        // [THEN] Transactions will NOT be created
        Assert.RecordCount(GenJournalLine, InitialGenJournalLineCount);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestReceivablesSkipPosting()
    var
        Customer: Record "Customer";
        GenJournalLine: Record "Gen. Journal Line";
        CustomerCount: Integer;
    begin
        // [SCENARIO] All Customers are queried from GP

        // [GIVEN] GP data
        Initialize();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Receivables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", false);
        GPCompanyAdditionalSettings.Validate("Skip Posting Customer Batches", true);
        GPCompanyAdditionalSettings.Modify();

        // When adding Customers, update the expected count here
        CustomerCount := 3;

        // [WHEN] Data is imported
        CreateCustomerData();
        CreateCustomerClassData();
        CreateCustomerTrx();

        GPTestHelperFunctions.InitializeMigration();

        Assert.AreEqual(CustomerCount, GPCustomer.Count(), 'Wrong number of Customers read');

        // [WHEN] Data is migrated
        Customer.DeleteAll();
        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);

        // [then] Then the correct number of Customers are applied
        Assert.AreEqual(CustomerCount, Customer.Count(), 'Wrong number of Migrated Customers read');

        // [THEN] The GL Batch is created but not posted
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Batch Name", 'GPCUST');
        Assert.AreEqual(false, GenJournalLine.IsEmpty(), 'Could not locate the account batch.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestReceivablesDisabled()
    var
        Customer: Record "Customer";
        CustomerCount: Integer;
    begin
        // [SCENARIO] All Customers are queried from GP, but the Receivables Module is disabled

        // [GIVEN] GP data
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Disable Receivables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] adding Customers, update the expected count here
        CustomerCount := 3;

        // [WHEN] Data is imported
        CreateCustomerData();

        GPTestHelperFunctions.InitializeMigration();

        // [THEN] Then the correct number of Customers are imported
        Assert.AreEqual(CustomerCount, GPCustomer.Count(), 'Wrong number of GPCustomers found.');
        Assert.AreEqual(0, HelperFunctions.GetNumberOfCustomers(), 'Wrong number of Customers calculated.');

        // [WHEN] data is migrated
        Customer.DeleteAll();
        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);

        Assert.RecordCount(Customer, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImport()
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        OrderAddress: Record "Order Address";
        RemitAddress: Record "Remit Address";
        GenJournalLine: Record "Gen. Journal Line";
        InitialGenJournalLineCount: Integer;
        Country: Code[10];
        VendorCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        InitialGenJournalLineCount := GenJournalLine.Count();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module and Vendor Classes settings
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();
        CreateVendorClassData();
        CreateVendorTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] adding Vendors, update the expected count here
        VendorCount := 54;

        // [Then] the correct number of Vendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of Vendor read');
        Assert.AreEqual(VendorCount, HelperFunctions.GetNumberOfVendors(), 'Wrong number of Vendors calculated.');

        // [THEN] Then fields for Vendor 1 are correctly imported to temporary table
        GPVendor.SetRange(VENDORID, '1160');
        GPVendor.FindFirst();
        Assert.AreEqual('Risco, Inc.', GPVendor.VENDNAME, 'VENDNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', GPVendor.SEARCHNAME, 'SEARCHNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', GPVendor.VNDCHKNM, 'VNDCHKNM of Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', GPVendor.ADDRESS1, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Suite 234', GPVendor.ADDRESS2, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Fort Worth', GPVendor.CITY, 'CITY of Vendor is wrong');
        Assert.AreEqual('Roger', GPVendor.VNDCNTCT, 'VNDCNTCT Phone of Vendor is wrong');
        Assert.AreEqual('50482743320000', GPVendor.PHNUMBR1, 'PHNUMBR1 of Vendor is wrong');
        Assert.AreEqual('3% 15th/Net 30', GPVendor.PYMTRMID, 'PYMTRMID of Vendor is wrong');
        Assert.AreEqual('UPS BLUE', GPVendor.SHIPMTHD, 'SHIPMTHD of Vendor is wrong');
        Assert.AreEqual('', GPVendor.COUNTRY, 'SLPRSNID of Vendor is wrong');
        Assert.AreEqual('', GPVendor.PYMNTPRI, 'PYMNTPRI of Vendor is wrong');
        Assert.AreEqual(12.18, GPVendor.AMOUNT, 'AMOUNT of Vendor is wrong');
        Assert.AreEqual('50482743400000', GPVendor.FAXNUMBR, 'FAXNUMBR of Vendor is wrong');
        Assert.AreEqual('TX', GPVendor.STATE, 'STATE of Vendor is wrong');
        Assert.AreEqual('', GPVendor.INET1, 'INET1 of Vendor is wrong');
        Assert.AreEqual(' ', GPVendor.INET2, 'INET2 of Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', GPVendor.TAXSCHID, 'TAXSCHID of Vendor is wrong');
        Assert.AreEqual('T3', GPVendor.UPSZONE, 'UPSZONE of Vendor is wrong');
        Assert.AreEqual('45-0029728', GPVendor.TXIDNMBR, 'TXIDNMBR of Vendor is wrong');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        GPVendor.Reset();
        MigrateVendors(GPVendor);

        // [THEN] The correct number of Vendors are applied
        Assert.AreEqual(VendorCount, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [THEN] The fields for Vendors 1 are correctly applied
        Vendor.SetRange("No.", '1160');
        Vendor.FindFirst();

        CompanyInformation.Get();
        Country := CompanyInformation."Country/Region Code";

        Assert.AreEqual('Risco, Inc.', Vendor.Name, 'Name of Migrated Vendor is wrong');

        // [THEN] The Vendor Name 2 will be blank because it is the same as the Vendor name
        Assert.AreEqual('', Vendor."Name 2", 'Name 2 of Migrated Vendor is wrong');
        Assert.AreEqual('Roger', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('RISCO, INC.', Vendor."Search Name", 'Search Name of Migrated Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('Suite 234', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Fort Worth', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('50482743320000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('50482743400000', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');
        Assert.AreEqual(Country, Vendor."Country/Region Code", 'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('UPS BLUE', Vendor."Shipment Method Code", 'Shipment Method Code of Migrated Vendor is wrong');
        Assert.AreEqual('3% 15TH/NE', Vendor."Payment Terms Code", 'Payment Terms Code of Migrated Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', Vendor."Tax Area Code", 'Tax Area Code of Migrated Vendor is wrong');
        Assert.AreEqual(true, Vendor."Tax Liable", 'Tax Liable of Migrated Vendor is wrong');

        // [THEN] The Order addresses will be created correctly
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0001');
        Assert.RecordCount(OrderAddress, 1);

        OrderAddress.FindFirst();
        Assert.AreEqual(AddressCodePrimaryTxt, OrderAddress.Code, 'Code of Order Address is wrong.');
        Assert.AreEqual('Greg Powell', OrderAddress.Contact, 'Contact of Order Address is wrong.');
        Assert.AreEqual('123 Riley Street', OrderAddress.Address, 'Address of Order Address is wrong.');
        Assert.AreEqual('Sydney', OrderAddress.City, 'City of Order Address is wrong.');
        Assert.AreEqual('NSW', OrderAddress.County, 'State/Region code of Order Address is wrong.');
        Assert.AreEqual('2086', OrderAddress."Post Code", 'Post Code of Order Address is wrong.');
        Assert.AreEqual('29855501010000', OrderAddress."Phone No.", 'Phone No. of Order Address is wrong.');
        Assert.AreEqual('29455501010000', OrderAddress."Fax No.", 'Fax No. of Order Address is wrong.');

        // [THEN] The Remit addresses will be created correctly
        RemitAddress.SetRange("Vendor No.", 'ACETRAVE0001');
        Assert.RecordCount(RemitAddress, 1);

        // [THEN] The Order addresses will be created correctly
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        Assert.RecordCount(OrderAddress, 2);

        RemitAddress.FindFirst();
        Assert.AreEqual('Greg Powell', RemitAddress.Contact, 'Contact of Remit Address is wrong.');
        Assert.AreEqual('Box 342', RemitAddress.Address, 'Address of Remit Address is wrong.');
        Assert.AreEqual('Sydney', RemitAddress.City, 'City of Remit Address is wrong.');
        Assert.AreEqual('NSW', RemitAddress.County, 'State/Region code of Remit Address is wrong.');
        Assert.AreEqual('2000', RemitAddress."Post Code", 'Post Code of Remit Address is wrong.');
        Assert.AreEqual('29855501020000', RemitAddress."Phone No.", 'Phone No. of Remit Address is wrong.');
        Assert.AreEqual('29455501020000', RemitAddress."Fax No.", 'Fax No. of Remit Address is wrong.');

        RemitAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        Assert.RecordCount(RemitAddress, 0);

        // [WHEN] The Primary and Remit to is the same

        // [THEN] The Order address will be created
        OrderAddress.SetRange("Vendor No.", 'ACME');
        OrderAddress.FindFirst();
        Assert.AreEqual(AddressCodePrimaryTxt, OrderAddress.Code, 'Code of Order Address is wrong.');
        Assert.AreEqual('Mr. Lashro', OrderAddress.Contact, 'Contact of Order Address is wrong.');
        Assert.AreEqual('P.O. Box 183', OrderAddress.Address, 'Address of Order Address is wrong.');
        Assert.AreEqual('Harvey', OrderAddress.City, 'City of Order Address is wrong.');
        Assert.AreEqual('ND', OrderAddress.County, 'State/Region code of Order Address is wrong.');
        Assert.AreEqual('70059', OrderAddress."Post Code", 'Post Code of Order Address is wrong.');
        Assert.AreEqual('30543212880000', OrderAddress."Phone No.", 'Phone No. of Order Address is wrong.');
        Assert.AreEqual('30543212900000', OrderAddress."Fax No.", 'Fax No. of Order Address is wrong.');

        // [THEN] The Remit address will be created
        RemitAddress.SetRange("Vendor No.", 'ACME');
        RemitAddress.FindFirst();
        Assert.AreEqual(AddressCodeRemitToTxt, RemitAddress.Code, 'Code of Remit Address is wrong.');
        Assert.AreEqual('Mr. Lashro', RemitAddress.Contact, 'Contact of Remit Address is wrong.');
        Assert.AreEqual('P.O. Box 183', RemitAddress.Address, 'Address of Remit Address is wrong.');
        Assert.AreEqual('Harvey', RemitAddress.City, 'City of Remit Address is wrong.');
        Assert.AreEqual('ND', RemitAddress.County, 'State/Region code of Remit Address is wrong.');
        Assert.AreEqual('70059', RemitAddress."Post Code", 'Post Code of Remit Address is wrong.');
        Assert.AreEqual('30543212880000', RemitAddress."Phone No.", 'Phone No. of Remit Address is wrong.');
        Assert.AreEqual('30543212900000', RemitAddress."Fax No.", 'Fax No. of Remit Address is wrong.');

        // [WHEN] the Vendor phone and/or fax were default (00000000000000)
        Vendor.Reset();
        Vendor.SetRange("No.", 'ACETRAVE0002');
        Vendor.FindFirst();

        // [THEN] The phone and/or fax values are empty
        Assert.AreEqual('', Vendor."Phone No.", 'Phone No. of Migrated Vendor should be empty');
        Assert.AreEqual('', Vendor."Fax No.", 'Fax No. of Migrated Vendor should be empty');

        // [WHEN] the Vendor address phone and/or fax were default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'WAREHOUSE');
        OrderAddress.FindFirst();

        // [THEN] The phone and/or fax values are empty
        Assert.AreEqual('', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');

        // [WHEN] the Vendor address phone and/or fax were not default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'Primary');
        OrderAddress.FindFirst();

        // [THEN] The phone and/or fax values will be set to the migrated value
        Assert.AreEqual('61855501040000', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('61855501040000', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');

        // [THEN] Vendor transactions will be created
        Assert.RecordCount(GenJournalLine, 2 + InitialGenJournalLineCount);

        // [WHEN] Vendor classes are migrated
        Assert.AreEqual('1', HelperFunctions.GetPostingAccountNumber('PayablesAccount'), 'Default Payables account is incorrect.');

        // [THEN] The class Payables account will be used for transactions when an account is configured for the class
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", '1160');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual('TEST123', GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [THEN] The default Payables account is used when no class is set on the Vender
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", 'V3130');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual(HelperFunctions.GetPostingAccountNumber('PayablesAccount'), GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [WHEN] Vendor addresses are migrated
        // [THEN] Email addresses are included with the addresses when they are valid
        Assert.IsTrue(OrderAddress.Get('ACME', 'PRIMARY'), 'Vendor primary address does not exist.');
        Assert.AreEqual('GoodEmailAddress@testing.tst', OrderAddress."E-Mail", 'Vendor primary address email was not set correctly.');

        Assert.IsTrue(RemitAddress.Get('REMIT TO', 'ACME'), 'Vendor remit address does not exist.');
        Assert.AreEqual('GoodEmailAddress2@testing.tst', RemitAddress."E-Mail", 'Vendor remit address email was not set correctly.');

        Assert.IsTrue(OrderAddress.Get('ACETRAVE0001', 'PRIMARY'), 'Vendor primary address does not exist.');
        Assert.AreEqual('', OrderAddress."E-Mail", 'Vendor primary address email should be empty.');

        Assert.IsTrue(RemitAddress.Get('REMIT TO', 'ACETRAVE0001'), 'Vendor remit address does not exist.');
        Assert.AreEqual('', RemitAddress."E-Mail", 'Vendor remit address email should be empty.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDisableTemporaryVendors()
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        OrderAddress: Record "Order Address";
        RemitAddress: Record "Remit Address";
        GenJournalLine: Record "Gen. Journal Line";
        InitialGenJournalLineCount: Integer;
        Country: Code[10];
        VendorCount: Integer;
        VendorsToMigrateCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        InitialGenJournalLineCount := GenJournalLine.Count();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Disable temporary Vendors
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Temporary Vendors", false);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();
        CreateVendorClassData();
        CreateVendorTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] adding Vendors, update the expected count here
        VendorCount := 54;
        VendorsToMigrateCount := 53;

        // [Then] the correct number of Vendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of Vendor read');
        Assert.AreEqual(VendorsToMigrateCount, HelperFunctions.GetNumberOfVendors(), 'Wrong number of Vendors calculated.');

        // [THEN] Then fields for Vendor 1 are correctly imported to temporary table
        GPVendor.SetRange(VENDORID, '1160');
        GPVendor.FindFirst();
        Assert.AreEqual('Risco, Inc.', GPVendor.VENDNAME, 'VENDNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', GPVendor.SEARCHNAME, 'SEARCHNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', GPVendor.VNDCHKNM, 'VNDCHKNM of Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', GPVendor.ADDRESS1, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Suite 234', GPVendor.ADDRESS2, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Fort Worth', GPVendor.CITY, 'CITY of Vendor is wrong');
        Assert.AreEqual('Roger', GPVendor.VNDCNTCT, 'VNDCNTCT Phone of Vendor is wrong');
        Assert.AreEqual('50482743320000', GPVendor.PHNUMBR1, 'PHNUMBR1 of Vendor is wrong');
        Assert.AreEqual('3% 15th/Net 30', GPVendor.PYMTRMID, 'PYMTRMID of Vendor is wrong');
        Assert.AreEqual('UPS BLUE', GPVendor.SHIPMTHD, 'SHIPMTHD of Vendor is wrong');
        Assert.AreEqual('', GPVendor.COUNTRY, 'SLPRSNID of Vendor is wrong');
        Assert.AreEqual('', GPVendor.PYMNTPRI, 'PYMNTPRI of Vendor is wrong');
        Assert.AreEqual(12.18, GPVendor.AMOUNT, 'AMOUNT of Vendor is wrong');
        Assert.AreEqual('50482743400000', GPVendor.FAXNUMBR, 'FAXNUMBR of Vendor is wrong');
        Assert.AreEqual('TX', GPVendor.STATE, 'STATE of Vendor is wrong');
        Assert.AreEqual('', GPVendor.INET1, 'INET1 of Vendor is wrong');
        Assert.AreEqual(' ', GPVendor.INET2, 'INET2 of Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', GPVendor.TAXSCHID, 'TAXSCHID of Vendor is wrong');
        Assert.AreEqual('T3', GPVendor.UPSZONE, 'UPSZONE of Vendor is wrong');
        Assert.AreEqual('45-0029728', GPVendor.TXIDNMBR, 'TXIDNMBR of Vendor is wrong');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        GPVendor.Reset();
        MigrateVendors(GPVendor);

        // [THEN] The correct number of Vendors are applied
        Assert.AreEqual(VendorsToMigrateCount, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [THEN] The fields for Vendors 1 are correctly applied
        Vendor.SetRange("No.", '1160');
        Vendor.FindFirst();

        CompanyInformation.Get();
        Country := CompanyInformation."Country/Region Code";

        Assert.AreEqual('Risco, Inc.', Vendor.Name, 'Name of Migrated Vendor is wrong');

        // [THEN] The Vendor Name 2 will be blank because it is the same as the Vendor name
        Assert.AreEqual('', Vendor."Name 2", 'Name 2 of Migrated Vendor is wrong');
        Assert.AreEqual('Roger', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('RISCO, INC.', Vendor."Search Name", 'Search Name of Migrated Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('Suite 234', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Fort Worth', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('50482743320000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('50482743400000', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');
        Assert.AreEqual(Country, Vendor."Country/Region Code", 'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('UPS BLUE', Vendor."Shipment Method Code", 'Shipment Method Code of Migrated Vendor is wrong');
        Assert.AreEqual('3% 15TH/NE', Vendor."Payment Terms Code", 'Payment Terms Code of Migrated Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', Vendor."Tax Area Code", 'Tax Area Code of Migrated Vendor is wrong');
        Assert.AreEqual(true, Vendor."Tax Liable", 'Tax Liable of Migrated Vendor is wrong');

        // [THEN] The Order addresses will be created correctly
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0001');
        Assert.RecordCount(OrderAddress, 1);

        OrderAddress.FindFirst();
        Assert.AreEqual(AddressCodePrimaryTxt, OrderAddress.Code, 'Code of Order Address is wrong.');
        Assert.AreEqual('Greg Powell', OrderAddress.Contact, 'Contact of Order Address is wrong.');
        Assert.AreEqual('123 Riley Street', OrderAddress.Address, 'Address of Order Address is wrong.');
        Assert.AreEqual('Sydney', OrderAddress.City, 'City of Order Address is wrong.');
        Assert.AreEqual('NSW', OrderAddress.County, 'State/Region code of Order Address is wrong.');
        Assert.AreEqual('2086', OrderAddress."Post Code", 'Post Code of Order Address is wrong.');
        Assert.AreEqual('29855501010000', OrderAddress."Phone No.", 'Phone No. of Order Address is wrong.');
        Assert.AreEqual('29455501010000', OrderAddress."Fax No.", 'Fax No. of Order Address is wrong.');

        // [THEN] The Remit addresses will be created correctly
        RemitAddress.SetRange("Vendor No.", 'ACETRAVE0001');
        Assert.RecordCount(RemitAddress, 1);

        // [THEN] The Order addresses will be created correctly
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        Assert.RecordCount(OrderAddress, 2);

        RemitAddress.FindFirst();
        Assert.AreEqual('Greg Powell', RemitAddress.Contact, 'Contact of Remit Address is wrong.');
        Assert.AreEqual('Box 342', RemitAddress.Address, 'Address of Remit Address is wrong.');
        Assert.AreEqual('Sydney', RemitAddress.City, 'City of Remit Address is wrong.');
        Assert.AreEqual('NSW', RemitAddress.County, 'State/Region code of Remit Address is wrong.');
        Assert.AreEqual('2000', RemitAddress."Post Code", 'Post Code of Remit Address is wrong.');
        Assert.AreEqual('29855501020000', RemitAddress."Phone No.", 'Phone No. of Remit Address is wrong.');
        Assert.AreEqual('29455501020000', RemitAddress."Fax No.", 'Fax No. of Remit Address is wrong.');

        RemitAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        Assert.RecordCount(RemitAddress, 0);

        // [WHEN] The Primary and Remit to is the same

        // [THEN] The Order address will be created
        OrderAddress.SetRange("Vendor No.", 'ACME');
        OrderAddress.FindFirst();
        Assert.AreEqual(AddressCodePrimaryTxt, OrderAddress.Code, 'Code of Order Address is wrong.');
        Assert.AreEqual('Mr. Lashro', OrderAddress.Contact, 'Contact of Order Address is wrong.');
        Assert.AreEqual('P.O. Box 183', OrderAddress.Address, 'Address of Order Address is wrong.');
        Assert.AreEqual('Harvey', OrderAddress.City, 'City of Order Address is wrong.');
        Assert.AreEqual('ND', OrderAddress.County, 'State/Region code of Order Address is wrong.');
        Assert.AreEqual('70059', OrderAddress."Post Code", 'Post Code of Order Address is wrong.');
        Assert.AreEqual('30543212880000', OrderAddress."Phone No.", 'Phone No. of Order Address is wrong.');
        Assert.AreEqual('30543212900000', OrderAddress."Fax No.", 'Fax No. of Order Address is wrong.');

        // [THEN] The Remit address will be created
        RemitAddress.SetRange("Vendor No.", 'ACME');
        RemitAddress.FindFirst();
        Assert.AreEqual(AddressCodeRemitToTxt, RemitAddress.Code, 'Code of Remit Address is wrong.');
        Assert.AreEqual('Mr. Lashro', RemitAddress.Contact, 'Contact of Remit Address is wrong.');
        Assert.AreEqual('P.O. Box 183', RemitAddress.Address, 'Address of Remit Address is wrong.');
        Assert.AreEqual('Harvey', RemitAddress.City, 'City of Remit Address is wrong.');
        Assert.AreEqual('ND', RemitAddress.County, 'State/Region code of Remit Address is wrong.');
        Assert.AreEqual('70059', RemitAddress."Post Code", 'Post Code of Remit Address is wrong.');
        Assert.AreEqual('30543212880000', RemitAddress."Phone No.", 'Phone No. of Remit Address is wrong.');
        Assert.AreEqual('30543212900000', RemitAddress."Fax No.", 'Fax No. of Remit Address is wrong.');

        // [WHEN] the Vendor phone and/or fax were default (00000000000000)
        Vendor.Reset();
        Vendor.SetRange("No.", 'ACETRAVE0002');
        Vendor.FindFirst();

        // [THEN] The phone and/or fax values are empty
        Assert.AreEqual('', Vendor."Phone No.", 'Phone No. of Migrated Vendor should be empty');
        Assert.AreEqual('', Vendor."Fax No.", 'Fax No. of Migrated Vendor should be empty');

        // [WHEN] the Vendor address phone and/or fax were default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'WAREHOUSE');
        OrderAddress.FindFirst();

        // [THEN] The phone and/or fax values are empty
        Assert.AreEqual('', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');

        // [WHEN] the Vendor address phone and/or fax were not default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'Primary');
        OrderAddress.FindFirst();

        // [THEN] The phone and/or fax values will be set to the migrated value
        Assert.AreEqual('61855501040000', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('61855501040000', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');

        // [THEN] Vendor transactions will be created
        Assert.RecordCount(GenJournalLine, 2 + InitialGenJournalLineCount);

        // [WHEN] Vendor classes are migrated
        Assert.AreEqual('1', HelperFunctions.GetPostingAccountNumber('PayablesAccount'), 'Default Payables account is incorrect.');

        // [THEN] The class Payables account will be used for transactions when an account is configured for the class
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", '1160');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual('TEST123', GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [THEN] The default Payables account is used when no class is set on the Vender
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", 'V3130');
        Assert.IsTrue(GenJournalLine.FindFirst(), 'Could not locate Gen. Journal Line.');
        Assert.AreEqual(HelperFunctions.GetPostingAccountNumber('PayablesAccount'), GenJournalLine."Bal. Account No.", 'Incorrect Bal. Account No. on Gen. Journal Line.');

        // [WHEN] Vendor addresses are migrated
        // [THEN] Email addresses are included with the addresses when they are valid
        Assert.IsTrue(OrderAddress.Get('ACME', 'PRIMARY'), 'Vendor primary address does not exist.');
        Assert.AreEqual('GoodEmailAddress@testing.tst', OrderAddress."E-Mail", 'Vendor primary address email was not set correctly.');

        Assert.IsTrue(RemitAddress.Get('REMIT TO', 'ACME'), 'Vendor remit address does not exist.');
        Assert.AreEqual('GoodEmailAddress2@testing.tst', RemitAddress."E-Mail", 'Vendor remit address email was not set correctly.');

        Assert.IsTrue(OrderAddress.Get('ACETRAVE0001', 'PRIMARY'), 'Vendor primary address does not exist.');
        Assert.AreEqual('', OrderAddress."E-Mail", 'Vendor primary address email should be empty.');

        Assert.IsTrue(RemitAddress.Get('REMIT TO', 'ACETRAVE0001'), 'Vendor remit address does not exist.');
        Assert.AreEqual('', RemitAddress."E-Mail", 'Vendor remit address email should be empty.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImportWithName2()
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        Country: Code[10];
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();
        CreateVendorClassData();
        GPTestHelperFunctions.InitializeMigration();

        // [Then] The fields for the Vendor are correctly imported to temporary table
        GPVendor.SetRange(VENDORID, '3070');
        GPVendor.FindFirst();
        Assert.AreEqual('L.M. Berry & co. -NYPS', GPVendor.VENDNAME, 'VENDNAME of Vendor is wrong');
        Assert.AreEqual('L.M. Berry & co. -NYPS', GPVendor.SEARCHNAME, 'SEARCHNAME of Vendor is wrong');
        Assert.AreEqual('L.M. Berry & co.', GPVendor.VNDCHKNM, 'VNDCHKNM of Vendor is wrong');
        Assert.AreEqual('Box 90255', GPVendor.ADDRESS1, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('', GPVendor.ADDRESS2, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Chicago', GPVendor.CITY, 'CITY of Vendor is wrong');
        Assert.AreEqual('', GPVendor.VNDCNTCT, 'VNDCNTCT Phone of Vendor is wrong');
        Assert.AreEqual('70143651130000', GPVendor.PHNUMBR1, 'PHNUMBR1 of Vendor is wrong');
        Assert.AreEqual('2% EOM/Net 15th', GPVendor.PYMTRMID, 'PYMTRMID of Vendor is wrong');
        Assert.AreEqual('MAIL', GPVendor.SHIPMTHD, 'SHIPMTHD of Vendor is wrong');
        Assert.AreEqual('', GPVendor.COUNTRY, 'SLPRSNID of Vendor is wrong');
        Assert.AreEqual('', GPVendor.PYMNTPRI, 'PYMNTPRI of Vendor is wrong');
        Assert.AreEqual(-34.70, GPVendor.AMOUNT, 'AMOUNT of Vendor is wrong');
        Assert.AreEqual('00000000000000', GPVendor.FAXNUMBR, 'FAXNUMBR of Vendor is wrong');
        Assert.AreEqual('IL', GPVendor.STATE, 'STATE of Vendor is wrong');
        Assert.AreEqual('505930011', GPVendor.ZIPCODE, 'ZIPCODE of Vendor is wrong');
        Assert.AreEqual('', GPVendor.INET1, 'INET1 of Vendor is wrong');
        Assert.AreEqual(' ', GPVendor.INET2, 'INET2 of Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%PTIP', GPVendor.TAXSCHID, 'TAXSCHID of Vendor is wrong');
        Assert.AreEqual('J6', GPVendor.UPSZONE, 'UPSZONE of Vendor is wrong');
        Assert.AreEqual('45-0029728', GPVendor.TXIDNMBR, 'TXIDNMBR of Vendor is wrong');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        GPVendor.Reset();
        MigrateVendors(GPVendor);

        // [THEN] The fields for Vendors are correctly applied
        Vendor.SetRange("No.", '3070');
        Vendor.FindFirst();

        CompanyInformation.Get();
        Country := CompanyInformation."Country/Region Code";

        Assert.AreEqual('L.M. Berry & co. -NYPS', Vendor.Name, 'Name of Migrated Vendor is wrong');

        // [THEN] The Vendor Name 2 will be set because it is not the same as the Vendor name
        Assert.AreEqual('L.M. Berry & co.', Vendor."Name 2", 'Name 2 of Migrated Vendor is wrong');
        Assert.AreEqual('', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('L.M. BERRY & CO. -NYPS', Vendor."Search Name", 'Search Name of Migrated Vendor is wrong');
        Assert.AreEqual('Box 90255', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Chicago', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('505930011', Vendor."Post Code", 'Post Code of Migrated Vendor is wrong');
        Assert.AreEqual('70143651130000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');
        Assert.AreEqual(Country, Vendor."Country/Region Code", 'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('MAIL', Vendor."Shipment Method Code", 'Shipment Method Code of Migrated Vendor is wrong');
        Assert.AreEqual(true, Vendor."Tax Liable", 'Tax Liable of Migrated Vendor is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPayablesMasterDataOnly()
    var
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        InitialGenJournalLineCount: Integer;
        VendorCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        InitialGenJournalLineCount := GenJournalLine.Count();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", true);
        GPCompanyAdditionalSettings.Validate("Migrate Temporary Vendors", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();
        CreateVendorClassData();
        CreateVendorTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] adding Vendors, update the expected count here
        VendorCount := 54;

        Clear(GPVendor);
        Clear(Vendor);

        // [THEN] Then the correct number of Vendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of Vendors read');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        MigrateVendors(GPVendor);

        // [THEN] Then the correct number of Vendors are applied
        Assert.AreEqual(VendorCount, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [THEN] Vendor transactions will NOT be created
        Assert.RecordCount(GenJournalLine, InitialGenJournalLineCount);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPayablesSkipPosting()
    var
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        VendorCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", false);
        GPCompanyAdditionalSettings.Validate("Skip Posting Vendor Batches", true);
        GPCompanyAdditionalSettings.Validate("Migrate Temporary Vendors", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();
        CreateVendorClassData();
        CreateVendorTrx();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] adding Vendors, update the expected count here
        VendorCount := 54;

        Clear(GPVendor);
        Clear(Vendor);

        // [THEN] Then the correct number of Vendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of Vendor read');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        MigrateVendors(GPVendor);

        // [THEN] Then the correct number of Vendors are applied
        Assert.AreEqual(VendorCount, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [THEN] The GL Batch is created but not posted
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Batch Name", 'GPVEND');
        Assert.AreEqual(false, GenJournalLine.IsEmpty(), 'Could not locate the account batch.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPayablesDisabled()
    var
        Vendor: Record Vendor;
        VendorCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP, but the Payables Module is disabled
        // [GIVEN] GP data
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Disable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateVendorData();

        GPTestHelperFunctions.InitializeMigration();

        // When adding Vendors, update the expected count here
        VendorCount := 54;

        Clear(GPVendor);
        Clear(Vendor);

        // [then] Then the correct number of GPVendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of GPVendors found.');
        Assert.AreEqual(0, HelperFunctions.GetNumberOfVendors(), 'Wrong number of Vendors calculated.');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        MigrateVendors(GPVendor);

        Assert.RecordCount(Vendor, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPPaymentTerms()
    var
        PaymentTerms: Record "Payment Terms";
        DiscountDateCalculation: DateFormula;
        DueDateCalculation: DateFormula;
        CurrentPaymentTerm: Text;
    begin
        // [SCENARIO] GP Payment Terms migrate successfully. Created due to bug 362674.
        // [GIVEN] GP Payment Terms staging table records
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Modify();
        CreateGPPaymentTermsRecords();

        // [WHEN] The Payment Terms migration code is run.
        PaymentTerms.DeleteAll();
        HelperFunctions.CreatePaymentTerms();

        GPTestHelperFunctions.InitializeMigration();

        // [THEN] payment terms get created in BC.
        PaymentTerms.FindFirst();
        Assert.AreEqual(7, PaymentTerms.Count(), 'Incorrect number of Payment Terms created.');

        Evaluate(DiscountDateCalculation, '<D10>');
        Evaluate(DueDateCalculation, '<D10>');
        CurrentPaymentTerm := '1.5% 10TH - BUG';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, '1.5% 10TH0');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(1.5, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));

        Evaluate(DiscountDateCalculation, '<10D>');
        Evaluate(DueDateCalculation, '<10D-CM+1M+9D>');
        CurrentPaymentTerm := '10% NET 10';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, '10% NET 10');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(10, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));

        Evaluate(DiscountDateCalculation, '<D10>');
        Evaluate(DueDateCalculation, '<-CM+1M+9D>');
        CurrentPaymentTerm := '2% 10TH - BUG';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, '2% 10TH -1');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(2, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));

        Evaluate(DiscountDateCalculation, '');
        Evaluate(DueDateCalculation, '<10D>');
        CurrentPaymentTerm := 'NET 10';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, 'NET 10');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(0, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));

        Evaluate(DiscountDateCalculation, '');
        Evaluate(DueDateCalculation, '<-CM+1M+9D>');
        CurrentPaymentTerm := 'NET 10TH';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, 'NET 10TH');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(0, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));

        Evaluate(DiscountDateCalculation, '<CM+10D>');
        Evaluate(DueDateCalculation, '<CM+10D>');
        CurrentPaymentTerm := '2% EOM';
        PaymentTerms.Reset();
        PaymentTerms.SetRange(Code, '2% EOM');
        PaymentTerms.FindFirst();
        Assert.AreEqual(CurrentPaymentTerm, PaymentTerms.Description, StrSubstNo('Invalid description for %1', CurrentPaymentTerm));
        Assert.AreEqual(2, PaymentTerms."Discount %", StrSubstNo('Invalid discount % for %1', CurrentPaymentTerm));
        Assert.AreEqual(DiscountDateCalculation, PaymentTerms."Discount Date Calculation", StrSubstNo('Invalid Discount Date Calculation for %1', CurrentPaymentTerm));
        Assert.AreEqual(DueDateCalculation, PaymentTerms."Due Date Calculation", StrSubstNo('Invalid Due Date Calculation for %1', CurrentPaymentTerm));
    end;

    local procedure IsDateFormulaValid(DateFormulaTxt: Text): Boolean
    var
        DateFormulaObj: DateFormula;
    begin
        exit(Evaluate(DateFormulaObj, DateFormulaTxt));
    end;

    [Test]
    procedure TestCalculateDueDateFormulaEmptyRecord()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] An empty record is encountered.
        GPPaymentTerms.DUETYPE := 0;

        // [THEN] The date formula string will be empty.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual('', DateFormulaText, 'The payment term date formula should be empty for an empty record.');

        // Same for discount date formula
        DateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual('', DateFormulaText, 'The payment term discount date formula should be empty for an empty record.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeNetDays()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";

        // [WHEN] DUEDTDS < 1
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will be empty.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual('', DateFormulaText, 'The payment term date formula should be empty for DueType Net Days, DUEDTDS < 1.');

        // [WHEN] DUEDTDS > 0
        GPPaymentTerms.DUEDTDS := 30;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<30D>', DateFormulaText, 'The payment term date formula is incorrect for DueType Net Days, DUEDTDS = 30.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeDate()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;

        // [WHEN] DUEDTDS < 1
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will be empty.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual('', DateFormulaText, 'The payment term date formula should be empty for DueType Date, DUEDTDS < 1.');

        // [WHEN] DUEDTDS > 0
        GPPaymentTerms.DUEDTDS := 30;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<D30>', DateFormulaText, 'The payment term date formula is incorrect for DueType Date, DUEDTDS = 30.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeEOM()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;

        // [WHEN] DUEDTDS < 1
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<CM>', DateFormulaText, 'The payment term date formula should be correct for DueType EOM, DUEDTDS < 1.');

        // [WHEN] DUEDTDS > 0
        GPPaymentTerms.DUEDTDS := 2;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<CM+2D>', DateFormulaText, 'The payment term date formula is incorrect for DueType EOM, DUEDTDS = 2.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeNone()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;

        // [WHEN] CalculateDateFromDays < 1
        GPPaymentTerms.CalculateDateFromDays := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<0D>', DateFormulaText, 'The payment term date formula should be correct for DueType None, CalculateDateFromDays < 1.');

        // [WHEN] CalculateDateFromDays > 0
        GPPaymentTerms.CalculateDateFromDays := 2;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<2D>', DateFormulaText, 'The payment term date formula is incorrect for DueType None, CalculateDateFromDays = 2.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeNextMonth()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";

        // [WHEN] DUEDTDS < 1
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<-CM+1M+0D>', DateFormulaText, 'The payment term date formula should be correct for DueType Next Month, DUEDTDS < 1.');

        // [WHEN] DUEDTDS > 0
        GPPaymentTerms.DUEDTDS := 16;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<-CM+1M+15D>', DateFormulaText, 'The payment term date formula is incorrect for DueType Next Month, DUEDTDS = 16.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeMonths()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;

        // [WHEN] DUEDTDS < 1
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<0M+0D>', DateFormulaText, 'The payment term date formula should be correct for DueType Months, DUEDTDS < 1.');

        // [WHEN] DUEDTDS > 0
        GPPaymentTerms.DUEDTDS := 1;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<1M+0D>', DateFormulaText, 'The payment term date formula is incorrect for DueType Months, DUEDTDS = 1.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeMonthDay()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";

        // [WHEN] DueMonth and DUEDTDS < 1
        GPPaymentTerms.DueMonth := 0;
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(false, IsDateFormulaValid(DateFormulaText), 'The payment term date formula should have been invalid. ' + DateFormulaText);
        Assert.AreEqual('<M0+D0>', DateFormulaText, 'The payment term date formula should be correct for DueType Month/Day, DUEDTDS < 1.');

        // [WHEN] DueMonth and DUEDTDS > 0
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<M1+D1>', DateFormulaText, 'The payment term date formula is incorrect for DueType Month/Day, DueMonth = 1, DUEDTDS = 1.');
    end;

    [Test]
    procedure TestCalculateDueDateFormulaDueTypeAnnual()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DateFormulaText: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term is configured for Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;

        // [WHEN] CalculateDateFromDays and DUEDTDS < 1
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DUEDTDS := 0;

        // [THEN] The date formula string will have a correct value.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<0Y+0D>', DateFormulaText, 'The payment term date formula should be correct for DueType Annual, DUEDTDS < 1.');

        // [WHEN] CalculateDateFromDays and DUEDTDS > 0
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;

        // [THEN] A valid payment term date formula will be generated.
        DateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, false, '');
        Assert.AreEqual(true, IsDateFormulaValid(DateFormulaText), 'The payment term date formula is invalid. ' + DateFormulaText);
        Assert.AreEqual('<1Y+15D>', DateFormulaText, 'The payment term date formula is incorrect for DueType Annual, CalculateDateFromDays = 15, DUEDTDS = 1.');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeDays()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Days;

        // [WHEN] DISCDTDS < 1
        GPPaymentTerms.DISCDTDS := 0;

        // [THEN] The date formula string will be empty.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual('', DiscountDateFormulaText, 'The payment term discount date formula should be empty.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 15;

        // [THEN] A valid payment term date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := '15D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeDate()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Date;

        // [WHEN] DISCDTDS < 1
        GPPaymentTerms.DISCDTDS := 0;

        // [THEN] The date formula string will be empty.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual('', DiscountDateFormulaText, 'The payment term discount date formula should be empty.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 15;

        // [THEN] A valid payment term date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := 'D15';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeEOM()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::EOM;

        // [WHEN] DISCDTDS < 1
        GPPaymentTerms.DISCDTDS := 0;

        // [THEN] The date formula string will be correct.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<CM>', DiscountDateFormulaText, 'The payment term discount date formula is not correct.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 2;

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := 'CM+2D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeNone()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::None;

        // [WHEN] CalculateDateFromDays < 1
        GPPaymentTerms.CalculateDateFromDays := -1;

        // [THEN] The date formula string will be empty.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<+0D>', DiscountDateFormulaText, 'The payment term discount date formula is not correct.');

        // [WHEN] CalculateDateFromDays > 0
        GPPaymentTerms.CalculateDateFromDays := 2;

        // [THEN] The date formula string will be empty.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<+2D>', DiscountDateFormulaText, 'The payment term discount date formula is not correct.');

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := '+2D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+32D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+CM+4D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeNextMonth()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::"Next Month";

        // [WHEN] DISCDTDS < 1
        GPPaymentTerms.DISCDTDS := 0;

        // [THEN] The date formula string will be correct.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<-CM+1M+0D>;', DiscountDateFormulaText, 'The payment term discount date formula is not correct.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 3;

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := '-CM+1M+2D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>;', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeMonths()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Months;

        // [WHEN] CalculateDateFromDays and DISCDTDS < 1
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DISCDTDS := 0;

        // [THEN] The date formula string will be correct.
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<0M+0D>;', DiscountDateFormulaText, 'The payment term discount date formula is not correct.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 1;

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := '1M+0D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>;', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeMonthDay()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::"Month/Day";

        // [WHEN] DiscountMonth and DISCDTDS > 1
        GPPaymentTerms.DiscountMonth := 2;
        GPPaymentTerms.DISCDTDS := 1;

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := 'M2+D1';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    [Test]
    procedure TestCalculateDiscountDateFormulaDueTypeAnnual()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        DiscountDateFormulaText: Text;
        CombinedDateFormulaText: Text;
        ExpectedDiscountDateFormulaMinusBrackets: Text;
    begin
        // [SCENARIO] GP Payment Terms staging table is populated.
        // [GIVEN] Payment term date formula calculations are to be performed.

        // [WHEN] The payment term discount is configured.
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Annual;

        // [WHEN] DISCDTDS < 1
        GPPaymentTerms.DISCDTDS := -1;

        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<0Y+0D>;', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] DISCDTDS > 0
        GPPaymentTerms.DISCDTDS := 1;

        // [THEN] A valid date formula will be generated.
        ExpectedDiscountDateFormulaMinusBrackets := '1Y+0D';
        DiscountDateFormulaText := HelperFunctions.CalculateDiscountDateFormula(GPPaymentTerms);
        Assert.AreEqual(true, IsDateFormulaValid(DiscountDateFormulaText), 'The payment term discount date formula is invalid. ' + DiscountDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>;', DiscountDateFormulaText, 'The payment term discount date formula is incorrect.');

        // [WHEN] Combined with Due Date calculation, the correct combined date formula text will be correct.
        // [THEN] A valid payment term date formula will be generated.

        // Net Days
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days";
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+30D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 1');

        // Date
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Date;
        GPPaymentTerms.DUEDTDS := 30;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+D30>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 2');

        // EOM
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+CM+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 3');

        // None
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::None;
        GPPaymentTerms.CalculateDateFromDays := 2;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+2D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 4');

        // Next Month
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month";
        GPPaymentTerms.DUEDTDS := 16;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>-CM+1M+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 5');

        // Months
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Months;
        GPPaymentTerms.DUEDTDS := 1;
        GPPaymentTerms.CalculateDateFromDays := 0;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1M+0D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 6');

        // Month/Day
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Month/Day";
        GPPaymentTerms.DueMonth := 1;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+M1+D1>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 7');

        // Annual
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::Annual;
        GPPaymentTerms.CalculateDateFromDays := 15;
        GPPaymentTerms.DUEDTDS := 1;
        CombinedDateFormulaText := HelperFunctions.CalculateDueDateFormula(GPPaymentTerms, true, CopyStr(DiscountDateFormulaText, 1, 32));
        Assert.AreEqual(true, IsDateFormulaValid(CombinedDateFormulaText), 'The combined payment term date formula is invalid. ' + CombinedDateFormulaText);
        Assert.AreEqual('<' + ExpectedDiscountDateFormulaMinusBrackets + '>+1Y+15D>', CombinedDateFormulaText, 'The combined payment term date formula is incorrect. 8');
    end;

    local procedure CreateGPPaymentTermsRecords()
    var
        GPPaymentTerms: Record "GP Payment Terms";
    begin
        GPPaymentTerms.DeleteAll();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := '10% NET 10';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month"; // 5
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Days; // 1
        GPPaymentTerms.DISCDTDS := 10;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 1000;
        GPPaymentTerms.TAX := true;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Discount Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := 'NET 10';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days"; // 1
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Days; // 1
        GPPaymentTerms.DISCDTDS := 0;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 0;
        GPPaymentTerms.TAX := false;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Discount Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := 'NET 10TH';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month"; // 5
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Days; // 1
        GPPaymentTerms.DISCDTDS := 0;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 0;
        GPPaymentTerms.TAX := false;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Transaction Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := '2% 10TH - BUG';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Next Month"; // 5
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Date; // 2
        GPPaymentTerms.DISCDTDS := 10;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 200;
        GPPaymentTerms.TAX := true;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Transaction Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := '1.5% 10TH - BUG';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::"Net Days"; // 1
        GPPaymentTerms.DUEDTDS := 0;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::Date; // 2
        GPPaymentTerms.DISCDTDS := 10;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 150;
        GPPaymentTerms.TAX := true;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Discount Date"; // 2
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := '2% EOM';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM; // 3
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::EOM; // 3
        GPPaymentTerms.DISCDTDS := 10;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent; // 1
        GPPaymentTerms.DSCPCTAM := 200;
        GPPaymentTerms.TAX := true;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Transaction Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0; // empty
        GPPaymentTerms.DiscountMonth := 0; // empty
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();

        GPPaymentTerms.Init();
        GPPaymentTerms.PYMTRMID := '5% 10/NET 30';
        GPPaymentTerms.DUETYPE := GPPaymentTerms.DUETYPE::EOM;
        GPPaymentTerms.DUEDTDS := 10;
        GPPaymentTerms.DISCTYPE := GPPaymentTerms.DISCTYPE::EOM;
        GPPaymentTerms.DISCDTDS := 10;
        GPPaymentTerms.DSCLCTYP := GPPaymentTerms.DSCLCTYP::Percent;
        GPPaymentTerms.DSCPCTAM := 200;
        GPPaymentTerms.TAX := true;
        GPPaymentTerms.CBUVATMD := false;
        GPPaymentTerms.USEGRPER := false;
        GPPaymentTerms.CalculateDateFrom := GPPaymentTerms.CalculateDateFrom::"Transaction Date";
        GPPaymentTerms.CalculateDateFromDays := 0;
        GPPaymentTerms.DueMonth := 0;
        GPPaymentTerms.DiscountMonth := 0;
        GPPaymentTerms.PYMTRMID_New := '';
        GPPaymentTerms.Insert();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorBankAccountImport()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        Currency: Record Currency;
        VendorBankAccountCount: Integer;
        ActiveVendorBankAccountCount: Integer;
        BankAccountCounter: Integer;
    begin
        VendorBankAccountCount := 13;
        ActiveVendorBankAccountCount := 12;

        // [SCENARIO] Vendors and their bank account information are queried from GP
        // [GIVEN] GP data
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] Data is imported
        CreateGPVendorBankInformation();
        CreateVendorClassData();

        GPTestHelperFunctions.InitializeMigration();

        // [THEN] The correct number of GPSY06000 are imported
        Assert.AreEqual(VendorBankAccountCount, GPSY06000.Count(), 'Wrong number of GPSY06000 read.');

        // [THEN] The fields for the first record are correctly imported to temporary table
        GPSY06000.SetRange(CustomerVendor_ID, VendorIdWithBankStr1Txt);
        GPSY06000.SetRange(ADRSCODE, AddressCodeRemitToTxt);
        GPSY06000.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr1Txt, GPSY06000.CustomerVendor_ID, 'CustomerVendor_ID of GPSY06000 is wrong.');
        Assert.AreEqual(AddressCodeRemitToTxt, GPSY06000.ADRSCODE, 'ADRSCODE of GPSY06000 is wrong.');
        Assert.AreEqual('V01_RemitTo', GPSY06000.EFTBankCode, 'EFTBankCode of GPSY06000 is wrong.');
        Assert.AreEqual('V01_RemitTo_Name', GPSY06000.BANKNAME, 'BANKNAME of GPSY06000 is wrong.');
        Assert.AreEqual('01234', GPSY06000.EFTBankBranchCode, 'EFTBankBranchCode of GPSY06000 is wrong.');
        Assert.AreEqual('123456789', GPSY06000.EFTBankAcct, 'EFTBankAcct of GPSY06000 is wrong.');
        Assert.AreEqual('123456789', GPSY06000.EFTTransitRoutingNo, 'EFTTransitRoutingNo of GPSY06000 is wrong.');
        Assert.AreEqual(CurrencyCodeUSTxt, GPSY06000.CURNCYID, 'CURNCYID of GPSY06000 is wrong.');
        Assert.AreEqual(ValidIBANStrTxt, GPSY06000.IntlBankAcctNum, 'IntlBankAcctNum of GPSY06000 is wrong.');
        Assert.AreEqual(ValidSwiftCodeStrTxt, GPSY06000.SWIFTADDR, 'SWIFTADDR of GPSY06000 is wrong.');

        // [WHEN] Data is migrated
        Clear(GPVendor);
        GPVendor.SetFilter(VENDORID, '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        MigrateVendors(GPVendor);
        RunPostMigration();

        // [THEN] The currencies will be migrated
        Clear(Currency);
        Currency.SetRange(Code, CurrencyCodeUSTxt);
        Assert.IsFalse(Currency.IsEmpty(), 'Currency was not created.');

        // [THEN] The correct number of Vendor Bank Accounts are imported
        Clear(VendorBankAccount);
        VendorBankAccount.SetFilter("Vendor No.", '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        Assert.AreEqual(ActiveVendorBankAccountCount, VendorBankAccount.Count(), 'Wrong number of migrated Vendor Bank Accounts read');

        // [THEN] The fields for Vendors 1 are correctly applied
        Clear(VendorBankAccount);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr1Txt);
        VendorBankAccount.SetRange("Name", 'V01_RemitTo_Name');
        VendorBankAccount.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr1Txt, VendorBankAccount."Vendor No.", 'Vendor No. of VendorBankAccount is wrong.');
        Assert.IsTrue(StrPos(VendorBankAccount.Code, '-') > 0, 'Vendor Bank Account Code missing dash (-).');
        Assert.AreEqual('V01_RemitTo_Name', VendorBankAccount.Name, 'Name of VendorBankAccount is wrong.');
        Assert.AreEqual('01234', VendorBankAccount."Bank Branch No.", 'Bank Branch No. of VendorBankAccount is wrong.');
        Assert.AreEqual('123456789', VendorBankAccount."Bank Account No.", 'Bank Account No. of VendorBankAccount is wrong.');
        Assert.AreEqual('123456789', VendorBankAccount."Transit No.", 'Transit No. of VendorBankAccount is wrong.');
        Assert.AreEqual(CurrencyCodeUSTxt, VendorBankAccount."Currency Code", 'Currency Code of VendorBankAccount is wrong.');
        Assert.AreEqual(ValidIBANStrTxt, VendorBankAccount.IBAN, 'IBAN of VendorBankAccount is wrong. V01_REMITTO');
        Assert.AreEqual(ValidSwiftCodeStrTxt, VendorBankAccount."SWIFT Code", 'SWIFT Code of VendorBankAccount is wrong.');

        // [WHEN] The Vendor has a Remit To bank account
        Clear(Vendor);
        Vendor.SetRange("No.", VendorIdWithBankStr1Txt);
        Vendor.FindFirst();

        // [THEN] The Remit To bank account will be the Vendor's preferred bank account
        Clear(VendorBankAccount);
        VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
        Assert.AreEqual('V01_RemitTo_Name', VendorBankAccount.Name, 'Preferred Bank Account Code of migrated Vendor should be the Remit To account.');

        // [WHEN] The Vendor does not have a Remit To bank account, but has a Primary bank account
        Clear(Vendor);
        Vendor.SetRange("No.", VendorIdWithBankStr2Txt);
        Vendor.FindFirst();

        // [THEN] The Primary bank account will be the Vendor's preferred bank account
        Clear(VendorBankAccount);
        VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
        Assert.AreEqual('V02_Primary_Name', VendorBankAccount.Name, 'Preferred Bank Account Code of migrated Vendor should be the Primary account.');

        // [WHEN] The Vendor does not have either a Remit To or Primary bank account
        Clear(Vendor);
        Vendor.SetRange("No.", VendorIdWithBankStr3Txt);
        Vendor.FindFirst();

        // [THEN] The Vendor's preferred bank account will be blank
        Assert.AreEqual('', Vendor."Preferred Bank Account Code", 'Preferred Bank Account Code of migrated Vendor should be blank.');

        // [WHEN] The Vendor does not have an active Remit To but has a Primary bank account
        Clear(Vendor);
        Vendor.SetRange("No.", VendorIdWithBankStr4Txt);
        Vendor.FindFirst();

        // [THEN] The Primary bank account will be the Vendor's preferred bank account
        Clear(VendorBankAccount);
        VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
        Assert.AreEqual('V04_Primary_Name', VendorBankAccount.Name, 'Preferred Bank Account Code of migrated Vendor should be the Primary account.');

        // [WHEN] The Vendor Bank Accounts are created
        // [THEN] The IBAN field will get populated only if it passed validation checks

        // Vendor 2, V02_Primary - Invalid IBAN
        Clear(VendorBankAccount);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr2Txt);
        VendorBankAccount.SetRange("Name", 'V02_Primary_Name');
        VendorBankAccount.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr2Txt, VendorBankAccount."Vendor No.", 'Vendor No. of VendorBankAccount is wrong.');
        Assert.IsTrue(StrPos(VendorBankAccount.Code, '-') > 0, 'Vendor Bank Account Code not generated in the correct format.');
        Assert.AreEqual('', VendorBankAccount.IBAN, 'IBAN of VendorBankAccount should be empty because it was invalid. V02_PRIMARY');

        // Vendor 2, V02_Other - Valid IBAN
        Clear(VendorBankAccount);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr2Txt);
        VendorBankAccount.SetRange("Name", 'V02_Other_Name');
        VendorBankAccount.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr2Txt, VendorBankAccount."Vendor No.", 'Vendor No. of VendorBankAccount is wrong.');
        Assert.IsTrue(StrPos(VendorBankAccount.Code, '-') > 0, 'Vendor Bank Account Code not generated in the correct format.');
        Assert.AreEqual(ValidIBANStrTxt, VendorBankAccount.IBAN, 'IBAN of VendorBankAccount is wrong. V02_OTHER');

        // Vendor 3, V03_Other2 - Invalid IBAN
        Clear(VendorBankAccount);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr3Txt);
        VendorBankAccount.SetRange("Name", 'V03_Other2_Name');
        VendorBankAccount.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr3Txt, VendorBankAccount."Vendor No.", 'Vendor No. of VendorBankAccount is wrong.');
        Assert.IsTrue(StrPos(VendorBankAccount.Code, '-') > 0, 'Vendor Bank Account Code not generated in the correct format.');
        Assert.AreEqual('', VendorBankAccount.IBAN, 'IBAN of VendorBankAccount should be empty because it was invalid. V03_OTHER2');

        // Vendor 3, V03_Other - Valid IBAN
        Clear(VendorBankAccount);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr3Txt);
        VendorBankAccount.SetRange("Name", 'V03_Other_Name');
        VendorBankAccount.FindFirst();

        Assert.AreEqual(VendorIdWithBankStr3Txt, VendorBankAccount."Vendor No.", 'Vendor No. of VendorBankAccount is wrong.');
        Assert.IsTrue(StrPos(VendorBankAccount.Code, '-') > 0, 'Vendor Bank Account Code not generated in the correct format.');
        Assert.AreEqual(ValidIBANStrTxt, VendorBankAccount.IBAN, 'IBAN of VendorBankAccount is wrong. V03_OTHER');

        // Vendor 5
        Clear(VendorBankAccount);
        Clear(BankAccountCounter);
        VendorBankAccount.SetCurrentKey("Vendor No.", Code);
        VendorBankAccount.SetRange("Vendor No.", VendorIdWithBankStr5Txt);
        Assert.IsTrue(VendorBankAccount.FindSet(), 'Vendor 5 bank accounts were not created.');

        repeat
            BankAccountCounter := BankAccountCounter + 1;
            Assert.AreEqual(VendorIdWithBankStr5Txt + '-' + Format(BankAccountCounter), VendorBankAccount.Code, 'Bank account code is not correct.');
        until VendorBankAccount.Next() = 0;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorClassesConfiguredToNotImport()
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        // [SCENARIO] Vendors and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, but configured to NOT import Vendor Classes
        CreateVendorData();
        CreateVendorClassData();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        GPVendor.Reset();
        GPVendor.SetFilter("VENDORID", '%1|%2|%3', 'ACME', 'ADEMCO', 'AIRCARG');
        MigrateVendors(GPVendor);
        HelperFunctions.CreatePostMigrationData();

        // [then] Then the Vendor Posting Groups will NOT be migrated
        VendorPostingGroup.SetFilter("Code", '%1|%2|%3', 'USA-US-C', 'USA-US-I', 'USA-US-M');
        Assert.AreEqual(0, VendorPostingGroup.Count(), 'Vendor Posting Groups were created when they should not have been.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorClassesImport()
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        // [SCENARIO] Vendors and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated
        CreateVendorData();
        CreateVendorClassData();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        GPVendor.Reset();
        GPVendor.SetFilter("VENDORID", '%1|%2|%3', 'ACME', 'ADEMCO', 'AIRCARG');
        MigrateVendors(GPVendor);
        HelperFunctions.CreatePostMigrationData();

        // [then] Then the Vendor Posting Groups will be migrated
        VendorPostingGroup.SetFilter("Code", '%1|%2|%3', 'USA-US-C', 'USA-US-I', 'USA-US-M');
        Assert.AreEqual(3, VendorPostingGroup.Count(), 'Vendor Posting Groups were not created.');

        // [then] Then fields for the Vendor Posting Groups will be correct
        VendorPostingGroup.Get('USA-US-C');
        Assert.AreEqual('USA-US-C', VendorPostingGroup.Code, 'Code of VendorPostingGroup is incorrect.');
        Assert.AreEqual('U.S. Vendors-Contract Services', VendorPostingGroup.Description, 'Description of VendorPostingGroup is incorrect.');
        Assert.AreEqual('1', VendorPostingGroup."Payables Account", 'Payables Account of VendorPostingGroup is incorrect.');
        Assert.AreEqual('4', VendorPostingGroup."Service Charge Acc.", 'Service Charge Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('3', VendorPostingGroup."Payment Disc. Debit Acc.", 'Payment Disc. Debit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('2', VendorPostingGroup."Payment Disc. Credit Acc.", 'Payment Disc. Credit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Tolerance Debit Acc.", 'Payment Tolerance Debit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Tolerance Credit Acc.", 'Payment Tolerance Credit Acc. of VendorPostingGroup is incorrect.');

        VendorPostingGroup.Get('USA-US-M');
        Assert.AreEqual('USA-US-M', VendorPostingGroup.Code, 'Code of VendorPostingGroup is incorrect.');
        Assert.AreEqual('U.S. Vendors-Misc. Expenses', VendorPostingGroup.Description, 'Description of VendorPostingGroup is incorrect.');
        Assert.AreEqual('1', VendorPostingGroup."Payables Account", 'Payables Account of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Service Charge Acc.", 'Service Charge Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Disc. Debit Acc.", 'Payment Disc. Debit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Disc. Credit Acc.", 'Payment Disc. Credit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Tolerance Debit Acc.", 'Payment Tolerance Debit Acc. of VendorPostingGroup is incorrect.');
        Assert.AreEqual('', VendorPostingGroup."Payment Tolerance Credit Acc.", 'Payment Tolerance Credit Acc. of VendorPostingGroup is incorrect.');

        Vendor.Get('ACME');

        // [then] The Vendors have the correct Vendor Posting Group set
        Assert.AreEqual('USA-US-C', Vendor."Vendor Posting Group", 'Vendor Posting Group of migrated Vendor should be set.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerClassesConfiguredToNotImport()
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        // [SCENARIO] Customers and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, but configured to NOT import Customer Classes
        CreateCustomerData();
        CreateCustomerClassData();
        GPTestHelperFunctions.CreateConfigurationSettings();

        GPTestHelperFunctions.InitializeMigration();

        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);

        HelperFunctions.CreatePostMigrationData();

        // [then] Then the Customer Posting Groups will NOT be migrated
        CustomerPostingGroup.SetFilter("Code", '%1|%2', 'USA-TEST-1', 'USA-TEST-2');
        Assert.RecordCount(CustomerPostingGroup, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerClassesImport()
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        // [SCENARIO] Customers and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported, and data is migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        GPCompanyAdditionalSettings.Modify();

        CreateCustomerData();
        CreateCustomerClassData();
        CreateCustomerTrx();

        GPTestHelperFunctions.InitializeMigration();

        GPCustomer.Reset();
        MigrateCustomers(GPCustomer);
        HelperFunctions.CreatePostMigrationData();

        // [then] Then the Customer Posting Groups will be migrated
        CustomerPostingGroup.SetFilter("Code", '%1|%2', 'USA-TEST-1', 'USA-TEST-2');
        Assert.AreEqual(2, CustomerPostingGroup.Count(), 'Customer Posting Groups were not created.');

        // [then] Then fields for the first Customer Posting Groups will be correct
        CustomerPostingGroup.Get('USA-TEST-1');
        Assert.AreEqual('USA-TEST-1', CustomerPostingGroup.Code, 'Code of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('Test cust class 1', CustomerPostingGroup.Description, 'Description of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('1', CustomerPostingGroup."Receivables Account", 'Receivables Account of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('2', CustomerPostingGroup."Payment Disc. Debit Acc.", 'Payment Disc. Debit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('1', CustomerPostingGroup."Additional Fee Account", 'Additional Fee Account of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('2', CustomerPostingGroup."Payment Disc. Credit Acc.", 'Payment Disc. Credit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Tolerance Debit Acc.", 'Payment Tolerance Debit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Tolerance Credit Acc.", 'Payment Tolerance Credit Acc. of CustomerPostingGroup is incorrect.');

        CustomerPostingGroup.Get('USA-TEST-2');
        Assert.AreEqual('USA-TEST-2', CustomerPostingGroup.Code, 'Code of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('Test cust class 2', CustomerPostingGroup.Description, 'Description of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('100', CustomerPostingGroup."Receivables Account", 'Receivables Account of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Disc. Debit Acc.", 'Payment Disc. Debit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Additional Fee Account", 'Additional Fee Account of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Disc. Credit Acc.", 'Payment Disc. Credit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Tolerance Debit Acc.", 'Payment Tolerance Debit Acc. of CustomerPostingGroup is incorrect.');
        Assert.AreEqual('', CustomerPostingGroup."Payment Tolerance Credit Acc.", 'Payment Tolerance Credit Acc. of CustomerPostingGroup is incorrect.');

        // [then] The correct Customer Posting Groups are set
        Customer.Get('!WOW!');
        Assert.AreEqual('TEST', Customer."Customer Posting Group", 'Customer Posting Group of migrated Customer should not be set.');

        Customer.Get('"AMERICAN"');
        Assert.AreEqual('USA-TEST-1', Customer."Customer Posting Group", 'Customer Posting Group of migrated Customer should be set.');

        Customer.Get('#1');
        Assert.AreEqual('USA-TEST-2', Customer."Customer Posting Group", 'Customer Posting Group of migrated Customer should be set.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestOpenPOSettingDisabled()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [SCENARIO] Vendors and their PO information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, but configured to NOT import open POs
        CreateVendorData();
        CreateVendorClassData();
        CreateOpenPOData();
        GPTestHelperFunctions.CreateConfigurationSettings();

        // Disable Migrate Open POs setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Open POs", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        GPVendor.Reset();
        MigrateVendors(GPVendor);
        HelperFunctions.CreatePostMigrationData();

        // [then] Then the POs will NOT be migrated
        PurchaseHeader.SetRange("No.", PONumberTxt);
        Assert.IsTrue(PurchaseHeader.IsEmpty(), 'POs should not have been created.');
    end;

    [Test]
    procedure TestPhoneFaxContainsAlphaCharsCheck()
    begin
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('2985550101000x'), 'Phone/Fax number does have an alpha character.');
        Assert.IsFalse(HelperFunctions.ContainsAlphaChars('29855501010000'), 'Phone/Fax number does not have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('a'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('b'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('c'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('x'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('y'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('z'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('A'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('B'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('C'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('X'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('Y'), 'Phone/Fax number does have an alpha character.');
        Assert.IsTrue(HelperFunctions.ContainsAlphaChars('Z'), 'Phone/Fax number does have an alpha character.');
    end;

    [Normal]
    local procedure Initialize()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        GPConfiguration: Record "GP Configuration";
        GPPostingAccounts: Record "GP Posting Accounts";
        PurchaseHeader: Record "Purchase Header";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        if not BindSubscription(GPDataMigrationTests) then
            exit;

        DataMigrationEntity.DeleteAll();
        PurchaseHeader.DeleteAll();
        GPConfiguration.DeleteAll();
        GPTestHelperFunctions.DeleteAllSettings();
        GPCustomer.DeleteAll();
        GPCustomerAddress.DeleteAll();
        GPVendorAddress.DeleteAll();
        GPVendor.DeleteAll();
        GPPM00100.DeleteAll();
        GPPM00200.DeleteAll();
        GPRM00101.DeleteAll();
        GPRM00201.DeleteAll();
        GPPOP10100.DeleteAll();
        GPPOP10110.DeleteAll();
        GPSY01200.DeleteAll();

        if not GenBusPostingGroup.Get(PostingGroupCodeTxt) then begin
            GenBusPostingGroup.Validate("Code", PostingGroupCodeTxt);
            GenBusPostingGroup.Insert(true);
        end;

        if not VendorPostingGroup.Get(PostingGroupCodeTxt) then begin
            VendorPostingGroup.Validate("Code", PostingGroupCodeTxt);
            VendorPostingGroup.Insert(true);
        end;

        if not GPPostingAccounts.Get() then begin
            GPPostingAccounts.PayablesAccount := '1';
            GPPostingAccounts.ReceivablesAccount := '100';
            GPPostingAccounts.Insert();
        end;

        if not GenProductPostingGroup.Get(PostingGroupCodeTxt) then begin
            GenProductPostingGroup.Code := PostingGroupCodeTxt;
            GenProductPostingGroup.Insert();
        end;

        if not InventoryPostingGroup.Get(PostingGroupCodeTxt) then begin
            InventoryPostingGroup.Code := PostingGroupCodeTxt;
            InventoryPostingGroup.Insert();
        end;

        if UnbindSubscription(GPDataMigrationTests) then
            exit;
    end;

    local procedure MigrateCustomers(var GPCustomers: Record "GP Customer")
    begin
        if not GPTestHelperFunctions.MigrationConfiguredForTable(Database::Customer) then
            exit;

        if GPCustomers.FindSet() then
            repeat
                CustomerMigrator.OnMigrateCustomer(CustomerFacade, GPCustomers.RecordId());
                CustomerMigrator.OnMigrateCustomerPostingGroups(CustomerFacade, GPCustomers.RecordId(), true);
                CustomerMigrator.OnMigrateCustomerTransactions(CustomerFacade, GPCustomers.RecordId(), true);
            until GPCustomers.Next() = 0;
    end;

    local procedure MigrateVendors(var GPVendors: Record "GP Vendor")
    begin
        if not GPTestHelperFunctions.MigrationConfiguredForTable(Database::Vendor) then
            exit;

        if GPVendors.FindSet() then
            repeat
                VendorMigrator.OnMigrateVendor(VendorFacade, GPVendors.RecordId());
                VendorMigrator.OnMigrateVendorPostingGroups(VendorFacade, GPVendors.RecordId(), true);
                VendorMigrator.OnMigrateVendorTransactions(VendorFacade, GPVendors.RecordId(), true);
            until GPVendors.Next() = 0;
    end;

    local procedure RunPostMigration()
    begin
        HelperFunctions.CreatePostMigrationData();
    end;

    local procedure CreateCustomerData()
    begin
        Clear(GPRM00101);
        GPRM00101.CUSTNMBR := '!WOW!';
        GPRM00101.CUSTNAME := 'Oh! What a feeling!';
        GPRM00101.ADRSCODE := '';
        GPRM00101.Insert();

        Clear(GPCustomer);
        GPCustomer.CUSTNMBR := GPRM00101.CUSTNMBR;
        GPCustomer.CUSTNAME := GPRM00101.CUSTNAME;
        GPCustomer.STMTNAME := GPRM00101.CUSTNAME;
        GPCustomer.ADDRESS1 := '';
        GPCustomer.ADDRESS2 := 'Toyota Land';
        GPCustomer.CITY := '!What a city!';
        GPCustomer.CNTCPRSN := 'Todd Scott';
        GPCustomer.PHONE1 := '00000000000000';
        GPCustomer.SALSTERR := 'MIDWEST';
        GPCustomer.CRLMTAMT := 1000.00000;
        GPCustomer.PYMTRMID := '2% EOM/Net 15th';
        GPCustomer.SLPRSNID := 'KNOBL-CHUCK-001';
        GPCustomer.SHIPMTHD := 'MAIL';
        GPCustomer.COUNTRY := 'USA';
        GPCustomer.AMOUNT := 3970.61000;
        GPCustomer.STMTCYCL := true;
        GPCustomer.FAX := '00000000000000';
        GPCustomer.ZIPCODE := '84953';
        GPCustomer.STATE := 'OH';
        GPCustomer.INET1 := '';
        GPCustomer.INET2 := '';
        GPCustomer.TAXSCHID := 'S-N-NO-%S';
        GPCustomer.UPSZONE := 'O4';
        GPCustomer.TAXEXMT1 := '';
        GPCustomer.Insert();

        Clear(GPRM00101);
        GPRM00101.CUSTNMBR := '"AMERICAN"';
        GPRM00101.CUSTNAME := '"American Clothing"';
        GPRM00101.ADRSCODE := '';
        GPRM00101.Insert();

        Clear(GPCustomer);
        GPCustomer.CUSTNMBR := GPRM00101.CUSTNMBR;
        GPCustomer.CUSTNAME := GPRM00101.CUSTNAME;
        GPCustomer.STMTNAME := GPRM00101.CUSTNAME;
        GPCustomer.ADDRESS1 := '';
        GPCustomer.ADDRESS2 := '';
        GPCustomer.CITY := '"CITY"';
        GPCustomer.CNTCPRSN := 'Fuad Reveiz';
        GPCustomer.PHONE1 := '31847240170000';
        GPCustomer.SALSTERR := 'SOUTHERN';
        GPCustomer.CRLMTAMT := 500.00000;
        GPCustomer.PYMTRMID := '2.5% EOM/EOM';
        GPCustomer.SLPRSNID := 'CORWIN''S';
        GPCustomer.SHIPMTHD := 'UPS BLUE';
        GPCustomer.COUNTRY := 'USA';
        GPCustomer.AMOUNT := 0.00000;
        GPCustomer.STMTCYCL := true;
        GPCustomer.FAX := '31847240200000';
        GPCustomer.ZIPCODE := '14563';
        GPCustomer.STATE := 'LA';
        GPCustomer.INET1 := '';
        GPCustomer.INET2 := '';
        GPCustomer.TAXSCHID := 'S-N-NO-%AD-%S';
        GPCustomer.UPSZONE := 'T3';
        GPCustomer.TAXEXMT1 := '';
        GPCustomer.Insert();

        Clear(GPRM00101);
        GPRM00101.CUSTNMBR := '#1';
        GPRM00101.CUSTNAME := '#1 Company';
        GPRM00101.ADRSCODE := 'PRIMARY';
        GPRM00101.Insert();

        Clear(GPCustomer);
        GPCustomer.CUSTNMBR := GPRM00101.CUSTNMBR;
        GPCustomer.CUSTNAME := GPRM00101.CUSTNAME;
        GPCustomer.STMTNAME := GPRM00101.CUSTNAME;
        GPCustomer.ADDRESS1 := 'GPS Alley';
        GPCustomer.ADDRESS2 := '';
        GPCustomer.CITY := '#1 City';
        GPCustomer.CNTCPRSN := 'Ray Berry';
        GPCustomer.PHONE1 := '91533340120000';
        GPCustomer.SALSTERR := 'SOUTHERN';
        GPCustomer.CRLMTAMT := 500.00000;
        GPCustomer.PYMTRMID := '2.5% EOM/EOM';
        GPCustomer.SLPRSNID := 'CORWIN''S';
        GPCustomer.SHIPMTHD := 'UPS BLUE';
        GPCustomer.COUNTRY := 'USA';
        GPCustomer.AMOUNT := 508.06000;
        GPCustomer.STMTCYCL := true;
        GPCustomer.FAX := '91533340200000';
        GPCustomer.ZIPCODE := '58103-3342';
        GPCustomer.STATE := 'TX';
        GPCustomer.INET1 := '';
        GPCustomer.INET2 := '';
        GPCustomer.TAXSCHID := 'S-T-NO-%AD%S';
        GPCustomer.UPSZONE := 'P3';
        GPCustomer.TAXEXMT1 := '';
        GPCustomer.Insert();

        Clear(GPCustomerAddress);
        GPCustomerAddress.CUSTNMBR := CopyStr(GPCustomer.CUSTNMBR, 1, MaxStrLen(GPCustomerAddress.CUSTNMBR));
        GPCustomerAddress.ADRSCODE := 'PRIMARY';
        GPCustomerAddress.ADDRESS1 := GPCustomer.ADDRESS1;
        GPCustomerAddress.CITY := GPCustomer.CITY;
        GPCustomerAddress.CNTCPRSN := 'Test user';
        GPCustomerAddress.SHIPMTHD := 'GROUND';
        GPCustomerAddress.STATE := GPCustomer.STATE;
        GPCustomerAddress.ZIP := GPCustomer.ZIPCODE;
        GPCustomerAddress.TAXSCHID := GPCustomer.TAXSCHID;
        GPCustomerAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'CUS';
        GPSY01200.Master_ID := GPCustomerAddress.CUSTNMBR;
        GPSY01200.ADRSCODE := GPCustomerAddress.ADRSCODE;
        GPSY01200.EmailToAddress := 'GoodEmailAddress@testing.tst';
        GPSY01200.INET1 := 'support@testing.tst';
        GPSY01200.Insert();

        Clear(GPCustomerAddress);
        GPCustomerAddress.CUSTNMBR := CopyStr(GPCustomer.CUSTNMBR, 1, MaxStrLen(GPCustomerAddress.CUSTNMBR));
        GPCustomerAddress.ADRSCODE := 'BILLING';
        GPCustomerAddress.ADDRESS1 := GPCustomer.ADDRESS1;
        GPCustomerAddress.CITY := GPCustomer.CITY;
        GPCustomerAddress.CNTCPRSN := 'Test user';
        GPCustomerAddress.SHIPMTHD := 'GROUND';
        GPCustomerAddress.STATE := GPCustomer.STATE;
        GPCustomerAddress.ZIP := GPCustomer.ZIPCODE;
        GPCustomerAddress.TAXSCHID := GPCustomer.TAXSCHID;
        GPCustomerAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'CUS';
        GPSY01200.Master_ID := GPCustomerAddress.CUSTNMBR;
        GPSY01200.ADRSCODE := GPCustomerAddress.ADRSCODE;
        GPSY01200.INET1 := 'AP@testing.tst';
        GPSY01200.EmailToAddress := 'GoodEmailAddress2@testing.tst';
        GPSY01200.Insert();

        Clear(GPCustomerAddress);
        GPCustomerAddress.CUSTNMBR := CopyStr(GPCustomer.CUSTNMBR, 1, MaxStrLen(GPCustomerAddress.CUSTNMBR));
        GPCustomerAddress.ADRSCODE := 'WAREHOUSE';
        GPCustomerAddress.ADDRESS1 := GPCustomer.ADDRESS1;
        GPCustomerAddress.CITY := GPCustomer.CITY;
        GPCustomerAddress.CNTCPRSN := 'Test user';
        GPCustomerAddress.SHIPMTHD := 'GROUND';
        GPCustomerAddress.STATE := GPCustomer.STATE;
        GPCustomerAddress.ZIP := GPCustomer.ZIPCODE;
        GPCustomerAddress.TAXSCHID := GPCustomer.TAXSCHID;
        GPCustomerAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'CUS';
        GPSY01200.Master_ID := GPCustomerAddress.CUSTNMBR;
        GPSY01200.ADRSCODE := GPCustomerAddress.ADRSCODE;
        GPSY01200.INET1 := '@testing.tst';
        GPSY01200.Insert();

        Clear(GPCustomerAddress);
        GPCustomerAddress.CUSTNMBR := CopyStr(GPCustomer.CUSTNMBR, 1, MaxStrLen(GPCustomerAddress.CUSTNMBR));
        GPCustomerAddress.ADRSCODE := 'OTHER';
        GPCustomerAddress.ADDRESS1 := GPCustomer.ADDRESS1;
        GPCustomerAddress.CITY := GPCustomer.CITY;
        GPCustomerAddress.CNTCPRSN := 'Test user';
        GPCustomerAddress.SHIPMTHD := 'GROUND';
        GPCustomerAddress.STATE := GPCustomer.STATE;
        GPCustomerAddress.ZIP := GPCustomer.ZIPCODE;
        GPCustomerAddress.TAXSCHID := GPCustomer.TAXSCHID;
        GPCustomerAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'CUS';
        GPSY01200.Master_ID := GPCustomerAddress.CUSTNMBR;
        GPSY01200.ADRSCODE := GPCustomerAddress.ADRSCODE;
        GPSY01200.INET1 := '';
        GPSY01200.Insert();
    end;

    local procedure CreateCustomerTrx()
    var
        GPCustomerTransactions: Record "GP Customer Transactions";
    begin
        Clear(GPCustomerTransactions);
        GPCustomerTransactions.Id := '1';
        GPCustomerTransactions.CUSTNMBR := '#1';
        GPCustomerTransactions.DOCNUMBR := '1';
        GPCustomerTransactions.GLDocNo := '1';
        GPCustomerTransactions.DOCDATE := DMY2Date(11, 8, 2022);
        GPCustomerTransactions.CURTRXAM := 1;
        GPCustomerTransactions.TransType := GPCustomerTransactions.TransType::Invoice;
        GPCustomerTransactions.PYMTRMID := '2.5% EOM/EOM';
        GPCustomerTransactions.Insert();

        Clear(GPCustomerTransactions);
        GPCustomerTransactions.Id := '2';
        GPCustomerTransactions.CUSTNMBR := '!WOW!';
        GPCustomerTransactions.DOCNUMBR := '2';
        GPCustomerTransactions.GLDocNo := '2';
        GPCustomerTransactions.DOCDATE := DMY2Date(11, 8, 2022);
        GPCustomerTransactions.CURTRXAM := 2;
        GPCustomerTransactions.TransType := GPCustomerTransactions.TransType::Invoice;
        GPCustomerTransactions.PYMTRMID := '2.5% EOM/EOM';
        GPCustomerTransactions.Insert();
    end;

    local procedure CreateCustomerClassData()
    var
        GLAccount: Record "G/L Account";
        GPAccount: Record "GP Account";
    begin
        if not GPAccount.Get('1') then begin
            GPAccount.AcctNum := '1';
            GPAccount.AcctIndex := 1;
            GPAccount.Name := 'Test account 1';
            GPAccount.Active := true;
            GPAccount.Insert();
        end;

        if not GLAccount.Get(GPAccount.AcctNum) then begin
            GLAccount.Validate("No.", GPAccount.AcctNum);
            GLAccount.Validate(Name, GPAccount.Name);
            GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
            GLAccount.Insert();
        end;

        if not GPAccount.Get('2') then begin
            GPAccount.AcctNum := '2';
            GPAccount.AcctIndex := 2;
            GPAccount.Name := 'Test account 2';
            GPAccount.Active := true;
            GPAccount.Insert();
        end;

        if not GLAccount.Get(GPAccount.AcctNum) then begin
            GLAccount.Validate("No.", GPAccount.AcctNum);
            GLAccount.Validate(Name, GPAccount.Name);
            GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
            GLAccount.Insert();
        end;

        if not GPAccount.Get('100') then begin
            GPAccount.AcctNum := '100';
            GPAccount.AcctIndex := 100;
            GPAccount.Name := 'Test account 100';
            GPAccount.Active := true;
            GPAccount.Insert();
        end;

        if not GLAccount.Get(GPAccount.AcctNum) then begin
            GLAccount.Validate("No.", GPAccount.AcctNum);
            GLAccount.Validate(Name, GPAccount.Name);
            GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
            GLAccount.Insert();
        end;

        GPRM00201.Init();
        GPRM00201.CLASSID := 'USA-TEST-1';
        GPRM00201.CLASDSCR := 'Test cust class 1';
        GPRM00201.RMARACC := 1;
        GPRM00201.RMTAKACC := 2;
        GPRM00201.RMFCGACC := 1;
        GPRM00201.RMAVACC := 2;
        GPRM00201.RMWRACC := 0;
        GPRM00201.Insert();

        GPRM00201.Init();
        GPRM00201.CLASSID := 'USA-TEST-2';
        GPRM00201.CLASDSCR := 'Test cust class 2';
        GPRM00201.RMARACC := 0;
        GPRM00201.RMTAKACC := 0;
        GPRM00201.RMFCGACC := 0;
        GPRM00201.RMAVACC := 0;
        GPRM00201.RMWRACC := 0;
        GPRM00201.Insert();

        GPRM00101.Get('!WOW!');
        GPRM00101.CUSTCLAS := 'TEST';
        GPRM00101.Modify();

        GPRM00101.Get('"AMERICAN"');
        GPRM00101.CUSTCLAS := 'USA-TEST-1';
        GPRM00101.Modify();

        GPRM00101.Get('#1');
        GPRM00101.CUSTCLAS := 'USA-TEST-2';
        GPRM00101.Modify();

        GPAccount.Init();
        GPAccount.AcctNum := 'TEST987';
        GPAccount.AcctIndex := 1000;
        GPAccount.Name := 'Accounts Receivable';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        Clear(GPRM00201);
        GPRM00201.CLASSID := 'TEST';
        GPRM00201.RMARACC := 1000;
        GPRM00201.Insert();
    end;

    local procedure CreateVendorData()
    begin
        Clear(GPVendor);
        GPVendor.VENDORID := '%#$!<>';
        GPVendor.VENDNAME := 'Light';
        GPVendor.SEARCHNAME := 'Light';
        GPVendor.VNDCHKNM := 'Light';
        GPVendor.ADDRESS1 := '323 Walnut Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Lebanon';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '01321112300000';
        GPVendor.PYMTRMID := '';
        GPVendor.SHIPMTHD := '';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '01321112500000';
        GPVendor.ZIPCODE := '17042';
        GPVendor.STATE := 'PA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-T&T-COMBO';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPPM00200.VENDORID));
        GPPM00200.VENDSTTS := 3;
        GPPM00200.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '&2010';
        GPVendor.VENDNAME := 'American Airlines Cargo';
        GPVendor.SEARCHNAME := 'American Airlines Cargo';
        GPVendor.VNDCHKNM := 'American Airlines Cargo';
        GPVendor.ADDRESS1 := 'Caller 28510';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Columbus';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '20623290140000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 50.84000;
        GPVendor.FAXNUMBR := '20623290200000';
        GPVendor.ZIPCODE := '432280510';
        GPVendor.STATE := 'OHIO';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*0';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '(=)';
        GPVendor.VENDNAME := 'L.B. Foster Company';
        GPVendor.SEARCHNAME := 'L.B. Foster Company';
        GPVendor.VNDCHKNM := 'L.B. Foster Company';
        GPVendor.ADDRESS1 := 'P.O. Box 1009878';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Atlanta';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '70128053320000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -5.26000;
        GPVendor.FAXNUMBR := '70128053330000';
        GPVendor.ZIPCODE := '303840987';
        GPVendor.STATE := 'GA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*1';
        GPVendor.UPSZONE := 'J5';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '10(61)';
        GPVendor.VENDNAME := 'ACS Hydrolics';
        GPVendor.SEARCHNAME := 'ACS Hydrolics';
        GPVendor.VNDCHKNM := 'ACS Hydrolics';
        GPVendor.ADDRESS1 := '1101 Stanley Dr.';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Euliss';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '40444472350000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 57.00000;
        GPVendor.FAXNUMBR := '40444472400000';
        GPVendor.ZIPCODE := '76040';
        GPVendor.STATE := 'SD';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*2';
        GPVendor.UPSZONE := 'M3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '100000';
        GPVendor.VENDNAME := 'Alexander & Alexander';
        GPVendor.SEARCHNAME := 'Alexander & Alexander';
        GPVendor.VNDCHKNM := 'Alexander & Alexander';
        GPVendor.ADDRESS1 := 'Lock Box Number 960434';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Chicago';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '21863614590000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '60694';
        GPVendor.STATE := 'IL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-A/U*0';
        GPVendor.UPSZONE := 'K3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1021';
        GPVendor.VENDNAME := 'Swieco';
        GPVendor.SEARCHNAME := 'Swieco';
        GPVendor.VNDCHKNM := 'Swieco';
        GPVendor.ADDRESS1 := '1315 Broodside Drive';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Hust';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '80548423131034';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 229.19000;
        GPVendor.FAXNUMBR := '80548423200000';
        GPVendor.ZIPCODE := '76053';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-A/U*1';
        GPVendor.UPSZONE := 'C6';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1090';
        GPVendor.VENDNAME := 'Adleta Company, Inc.';
        GPVendor.SEARCHNAME := 'Adleta Company, Inc.';
        GPVendor.VNDCHKNM := 'Adleta Company, Inc.';
        GPVendor.ADDRESS1 := '1645 Diplomat';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Carrolltom';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '80453510110000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '80453510200000';
        GPVendor.ZIPCODE := '56502';
        GPVendor.STATE := 'MN';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%AD%PT';
        GPVendor.UPSZONE := 'U2';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '110ADV';
        GPVendor.VENDNAME := 'Lighting Technologies';
        GPVendor.SEARCHNAME := 'Lighting Technologies';
        GPVendor.VNDCHKNM := 'Lighting Technologies';
        GPVendor.ADDRESS1 := '11105 Shady Trail';
        GPVendor.ADDRESS2 := '#109';
        GPVendor.CITY := 'New York';
        GPVendor.VNDCNTCT := 'John Rock';
        GPVendor.PHNUMBR1 := '30229207380000';
        GPVendor.PYMTRMID := '';
        GPVendor.SHIPMTHD := '';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 1272.88000;
        GPVendor.FAXNUMBR := '30229207400000';
        GPVendor.ZIPCODE := '596878686';
        GPVendor.STATE := 'NY';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%AD%P';
        GPVendor.UPSZONE := 'Y3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1122';
        GPVendor.VENDNAME := 'Airborne Express';
        GPVendor.SEARCHNAME := 'Airborne Express';
        GPVendor.VNDCHKNM := 'Airborne Express';
        GPVendor.ADDRESS1 := 'Route 55322';
        GPVendor.ADDRESS2 := 'Box 9101';
        GPVendor.CITY := 'Seattle';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '91364280140000';
        GPVendor.PYMTRMID := '2% 10/Net 30';
        GPVendor.SHIPMTHD := 'EXPRESS MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 198126.82000;
        GPVendor.FAXNUMBR := '91364280200000';
        GPVendor.ZIPCODE := '98111';
        GPVendor.STATE := 'WA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%ADTIP';
        GPVendor.UPSZONE := 'Q3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1123';
        GPVendor.VENDNAME := 'Electric & Air Tool Company';
        GPVendor.SEARCHNAME := 'Electric & Air Tool Company';
        GPVendor.VNDCHKNM := 'Electric & Air Tool Company';
        GPVendor.ADDRESS1 := '3301 South Grove';
        GPVendor.ADDRESS2 := 'Suite 10';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := 'Purchasing';
        GPVendor.PHNUMBR1 := '40221281390000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 782.74000;
        GPVendor.FAXNUMBR := '40221281500000';
        GPVendor.ZIPCODE := '76110';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P%PT';
        GPVendor.UPSZONE := 'R7';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1140';
        GPVendor.VENDNAME := 'Air, Power Tool & Hoist Inc.';
        GPVendor.SEARCHNAME := 'Air, Power Tool & Hoist Inc.';
        GPVendor.VNDCHKNM := 'Air, Power Tool & Hoist Inc.';
        GPVendor.ADDRESS1 := 'P.O. Box 650037';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '51380271430000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 1225.70000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '752650037';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*3';
        GPVendor.UPSZONE := 'O5';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '11460';
        GPVendor.VENDNAME := 'Bowen Supply, Inc.';
        GPVendor.SEARCHNAME := 'Bowen Supply, Inc.';
        GPVendor.VNDCHKNM := 'Bowen Supply, Inc.';
        GPVendor.ADDRESS1 := 'P.O. Box 1008';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Americus';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '91533340120000';
        GPVendor.PYMTRMID := '';
        GPVendor.SHIPMTHD := '';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '91533340200000';
        GPVendor.ZIPCODE := '31790';
        GPVendor.STATE := 'GA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*5';
        GPVendor.UPSZONE := 'P3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '1160';
        GPVendor.VENDNAME := 'Risco, Inc.';
        GPVendor.SEARCHNAME := 'Risco, Inc.';
        GPVendor.VNDCHKNM := 'Risco, Inc.';
        GPVendor.ADDRESS1 := '2344 Brookings St';
        GPVendor.ADDRESS2 := 'Suite 234';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := 'Roger';
        GPVendor.PHNUMBR1 := '50482743320000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 12.18000;
        GPVendor.FAXNUMBR := '50482743400000';
        GPVendor.ZIPCODE := '76511';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*6';
        GPVendor.UPSZONE := 'T3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '11@20%';
        GPVendor.VENDNAME := 'Shield Plastic Co.';
        GPVendor.SEARCHNAME := 'Shield Plastic Co.';
        GPVendor.VNDCHKNM := 'Shield Plastic Co.';
        GPVendor.ADDRESS1 := 'P.O. Box 15272';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '30255510100000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '30255510110000';
        GPVendor.ZIPCODE := '76119';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*7';
        GPVendor.UPSZONE := 'Y3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3009';
        GPVendor.VENDNAME := 'Jorgensen Stell and Aluminum';
        GPVendor.SEARCHNAME := 'Jorgensen Stell and Aluminum';
        GPVendor.VNDCHKNM := 'Jorgensen Stell and Aluminum';
        GPVendor.ADDRESS1 := '34 Winnipeg';
        GPVendor.ADDRESS2 := 'Suite 45';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '60238571730000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '30238571800000';
        GPVendor.ZIPCODE := '752840718';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*8';
        GPVendor.UPSZONE := 'Z4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3025';
        GPVendor.VENDNAME := 'Kilsby-Roberts';
        GPVendor.SEARCHNAME := 'Kilsby-Roberts';
        GPVendor.VNDCHKNM := 'Kilsby-Roberts';
        GPVendor.ADDRESS1 := 'Box 5747';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Arlington';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '50527210000000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 25.94000;
        GPVendor.FAXNUMBR := '50527210100000';
        GPVendor.ZIPCODE := '76011';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*9';
        GPVendor.UPSZONE := 'W4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3030';
        GPVendor.VENDNAME := 'Kaltenback Inc.';
        GPVendor.SEARCHNAME := 'Kaltenback Inc.';
        GPVendor.VNDCHKNM := 'Kaltenback Inc.';
        GPVendor.ADDRESS1 := 'Department #1120';
        GPVendor.ADDRESS2 := 'P.O. Box 650290';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '70148457190000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '70148457200000';
        GPVendor.ZIPCODE := '752650290';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%PA/U';
        GPVendor.UPSZONE := 'J5';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3070';
        GPVendor.VENDNAME := 'L.M. Berry & co. -NYPS';
        GPVendor.SEARCHNAME := 'L.M. Berry & co. -NYPS';
        GPVendor.VNDCHKNM := 'L.M. Berry & co.';
        GPVendor.ADDRESS1 := 'Box 90255';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Chicago';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '70143651130000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -34.70000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '505930011';
        GPVendor.STATE := 'IL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%PTIP';
        GPVendor.UPSZONE := 'J6';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3080';
        GPVendor.VENDNAME := 'Lake Shore Electric';
        GPVendor.SEARCHNAME := 'Lake Shore Electric';
        GPVendor.VNDCHKNM := 'Lake Shore Electric';
        GPVendor.ADDRESS1 := '205 Willis Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Bedford';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '41866634922300';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '41866634950000';
        GPVendor.ZIPCODE := '44146';
        GPVendor.STATE := 'OH';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-T&T-%PA/U*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3090';
        GPVendor.VENDNAME := 'Lane McDuff Company Inc.';
        GPVendor.SEARCHNAME := 'Lane McDuff Company Inc.';
        GPVendor.VNDCHKNM := 'Lane McDuff Company Inc.';
        GPVendor.ADDRESS1 := 'P.O. Box 14311';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := 'Lane McDuff';
        GPVendor.PHNUMBR1 := '41853657220000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '41853657300000';
        GPVendor.ZIPCODE := '76117';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TAX-%ADTIP';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3102';
        GPVendor.VENDNAME := 'Franklin Elextric Services';
        GPVendor.SEARCHNAME := 'Franklin Elextric Services';
        GPVendor.VNDCHKNM := 'Franklin Elextric Services';
        GPVendor.ADDRESS1 := '';
        GPVendor.ADDRESS2 := '225 East Third Street';
        GPVendor.CITY := 'Bowling Green';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '40342418880000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '421011250';
        GPVendor.STATE := 'KY';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TAX%PT%P*0';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3102-0';
        GPVendor.VENDNAME := 'Lay Machinery Company, Inc.';
        GPVendor.SEARCHNAME := 'Lay Machinery Company, Inc.';
        GPVendor.VNDCHKNM := 'Lay Machinery Company, Inc.';
        GPVendor.ADDRESS1 := '';
        GPVendor.ADDRESS2 := '13633 OMEGA';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '40372351300000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '40372351350000';
        GPVendor.ZIPCODE := '75224';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TAX-%PT%P*1';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '3160';
        GPVendor.VENDNAME := 'Quist Paper Company';
        GPVendor.SEARCHNAME := 'Quist Paper Company';
        GPVendor.VNDCHKNM := 'Quist Paper Company';
        GPVendor.ADDRESS1 := '3216 S. Nordic Road';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Arlington Heights';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '60347123781310';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -55.90000;
        GPVendor.FAXNUMBR := '60347123790000';
        GPVendor.ZIPCODE := '735323093';
        GPVendor.STATE := 'IL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TAX-%PTTIP';
        GPVendor.UPSZONE := 'G3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '55544';
        GPVendor.VENDNAME := 'Longhorn Gasket & Supply Co.';
        GPVendor.SEARCHNAME := 'Longhorn Gasket & Supply Co.';
        GPVendor.VNDCHKNM := 'Longhorn Gasket & Supply Co.';
        GPVendor.ADDRESS1 := 'Box 763039';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '41328170140000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -631.98000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '752660062';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%AD%P';
        GPVendor.UPSZONE := 'D2';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '6544';
        GPVendor.VENDNAME := 'John Roberts';
        GPVendor.SEARCHNAME := 'John Roberts';
        GPVendor.VNDCHKNM := 'John Roberts';
        GPVendor.ADDRESS1 := '1104 East Dallas Road';
        GPVendor.ADDRESS2 := 'Suite 100';
        GPVendor.CITY := 'Grapevine';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '21847408170000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '21847408200000';
        GPVendor.ZIPCODE := '76051';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P**';
        GPVendor.UPSZONE := 'K4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '9999';
        GPVendor.VENDNAME := 'Lighting Technologies';
        GPVendor.SEARCHNAME := 'Lighting Technologies';
        GPVendor.VNDCHKNM := 'Lighting Technologies';
        GPVendor.ADDRESS1 := '122 Leesley Lane';
        GPVendor.ADDRESS2 := 'Box 2';
        GPVendor.CITY := 'Argyle';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '91970362930000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -32.30000;
        GPVendor.FAXNUMBR := '91970362950000';
        GPVendor.ZIPCODE := '76226';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PA/U*0';
        GPVendor.UPSZONE := 'X7';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := ':V6544';
        GPVendor.VENDNAME := 'Sarah Roberts';
        GPVendor.SEARCHNAME := 'Sarah Roberts';
        GPVendor.VNDCHKNM := 'Sarah Roberts';
        GPVendor.ADDRESS1 := 'P.O. Box 300';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Hopewell';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '21863653270000';
        GPVendor.PYMTRMID := '';
        GPVendor.SHIPMTHD := '';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '21863653300000';
        GPVendor.ZIPCODE := '85257';
        GPVendor.STATE := 'NJ';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*0';
        GPVendor.UPSZONE := 'K3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := '?11 40';
        GPVendor.VENDNAME := 'Friplex Tire & Appliance';
        GPVendor.SEARCHNAME := 'Friplex Tire & Appliance';
        GPVendor.VNDCHKNM := 'Friplex Tire & Appliance';
        GPVendor.ADDRESS1 := '401 East Central Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Comanche';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '51347334320000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '51347334350000';
        GPVendor.ZIPCODE := '76442';
        GPVendor.STATE := 'OG';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*1';
        GPVendor.UPSZONE := 'O4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'A11--70';
        GPVendor.VENDNAME := 'Alexander & Alexander';
        GPVendor.SEARCHNAME := 'Alexander & Alexander';
        GPVendor.VNDCHKNM := 'Alexander & Alexander';
        GPVendor.ADDRESS1 := 'P.O. Box 2950';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Newport';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '31847240170000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '31847240200000';
        GPVendor.ZIPCODE := '76888';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := 'T3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'ACETRAVE0001';
        GPVendor.VENDNAME := 'A Travel Company';
        GPVendor.SEARCHNAME := 'A Travel Company';
        GPVendor.VNDCHKNM := 'A Travel Company';
        GPVendor.ADDRESS1 := '123 Riley Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Sydney';
        GPVendor.VNDCNTCT := 'Greg Powell';
        GPVendor.PHNUMBR1 := '29855501010000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'Australia';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 6713.27000;
        GPVendor.FAXNUMBR := '29455501010000';
        GPVendor.ZIPCODE := '2086';
        GPVendor.STATE := 'NSW';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'AUSNSWST+20';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := 'Greg Powell';
        GPVendorAddress.ADDRESS1 := '123 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '29855501010000';
        GPVendorAddress.FAXNUMBR := '29455501010000';
        GPVendorAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'VEN';
        GPSY01200.Master_ID := GPVendorAddress.VENDORID;
        GPSY01200.ADRSCODE := GPVendorAddress.ADRSCODE;
        GPSY01200.INET1 := '@testing.tst';
        GPSY01200.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodeRemitToTxt;
        GPVendorAddress.VNDCNTCT := 'Greg Powell';
        GPVendorAddress.ADDRESS1 := 'Box 342';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2000';
        GPVendorAddress.PHNUMBR1 := '29855501020000';
        GPVendorAddress.FAXNUMBR := '29455501020000';
        GPVendorAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'VEN';
        GPSY01200.Master_ID := GPVendorAddress.VENDORID;
        GPSY01200.ADRSCODE := GPVendorAddress.ADRSCODE;
        GPSY01200.INET1 := '                          ';
        GPSY01200.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPPM00200.VENDORID));
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.VADCDTRO := AddressCodeRemitToTxt;
        GPPM00200.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'ACETRAVE0002';
        GPVendor.VENDNAME := 'A Travel Company 2';
        GPVendor.SEARCHNAME := 'A Travel Company 2';
        GPVendor.VNDCHKNM := 'A Travel Company 2';
        GPVendor.ADDRESS1 := '124 Riley Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Sydney';
        GPVendor.VNDCNTCT := 'Greg Powell Jr.';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'Australia';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 6713.27000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '2086';
        GPVendor.STATE := 'NSW';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'AUSNSWST+20';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := 'Greg Powell Jr.';
        GPVendorAddress.ADDRESS1 := '124 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '61855501040000';
        GPVendorAddress.FAXNUMBR := '61855501040000';
        GPVendorAddress.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodeWarehouseTxt;
        GPVendorAddress.VNDCNTCT := 'Greg Powell Jr.';
        GPVendorAddress.ADDRESS1 := '124 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '00000000000000';
        GPVendorAddress.FAXNUMBR := '00000000000000';
        GPVendorAddress.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPPM00200.VENDORID));
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.VADCDSFR := AddressCodeRemitToTxt;
        GPPM00200.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'ACME';
        GPVendor.VENDNAME := 'Acme Truck Line';
        GPVendor.SEARCHNAME := 'Acme Truck Line';
        GPVendor.VNDCHKNM := 'Acme Truck Line';
        GPVendor.ADDRESS1 := 'P.O. Box 183';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Harvey';
        GPVendor.VNDCNTCT := 'Mr. Lashro';
        GPVendor.PHNUMBR1 := '30543212880000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '30543212900000';
        GPVendor.ZIPCODE := '70059';
        GPVendor.STATE := 'ND';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*8';
        GPVendor.UPSZONE := 'N4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := 'Mr. Lashro';
        GPVendorAddress.ADDRESS1 := 'P.O. Box 183';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Harvey';
        GPVendorAddress.STATE := 'ND';
        GPVendorAddress.ZIPCODE := '70059';
        GPVendorAddress.PHNUMBR1 := '30543212880000';
        GPVendorAddress.FAXNUMBR := '30543212900000';
        GPVendorAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'VEN';
        GPSY01200.Master_ID := GPVendorAddress.VENDORID;
        GPSY01200.ADRSCODE := GPVendorAddress.ADRSCODE;
        GPSY01200.INET1 := 'GoodEmailAddress@testing.tst';
        GPSY01200.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPVendorAddress.VENDORID));
        GPVendorAddress.ADRSCODE := AddressCodeRemitToTxt;
        GPVendorAddress.VNDCNTCT := 'Mr. Lashro';
        GPVendorAddress.ADDRESS1 := 'P.O. Box 183';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Harvey';
        GPVendorAddress.STATE := 'ND';
        GPVendorAddress.ZIPCODE := '70059';
        GPVendorAddress.PHNUMBR1 := '30543212880000';
        GPVendorAddress.FAXNUMBR := '30543212900000';
        GPVendorAddress.Insert();

        Clear(GPSY01200);
        GPSY01200.Master_Type := 'VEN';
        GPSY01200.Master_ID := GPVendorAddress.VENDORID;
        GPSY01200.ADRSCODE := GPVendorAddress.ADRSCODE;
        GPSY01200.INET1 := 'GoodEmailAddress2@testing.tst';
        GPSY01200.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(GPPM00200.VENDORID));
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.VADCDTRO := AddressCodeRemitToTxt;
        GPPM00200.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'ADEMCO';
        GPVendor.VENDNAME := 'ADEMCO';
        GPVendor.SEARCHNAME := 'ADEMCO';
        GPVendor.VNDCHKNM := 'ADEMCO';
        GPVendor.ADDRESS1 := '165';
        GPVendor.ADDRESS2 := 'P.O. Box 4321';
        GPVendor.CITY := 'Syosset';
        GPVendor.VNDCNTCT := 'Eileen West';
        GPVendor.PHNUMBR1 := '20524198270000';
        GPVendor.PYMTRMID := '2% EOM/Net 15th';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '20524198300000';
        GPVendor.ZIPCODE := '324658977';
        GPVendor.STATE := 'MI';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTA/U';
        GPVendor.UPSZONE := 'L3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'AIRCARG';
        GPVendor.VENDNAME := 'American Airlines Cargo';
        GPVendor.SEARCHNAME := 'American Airlines Cargo';
        GPVendor.VNDCHKNM := 'American Airlines Cargo';
        GPVendor.ADDRESS1 := 'P.O. Box 43324';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := 'Ron Ward';
        GPVendor.PHNUMBR1 := '90489170140000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '';
        GPVendor.ZIPCODE := '751845305';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTIP*0';
        GPVendor.UPSZONE := 'N4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'AMERICA';
        GPVendor.VENDNAME := 'American Airlines Cargo';
        GPVendor.SEARCHNAME := 'American Airlines Cargo';
        GPVendor.VNDCHKNM := 'American Airlines Cargo';
        GPVendor.ADDRESS1 := 'P.O. Box 375';
        GPVendor.ADDRESS2 := 'Bin 2114';
        GPVendor.CITY := 'Ector';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '30532373490000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '30532373500000';
        GPVendor.ZIPCODE := '75439';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTIP*1';
        GPVendor.UPSZONE := 'N4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'C1161';
        GPVendor.VENDNAME := 'All Controls Company';
        GPVendor.SEARCHNAME := 'All Controls Company';
        GPVendor.VNDCHKNM := 'All Controls Company';
        GPVendor.ADDRESS1 := '7578 Sands';
        GPVendor.ADDRESS2 := 'Box 5';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '81723515770000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 20.04000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '76118';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTTIP0';
        GPVendor.UPSZONE := 'P3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'CHUB';
        GPVendor.VENDNAME := 'Chub';
        GPVendor.SEARCHNAME := 'Chub';
        GPVendor.VNDCHKNM := 'Chub';
        GPVendor.ADDRESS1 := '261 N 11th St.';
        GPVendor.ADDRESS2 := 'P.O. Box 3425';
        GPVendor.CITY := 'Jackonsville';
        GPVendor.VNDCNTCT := 'Norman Johnson';
        GPVendor.PHNUMBR1 := '90439945610000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '90439945610000';
        GPVendor.ZIPCODE := '1';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTTIP1';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'CORWIN';
        GPVendor.VENDNAME := 'CORWIN';
        GPVendor.SEARCHNAME := 'CORWIN';
        GPVendor.VNDCHKNM := 'CORWIN';
        GPVendor.ADDRESS1 := '4423 E 15th AVE.';
        GPVendor.ADDRESS2 := 'P.O. Box 555';
        GPVendor.CITY := 'ATLANTA';
        GPVendor.VNDCNTCT := 'DION SANDERS';
        GPVendor.PHNUMBR1 := '40473266430000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 120.02000;
        GPVendor.FAXNUMBR := '40473266430000';
        GPVendor.ZIPCODE := '23103';
        GPVendor.STATE := 'GA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTTIP2';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'DUFFY';
        GPVendor.VENDNAME := 'Duffy';
        GPVendor.SEARCHNAME := 'Duffy';
        GPVendor.VNDCHKNM := 'Duffy';
        GPVendor.ADDRESS1 := '601 12th St. S';
        GPVendor.ADDRESS2 := 'P.O. Box 642';
        GPVendor.CITY := 'Bangor';
        GPVendor.VNDCNTCT := 'John Cougar';
        GPVendor.PHNUMBR1 := '20725555440000';
        GPVendor.PYMTRMID := 'EOM';
        GPVendor.SHIPMTHD := 'MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '21103';
        GPVendor.STATE := 'ME';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PTIP*2';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'FREIGHT';
        GPVendor.VENDNAME := 'Air Freight Services';
        GPVendor.SEARCHNAME := 'Air Freight Services';
        GPVendor.VNDCHKNM := 'Air Freight Services';
        GPVendor.ADDRESS1 := 'P.O. Box 1662';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Grapevine';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '91364271030000';
        GPVendor.PYMTRMID := '';
        GPVendor.SHIPMTHD := '';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -39.98000;
        GPVendor.FAXNUMBR := '';
        GPVendor.ZIPCODE := '368963426';
        GPVendor.STATE := 'NH';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-NO-%P';
        GPVendor.UPSZONE := 'Q3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'GERELL';
        GPVendor.VENDNAME := 'Gerell';
        GPVendor.SEARCHNAME := 'Gerell';
        GPVendor.VNDCHKNM := 'Gerell';
        GPVendor.ADDRESS1 := 'P.O. Box 244';
        GPVendor.ADDRESS2 := '701 4th Ave. N.';
        GPVendor.CITY := 'San Diego';
        GPVendor.VNDCNTCT := 'Bill Swift';
        GPVendor.PHNUMBR1 := '61928105440000';
        GPVendor.PYMTRMID := '2% 10/Net 30';
        GPVendor.SHIPMTHD := 'EXPRESS MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '61928105440000';
        GPVendor.ZIPCODE := '11103';
        GPVendor.STATE := 'CA';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%AD%P';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'KNIGHT';
        GPVendor.VENDNAME := 'Knight';
        GPVendor.SEARCHNAME := 'Knight';
        GPVendor.VNDCHKNM := 'Knight';
        GPVendor.ADDRESS1 := '5523 N Oak St.';
        GPVendor.ADDRESS2 := 'P.O. Box 7432';
        GPVendor.CITY := 'Montreal';
        GPVendor.VNDCNTCT := 'Carl Eller';
        GPVendor.PHNUMBR1 := '51443299310000';
        GPVendor.PYMTRMID := 'Due 20th';
        GPVendor.SHIPMTHD := 'EXPRESS MAIL';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '51443299310000';
        GPVendor.ZIPCODE := '58103';
        GPVendor.STATE := 'PQ';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*0';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'LASITOR';
        GPVendor.VENDNAME := 'Lasitor plumbing';
        GPVendor.SEARCHNAME := 'Lasitor plumbing';
        GPVendor.VNDCHKNM := 'Lasitor plumbing';
        GPVendor.ADDRESS1 := 'P.O. Box 14638';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Haltom City';
        GPVendor.VNDCNTCT := 'Jon Lasitor';
        GPVendor.PHNUMBR1 := '81947351230000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '81947351300000';
        GPVendor.ZIPCODE := '76117';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*1';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'LNESTAR';
        GPVendor.VENDNAME := 'Lone Star Fuel Injections';
        GPVendor.SEARCHNAME := 'Lone Star Fuel Injections';
        GPVendor.VNDCHKNM := 'Lone Star Fuel Injections';
        GPVendor.ADDRESS1 := 'P.O. Box 7026';
        GPVendor.ADDRESS2 := '3245 Crabtree';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '20731342300000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '20731342350000';
        GPVendor.ZIPCODE := '76114';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TAX-%P*2';
        GPVendor.UPSZONE := 'D3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'LONSTAR';
        GPVendor.VENDNAME := 'Lone Star Gas Company';
        GPVendor.SEARCHNAME := 'Lone Star Gas Company';
        GPVendor.VNDCHKNM := 'Lone Star Gas Company';
        GPVendor.ADDRESS1 := 'P.O. Box 6200031';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '41347432130000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -53.50000;
        GPVendor.FAXNUMBR := '41347432140000';
        GPVendor.ZIPCODE := '76114';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*3';
        GPVendor.UPSZONE := 'F4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'MACHO';
        GPVendor.VENDNAME := 'Macho Tire Company';
        GPVendor.SEARCHNAME := 'Macho Tire Company';
        GPVendor.VNDCHKNM := 'Macho Tire Company';
        GPVendor.ADDRESS1 := '913 North Beltine Rd.';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Irving';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '60347428190000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -107.54000;
        GPVendor.FAXNUMBR := '60347428220000';
        GPVendor.ZIPCODE := '60005';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*5';
        GPVendor.UPSZONE := 'G3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'RAYS';
        GPVendor.VENDNAME := 'Rays Auto Supply';
        GPVendor.SEARCHNAME := 'Rays Auto Supply';
        GPVendor.VNDCHKNM := 'Rays Auto Supply';
        GPVendor.ADDRESS1 := 'P.O. Box 906';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := 'Ray';
        GPVendor.PHNUMBR1 := '50912140010000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -34.20000;
        GPVendor.FAXNUMBR := '50912140100000';
        GPVendor.ZIPCODE := '7611';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*6';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'S.S. SALES';
        GPVendor.VENDNAME := 'S.S. Sales';
        GPVendor.SEARCHNAME := 'S.S. Sales';
        GPVendor.VNDCHKNM := 'S.S. Sales';
        GPVendor.ADDRESS1 := '1001 S 3rd St.';
        GPVendor.ADDRESS2 := 'Suite 101';
        GPVendor.CITY := 'Tampa Bay';
        GPVendor.VNDCNTCT := 'Kirby Puckett';
        GPVendor.PHNUMBR1 := '81537155550000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '81537155550000';
        GPVendor.ZIPCODE := '75061';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%P*7';
        GPVendor.UPSZONE := 'A3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V1030';
        GPVendor.VENDNAME := 'ABF Freight Systems Inc.';
        GPVendor.SEARCHNAME := 'ABF Freight Systems Inc.';
        GPVendor.VNDCHKNM := 'ABF Freight Systems Inc.';
        GPVendor.ADDRESS1 := 'p.o. bOX 9434';
        GPVendor.ADDRESS2 := 'Route 44';
        GPVendor.CITY := 'Jenks';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '50362013570000';
        GPVendor.PYMTRMID := '$2.50 10th/Net 45';
        GPVendor.SHIPMTHD := 'UPS GROUND';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '74398';
        GPVendor.STATE := 'OK';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-N-TXB-%PTIP';
        GPVendor.UPSZONE := 'K2';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V1100';
        GPVendor.VENDNAME := 'Advanced Image Systems Inc.';
        GPVendor.SEARCHNAME := 'Advanced Image Systems Inc.';
        GPVendor.VNDCHKNM := 'Advanced Image Systems Inc.';
        GPVendor.ADDRESS1 := 'P.O. Box 8302334';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Dallas';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '91972143800000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '752841407';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%P*2';
        GPVendor.UPSZONE := 'X6';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V1150000';
        GPVendor.VENDNAME := 'Aircom Fasterners';
        GPVendor.SEARCHNAME := 'Aircom Fasterners';
        GPVendor.VNDCHKNM := 'Aircom Fasterners';
        GPVendor.ADDRESS1 := 'P.O. Box 151227';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Arlington';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '31833207890000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '31833207950000';
        GPVendor.ZIPCODE := '76015';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*1';
        GPVendor.UPSZONE := 'T3';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V3110';
        GPVendor.VENDNAME := 'Joe Lancaster';
        GPVendor.SEARCHNAME := 'Joe Lancaster';
        GPVendor.VNDCHKNM := 'Joe Lancaster';
        GPVendor.ADDRESS1 := '5701-a East Rosedale';
        GPVendor.ADDRESS2 := 'Box 8479';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := 'Joe';
        GPVendor.PHNUMBR1 := '40332330170000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := -19.60000;
        GPVendor.FAXNUMBR := '40332330200000';
        GPVendor.ZIPCODE := '76112';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '45-002978';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V3120';
        GPVendor.VENDNAME := 'Quist Paper Company';
        GPVendor.SEARCHNAME := 'Quist Paper Company';
        GPVendor.VNDCHKNM := 'Quist Paper Company';
        GPVendor.ADDRESS1 := 'P.O. Box 285';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '20722112210000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '76101';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*3';
        GPVendor.UPSZONE := 'D2';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendor);
        GPVendor.VENDORID := 'V3130';
        GPVendor.VENDNAME := 'Lmd Telecom, Inc.';
        GPVendor.SEARCHNAME := 'Lmd Telecom, Inc.';
        GPVendor.VNDCHKNM := 'Lmd Telecom, Inc.';
        GPVendor.ADDRESS1 := 'P.O. Box10158';
        GPVendor.ADDRESS2 := '2201a Jacsboro Highway';
        GPVendor.CITY := 'Fort Worth';
        GPVendor.VNDCNTCT := '';
        GPVendor.PHNUMBR1 := '41327348230000';
        GPVendor.PYMTRMID := '3% 15th/Net 30';
        GPVendor.SHIPMTHD := 'UPS BLUE';
        GPVendor.COUNTRY := '';
        GPVendor.PYMNTPRI := '';
        GPVendor.AMOUNT := 0.00000;
        GPVendor.FAXNUMBR := '41327348300000';
        GPVendor.ZIPCODE := '76114';
        GPVendor.STATE := 'TX';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*4';
        GPVendor.UPSZONE := 'F4';
        GPVendor.TXIDNMBR := '45-0029728';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := 'V3130';
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := 'Test Contact';
        GPVendorAddress.ADDRESS1 := 'P.O. Box10159';
        GPVendorAddress.ADDRESS2 := '2201a Jacsboro Highway 2';
        GPVendorAddress.CITY := 'Fort Worth';
        GPVendorAddress.STATE := 'TX';
        GPVendorAddress.ZIPCODE := '76114';
        GPVendorAddress.PHNUMBR1 := '41327348230000';
        GPVendorAddress.FAXNUMBR := '41327348300000';
        GPVendorAddress.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := 'V3130';
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.Insert();
    end;

    local procedure CreateVendorTrx()
    var
        GPVendorTransactions: Record "GP Vendor Transactions";
    begin
        Clear(GPVendorTransactions);
        GPVendorTransactions.Id := '1';
        GPVendorTransactions.VENDORID := 'V3130';
        GPVendorTransactions.DOCNUMBR := '1';
        GPVendorTransactions.GLDocNo := '1';
        GPVendorTransactions.DOCDATE := DMY2Date(11, 8, 2022);
        GPVendorTransactions.CURTRXAM := 1;
        GPVendorTransactions.TransType := GPVendorTransactions.TransType::Invoice;
        GPVendorTransactions.PYMTRMID := '3% 15th/Net 30';
        GPVendorTransactions.Insert();

        Clear(GPVendorTransactions);
        GPVendorTransactions.Id := '2';
        GPVendorTransactions.VENDORID := '1160';
        GPVendorTransactions.DOCNUMBR := '2';
        GPVendorTransactions.GLDocNo := '2';
        GPVendorTransactions.DOCDATE := DMY2Date(11, 8, 2022);
        GPVendorTransactions.CURTRXAM := 2;
        GPVendorTransactions.TransType := GPVendorTransactions.TransType::Invoice;
        GPVendorTransactions.PYMTRMID := '3% 15th/Net 30';
        GPVendorTransactions.Insert();
    end;

    local procedure CreateGPVendorBankInformation()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        SwiftCode: Record "SWIFT Code";
    begin
        GPVendorAddress.Reset();
        GPVendorAddress.SetFilter(VENDORID, '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        GPVendorAddress.DeleteAll();

        GPVendor.Reset();
        GPVendor.SetFilter(VENDORID, '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        GPVendor.DeleteAll();

        VendorBankAccount.Reset();
        VendorBankAccount.SetFilter("Vendor No.", '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        VendorBankAccount.DeleteAll();

        Vendor.Reset();
        Vendor.SetFilter("No.", '%1|%2|%3|%4|%5', VendorIdWithBankStr1Txt, VendorIdWithBankStr2Txt, VendorIdWithBankStr3Txt, VendorIdWithBankStr4Txt, VendorIdWithBankStr5Txt);
        Vendor.DeleteAll();

        SwiftCode.Reset();
        SwiftCode.SetRange(Code, ValidSwiftCodeStrTxt);
        SwiftCode.DeleteAll();

        GPMC40200.DeleteAll();
        GPSY06000.DeleteAll();

        Clear(GPMC40200);
        GPMC40200.CURNCYID := CurrencyCodeUSTxt;
        GPMC40200.CRNCYSYM := '$';
        GPMC40200.CRNCYDSC := 'US Dollar';
        GPMC40200.Insert();

        // Vendor 1
        Clear(GPVendor);
        GPVendor.VENDORID := VendorIdWithBankStr1Txt;
        GPVendor.VENDNAME := 'Vendor with bank account 1';
        GPVendor.SEARCHNAME := GPVendor.VENDNAME;
        GPVendor.VNDCHKNM := GPVendor.VENDNAME;
        GPVendor.ADDRESS1 := '124 Main Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Orlando';
        GPVendor.VNDCNTCT := 'Tester Testerson';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'USA';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 0;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '32830';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
#pragma warning disable AA0139
        GPVendorAddress.VENDORID := GPVendor.VENDORID;
        GPVendorAddress.ADRSCODE := AddressCodeRemitToTxt;
        GPVendorAddress.VNDCNTCT := GPVendor.VNDCNTCT;
        GPVendorAddress.ADDRESS1 := GPVendor.ADDRESS1;
        GPVendorAddress.ADDRESS2 := GPVendor.ADDRESS2;
        GPVendorAddress.CITY := GPVendor.CITY;
        GPVendorAddress.STATE := GPVendor.STATE;
        GPVendorAddress.ZIPCODE := GPVendor.ZIPCODE;
        GPVendorAddress.PHNUMBR1 := GPVendor.PHNUMBR1;
        GPVendorAddress.FAXNUMBR := GPVendor.FAXNUMBR;
        GPVendorAddress.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := GPVendor.VENDORID;
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := GPVendor.VNDCNTCT;
        GPVendorAddress.ADDRESS1 := GPVendor.ADDRESS1 + '_Primary';
        GPVendorAddress.ADDRESS2 := GPVendor.ADDRESS2;
        GPVendorAddress.CITY := GPVendor.CITY;
        GPVendorAddress.STATE := GPVendor.STATE;
        GPVendorAddress.ZIPCODE := GPVendor.ZIPCODE;
        GPVendorAddress.PHNUMBR1 := GPVendor.PHNUMBR1;
        GPVendorAddress.FAXNUMBR := GPVendor.FAXNUMBR;
        GPVendorAddress.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeRemitToTxt;
        GPSY06000.EFTBankCode := 'V01_RemitTo';
        GPSY06000.BANKNAME := 'V01_RemitTo_Name';
        GPSY06000.EFTBankBranchCode := '01234';
        GPSY06000.EFTBankAcct := '123456789';
        GPSY06000.EFTTransitRoutingNo := '123456789';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodePrimaryTxt;
        GPSY06000.EFTBankCode := 'V01_Primary';
        GPSY06000.BANKNAME := 'V01_Primary_Name';
        GPSY06000.EFTBankBranchCode := '12345';
        GPSY06000.EFTBankAcct := '234567890';
        GPSY06000.EFTTransitRoutingNo := '234567891';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOtherTxt;
        GPSY06000.EFTBankCode := 'V01_Other';
        GPSY06000.BANKNAME := 'V01_Other_Name';
        GPSY06000.EFTBankBranchCode := '23450';
        GPSY06000.EFTBankAcct := '34567894';
        GPSY06000.EFTTransitRoutingNo := '345678917';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := GPVendor.VENDORID;
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.VADCDTRO := AddressCodeRemitToTxt;
        GPPM00200.Insert();

        // Vendor 2
        Clear(GPVendor);
        GPVendor.VENDORID := VendorIdWithBankStr2Txt;
        GPVendor.VENDNAME := 'Vendor with bank account 2';
        GPVendor.SEARCHNAME := GPVendor.VENDNAME;
        GPVendor.VNDCHKNM := GPVendor.VENDNAME;
        GPVendor.ADDRESS1 := '125 Main Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Orlando';
        GPVendor.VNDCNTCT := 'Tester Testerson Jr.';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'USA';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 0;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '32830';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := GPVendor.VENDORID;
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := GPVendor.VNDCNTCT;
        GPVendorAddress.ADDRESS1 := GPVendor.ADDRESS1;
        GPVendorAddress.ADDRESS2 := GPVendor.ADDRESS2;
        GPVendorAddress.CITY := GPVendor.CITY;
        GPVendorAddress.STATE := GPVendor.STATE;
        GPVendorAddress.ZIPCODE := GPVendor.ZIPCODE;
        GPVendorAddress.PHNUMBR1 := GPVendor.PHNUMBR1;
        GPVendorAddress.FAXNUMBR := GPVendor.FAXNUMBR;
        GPVendorAddress.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := GPVendor.VENDORID;
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodePrimaryTxt;
        GPSY06000.EFTBankCode := 'V02_Primary';
        GPSY06000.BANKNAME := 'V02_Primary_Name';
        GPSY06000.EFTBankBranchCode := '23456';
        GPSY06000.EFTBankAcct := '345678901';
        GPSY06000.EFTTransitRoutingNo := '345678910';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := InvalidIBANStr1Txt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOtherTxt;
        GPSY06000.EFTBankCode := 'V02_Other';
        GPSY06000.BANKNAME := 'V02_Other_Name';
        GPSY06000.EFTBankBranchCode := '23458';
        GPSY06000.EFTBankAcct := '45678947';
        GPSY06000.EFTTransitRoutingNo := '345678917';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        // Vendor 3
        Clear(GPVendor);
        GPVendor.VENDORID := VendorIdWithBankStr3Txt;
        GPVendor.VENDNAME := 'Vendor with bank account 3';
        GPVendor.SEARCHNAME := GPVendor.VENDNAME;
        GPVendor.VNDCHKNM := GPVendor.VENDNAME;
        GPVendor.ADDRESS1 := '126 Main Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Orlando';
        GPVendor.VNDCNTCT := 'Tester Testerson Sr.';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'USA';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 0;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '32830';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := GPVendor.VENDORID;
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := GPVendor.VNDCNTCT;
        GPVendorAddress.ADDRESS1 := GPVendor.ADDRESS1;
        GPVendorAddress.ADDRESS2 := GPVendor.ADDRESS2;
        GPVendorAddress.CITY := GPVendor.CITY;
        GPVendorAddress.STATE := GPVendor.STATE;
        GPVendorAddress.ZIPCODE := GPVendor.ZIPCODE;
        GPVendorAddress.PHNUMBR1 := GPVendor.PHNUMBR1;
        GPVendorAddress.FAXNUMBR := GPVendor.FAXNUMBR;
        GPVendorAddress.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOtherTxt;
        GPSY06000.EFTBankCode := 'V03_Other';
        GPSY06000.BANKNAME := 'V03_Other_Name';
        GPSY06000.EFTBankBranchCode := '34567';
        GPSY06000.EFTBankAcct := '456789012';
        GPSY06000.EFTTransitRoutingNo := '456789102';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOther2Txt;
        GPSY06000.EFTBankCode := 'V03_Other2';
        GPSY06000.BANKNAME := 'V03_Other2_Name';
        GPSY06000.EFTBankBranchCode := '34567';
        GPSY06000.EFTBankAcct := '456789014';
        GPSY06000.EFTTransitRoutingNo := '456789104';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := InvalidIBANStr2Txt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := GPVendor.VENDORID;
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.Insert();

        // Vendor 4
        Clear(GPVendor);
        GPVendor.VENDORID := VendorIdWithBankStr4Txt;
        GPVendor.VENDNAME := 'Vendor with bank account 4';
        GPVendor.SEARCHNAME := GPVendor.VENDNAME;
        GPVendor.VNDCHKNM := GPVendor.VENDNAME;
        GPVendor.ADDRESS1 := '127 Main Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Orlando';
        GPVendor.VNDCNTCT := 'Tester Testerson II';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'USA';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 0;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '32830';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPVendorAddress);
        GPVendorAddress.VENDORID := GPVendor.VENDORID;
        GPVendorAddress.ADRSCODE := AddressCodePrimaryTxt;
        GPVendorAddress.VNDCNTCT := GPVendor.VNDCNTCT;
        GPVendorAddress.ADDRESS1 := GPVendor.ADDRESS1;
        GPVendorAddress.ADDRESS2 := GPVendor.ADDRESS2;
        GPVendorAddress.CITY := GPVendor.CITY;
        GPVendorAddress.STATE := GPVendor.STATE;
        GPVendorAddress.ZIPCODE := GPVendor.ZIPCODE;
        GPVendorAddress.PHNUMBR1 := GPVendor.PHNUMBR1;
        GPVendorAddress.FAXNUMBR := GPVendor.FAXNUMBR;
        GPVendorAddress.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeRemitToTxt;
        GPSY06000.INACTIVE := true;
        GPSY06000.EFTBankCode := 'V04_RemitTo';
        GPSY06000.BANKNAME := 'V04_RemitTo_Name';
        GPSY06000.EFTBankBranchCode := '01234';
        GPSY06000.EFTBankAcct := '56789078';
        GPSY06000.EFTTransitRoutingNo := '123456789';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodePrimaryTxt;
        GPSY06000.EFTBankCode := 'V04_Primary';
        GPSY06000.BANKNAME := 'V04_Primary_Name';
        GPSY06000.EFTBankBranchCode := '23456';
        GPSY06000.EFTBankAcct := '345678909';
        GPSY06000.EFTTransitRoutingNo := '456789107';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOtherTxt;
        GPSY06000.EFTBankCode := 'V04_Other';
        GPSY06000.BANKNAME := 'V04_Other_Name';
        GPSY06000.EFTBankBranchCode := '34567';
        GPSY06000.EFTBankAcct := '56789025';
        GPSY06000.EFTTransitRoutingNo := '456789102';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.IntlBankAcctNum := ValidIBANStrTxt;
        GPSY06000.SWIFTADDR := ValidSwiftCodeStrTxt;
        GPSY06000.Insert();


        Clear(GPPM00200);
        GPPM00200.VENDORID := GPVendor.VENDORID;
        GPPM00200.VADDCDPR := AddressCodePrimaryTxt;
        GPPM00200.VADCDTRO := AddressCodeRemitToTxt;
        GPPM00200.Insert();

        // Vendor 5
        Clear(GPVendor);
        GPVendor.VENDORID := VendorIdWithBankStr5Txt;
        GPVendor.VENDNAME := 'Vendor with bank account 5';
        GPVendor.SEARCHNAME := GPVendor.VENDNAME;
        GPVendor.VNDCHKNM := GPVendor.VENDNAME;
        GPVendor.ADDRESS1 := '127 Main Street';
        GPVendor.ADDRESS2 := '';
        GPVendor.CITY := 'Orlando';
        GPVendor.VNDCNTCT := 'Tester Testerson II';
        GPVendor.PHNUMBR1 := '00000000000000';
        GPVendor.PYMTRMID := 'Net 30';
        GPVendor.SHIPMTHD := 'OVERNIGHT';
        GPVendor.COUNTRY := 'USA';
        GPVendor.PYMNTPRI := '1';
        GPVendor.AMOUNT := 0;
        GPVendor.FAXNUMBR := '00000000000000';
        GPVendor.ZIPCODE := '32830';
        GPVendor.STATE := 'FL';
        GPVendor.INET1 := '';
        GPVendor.INET2 := ' ';
        GPVendor.TAXSCHID := 'P-T-TXB-%PT%P*2';
        GPVendor.UPSZONE := '';
        GPVendor.TXIDNMBR := '';
        GPVendor.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodePrimaryTxt;
        GPSY06000.EFTBankCode := '';
        GPSY06000.BANKNAME := 'Bank Name 1';
        GPSY06000.EFTBankBranchCode := '01234';
        GPSY06000.EFTBankAcct := '56789078';
        GPSY06000.EFTTransitRoutingNo := '123456789';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeRemitToTxt;
        GPSY06000.EFTBankCode := '';
        GPSY06000.BANKNAME := 'Bank Name 2';
        GPSY06000.EFTBankBranchCode := '01234';
        GPSY06000.EFTBankAcct := '56789078';
        GPSY06000.EFTTransitRoutingNo := '123456789';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.Insert();

        Clear(GPSY06000);
        GPSY06000.CustomerVendor_ID := GPVendor.VENDORID;
        GPSY06000.ADRSCODE := AddressCodeOtherTxt;
        GPSY06000.EFTBankCode := '';
        GPSY06000.BANKNAME := 'Bank Name 3';
        GPSY06000.EFTBankBranchCode := '01234';
        GPSY06000.EFTBankAcct := '56789078';
        GPSY06000.EFTTransitRoutingNo := '123456789';
        GPSY06000.CURNCYID := CurrencyCodeUSTxt;
        GPSY06000.Insert();
#pragma warning restore AA0139
    end;

    local procedure CreateVendorClassData()
    var
        GLAccount: Record "G/L Account";
        GPAccount: Record "GP Account";
    begin
        GPAccount.Init();
        GPAccount.AcctNum := '1';
        GPAccount.AcctIndex := 35;
        GPAccount.Name := 'Accounts Payable';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPAccount.Init();
        GPAccount.AcctNum := '2';
        GPAccount.AcctIndex := 36;
        GPAccount.Name := 'Purchases Discounts Available';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPAccount.Init();
        GPAccount.AcctNum := '3';
        GPAccount.AcctIndex := 139;
        GPAccount.Name := 'Purchases Discounts Taken';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPAccount.Init();
        GPAccount.AcctNum := '4';
        GPAccount.AcctIndex := 190;
        GPAccount.Name := 'Finance Charge Expense';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPAccount.Init();
        GPAccount.AcctNum := 'TEST123';
        GPAccount.AcctIndex := 999;
        GPAccount.Name := 'Test 123';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPPM00100.Init();
        GPPM00100.VNDCLSID := 'USA-US-C';
        GPPM00100.VNDCLDSC := 'U.S. Vendors-Contract Services';
        GPPM00100.PMAPINDX := 35;
        GPPM00100.PMCSHIDX := 0;
        GPPM00100.PMDAVIDX := 36;
        GPPM00100.PMDTKIDX := 139;
        GPPM00100.PMFINIDX := 190;
        GPPM00100.PMMSCHIX := 184;
        GPPM00100.PMFRTIDX := 281;
        GPPM00100.PMTAXIDX := 83;
        GPPM00100.PMWRTIDX := 0;
        GPPM00100.PMPRCHIX := 270;
        GPPM00100.PMRTNGIX := 0;
        GPPM00100.PMTDSCIX := 0;
        GPPM00100.ACPURIDX := 447;
        GPPM00100.PURPVIDX := 446;
        GPPM00100.Insert();

        GPPM00100.Init();
        GPPM00100.VNDCLSID := 'USA-US-I';
        GPPM00100.VNDCLDSC := 'U.S. Vendors - Inventory';
        GPPM00100.PMAPINDX := 35;
        GPPM00100.PMCSHIDX := 0;
        GPPM00100.PMDAVIDX := 36;
        GPPM00100.PMDTKIDX := 139;
        GPPM00100.PMFINIDX := 190;
        GPPM00100.PMMSCHIX := 184;
        GPPM00100.PMFRTIDX := 281;
        GPPM00100.PMTAXIDX := 83;
        GPPM00100.PMWRTIDX := 0;
        GPPM00100.PMPRCHIX := 18;
        GPPM00100.PMRTNGIX := 0;
        GPPM00100.PMTDSCIX := 0;
        GPPM00100.ACPURIDX := 447;
        GPPM00100.PURPVIDX := 446;
        GPPM00100.Insert();

        GPPM00100.Init();
        GPPM00100.VNDCLSID := 'USA-US-M';
        GPPM00100.VNDCLDSC := 'U.S. Vendors-Misc. Expenses';
        GPPM00100.PMAPINDX := 0;
        GPPM00100.PMCSHIDX := 0;
        GPPM00100.PMDAVIDX := 0;
        GPPM00100.PMDTKIDX := 0;
        GPPM00100.PMFINIDX := 0;
        GPPM00100.PMMSCHIX := 0;
        GPPM00100.PMFRTIDX := 0;
        GPPM00100.PMTAXIDX := 0;
        GPPM00100.PMWRTIDX := 0;
        GPPM00100.PMPRCHIX := 0;
        GPPM00100.PMRTNGIX := 0;
        GPPM00100.PMTDSCIX := 0;
        GPPM00100.ACPURIDX := 0;
        GPPM00100.PURPVIDX := 0;
        GPPM00100.Insert();

        if GPPM00200.Get('ACME') then begin
            GPPM00200.VNDCLSID := 'USA-US-C';
            GPPM00200.Modify();
        end;

        GPPM00200.Init();
        GPPM00200.VENDORID := 'ADEMCO';
        GPPM00200.VENDNAME := 'ADEMCO';
        GPPM00200.VNDCLSID := 'USA-US-I';
        GPPM00200.Insert();

        GPPM00200.Init();
        GPPM00200.VENDORID := 'AIRCARG';
        GPPM00200.VENDNAME := 'American Airlines Cargo';
        GPPM00200.VNDCLSID := 'USA-US-M';
        GPPM00200.Insert();

        Clear(GPPM00200);
        GPPM00200.VENDORID := '1160';
        GPPM00200.VNDCLSID := 'TEST';
        GPPM00200.Insert();

        Clear(GPPM00100);
        GPPM00100.VNDCLSID := 'TEST';
        GPPM00100.PMAPINDX := 999;
        GPPM00100.Insert();
    end;

    local procedure CreateOpenPOData()
    begin
        Clear(Item);
        Item."No." := 'ITEM-1';
        Item.Validate("Gen. Prod. Posting Group", PostingGroupCodeTxt);
        Item.Validate("Inventory Posting Group", PostingGroupCodeTxt);
        Item.Insert();

        Clear(GPMC40200);
        GPMC40200.CURNCYID := TestMoneyCurrencyCodeTxt;
        GPMC40200.CRNCYDSC := 'Test Money :)';
        GPMC40200.CRNCYSYM := 'TM';
        GPMC40200.Insert();

        Clear(GPPOP10100);
        GPPOP10100.POTYPE := GPPOP10100.POTYPE::Standard;
        GPPOP10100.POSTATUS := GPPOP10100.POSTATUS::New;
        GPPOP10100.PONUMBER := CopyStr(PONumberTxt, 1, MaxStrLen(GPPOP10110.PONUMBER));
        GPPOP10100.VENDORID := 'DUFFY';
        GPPOP10100.DOCDATE := 20230101D;
        GPPOP10100.PRMDATE := 20230101D;
        GPPOP10100.PYMTRMID := '5% 10/NET 30';
        GPPOP10100.SHIPMTHD := 'Space Ship';
        GPPOP10100.XCHGRATE := 0.01;
        GPPOP10100.EXCHDATE := 20230101D;
        GPPOP10100.Insert();

        Clear(GPPOP10110);
        GPPOP10110.PONUMBER := GPPOP10100.PONUMBER;
        GPPOP10110.QTYORDER := 1;
        GPPOP10110.QTYCANCE := 0;
        GPPOP10110.ORD := 1;
        GPPOP10110.UOFM := 'EACH';
        GPPOP10110.ITEMNMBR := Item."No.";
        GPPOP10110.VENDORID := GPPOP10100.VENDORID;
        GPPOP10110.Insert();

        // PO with a line that won't be migrated.
        GPPOP10100.POTYPE := GPPOP10100.POTYPE::Standard;
        GPPOP10100.POSTATUS := GPPOP10100.POSTATUS::New;
        GPPOP10100.PONUMBER := 'PO002';
        GPPOP10100.VENDORID := 'DUFFY';
        GPPOP10100.DOCDATE := 20230101D;
        GPPOP10100.PRMDATE := 20230101D;
        GPPOP10100.PYMTRMID := '5% 10/NET 30';
        GPPOP10100.SHIPMTHD := 'Space Ship';
        GPPOP10100.CURNCYID := TestMoneyCurrencyCodeTxt;
        GPPOP10100.XCHGRATE := 0.01;
        GPPOP10100.EXCHDATE := 20230101D;
        GPPOP10100.Insert();

        Clear(GPPOP10110);
        GPPOP10110.PONUMBER := GPPOP10100.PONUMBER;
        GPPOP10110.QTYORDER := 1;
        GPPOP10110.QTYCANCE := 1;
        GPPOP10110.ORD := 1;
        GPPOP10110.UOFM := 'EACH';
        GPPOP10110.ITEMNMBR := Item."No.";
        GPPOP10110.VENDORID := GPPOP10100.VENDORID;
        GPPOP10110.Insert();
    end;
}