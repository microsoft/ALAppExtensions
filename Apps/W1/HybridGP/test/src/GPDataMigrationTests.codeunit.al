codeunit 139664 "GP Data Migration Tests"
{
    // version Test,W1,US,CA,GB

    // // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GPCustomer: Record "GP Customer";
        GPVendor: Record "GP Vendor";
        GPVendorAddress: Record "GP Vendor Address";
        CustomerFacade: Codeunit "Customer Data Migration Facade";
        CustomerMigrator: Codeunit "GP Customer Migrator";
        VendorMigrator: Codeunit "GP Vendor Migrator";
        VendorFacade: Codeunit "Vendor Data Migration Facade";
        Assert: Codeunit Assert;
        GPDataMigrationTests: Codeunit "GP Data Migration Tests";


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCustomerImport()
    var
        Customer: Record "Customer";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        CustomerCount: Integer;
    begin
        // [SCENARIO] All Customers are queried from GP

        // [GIVEN] GP data
        Initialize();

        // When adding Customers, update the expected count here
        CustomerCount := 3;

        GenBusPostingGroup.Init();
        GenBusPostingGroup.Validate(GenBusPostingGroup.Code, 'GP');
        GenBusPostingGroup.Insert(true);

        // [WHEN] Data is imported
        CreateCustomerData();

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
        Assert.AreEqual('USA', Customer."Country/Region Code", 'Country/Region of Migrated Customer is wrong');
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
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPVendorImport()
    var
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        OrderAddress: Record "Order Address";
        Country: Code[10];
        VendorCount: Integer;
    begin
        // [SCENARIO] All Vendor are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported
        CreateVendorData();

        // When adding Vendors, update the expected count here
        VendorCount := 54;

        // [then] Then the correct number of Vendors are imported
        Assert.AreEqual(VendorCount, GPVendor.Count(), 'Wrong number of Vendor read');

        // [then] Then fields for Vendor 1 are correctly imported to temporary table
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

        // [then] Then the correct number of Vendors are applied
        Assert.AreEqual(VendorCount, Vendor.Count(), 'Wrong number of Migrated Vendors read');

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
        Assert.AreEqual(Country, Vendor."Country/Region Code", 'Country/Region of Migrated Vendor is wrong');
        Assert.AreEqual('UPS BLUE', Vendor."Shipment Method Code", 'Shipment Method Code of Migrated Vendor is wrong');
        Assert.AreEqual('3% 15TH/NE', Vendor."Payment Terms Code", 'Payment Terms Code of Migrated Vendor is wrong');
        Assert.AreEqual('P-N-TXB-%P*6', Vendor."Tax Area Code", 'Tax Area Code of Migrated Vendor is wrong');
        Assert.AreEqual(true, Vendor."Tax Liable", 'Tax Liable of Migrated Vendor is wrong');

        // [WHEN] the Remit To address differs from the originally selected main address
        Vendor.Reset();
        Vendor.SetRange("No.", 'ACETRAVE0001');
        Vendor.FindFirst();

        // [then] The Remit To address will have overridden the main address
        Assert.AreEqual('A Travel Company', Vendor.Name, 'Name of Migrated Vendor is wrong');
        Assert.AreEqual('Greg Powell', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('Box 342', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Sydney', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('29855501020000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('29455501020000', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');

        // [WHEN] the Vendor does not have a Remit To address
        Vendor.Reset();
        Vendor.SetRange("No.", 'V3130');
        Vendor.FindFirst();

        // [then] The originally selected main address stays the same
        Assert.AreEqual('Lmd Telecom, Inc.', Vendor.Name, 'Name of Migrated Vendor is wrong');
        Assert.AreEqual('', Vendor.Contact, 'Contact Name of Migrated Vendor is wrong');
        Assert.AreEqual('P.O. Box10158', Vendor.Address, 'Address of Migrated Vendor is wrong');
        Assert.AreEqual('2201a Jacsboro Highway', Vendor."Address 2", 'Address2 of Migrated Vendor is wrong');
        Assert.AreEqual('Fort Worth', Vendor.City, 'City of Migrated Vendor is wrong');
        Assert.AreEqual('41327348230000', Vendor."Phone No.", 'Phone No. of Migrated Vendor is wrong');
        Assert.AreEqual('41327348300000', Vendor."Fax No.", 'Fax No. of Migrated Vendor is wrong');

        // [WHEN] the Vendor phone and/or fax were default (00000000000000)
        Vendor.Reset();
        Vendor.SetRange("No.", 'ACETRAVE0002');
        Vendor.FindFirst();

        // [then] The phone and/or fax values are empty
        Assert.AreEqual('', Vendor."Phone No.", 'Phone No. of Migrated Vendor should be empty');
        Assert.AreEqual('', Vendor."Fax No.", 'Fax No. of Migrated Vendor should be empty');

        // [WHEN] the Vendor address phone and/or fax were default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'WAREHOUSE');
        OrderAddress.FindFirst();

        // [then] The phone and/or fax values are empty
        Assert.AreEqual('', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');

        // [WHEN] the Vendor address phone and/or fax were not default (00000000000000)
        OrderAddress.Reset();
        OrderAddress.SetRange("Vendor No.", 'ACETRAVE0002');
        OrderAddress.SetRange(Code, 'Primary');
        OrderAddress.FindFirst();

        // [then] The phone and/or fax values will be set to the migrated value
        Assert.AreEqual('61855501040000', OrderAddress."Phone No.", 'Phone No. of Migrated Vendor Address should be empty');
        Assert.AreEqual('61855501040000', OrderAddress."Fax No.", 'Fax No. of Migrated Vendor Address should be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPPaymentTerms()
    var
        PaymentTerms: Record "Payment Terms";
        HelperFunctions: Codeunit "Helper Functions";
        DiscountDateCalculation: DateFormula;
        DueDateCalculation: DateFormula;
        CurrentPaymentTerm: Text;
    begin
        // [SCENARIO] GP Payment Terms migrate successfully. Created due to bug 362674.
        // [GIVEN] GP Payment Terms staging table records
        Initialize();
        CreateGPPaymentTermsRecords();

        // [WHEN] The Payment Terms migration code is run.
        PaymentTerms.DeleteAll();
        HelperFunctions.CreatePaymentTerms();

        // [THEN] payment terms get created in BC.
        PaymentTerms.FindFirst();
        Assert.AreEqual(6, PaymentTerms.Count(), 'Incorrect number of Payment Terms created.');

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
    end;

    [Normal]
    local procedure Initialize()
    begin
        if not BindSubscription(GPDataMigrationTests) then
            exit;

        GPCustomer.DeleteAll();
        GPVendorAddress.DeleteAll();
        GPVendor.DeleteAll();

        if UnbindSubscription(GPDataMigrationTests) then
            exit;
    end;

    local procedure MigrateCustomers(Customers: Record "GP Customer")
    begin
        if Customers.FindSet() then
            repeat
                CustomerMigrator.OnMigrateCustomer(CustomerFacade, Customers.RecordId());
            until Customers.Next() = 0;
    end;

    local procedure MigrateVendors(Vendors: Record "GP Vendor")
    begin
        if Vendors.FindSet() then
            repeat
                VendorMigrator.OnMigrateVendor(VendorFacade, Vendors.RecordId());
            until Vendors.Next() = 0;
    end;

    local procedure CreateCustomerData()
    begin
        GPCustomer.DeleteAll();

        GPCustomer.Init();
        GPCustomer.CUSTNMBR := '!WOW!';
        GPCustomer.CUSTNAME := 'Oh! What a feeling!';
        GPCustomer.STMTNAME := 'Oh! What a feeling!';
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

        GPCustomer.Init();
        GPCustomer.CUSTNMBR := '"AMERICAN"';
        GPCustomer.CUSTNAME := '"American Clothing"';
        GPCustomer.STMTNAME := '"American Clothing"';
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

        GPCustomer.Init();
        GPCustomer.CUSTNMBR := '#1';
        GPCustomer.CUSTNAME := '#1 Company';
        GPCustomer.STMTNAME := '#1 Company';
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
    end;

    local procedure CreateVendorData()
    begin
        GPVendor.DeleteAll();
        GPVendorAddress.DeleteAll();

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
        GPVendor.VENDORID := '3070';
        GPVendor.VENDNAME := 'L.M. Berry & co. -NYPS';
        GPVendor.SEARCHNAME := 'L.M. Berry & co. -NYPS';
        GPVendor.VNDCHKNM := 'L.M. Berry & co. -NYPS';
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendorAddress.Init();
        GPVendorAddress.VENDORID := 'ACETRAVE0001';
        GPVendorAddress.ADRSCODE := 'PRIMARY';
        GPVendorAddress.VNDCNTCT := 'Greg Powell';
        GPVendorAddress.ADDRESS1 := '123 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '29855501010000';
        GPVendorAddress.FAXNUMBR := '29455501010000';
        GPVendorAddress.Insert();

        GPVendorAddress.Init();
        GPVendorAddress.VENDORID := 'ACETRAVE0001';
        GPVendorAddress.ADRSCODE := 'REMIT TO';
        GPVendorAddress.VNDCNTCT := 'Greg Powell';
        GPVendorAddress.ADDRESS1 := 'Box 342';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2000';
        GPVendorAddress.PHNUMBR1 := '29855501020000';
        GPVendorAddress.FAXNUMBR := '29455501020000';
        GPVendorAddress.Insert();

        GPVendor.Init();
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

        GPVendorAddress.Init();
        GPVendorAddress.VENDORID := 'ACETRAVE0002';
        GPVendorAddress.ADRSCODE := 'PRIMARY';
        GPVendorAddress.VNDCNTCT := 'Greg Powell Jr.';
        GPVendorAddress.ADDRESS1 := '124 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '61855501040000';
        GPVendorAddress.FAXNUMBR := '61855501040000';
        GPVendorAddress.Insert();

        GPVendorAddress.Init();
        GPVendorAddress.VENDORID := 'ACETRAVE0002';
        GPVendorAddress.ADRSCODE := 'WAREHOUSE';
        GPVendorAddress.VNDCNTCT := 'Greg Powell Jr.';
        GPVendorAddress.ADDRESS1 := '124 Riley Street';
        GPVendorAddress.ADDRESS2 := '';
        GPVendorAddress.CITY := 'Sydney';
        GPVendorAddress.STATE := 'NSW';
        GPVendorAddress.ZIPCODE := '2086';
        GPVendorAddress.PHNUMBR1 := '00000000000000';
        GPVendorAddress.FAXNUMBR := '00000000000000';
        GPVendorAddress.Insert();

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendor.Init();
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

        GPVendorAddress.Init();
        GPVendorAddress.VENDORID := 'V3130';
        GPVendorAddress.ADRSCODE := 'PRIMARY';
        GPVendorAddress.VNDCNTCT := 'Test Contact';
        GPVendorAddress.ADDRESS1 := 'P.O. Box10159';
        GPVendorAddress.ADDRESS2 := '2201a Jacsboro Highway 2';
        GPVendorAddress.CITY := 'Fort Worth';
        GPVendorAddress.STATE := 'TX';
        GPVendorAddress.ZIPCODE := '76114';
        GPVendorAddress.PHNUMBR1 := '41327348230000';
        GPVendorAddress.FAXNUMBR := '41327348300000';
        GPVendorAddress.Insert();
    end;
}