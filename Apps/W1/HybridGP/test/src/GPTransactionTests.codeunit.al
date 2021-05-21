codeunit 139663 "GP Transaction Tests"
{
    // version Test,W1,US,CA,GB

    // // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CustomerTrans: Record "GP Customer Transactions";
        Assert: Codeunit Assert;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCustomerTrxImport()
    var
        Customer: Record "Customer";
    begin
        // [SCENARIO] All Customers are queried from QBO

        // [GIVEN] QBO data
        Initialize();

        // [WHEN] Data is imported
        CreateCustomerTrxData();

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

        CustomerTrans.SetRange(Id, '5');
        CustomerTrans.FindFirst();
        Assert.AreEqual('3M', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('7', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('CRDIT0011', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('04/15/99', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('25.55', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('5', CustomerTrans.Id, 'Wrong Id');

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

        CustomerTrans.SetRange(Id, '7');
        CustomerTrans.FindFirst();
        Assert.AreEqual('$MILLION', CustomerTrans.CUSTNMBR, 'Wrong Customer Number');
        Assert.AreEqual('9', Format(CustomerTrans.RMDTYPAL), 'Wrong RMDTYPAL value');
        Assert.AreEqual('PYMNT0006', CustomerTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('05/15/99', Format(CustomerTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(CustomerTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('66.6', Format(CustomerTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('7', CustomerTrans.Id, 'Wrong Id');

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
        VendorTrans: Record "GP Vendor Transactions";
        Vendor: Record "Vendor";
    begin
        // [SCENARIO] All Customers are queried from QBO

        // [GIVEN] QBO data
        Initialize();

        // [WHEN] Data is imported
        CreateVendorTrxData();

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

        VendorTrans.SetRange(Id, '2');
        VendorTrans.FindFirst();
        Assert.AreEqual('C1161', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('2', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1018', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('10/02/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('10/02/99', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('10.02', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('2', VendorTrans.Id, 'Wrong Id');

        VendorTrans.SetRange(Id, '3');
        VendorTrans.FindFirst();
        Assert.AreEqual('1122', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('3', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1021', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('11/05/98', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('12/05/98', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('11.77', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('3', VendorTrans.Id, 'Wrong Id');

        VendorTrans.SetRange(Id, '4');
        VendorTrans.FindFirst();
        Assert.AreEqual('1122', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('4', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1032', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('03/06/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('16.22', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('4', VendorTrans.Id, 'Wrong Id');

        VendorTrans.SetRange(Id, '5');
        VendorTrans.FindFirst();
        Assert.AreEqual('9999', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('5', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('1016', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('06/15/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('16.15', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('5', VendorTrans.Id, 'Wrong Id');

        VendorTrans.SetRange(Id, '6');
        VendorTrans.FindFirst();
        Assert.AreEqual('10(61)', VendorTrans.VENDORID, 'Wrong Vendor Id');
        Assert.AreEqual('6', Format(VendorTrans.DOCTYPE), 'Wrong DOCTYPE value');
        Assert.AreEqual('CM000000000000002', VendorTrans.DOCNUMBR, 'Wrong Document Number');
        Assert.AreEqual('09/13/99', Format(VendorTrans.DOCDATE), 'Wrong Document Date');
        Assert.AreEqual('', Format(VendorTrans.DUEDATE), 'Wrong Due Date');
        Assert.AreEqual('35', Format(VendorTrans.CURTRXAM), 'Wrong Current Trx Amount');
        Assert.AreEqual('6', VendorTrans.Id, 'Wrong Id');

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

    [Normal]
    local procedure Initialize()
    begin
        CustomerTrans.DeleteAll();
    end;

    local procedure CreateCustomerTrxData()
    var
        GPCustomerTrx: Record "GP Customer Transactions";
    begin
        GPCustomerTrx.DeleteAll();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '!WOW!';
        GPCustomerTrx.RMDTYPAL := 1;
        GPCustomerTrx.DOCNUMBR := 'FIV3-04';
        GPCustomerTrx.DOCDATE := 19990115D;
        GPCustomerTrx.DUEDATE := 19990215D;
        GPCustomerTrx.CURTRXAM := 65.07000;
        GPCustomerTrx.SLPRSNID := 'KNOBL-CHUCK-001';
        GPCustomerTrx.Id := '1';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '#1';
        GPCustomerTrx.RMDTYPAL := 3;
        GPCustomerTrx.DOCNUMBR := 'DEBIT0004';
        GPCustomerTrx.DOCDATE := 19981205D;
        GPCustomerTrx.DUEDATE := 19990131D;
        GPCustomerTrx.CURTRXAM := 50.00000;
        GPCustomerTrx.SLPRSNID := '';
        GPCustomerTrx.Id := '2';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '!WOW!';
        GPCustomerTrx.RMDTYPAL := 4;
        GPCustomerTrx.DOCNUMBR := 'FINCH0004';
        GPCustomerTrx.DOCDATE := 19990601D;
        GPCustomerTrx.DUEDATE := 19990601D;
        GPCustomerTrx.CURTRXAM := 2.50000;
        GPCustomerTrx.SLPRSNID := '';
        GPCustomerTrx.Id := '3';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := 'DEF';
        GPCustomerTrx.RMDTYPAL := 5;
        GPCustomerTrx.DOCNUMBR := 'SRVCE0005';
        GPCustomerTrx.DOCDATE := 19990901D;
        GPCustomerTrx.DUEDATE := 19991001D;
        GPCustomerTrx.CURTRXAM := 15.00000;
        GPCustomerTrx.SLPRSNID := 'SMITH-JOHN-001';
        GPCustomerTrx.Id := '4';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '3M';
        GPCustomerTrx.RMDTYPAL := 7;
        GPCustomerTrx.DOCNUMBR := 'CRDIT0011';
        GPCustomerTrx.DOCDATE := 19990415D;
        GPCustomerTrx.CURTRXAM := 25.55000;
        GPCustomerTrx.SLPRSNID := '';
        GPCustomerTrx.Id := '5';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '3M';
        GPCustomerTrx.RMDTYPAL := 8;
        GPCustomerTrx.DOCNUMBR := 'RETRN0019';
        GPCustomerTrx.DOCDATE := 19981212D;
        GPCustomerTrx.CURTRXAM := 70.14000;
        GPCustomerTrx.SLPRSNID := 'HRBEK-KENT-001';
        GPCustomerTrx.Id := '6';
        GPCustomerTrx.Insert();

        GPCustomerTrx.Init();
        GPCustomerTrx.CUSTNMBR := '$MILLION';
        GPCustomerTrx.RMDTYPAL := 9;
        GPCustomerTrx.DOCNUMBR := 'PYMNT0006';
        GPCustomerTrx.DOCDATE := 19990515D;
        GPCustomerTrx.CURTRXAM := 66.60000;
        GPCustomerTrx.SLPRSNID := '';
        GPCustomerTrx.Id := '7';
        GPCustomerTrx.Insert();
    end;

    local procedure CreateVendorTrxData()
    var
        GPVendorTrx: Record "GP Vendor Transactions";
    begin
        GPVendorTrx.DeleteAll();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := '&2010';
        GPVendorTrx.DOCTYPE := 1;
        GPVendorTrx.DOCNUMBR := '1002';
        GPVendorTrx.DOCDATE := 19990901D;
        GPVendorTrx.DUEDATE := 19991015D;
        GPVendorTrx.CURTRXAM := 25.42000;
        GPVendorTrx.Id := '1';
        GPVendorTrx.Insert();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := 'C1161';
        GPVendorTrx.DOCTYPE := 2;
        GPVendorTrx.DOCNUMBR := '1018';
        GPVendorTrx.DOCDATE := 19991002D;
        GPVendorTrx.DUEDATE := 19991002D;
        GPVendorTrx.CURTRXAM := 10.02000;
        GPVendorTrx.Id := '2';
        GPVendorTrx.Insert();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := '1122';
        GPVendorTrx.DOCTYPE := 3;
        GPVendorTrx.DOCNUMBR := '1021';
        GPVendorTrx.DOCDATE := 19981105D;
        GPVendorTrx.DUEDATE := 19981205D;
        GPVendorTrx.CURTRXAM := 11.77000;
        GPVendorTrx.Id := '3';
        GPVendorTrx.Insert();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := '1122';
        GPVendorTrx.DOCTYPE := 4;
        GPVendorTrx.DOCNUMBR := '1032';
        GPVendorTrx.DOCDATE := 19990306D;
        GPVendorTrx.CURTRXAM := 16.22000;
        GPVendorTrx.Id := '4';
        GPVendorTrx.Insert();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := '9999';
        GPVendorTrx.DOCTYPE := 5;
        GPVendorTrx.DOCNUMBR := '1016';
        GPVendorTrx.DOCDATE := 19990615D;
        GPVendorTrx.CURTRXAM := 16.15000;
        GPVendorTrx.Id := '5';
        GPVendorTrx.Insert();

        GPVendorTrx.Init();
        GPVendorTrx.VENDORID := '10(61)';
        GPVendorTrx.DOCTYPE := 6;
        GPVendorTrx.DOCNUMBR := 'CM000000000000002';
        GPVendorTrx.DOCDATE := 19990913D;
        GPVendorTrx.CURTRXAM := 35.00000;
        GPVendorTrx.Id := '6';
        GPVendorTrx.Insert();

    end;
}


