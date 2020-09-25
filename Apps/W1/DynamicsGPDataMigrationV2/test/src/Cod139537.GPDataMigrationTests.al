codeunit 139537 "GP Data Migration Tests"
{
    // version Test,W1,US,CA,GB

    // // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        MigrationGPCustomer: Record "MigrationGP Customer";
        MigrationGPVendor: Record "MigrationGP Vendor";
        CustomerFacade: Codeunit "Customer Data Migration Facade";
        CustomerMigrator: Codeunit "MigrationGP Customer Migrator";
        VendorMigrator: Codeunit "MigrationGP Vendor Migrator";
        VendorFacade: Codeunit "Vendor Data Migration Facade";
        Assert: Codeunit Assert;
        MSGPDataMigrationTests: Codeunit "GP Data Migration Tests";
        JsonErr: Label 'Should have no data from JSON file.';



    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerImport()
    var
        Customer: Record "Customer";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Customers are queried from GP

        // [GIVEN] GP data
        Initialize();
        GetDataFromFile('Customer', GetGetAllCustomersResponse(), JArray);

        GenBusPostingGroup.Init();
        GenBusPostingGroup.Validate(GenBusPostingGroup.Code, 'GP');
        GenBusPostingGroup.Insert(true);

        // [WHEN] Data is imported
        CustomerMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(3, MigrationGPCustomer.Count(), 'Wrong number of Customers read');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        MigrationGPCustomer.SetRange(CUSTNMBR, '!WOW!');
        MigrationGPCustomer.FindFirst();
        Assert.AreEqual('Oh! What a feeling!', MigrationGPCustomer.CUSTNAME, 'CUSTNAME of Customer is wrong');
        Assert.AreEqual('Oh! What a feeling!', MigrationGPCustomer.STMTNAME, 'STMTNAME of Customer is wrong');
        Assert.AreEqual('', MigrationGPCustomer.ADDRESS1, 'ADDRESS1 of Customer is wrong');
        Assert.AreEqual('Toyota Land', MigrationGPCustomer.ADDRESS2, 'ADDRESS2 of Customer is wrong');
        Assert.AreEqual('!What a city!', MigrationGPCustomer.CITY, 'CITY of Customer is wrong');
        Assert.AreEqual('Todd Scott', MigrationGPCustomer.CNTCPRSN, 'CNTCPRSN of Customer is wrong');
        Assert.AreEqual('00000000000000', MigrationGPCustomer.PHONE1, 'PHONE1 Phone of Customer is wrong');
        Assert.AreEqual('MIDWEST', MigrationGPCustomer.SALSTERR, 'SALSTERR of Customer is wrong');
        Assert.AreEqual(1000, MigrationGPCustomer.CRLMTAMT, 'CRLMTAMT of Customer is wrong');
        Assert.AreEqual('2% EOM/Net 15th', MigrationGPCustomer.PYMTRMID, 'PYMTRMID of Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', MigrationGPCustomer.SLPRSNID, 'SLPRSNID of Customer is wrong');
        Assert.AreEqual('MAIL', MigrationGPCustomer.SHIPMTHD, 'SHIPMTHD of Customer is wrong');
        Assert.AreEqual('USA', MigrationGPCustomer.COUNTRY, 'COUNTRY of Customer is wrong');
        Assert.AreEqual(3970.61, MigrationGPCustomer.AMOUNT, 'AMOUNT of Customer is wrong');
        Assert.IsTrue(MigrationGPCustomer.STMTCYCL, 'STMTCYCL of Customer is wrong');
        Assert.AreEqual('00000000000000', MigrationGPCustomer.FAX, 'FAX of Customer is wrong');
        Assert.AreEqual('84953', MigrationGPCustomer.ZIPCODE, 'ZIPCODE of Customer is wrong');
        Assert.AreEqual('OH', MigrationGPCustomer.STATE, 'WebAdSTATEdr of Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', MigrationGPCustomer.TAXSCHID, 'TAXSCHID of Customer is wrong');
        Assert.AreEqual('O4', MigrationGPCustomer.UPSZONE, 'UPSZONE of Customer is wrong');


        // [WHEN] data is migrated
        Customer.DeleteAll();
        MigrationGPCustomer.Reset();
        MigrateCustomers(MigrationGPCustomer);

        // [then] Then the correct number of Customers are applied
        Assert.AreEqual(3, Customer.Count(), 'Wrong number of Migrated Customers read');

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
        Assert.AreEqual('00000000000000', Customer."Phone No.", 'Phone No. of Migrated Customer is wrong');
        Assert.AreEqual('00000000000000', Customer."Fax No.", 'Fax No. of Migrated Customer is wrong');
        Assert.AreEqual('84953', Customer."Post Code", 'Post Code of Migrated Customer is wrong');
        Assert.AreEqual('USA', Customer."Country/Region Code", 'Country/Region of Migrated Customer is wrong');
        Assert.AreEqual('KNOBL-CHUCK-001', Customer."Salesperson Code", 'Salesperson Code of Migrated Customer is wrong');
        Assert.AreEqual('MAIL', Customer."Shipment Method Code", 'Shipment Method Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Print Statements", 'Print Statements of Migrated Customer is wrong');
        Assert.AreEqual('MIDWEST', Customer."Territory Code", 'Territory Code of Migrated Customer is wrong');
        Assert.AreEqual(1000, Customer."Credit Limit (LCY)", 'Credit Limit (LCY) of Migrated Customer is wrong');
        Assert.AreEqual('2% EOM/NET', Customer."Payment Terms Code", 'Payment Terms Code of Migrated Customer is wrong');
        Assert.AreEqual('S-N-NO-%S', Customer."Tax Area Code", 'Tax Area Code of Migrated Customer is wrong');
        Assert.AreEqual(true, Customer."Tax Liable", 'Tax Liable of Migrated Customer is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerImportWhenNoneExistOnGP()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from GP where no accounts actually exist

        // [GIVEN] Default GPSetup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationGPCustomer.Init();

        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate        
        Assert.IsFalse(GetDataFromFile('Customer', GetGetAllEmptyResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerImportWhenBadResponseFromGP()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for GP accounts leads to a bad response which is handled gracefully.

        // [GIVEN] A default GP Setup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationGPCustomer.Init();

        // [WHEN] reading a bad response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Customer', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImport()
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        JArray: JsonArray;
        Country: Code[10];
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();
        GetDataFromFile('Vendor', GetGetAllVendorsResponse(), JArray);

        // [WHEN] Data is imported
        VendorMigrator.PopulateVendorStagingTable(JArray);

        // [then] Then the correct number of Vendors are imported
        Assert.AreEqual(52, MigrationGPVendor.Count(), 'Wrong number of Vendor read');

        // [then] Then fields for Vendor 1 are correctly imported to temporary table
        MigrationGPVendor.SetRange(VENDORID, '1160');
        MigrationGPVendor.FindFirst();
        Assert.AreEqual('Risco, Inc.', MigrationGPVendor.VENDNAME, 'VENDNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', MigrationGPVendor.SEARCHNAME, 'SEARCHNAME of Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', MigrationGPVendor.VNDCHKNM, 'VNDCHKNM of Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', MigrationGPVendor.ADDRESS1, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Suite 234', MigrationGPVendor.ADDRESS2, 'ADDRESS2 of Vendor is wrong');
        Assert.AreEqual('Fort Worth', MigrationGPVendor.CITY, 'CITY of Vendor is wrong');
        Assert.AreEqual('Roger', MigrationGPVendor.VNDCNTCT, 'VNDCNTCT Phone of Vendor is wrong');
        Assert.AreEqual('50482743320000', MigrationGPVendor.PHNUMBR1, 'PHNUMBR1 of Vendor is wrong');
        Assert.AreEqual('3% 15th/Net 30', MigrationGPVendor.PYMTRMID, 'PYMTRMID of Vendor is wrong');
        Assert.AreEqual('UPS BLUE', MigrationGPVendor.SHIPMTHD, 'SHIPMTHD of Vendor is wrong');
        Assert.AreEqual('', MigrationGPVendor.COUNTRY, 'SLPRSNID of Vendor is wrong');
        Assert.AreEqual('', MigrationGPVendor.PYMNTPRI, 'PYMNTPRI of Vendor is wrong');
        Assert.AreEqual(12.18, MigrationGPVendor.AMOUNT, 'AMOUNT of Vendor is wrong');
        Assert.AreEqual('50482743400000', MigrationGPVendor.FAXNUMBR, 'FAXNUMBR of Vendor is wrong');
        // Assert.AreEqual('76101',MigrationGPVendor.ZIPCODE,'ZIPCODE of Vendor is wrong');
        Assert.AreEqual('TX', MigrationGPVendor.STATE, 'STATE of Vendor is wrong');
        Assert.AreEqual('', MigrationGPVendor.INET1, 'INET1 of Vendor is wrong');
        Assert.AreEqual(' ', MigrationGPVendor.INET2, 'INET2 of Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', MigrationGPVendor.TAXSCHID, 'TAXSCHID of Vendor is wrong');
        Assert.AreEqual('T3', MigrationGPVendor.UPSZONE, 'UPSZONE of Vendor is wrong');
        Assert.AreEqual('45-0029728', MigrationGPVendor.TXIDNMBR, 'TXIDNMBR of Vendor is wrong');


        // [WHEN] data is migrated
        Vendor.DeleteAll();
        MigrationGPVendor.Reset();
        MigrateVendors(MigrationGPVendor);

        // [then] Then the correct number of Vendors are applied
        Assert.AreEqual(52, Vendor.Count(), 'Wrong number of Migrated Vendors read');

        // [then] Then fields for Vendors 1 are correctly applied
        Vendor.SetRange("No.", '1160');
        Vendor.FindFirst();

        CompanyInformation.Get();
        Country := CompanyInformation."Country/Region Code";

        Assert.AreEqual('Risco, Inc.', Vendor.Name, 'Name of Migrated Vendor is wrong');
        Assert.AreEqual('Risco, Inc.', Vendor."Name 2", 'Name 2 of Migrated Vendor is wrong');
        Assert.AreEqual('Roger', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('RISCO, INC.', Vendor."Search Name", 'Search Name of Migrated Vendor is wrong');
        Assert.AreEqual('2344 Brookings St', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('Suite 234', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Fort Worth', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('50482743320000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('50482743400000', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');
        // Assert.AreEqual('76101',Vendor."Post Code",'Post Code of Migrated Vendor is wrong');
        Assert.AreEqual(Country, Vendor."Country/Region Code", 'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('UPS BLUE', Vendor."Shipment Method Code", 'Shipment Method Code of Migrated Vendor is wrong');
        Assert.AreEqual('3% 15TH/NE', Vendor."Payment Terms Code", 'Payment Terms Code of Migrated Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', Vendor."Tax Area Code", 'Tax Area Code of Migrated Vendor is wrong');
        Assert.AreEqual(true, Vendor."Tax Liable", 'Tax Liable of Migrated Vendor is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImportWhenNoneExistOnGP()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] All accounts are queried from GP where no accounts actually exist

        // [GIVEN] Default GPSetup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationGPVendor.Init();

        // [WHEN] reading an empty response file
        // [THEN] there should be no data to migrate        
        Assert.IsFalse(GetDataFromFile('Vendor', GetGetAllEmptyResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImportWhenBadResponseFromGP()
    var
        JArray: JsonArray;
    begin
        // [SCENARIO] Querying for GP accounts leads to a bad response which is handled gracefully.

        // [GIVEN] A default GP Setup
        // [WHEN] The codeunit is initialized
        Initialize();
        MigrationGPVendor.Init();

        // [WHEN] reading a bad response file
        // [THEN] there should be no data to migrate
        Assert.IsFalse(GetDataFromFile('Vendor', GetGetAllBadResponse(), JArray), JsonErr);
        Assert.IsTrue(JArray.Count() = 0, JsonErr);
    end;

    local procedure GetInetroot(): Text[170]
    begin
        exit(ApplicationPath() + '\..\..\');
        //exit('D:\Git\Nav');
    end;

    local procedure GetGetAllEmptyResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\GetAllEmptyResponse.txt');
    end;

    local procedure GetGetAllBadResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\GetAllBadResponse.txt');
    end;

    local procedure GetGetAllCustomersResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\GetAllCustomersResponse.txt');
    end;

    local procedure GetGetAllVendorsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\GetAllVendorsResponse.txt');
    end;

    [Normal]
    local procedure Initialize()
    begin
        if not BindSubscription(MSGPDataMigrationTests) then
            exit;

        MigrationGPCustomer.DeleteAll();
        MigrationGPVendor.DeleteAll();

        if UnbindSubscription(MSGPDataMigrationTests) then
            exit;
    end;

    local procedure GetDataFromFile(EntityName: Text; TestDataFile: Text; var JArray: JsonArray): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(GetFileContent(GetInetroot() + TestDataFile)) then
            if JObject.SelectToken(EntityName, JToken) then
                if JToken.IsArray() then begin
                    JArray := JToken.AsArray();
                    exit(true);
                end;

        exit(false);
    end;

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

    local procedure MigrateCustomers(Customers: Record "MigrationGP Customer")
    begin
        //if SetupAccounts() then
        if Customers.FindSet() then
            repeat
                CustomerMigrator.OnMigrateCustomer(CustomerFacade, Customers.RecordId());
            //CustomerMigrator.OnMigrateCustomerPostingGroups(CustomerFacade, Customers.RecordId(), true);
            until Customers.Next() = 0;
    end;

    local procedure MigrateVendors(Vendors: Record "MigrationGP Vendor")
    begin
        //if SetupAccounts() then
        if Vendors.FindSet() then
            repeat
                VendorMigrator.OnMigrateVendor(VendorFacade, Vendors.RecordId());
            //VendorMigrator.OnMigrateVendorPostingGroups(VendorFacade, Vendors.RecordId(), true);
            until Vendors.Next() = 0;
    end;

}


