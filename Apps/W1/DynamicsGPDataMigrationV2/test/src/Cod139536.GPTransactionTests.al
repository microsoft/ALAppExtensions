codeunit 139536 "MigrationGP Transaction Tests"
{
    // version Test,W1,US,CA,GB

    // // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CustomerTrans: Record "MigrationGP CustomerTrans";
        CustomerMigrator: Codeunit "MigrationGP Customer Migrator";
        VendorMigrator: Codeunit "MigrationGP Vendor Migrator";
        Assert: Codeunit Assert;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCustomerTrxImport()
    var
        CustomerTrans: Record "MigrationGP CustomerTrans";
        Customer: Record "Customer";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Customers are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('RMTrx', GetGetAllCustomersTrxResponse(), JArray);

        // [WHEN] Data is imported
        CustomerMigrator.PopulateRMTRxStagingTable(JArray);

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(7, CustomerTrans.Count(), 'Wrong number of Customers read');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        CustomerTrans.SetRange(Id, '1');
        CustomerTrans.FindFirst();
        Assert.AreEqual('!WOW!', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('1', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('FIV3-04', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('01/15/99', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('02/15/99', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('65.07', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('KNOBL-CHUCK-001', CustomerTrans.SLPRSNID, 'Wrong Saleperson Id');
        Assert.AreEqual('1', CustomerTrans.Id, 'Wrong Id');
        Assert.AreEqual('C00001', CustomerTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Invoice', Format(CustomerTrans.TransType), 'Wrong TransType');

        CustomerTrans.SetRange(Id, '5');
        CustomerTrans.FindFirst();
        Assert.AreEqual('3M', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('7', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('CRDIT0011', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('04/15/99', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('25.55', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('5', CustomerTrans.Id, 'Wrong Id');
        Assert.AreEqual('C00005', CustomerTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Credit Memo', Format(CustomerTrans.TransType), 'Wrong TransType');

        CustomerTrans.SetRange(Id, '6');
        CustomerTrans.FindFirst();
        Assert.AreEqual('3M', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('8', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('RETRN0019', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('12/12/98', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('70.14', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('HRBEK-KENT-001', CustomerTrans.SLPRSNID, 'Wrong Salesperson Id');
        Assert.AreEqual('6', CustomerTrans.Id, 'Wrong Id');
        Assert.AreEqual('C00006', CustomerTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Credit Memo', Format(CustomerTrans.TransType), 'Wrong TransType');

        CustomerTrans.SetRange(Id, '7');
        CustomerTrans.FindFirst();
        Assert.AreEqual('$MILLION', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('9', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('PYMNT0006', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('05/15/99', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('66.6', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('7', CustomerTrans.Id, 'Wrong Id');
        Assert.AreEqual('C00007', CustomerTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Payment', Format(CustomerTrans.TransType), 'Wrong TransType');

        // [WHEN] data is migrated
        Customer.DeleteAll();
        // MigrationQBCustomer.Reset();
        //MigrateCustomers(MigrationQBCustomer);

        // [then] Then the correct number of Customers are applied
        // Assert.AreEqual(29,Customer.Count(),'Wrong number of Migrated Customers read');

        // [then] Then fields for Customer 1 are correctly applied
        // Customer.SetRange("No.",'1');
        // Customer.FindFirst();
        // Assert.AreEqual('Amy''s Bird Sanctuary',Customer.Name,'Name of Migrated Customer is wrong');
        // Assert.AreEqual('Amy Lauterbach',Customer.Contact,'Contact Name of Migrated Customer is wrong');
        // Assert.AreEqual('AMY''S BIRD SANCTUARY',Customer."Search Name",'Search Name of Migrated Customer is wrong');
        // Assert.AreEqual('4581 Finch St.',Customer.Address,'Address of Migrated Customer is wrong');
        // Assert.AreEqual('Apt. 2',Customer."Address 2",'Address2 of Migrated Customer is wrong');
        // Assert.AreEqual('Bayshore',Customer.City,'City of Migrated Customer is wrong');
        // Assert.AreEqual('(650) 555-3311',Customer."Phone No.",'Phone No. of Migrated Customer is wrong');
        // Assert.AreEqual('(701) 444-8585',Customer."Fax No.",'Fax No. of Migrated Customer is wrong');
        // Assert.AreEqual('94326',Customer."Post Code",'Post Code of Migrated Customer is wrong');
        // // Assert.AreEqual('USA',Customer."Country/Region Code",'Country/Region of Migrated Customer is wrong');
        // Assert.AreEqual('CA',Customer.County,'County of Migrated Customer is wrong');
        // Assert.AreEqual('Birds@Intuit.com',Customer."E-Mail",'E-Mail of Migrated Customer is wrong');
        // Assert.AreEqual('http://crazybirds.com',Customer."Home Page",'Home Page of Migrated Customer is wrong');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPVendorTrxImport()
    var
        VendorTrans: Record "MigrationGP VendorTrans";
        Vendor: Record "Vendor";
        JArray: JsonArray;
    begin
        // [SCENARIO] All Customers are queried from QBO

        // [GIVEN] QBO data
        Initialize();
        GetDataFromFile('PMTrx', GetGetAllVendorsTrxResponse(), JArray);

        // [WHEN] Data is imported
        VendorMigrator.PopulateStagingTable(JArray);

        // [then] Then the correct number of Customers are imported
        Assert.AreEqual(6, VendorTrans.Count(), 'Wrong number of Customers read');

        // [then] Then fields for Customer 1 are correctly imported to temporary table
        VendorTrans.SetRange(Id, '1');
        VendorTrans.FindFirst();
        Assert.AreEqual('&2010', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('1', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1002', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('09/01/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('10/15/99', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('25.42', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('1', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00001', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Invoice', Format(VendorTrans.TransType), 'Wrong TransType');

        VendorTrans.SetRange(Id, '2');
        VendorTrans.FindFirst();
        Assert.AreEqual('C1161', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('2', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1018', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('10/02/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('10/02/99', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('10.02', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('2', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00002', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Invoice', Format(VendorTrans.TransType), 'Wrong TransType');

        VendorTrans.SetRange(Id, '3');
        VendorTrans.FindFirst();
        Assert.AreEqual('1122', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('3', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1021', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('11/05/98', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('12/05/98', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('11.77', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('3', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00003', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Invoice', Format(VendorTrans.TransType), 'Wrong TransType');

        VendorTrans.SetRange(Id, '4');
        VendorTrans.FindFirst();
        Assert.AreEqual('1122', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('4', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1032', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('03/06/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('16.22', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('4', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00004', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Credit Memo', Format(VendorTrans.TransType), 'Wrong TransType');


        VendorTrans.SetRange(Id, '5');
        VendorTrans.FindFirst();
        Assert.AreEqual('9999', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('5', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1016', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('06/15/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('16.15', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('5', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00005', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Credit Memo', Format(VendorTrans.TransType), 'Wrong TransType');


        VendorTrans.SetRange(Id, '6');
        VendorTrans.FindFirst();
        Assert.AreEqual('10(61)', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('6', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('CM000000000000002', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('09/13/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('35', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('6', VendorTrans.Id, 'Wrong Id');
        Assert.AreEqual('V00006', VendorTrans.GLDocNo, 'Wrong GL No.');
        Assert.AreEqual('Payment', Format(VendorTrans.TransType), 'Wrong TransType');

        // [WHEN] data is migrated
        Vendor.DeleteAll();
        // MigrationQBCustomer.Reset();
        //MigrateCustomers(MigrationQBCustomer);

        // [then] Then the correct number of Customers are applied
        // Assert.AreEqual(29,Customer.Count(),'Wrong number of Migrated Customers read');

        // [then] Then fields for Customer 1 are correctly applied
        // Customer.SetRange("No.",'1');
        // Customer.FindFirst();
        // Assert.AreEqual('Amy''s Bird Sanctuary',Customer.Name,'Name of Migrated Customer is wrong');
        // Assert.AreEqual('Amy Lauterbach',Customer.Contact,'Contact Name of Migrated Customer is wrong');
        // Assert.AreEqual('AMY''S BIRD SANCTUARY',Customer."Search Name",'Search Name of Migrated Customer is wrong');
        // Assert.AreEqual('4581 Finch St.',Customer.Address,'Address of Migrated Customer is wrong');
        // Assert.AreEqual('Apt. 2',Customer."Address 2",'Address2 of Migrated Customer is wrong');
        // Assert.AreEqual('Bayshore',Customer.City,'City of Migrated Customer is wrong');
        // Assert.AreEqual('(650) 555-3311',Customer."Phone No.",'Phone No. of Migrated Customer is wrong');
        // Assert.AreEqual('(701) 444-8585',Customer."Fax No.",'Fax No. of Migrated Customer is wrong');
        // Assert.AreEqual('94326',Customer."Post Code",'Post Code of Migrated Customer is wrong');
        // // Assert.AreEqual('USA',Customer."Country/Region Code",'Country/Region of Migrated Customer is wrong');
        // Assert.AreEqual('CA',Customer.County,'County of Migrated Customer is wrong');
        // Assert.AreEqual('Birds@Intuit.com',Customer."E-Mail",'E-Mail of Migrated Customer is wrong');
        // Assert.AreEqual('http://crazybirds.com',Customer."Home Page",'Home Page of Migrated Customer is wrong');
    end;

    local procedure GetInetroot(): Text[170]
    begin
        exit(ApplicationPath() + '\..\..\');
        //exit('D:\Depot\Nav');
    end;

    local procedure GetGetAllCustomersTrxResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\RMTrx.txt');
    end;

    local procedure GetGetAllVendorsTrxResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\PMTrx.txt');
    end;


    [Normal]
    local procedure Initialize()
    begin
        CustomerTrans.DeleteAll();
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
        PAGE.Run(PAGE::"Data Migration Wizard");

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
        DataMigrators.GOTOKEY(codeunit::"MS - QBO Data Migrator");
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

    // local procedure SetupAccounts(): Boolean
    // var
    //     JToken: JsonToken;
    // begin
    //     if GetDataFromFile('Account', GetGetAllAccountsResponse(), JToken) then begin
    //         AccountMigrator.PopulateStagingTable(JToken);
    //         MigrateAccounts(MigrationQBAccount);
    //         exit(true);
    //     end;
    //     exit(false);
    // end;

    // local procedure MigrateCustomers(Customers: Record "MigrationQB Customer")
    // begin
    //     if SetupAccounts() then
    //         if Customers.FindSet() then
    //             repeat
    //                 CustomerMigrator.OnMigrateCustomer(CustomerFacade, Customers.RecordId());
    //                 CustomerMigrator.OnMigrateCustomerPostingGroups(CustomerFacade, Customers.RecordId(), true);
    //             until Customers.Next() = 0;        
    // end;    

    // local procedure MigrateVendors(Vendors: Record "MigrationQB Vendor")
    // begin
    //     if SetupAccounts() then
    //         if Vendors.FindSet() then
    //             repeat
    //                 VendorMigrator.OnMigrateVendor(VendorFacade, Vendors.RecordId());
    //                 VendorMigrator.OnMigrateVendorPostingGroups(VendorFacade, Vendors.RecordId(), true);
    //             until Vendors.Next() = 0;        
    // end; 



    // local procedure SetPostingAccounts()
    // var
    //     AccountNumber: Code[20];
    // begin
    //     MigrationQBAccountSetup.DeleteAll();
    //     AccountNumber := '1';
    //     MigrationQBAccountSetup.Init();
    //     MigrationQBAccountSetup.SalesAccount := AccountNumber;
    //     MigrationQBAccountSetup.SalesCreditMemoAccount := AccountNumber;
    //     MigrationQBAccountSetup.SalesLineDiscAccount := AccountNumber;
    //     MigrationQBAccountSetup.SalesInvDiscAccount := AccountNumber;
    //     MigrationQBAccountSetup.PurchAccount := AccountNumber;
    //     MigrationQBAccountSetup.PurchCreditMemoAccount := AccountNumber;
    //     MigrationQBAccountSetup.PurchInvDiscAccount := AccountNumber;
    //     MigrationQBAccountSetup.COGSAccount := AccountNumber;
    //     MigrationQBAccountSetup.InventoryAdjmtAccount := AccountNumber;
    //     MigrationQBAccountSetup.InventoryAccount := AccountNumber;
    //     MigrationQBAccountSetup.ReceivablesAccount := AccountNumber;
    //     MigrationQBAccountSetup.ServiceChargeAccount := AccountNumber;
    //     MigrationQBAccountSetup.PayablesAccount := AccountNumber;
    //     MigrationQBAccountSetup.PurchServiceChargeAccount := AccountNumber;
    //     MigrationQBAccountSetup.Insert();
    // end;
}


