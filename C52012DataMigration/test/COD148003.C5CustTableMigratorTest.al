// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148003 "C5 CustTable Migrator Tst"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        CustPriceGroupTxt: Label 'PriceGr', Locked = true;
        PaymentTxt: Label 'Payment', Locked = true;
        SalesPersonTxt: Label 'Saleser', Locked = true;
        DeliveryTxt: Label 'Deliver', Locked = true;
        DiscGroupTxt: Label 'DiscGroup', Locked = true;
        ProcCodeTxt: Label 'ProcCody', Locked = true;
        CustNumTxt: Label 'MYC5CUST', Locked = true;
        AltCustNumTxt: Label 'MYC5Cust2', Locked = true;
        DepartmentTxt: Label 'SALESX';
        CostCenterTxt: Label 'CostCntX';
        PurposeTxt: Label 'PurposeX';
        Department2Txt: Label 'SALESY';
        CostCenter2Txt: Label 'CostCntY';
        Purpose2Txt: Label 'PurposeY';

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    local procedure Initialize()
    var
        C5CustTable: Record "C5 CustTable";
        C5CustTrans: Record "C5 CustTrans";
        C5Payment: Record "C5 Payment";
        C5InventoryPriceGroup: Record "C5 InvenPriceGroup";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5CustDiscGroup: Record "C5 CustDiscGroup";
        C5ProcCode: Record "C5 ProcCode";
        C5CustContact: Record "C5 CustContact";
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        MarketingSetup: Record "Marketing Setup";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CustomerDiscountGroup: Record "Customer Discount Group";
        PaymentMethod: Record "Payment Method";
        GenJournalLine: Record "Gen. Journal Line";
        CountryRegion: Record "Country/Region";
        NoSeries: Record "No. Series";
        NoSeriesLines: Record "No. Series Line";
    begin
        Customer.DeleteAll();
        C5CustTable.DeleteAll();
        C5InventoryPriceGroup.DeleteAll();
        C5Employee.DeleteAll();
        C5Payment.DeleteAll();
        C5Delivery.DeleteAll();
        C5CustDiscGroup.DeleteAll();
        C5ProcCode.DeleteAll();
        C5CustContact.DeleteAll();
        CustomerPriceGroup.DeleteAll();
        PaymentTerms.DeleteAll();
        ShipmentMethod.DeleteAll();
        SalespersonPurchaser.DeleteAll();
        CustomerDiscountGroup.DeleteAll();
        PaymentMethod.DeleteAll();
        GenJournalLine.DeleteAll();
        CountryRegion.DeleteAll();
        NoSeries.DeleteAll();
        NoSeriesLines.DeleteAll();
        C5CustTrans.DeleteAll();

        CountryRegion.Init();
        CountryRegion.Validate(Code, 'AT');
        CountryRegion.Validate(Name, 'Austria');
        CountryRegion.Insert();

        NoSeries.Init();
        NoSeries.Code := 'G000CONT';
        NoSeries."Default Nos." := true;
        NoSeries.Insert();

        NoSeriesLines.Init();
        NoSeriesLines."Series Code" := 'G000CONT';
        NoSeriesLines."Starting Date" := WorkDate();
        NoSeriesLines."Starting No." := '8000';
        NoSeriesLines."Ending No." := '9500';
        NoSeriesLines.Insert();

        NoSeries.Init();
        NoSeries.Code := 'CUST';
        NoSeries."Manual Nos." := true;
        NoSeries."Default Nos." := true;
        NoSeries.Insert();

        NoSeriesLines.Init();
        NoSeriesLines."Series Code" := 'CUST';
        NoSeriesLines."Starting Date" := WorkDate();
        NoSeriesLines."Starting No." := '8000';
        NoSeriesLines."Ending No." := '9500';
        NoSeriesLines.Insert();

        if MarketingSetup.Get() then begin
            MarketingSetup."Autosearch for Duplicates" := false;
            MarketingSetup."Bus. Rel. Code for Customers" := 'CUST';
            MarketingSetup."Contact Nos." := 'G000CONT';
            MarketingSetup.Modify();
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCustTableMigrationWithCoA()
    var
        C5CustTable1: Record "C5 CustTable";
        C5CustTable2: Record "C5 CustTable";
    begin
        // [SCENARIO] Records from the C5 staging table for customers are migrated to Nav
        Initialize();

        // [GIVEN] Some records in the staging table are already present
        FillC5StagingTables(C5CustTable1, C5CustTable2);

        // [WHEN] The migrator is run
        Migrate(C5CustTable1, true);
        Migrate(C5CustTable2, true);

        // [THEN] New records are created in the customer table
        CheckCustomerExists(C5CustTable1);
        CheckCustomerExists(C5CustTable2);

        // [THEN] The Customer posting setup has been created and general journal lines have been created
        CheckCustomerPostingSetup(C5CustTable1);
        CheckCustomerPostingSetup(C5CustTable2);

        // [THEN] related records are migrated
        CheckRelatedEntitiesMigration(C5CustTable1, C5CustTable2);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCustTableMigrationWithoutCoA()
    var
        C5CustTable1: Record "C5 CustTable";
        C5CustTable2: Record "C5 CustTable";
    begin
        // [SCENARIO] Records from the C5 staging table for customers are migrated to Nav
        Initialize();

        // [GIVEN] Some records in the staging table are already present
        FillC5StagingTables(C5CustTable1, C5CustTable2);

        // [WHEN] The migrator is run
        Migrate(C5CustTable1, false);
        Migrate(C5CustTable2, false);

        // [THEN] New records are created in the customer table
        CheckCustomerExists(C5CustTable1);
        CheckCustomerExists(C5CustTable2);

        // [THEN] The customer posting setup is empty and no general journal line has been created
        CheckCustomerPostingSetupIsEmpty(C5CustTable1);
        CheckCustomerPostingSetupIsEmpty(C5CustTable2);

        // [THEN] related records are migrated
        CheckRelatedEntitiesMigration(C5CustTable1, C5CustTable2);
    end;

    local procedure CheckRelatedEntitiesMigration(C5CustTable1: Record "C5 CustTable"; C5CustTable2: Record "C5 CustTable")
    begin
        CheckDefaultDimensionExists(C5CustTable1.Account);
        CheckDefaultDimensionExists(C5CustTable2.Account);
        CheckPaymentTermsExist();
        CheckCustomerPriceGroupExists();
        CheckSalesPersonExists();
        CheckShipmentMethodExists();
        CheckCustomerDiscountGroupExists();
        CheckPaymentMethodExists();
        CheckContacts();
    end;

    local procedure CheckContacts()
    var
        Contact: Record Contact;
    begin
        Contact.SetRange(Name, CustNumTxt);
        Contact.FindFirst();
        Assert.AreEqual(Contact.Address, '123, Hobby Street', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact."Address 2", 'DerbyShire, Area GoGoland', 'Contact address 2 was migrated incorrectly');
        Assert.AreEqual(Contact."Phone No.", '02345556262', 'Contact phone was migrated incorrectly');
        Assert.AreEqual(Contact."Post Code", 'AT-1100', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact.City, 'Wien', 'Contact city was migrated incorrectly');
        Assert.AreEqual(Contact."Country/Region Code", 'AT', 'Contact Country was migrated incorrectly');
        Assert.AreEqual(Contact."E-Mail", CustNumTxt + '@mail.com', 'Contact Email was migrated incorrectly');

        Contact.SetRange(Name, 'Secondary Contact');
        Contact.FindFirst();
        Assert.AreEqual(Contact.Address, 'Address1', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact."Address 2", 'Address2', 'Contact address 2 was migrated incorrectly');
        Assert.AreEqual(Contact."Phone No.", '12345678', 'Contact phone was migrated incorrectly');
        Assert.AreEqual(Contact."Mobile Phone No.", '12345678', 'Contact mobile was migrated incorrectly');
        Assert.AreEqual(Contact."Post Code", 'AT-1100', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact.City, 'Wien', 'Contact city was migrated incorrectly');
        Assert.AreEqual(Contact."Country/Region Code", 'AT', 'Contact Country was migrated incorrectly');
        Assert.AreEqual(Contact."E-Mail", 'second@mail.com', 'Contact email was migrated incorrectly');
    end;

    local procedure Migrate(C5CustTable: Record "C5 CustTable"; ChartOfAccountsMigrated: boolean)
    var
        C5CustTableMigrator: Codeunit "C5 CustTable Migrator";
    begin
        C5CustTableMigrator.OnMigrateCustomer(CustomerDataMigrationFacade, C5CustTable.RecordId());
        C5CustTableMigrator.OnMigrateCustomerDimensions(CustomerDataMigrationFacade, C5CustTable.RecordId());
        C5CustTableMigrator.OnMigrateCustomerPostingGroups(CustomerDataMigrationFacade, C5CustTable.RecordId(), ChartOfAccountsMigrated);
        C5CustTableMigrator.OnMigrateCustomerTransactions(CustomerDataMigrationFacade, C5CustTable.RecordId(), ChartOfAccountsMigrated);
    end;

    local procedure CreateC5CustTableRecord(Acc: Text[10]; InvAccount: Text[10]; var C5CustTable: Record "C5 CustTable")
    var
        C5CustTable2: Record "C5 CustTable";
    begin
        with C5CustTable do begin
            Init();
            if C5CustTable2.FindLast() then
                RecId := C5CustTable2.RecId + 1;
            Account := Acc;
            Name := Account;
            SearchName := Account + ' search';
            Address1 := '123, Hobby Street';
            Address2 := 'DerbyShire, Area GoGoland';
            ZipCity := 'AT-1100 Wien';
            Country := 'Austria';
            Attention := 'Tim Nut';
            Phone := '02345556262';
            CellPhone := '028352757';
            Email := Account + '@mail.com';
            Department := CopyStr(DepartmentTxt, 1, 10);
            Centre := CopyStr(CostCenterTxt, 1, 10);
            Purpose := CopyStr(PurposeTxt, 1, 10);
            SalesGroup := 'SalesGr';
            BalanceMax := 1415551;
            Group := 'CustGrp';
            PriceGroup := CopyStr(CustPriceGroupTxt, 1, 10);
            Language_ := Language_::English;
            Payment := CopyStr(PaymentTxt, 1, 10);
            SalesRep := CopyStr(SalesPersonTxt, 1, 10);
            Delivery := CopyStr(DeliveryTxt, 1, 10);
            TransportCode := 'PARAVION';
            DiscGroup := CopyStr(DiscGroupTxt, 1, 10);
            Blocked := Blocked::No;
            InvoiceAccount := CopyStr(InvAccount, 1, 10);
            PaymentMode := CopyStr(ProcCodeTxt, 1, 10);
            Fax := 'FaxeKondi';
            VatNumber := 'ATU' + Format(LibraryRandom.RandIntInRange(10000000, 99999999));
            URL := 'www.aliddr.com';
            Vat := 'VATPosting';
            Insert(true);
        end;
    end;

    local procedure CreateC5InvenPriceGroup()
    var
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
    begin
        with C5InvenPriceGroup do begin
            Init();
            Group := CopyStr(CustPriceGroupTxt, 1, 10);
            GroupName := 'My CPG Description';
            InclVat := InclVat::Yes;
            Insert(true);
        end;
    end;

    local procedure FillC5StagingTables(var C5CustTable1: Record "C5 CustTable"; var C5CustTable2: Record "C5 CustTable")
    begin
        CreateC5InvenPriceGroup();
        CreateC5Payment();
        CreateC5Employee();
        CreateC5Delivery();
        CreateC5CustDiscGroup();
        CreateC5ProcCode();
        CreateC5CustTableRecord(CopyStr(CustNumTxt, 1, 10), '', C5CustTable1);
        CreateC5CustTableRecord(CopyStr(AltCustNumTxt, 1, 10), CopyStr(CustNumTxt, 1, 10), C5CustTable2);
        CreateC5CustGroup();
        CreateC5CustTrans();
        CreateC5CustContact();
    end;

    local procedure CheckCustomerPriceGroupExists()
    var
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        CustomerPriceGroup.SetRange(Code, CustPriceGroupTxt);
        CustomerPriceGroup.SetRange(Description, 'My CPG Description');
        CustomerPriceGroup.SetRange("Price Includes VAT", true);
        CustomerPriceGroup.FindFirst();
    end;

    local procedure CreateC5Payment()
    var
        C5Payment: Record "C5 Payment";
    begin
        with C5Payment do begin
            Init();
            Payment := CopyStr(PaymentTxt, 1, 10);
            Txt := 'My payment';
            Method := Method::"Cur. month";
            UnitCode := UnitCode::Day;
            Qty := 5;
            Insert(true);
        end;
    end;

    local procedure CreateC5CustContact()
    var
        C5CustContact: Record "C5 CustContact";
    begin
        with C5CustContact do begin
            Init();
            RecId := 1;
            Account := CopyStr(CustNumTxt, 1, 10);
            Name := CopyStr(CustNumTxt, 1, 10);
            Address1 := '123, Hobby Street';
            Address2 := 'DerbyShire, Area GoGoland';
            Phone := '02345556262';
            ZipCity := 'AT-1100 Wien';
            Country := 'Austria';
            Email := Account + '@mail.com';
            PrimaryContact := PrimaryContact::Yes;
            Insert(true);

            Init();
            RecId := 2;
            Account := CopyStr(CustNumTxt, 1, 10);
            Name := 'Secondary Contact';
            Address1 := 'Address1';
            Address2 := 'Address2';
            Phone := '12345678';
            CellPhone := '12345678';
            ZipCity := 'AT-1100 Wien';
            Country := 'Austria';
            Email := 'second@mail.com';
            Insert(true);
        end;
    end;

    local procedure CheckPaymentTermsExist()
    var
        PaymentTerms: Record "Payment Terms";
        DueDateFormula: DateFormula;
    begin
        PaymentTerms.SetRange(Code, PaymentTxt);
        PaymentTerms.SetRange(Description, 'My payment');
        Evaluate(DueDateFormula, '<CM+5D>');
        PaymentTerms.SetRange("Due Date Calculation", DueDateFormula);
        PaymentTerms.FindFirst();
    end;

    local procedure CreateC5Employee()
    var
        C5Employee: Record "C5 Employee";
    begin
        with C5Employee do begin
            Init();
            Employee := CopyStr(SalesPersonTxt, 1, 10);
            EmployeeType := EmployeeType::"Sales rep.";
            Name := 'Gert Thomas';
            Phone := '123455';
            Email := 'gertThomas@c5.com';
            Insert(true);
        end;
    end;

    local procedure CheckSalesPersonExists()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetRange(Code, SalesPersonTxt);
        SalespersonPurchaser.SetRange(Name, 'Gert Thomas');
        SalespersonPurchaser.SetRange("Phone No.", '123455');
        SalespersonPurchaser.SetRange("E-Mail", 'gertThomas@c5.com');
        SalespersonPurchaser.FindFirst();
    end;

    local procedure CreateC5Delivery()
    var
        C5Delivery: Record "C5 Delivery";
    begin
        with C5Delivery do begin
            Init();
            Delivery := CopyStr(DeliveryTxt, 1, 10);
            Name := 'By Avion';
            Insert(true);
        end;
    end;

    local procedure CheckShipmentMethodExists()
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.SetRange(Code, DeliveryTxt);
        ShipmentMethod.SetRange(Description, 'By Avion');
        ShipmentMethod.FindFirst();
    end;

    local procedure CreateC5CustDiscGroup()
    var
        C5CustDiscGroup: Record "C5 CustDiscGroup";
    begin
        with C5CustDiscGroup do begin
            Init();
            DiscGroup := CopyStr(DiscGroupTxt, 1, 10);
            Comment := 'A comment for disc group';
            Insert(true);
        end;
    end;

    local procedure CheckCustomerDiscountGroupExists()
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        CustomerDiscountGroup.SetRange(Code, DiscGroupTxt);
        CustomerDiscountGroup.SetRange(Description, 'A comment for disc group');
        CustomerDiscountGroup.FindFirst();
    end;

    local procedure CreateC5ProcCode()
    var
        C5ProcCode: Record "C5 ProcCode";
    begin
        with C5ProcCode do begin
            Init();
            Type := Type::Customer;
            Code := CopyStr(ProcCodeTxt, 1, 10);
            Name := 'Proc Code full name';
            Insert(true);
        end;
    end;

    local procedure CheckPaymentMethodExists()
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetRange(Code, ProcCodeTxt);
        PaymentMethod.SetRange(Description, 'Proc Code full name');
        PaymentMethod.FindFirst();
    end;

    local procedure CheckDefaultDimensionExists(Customer: Text[10])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", Database::Customer);
        DefaultDimension.SetRange("No.", Customer);
        DefaultDimension.SetRange("Dimension Code", 'C5DEPARTMENT');
        DefaultDimension.FindFirst();
        Assert.AreEqual(Uppercase(DepartmentTxt), DefaultDimension."Dimension Value Code", 'Incorrect department in default dimension.');

        DefaultDimension.SetRange("Dimension Code", 'C5COSTCENTRE');
        DefaultDimension.FindFirst();
        Assert.AreEqual(Uppercase(CostCenterTxt), DefaultDimension."Dimension Value Code", 'Incorrect cost center in default dimension.');

        DefaultDimension.SetRange("Dimension Code", 'C5PURPOSE');
        DefaultDimension.FindFirst();
        Assert.AreEqual(Uppercase(PurposeTxt), DefaultDimension."Dimension Value Code", 'Incorrect purpose in default dimension.');
    end;

    local procedure CheckCustomerExists(C5CustTable: Record "C5 CustTable")
    var
        Customer: Record Customer;
    begin
        with Customer do begin
            SetRange("No.", UpperCase(C5CustTable.Account));
            FindFirst();
            Assert.AreEqual(Name, C5CustTable.Name, 'Name not migrated');
            Assert.AreEqual("Search Name", UpperCase(C5CustTable.SearchName), 'Search name not migrated');
            Assert.AreEqual(Address, C5CustTable.Address1, 'Address1 not migrated');
            Assert.AreEqual("Address 2", C5CustTable.Address2, 'Address2 not migrated');
            Assert.AreEqual("Post Code", 'AT-1100', 'Post code not migrated');
            Assert.AreEqual("Country/Region Code", 'AT', 'Country not migrated');
            Assert.AreEqual(Contact, C5CustTable.Attention, 'Attention not migrated');
            Assert.AreEqual("Phone No.", C5CustTable.Phone, 'Phone not migrated');
            Assert.AreEqual("Telex No.", C5CustTable.CellPhone, 'Cellphone not migrated');
            Assert.AreEqual("Credit Limit (LCY)", C5CustTable.BalanceMax, 'BalanceMax not migrated');
            Assert.AreEqual("Currency Code", C5CustTable.Currency, 'Currency not migrated');
            Assert.AreEqual("Customer Price Group", UpperCase(C5CustTable.PriceGroup), 'Pricegroup not migrated');
            Assert.AreEqual("Language Code", C5HelperFunctions.GetLanguageCodeForC5Language(C5CustTable.Language_), 'Language not migrated');
            Assert.AreEqual("Payment Terms Code", UpperCase(C5CustTable.Payment), 'Payment not migrated');
            Assert.AreEqual("Salesperson Code", UpperCase(C5CustTable.SalesRep), 'SalesRep not migrated');
            Assert.AreEqual("Shipment Method Code", UpperCase(C5CustTable.Delivery), 'Delivery not migrated');
            Assert.AreEqual("Invoice Disc. Code", UpperCase(C5CustTable.DiscGroup), 'Disc group not migrated');
            Assert.AreEqual(Blocked, Customer.Blocked::" ", 'Blocked not migrated');
            Assert.AreEqual("Bill-to Customer No.", UpperCase(C5CustTable.InvoiceAccount), 'InvoiceAccount not migrated');
            Assert.AreEqual("Payment Method Code", UpperCase(C5CustTable.PaymentMode), 'Payment mode not migrated');
            Assert.AreEqual("Fax No.", C5CustTable.Fax, 'Fax not migrated');
            Assert.AreEqual("VAT Registration No.", UpperCase(C5CustTable.VatNumber), 'Vat number not migrated');
            Assert.AreEqual("Home Page", C5CustTable.URL, 'Url not migrated');
            Assert.AreEqual("E-Mail", C5CustTable.Email, 'Email not migrated');
        end;
    end;

    local procedure CheckCustomerPostingSetupIsEmpty(C5CustTable: Record "C5 CustTable")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
    begin
        with Customer do begin
            SetRange("No.", UpperCase(C5CustTable.Account));
            FindFirst();
            // check customer posting group
            Assert.AreEqual('', "Customer Posting Group", 'Customer Posting group migrated from CustGroup');

            Assert.RecordIsEmpty(GenJournalLine);
        end;
    end;

    local procedure CheckCustomerPostingSetup(C5CustTable: Record "C5 CustTable")
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        DimensionSetEntry: Record "Dimension Set Entry";
        Customer: Record Customer;
    begin
        with Customer do begin
            SetRange("No.", UpperCase(C5CustTable.Account));
            FindFirst();
            // check customer posting group
            Assert.AreEqual('CUSTGRP', "Customer Posting Group", 'Customer Posting group was not migrated from CustGroup');
            CustomerPostingGroup.Get("Customer Posting Group");
            Assert.AreEqual('82020', CustomerPostingGroup."Receivables Account", 'incorrect receivables acc');

            // check general journal line
            GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
            GenJournalLine.SetRange("Account No.", C5CustTable.Account);
            GenJournalLine.FindFirst();
            Assert.AreEqual('CUSTMIGR', GenJournalLine."Journal Batch Name", 'Hard coded batch name incorrect');
            Assert.AreEqual(1000, GenJournalLine.Amount, 'Incorrect amount');
            Assert.AreEqual('C5MIGRATE', GenJournalLine."Document No.", 'Incorrect document number');
            Assert.AreEqual(DMY2Date(10, 4, 2014), GenJournalLine."Document Date", 'incorrect doc date');
            Assert.AreEqual(DMY2Date(10, 4, 2014), GenJournalLine."Posting Date", 'incorrect posting date');
            Assert.AreEqual(DMY2Date(12, 5, 2014), GenJournalLine."Due Date", 'incorrect due date');
            Assert.AreNotEqual('', GenJournalLine.Description, 'Empty discription');
            Assert.AreEqual(CustomerPostingGroup."Receivables Account", GenJournalLine."Bal. Account No.", 'Balance account was different than expected.');

            // check dimension on the general line
            DimensionSetEntry.SetRange("Dimension Set ID", GenJournalLine."Dimension Set ID");
            DimensionSetEntry.SetRange("Dimension Code", 'C5DEPARTMENT');
            DimensionSetEntry.FindFirst();
            Assert.AreEqual(Uppercase(Department2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect department code');
            DimensionSetEntry.SetRange("Dimension Code", 'C5COSTCENTRE');
            DimensionSetEntry.FindFirst();
            Assert.AreEqual(Uppercase(CostCenter2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect cost center code');
            DimensionSetEntry.SetRange("Dimension Code", 'C5PURPOSE');
            DimensionSetEntry.FindFirst();
            Assert.AreEqual(Uppercase(Purpose2Txt), DimensionSetEntry."Dimension Value Code", 'Incorrect purpose code');
        end;
    end;

    local procedure CreateC5CustGroup(): Text[10]
    var
        C5CustGroup: Record "C5 CustGroup";
        C5LedTable: Record "C5 LedTable";
    begin
        C5CustGroup.Init();
        C5CustGroup.RecId := 987654;
        C5CustGroup.Group := 'CustGrp';
        C5CustGroup.GroupName := 'Full group name';

        C5LedTable.DeleteAll();
        C5CustGroup.GroupAccount := '82020';
        C5LedTable.RecId := C5CustGroup.RecId;
        C5LedTable.Account := C5CustGroup.GroupAccount;
        C5LedTable.Insert();
        C5HelperFunctions.CreateGLAccount(C5CustGroup.GroupAccount);
        C5CustGroup.Insert(true);
        exit(C5CustGroup.Group);
    end;

    local procedure CreateC5CustTrans()
    var
        C5CustTrans: Record "C5 CustTrans";
    begin
        C5CustTrans.Init();
        C5CustTrans.RecId := 1;
        C5CustTrans.Account := CopyStr(CustNumTxt, 1, 10);
        C5CustTrans.Open := C5CustTrans.Open::Yes;
        C5CustTrans.BudgetCode := C5CustTrans.BudgetCode::Actual;
        C5CustTrans.Voucher := 352533;
        C5CustTrans.InvoiceNumber := 'MyInvoice';
        C5CustTrans.Txt := 'Some text';
        C5CustTrans.Date_ := DMY2Date(10, 4, 2014);
        C5CustTrans.DueDate := DMY2Date(12, 5, 2014);
        C5CustTrans.AmountMST := 1000;
        C5CustTrans.Department := CopyStr(Department2Txt, 1, 10);
        C5CustTrans.Centre := CopyStr(CostCenter2Txt, 1, 10);
        C5CustTrans.Purpose := CopyStr(Purpose2Txt, 1, 10);
        C5CustTrans.Insert();

        C5CustTrans.Init();
        C5CustTrans.RecId := 2;
        C5CustTrans.Account := CopyStr(AltCustNumTxt, 1, 10);
        C5CustTrans.Open := C5CustTrans.Open::Yes;
        C5CustTrans.BudgetCode := C5CustTrans.BudgetCode::Actual;
        C5CustTrans.Voucher := 352533;
        C5CustTrans.InvoiceNumber := 'MyInvoice2';
        C5CustTrans.Txt := 'Some text';
        C5CustTrans.Date_ := DMY2Date(10, 4, 2014);
        C5CustTrans.DueDate := DMY2Date(12, 5, 2014);
        C5CustTrans.AmountMST := 1000;
        C5CustTrans.Department := CopyStr(Department2Txt, 1, 10);
        C5CustTrans.Centre := CopyStr(CostCenter2Txt, 1, 10);
        C5CustTrans.Purpose := CopyStr(Purpose2Txt, 1, 10);
        C5CustTrans.Insert();
    end;
}

