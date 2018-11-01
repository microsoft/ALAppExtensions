// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148004 "C5 VendTable Migrator Tst"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        PurchaserTxt: Label 'Gerty', Locked = true;
        PaymentTxt: Label 'PaymentV', Locked = true;
        DeliveryTxt: Label 'DeliverV', Locked = true;
        DiscGroupTxt: Label 'DiscGroupV', Locked = true;
        VendNumTxt: Label 'MYC5VEND', Locked = true;
        AltVendNumTxt: Label 'MYC5VEND2', Locked = true;
        DepartmentTxt: Label 'PURCHX', Locked = true;
        CostCenterTxt: Label 'CostCntX', Locked = true;
        PurposeTxt: Label 'PurposeX', Locked = true;
        Department2Txt: Label 'PURCHY', Locked = true;
        CostCenter2Txt: Label 'CostCntY', Locked = true;
        Purpose2Txt: Label 'PurposeY', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    local procedure Initialize()
    var
        C5Payment: Record "C5 Payment";
        C5VendTable: Record "C5 VendTable";
        C5Employee: Record "C5 Employee";
        C5Delivery: Record "C5 Delivery";
        C5VendDiscGroup: Record "C5 VendDiscGroup";
        C5VendContact: Record "C5 VendContact";
        C5VendTrans: Record "C5 VendTrans";
        MarketingSetup: Record "Marketing Setup";
        Vendor: Record Vendor;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        VendorInvoiceDisc: Record "Vendor Invoice Disc.";
        GenJournalLine: Record "Gen. Journal Line";
        CountryRegion: Record "Country/Region";
        NoSeries: Record "No. Series";
        NoSeriesLines: Record "No. Series Line";
    begin
        C5Payment.DeleteAll();
        C5Employee.DeleteAll();
        C5Delivery.DeleteAll();
        C5VendDiscGroup.DeleteAll();
        C5VendContact.DeleteAll();
        C5VendTrans.DeleteAll();
        Vendor.DeleteAll();
        C5VendTable.DeleteAll();
        SalespersonPurchaser.DeleteAll();
        PaymentTerms.DeleteAll();
        ShipmentMethod.DeleteAll();
        VendorInvoiceDisc.DeleteAll();
        GenJournalLine.DeleteAll();

        CountryRegion.DeleteAll();

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
        NoSeries.Code := 'VEN';
        NoSeries."Default Nos." := true;
        NoSeries.Insert();

        NoSeriesLines.Init();
        NoSeriesLines."Series Code" := 'VEN';
        NoSeriesLines."Starting Date" := WorkDate();
        NoSeriesLines."Starting No." := '8000';
        NoSeriesLines."Ending No." := '9500';
        NoSeriesLines.Insert();

        if MarketingSetup.Get() then begin
            MarketingSetup."Autosearch for Duplicates" := false;
            MarketingSetup."Bus. Rel. Code for Vendors" := 'VEN';
            MarketingSetup."Contact Nos." := 'G000CONT';
            MarketingSetup.Modify();
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestVendTableMigrationWithCoA()
    var
        C5VendTable1: Record "C5 VendTable";
        C5VendTable2: Record "C5 VendTable";
    begin
        // [SCENARIO] Records from the C5 staging table for vendor are migrated to Nav
        Initialize();

        // [GIVEN] Some records in the staging table are already present
        FillC5StagingTables(C5VendTable1, C5VendTable2);

        // [WHEN] The migrator is run and chart of accounts has been migrated
        Migrate(C5VendTable1, true);
        Migrate(C5VendTable2, true);

        // [THEN] New records are created in the vendor table
        CheckVendorExists(C5VendTable1);
        CheckVendorExists(C5VendTable2);

        // [THEN] The Vedor Posting setup has been migrated and new general journal lines have been created
        CheckVendorPosting(C5VendTable1);
        CheckVendorPosting(C5VendTable2);

        // [THEN] Related records are created
        CheckRelatedTablesMigration(C5VendTable1, C5VendTable2);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestVendTableMigrationWithoutCoA()
    var
        C5VendTable1: Record "C5 VendTable";
        C5VendTable2: Record "C5 VendTable";
    begin
        // [SCENARIO] Records from the C5 staging table for vendor are migrated to Nav
        Initialize();

        // [GIVEN] Some records in the staging table are already present
        FillC5StagingTables(C5VendTable1, C5VendTable2);

        // [WHEN] The migrator is run and chart of accounts has not been migrated
        Migrate(C5VendTable1, false);
        Migrate(C5VendTable2, false);

        // [THEN] New records are created in the vendor table
        CheckVendorExists(C5VendTable1);
        CheckVendorExists(C5VendTable2);

        // [THEN] The Vedor Posting setup has not been migrated and no new general journal lines have been created
        CheckVendorPostingIsEmpty(C5VendTable1);
        CheckVendorPostingIsEmpty(C5VendTable2);

        // [THEN] Related records are created
        CheckRelatedTablesMigration(C5VendTable1, C5VendTable2);
    end;

    local procedure Migrate(C5VendTable: Record "C5 VendTable"; ChartOfAccountsMigrated: Boolean)
    var
        C5VendTableMigrator: Codeunit "C5 VendTable Migrator";
    begin
        C5VendTableMigrator.OnMigrateVendor(VendorDataMigrationFacade, C5VendTable.RecordId());
        C5VendTableMigrator.OnMigrateVendorDimensions(VendorDataMigrationFacade, C5VendTable.RecordId());
        C5VendTableMigrator.OnMigrateVendorPostingGroups(VendorDataMigrationFacade, C5VendTable.RecordId(), ChartOfAccountsMigrated);
        C5VendTableMigrator.OnMigrateVendorTransactions(VendorDataMigrationFacade, C5VendTable.RecordId(), ChartOfAccountsMigrated);
    end;

    local procedure CheckRelatedTablesMigration(C5VendTable1: Record "C5 VendTable"; C5VendTable2: Record "C5 VendTable")
    begin
        CheckDefaultDimensionExists(C5VendTable1.Account);
        CheckDefaultDimensionExists(C5VendTable2.Account);
        CheckPurchaserExists();
        CheckPaymentTermsExist();
        CheckShipmentMethodExists();
        CheckVendorInvDiscountExists();
        CheckContacts();
    end;

    local procedure FillC5StagingTables(var C5VendTable1: Record "C5 VendTable"; var C5VendTable2: Record "C5 VendTable")
    begin
        CreateC5Employee();
        CreateC5Payment();
        CreateC5Delivery();
        CreateC5VendDiscGroup();
        CreateC5VendTableRecord(CopyStr(VendNumTxt, 1, 10), '', C5VendTable1);
        CreateC5VendTableRecord(CopyStr(AltVendNumTxt, 1, 10), CopyStr(VendNumTxt, 1, 10), C5VendTable2);
        CreateC5VendGroup();
        CreateC5VendTrans();
        CreateC5VendContact();
    end;

    local procedure CheckContacts()
    var
        Contact: Record Contact;
    begin
        Contact.SetRange(Name, VendNumTxt);
        Contact.FindFirst();
        Assert.AreEqual(Contact.Address, '123, Hobby Street', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact."Address 2", 'DerbyShire, Area GoGoland', 'Contact address 2 was migrated incorrectly');
        Assert.AreEqual(Contact."Phone No.", '02345556262', 'Contact phone was migrated incorrectly');
        Assert.AreEqual(Contact."Post Code", 'AT-1100', 'Contact address was migrated incorrectly');
        Assert.AreEqual(Contact.City, 'Wien', 'Contact city was migrated incorrectly');
        Assert.AreEqual(Contact."Country/Region Code", 'AT', 'Contact Country was migrated incorrectly');
        Assert.AreEqual(Contact."E-Mail", VendNumTxt + '@mail.com', 'Contact Email was migrated incorrectly');

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

    local procedure CreateC5VendContact()
    var
        C5CVendContact: Record "C5 VendContact";
    begin
        with C5CVendContact do begin
            Init();
            RecId := 1;
            Account := CopyStr(VendNumTxt, 1, 10);
            Name := CopyStr(VendNumTxt, 1, 10);
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
            Account := CopyStr(VendNumTxt, 1, 10);
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

    local procedure CreateC5Employee()
    var
        C5Employee: Record "C5 Employee";
    begin
        with C5Employee do begin
            Init();
            Employee := CopyStr(PurchaserTxt, 1, 10);
            EmployeeType := EmployeeType::Purchaser;
            Name := 'Gert Thomas';
            Phone := '123455';
            Email := 'gertThomas@c5.com';
            Insert(true);
        end;
    end;

    local procedure CheckPurchaserExists()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetRange(Code, PurchaserTxt);
        SalespersonPurchaser.SetRange(Name, 'Gert Thomas');
        SalespersonPurchaser.SetRange("Phone No.", '123455');
        SalespersonPurchaser.SetRange("E-Mail", 'gertThomas@c5.com');
        Assert.AreEqual(1, SalespersonPurchaser.Count(), 'Sales person not migrated');
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

    local procedure CheckPaymentTermsExist()
    var
        PaymentTerms: Record "Payment Terms";
        DueDateFormula: DateFormula;
    begin
        PaymentTerms.SetRange(Code, PaymentTxt);
        PaymentTerms.SetRange(Description, 'My payment');
        Evaluate(DueDateFormula, '<CM+5D>');
        PaymentTerms.SetRange("Due Date Calculation", DueDateFormula);
        Assert.AreEqual(1, PaymentTerms.Count(), 'Payment term not inserted');
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
        Assert.AreEqual(1, ShipmentMethod.Count(), 'Shipment method not migrated');
    end;

    local procedure CreateC5VendDiscGroup()
    var
        C5VendDiscGroup: Record "C5 VendDiscGroup";
    begin
        with C5VendDiscGroup do begin
            Init();
            DiscGroup := CopyStr(DiscGroupTxt, 1, 10);
            Comment := 'A comment for vend disc group';
            Insert(true);
        end;
    end;

    local procedure CheckVendorInvDiscountExists()
    var
        VendorInvoiceDisc: Record "Vendor Invoice Disc.";
    begin
        VendorInvoiceDisc.SetRange(Code, DiscGroupTxt);
        Assert.AreEqual(1, VendorInvoiceDisc.Count(), 'Customer discount group not migrated');
    end;

    local procedure CreateC5VendTableRecord(Acc: Text[10]; InvAccount: Text[10]; var C5VendTable: Record "C5 VendTable")
    var
        C5VendTable2: Record "C5 VendTable";
    begin
        with C5VendTable do begin
            Init();
            if C5VendTable2.FindLast() then
                RecId := C5VendTable2.RecId + 1;
            Account := Acc;
            Name := Account;
            SearchName := Account + ' search';
            Address1 := '123, Hobby Street';
            Address2 := 'DerbyShire, Area GoGoland';
            ZipCity := '1100 Wien';
            Country := 'Austria';
            Attention := 'Tim Nut';
            Phone := '02345556262';
            Telex := '028352757';
            Email := Account + '@mail.com';
            Department := CopyStr(DepartmentTxt, 1, 10);
            Centre := CopyStr(CostCenterTxt, 1, 10);
            Purpose := CopyStr(PurposeTxt, 1, 10);
            OurAccount := 'MyAccount';
            Group := 'Grouppo';
            Language_ := Language_::English;
            Payment := CopyStr(PaymentTxt, 1, 10);
            Purchaser := CopyStr(PurchaserTxt, 1, 10);
            Delivery := CopyStr(DeliveryTxt, 1, 10);
            TransportCode := 'PARAVION';
            CashDisc := 'CashDisc';
            Blocked := Blocked::No;
            PaymentMode := 'PmntModeX';
            Fax := 'FaxeKondi';
            VatNumber := 'ATU' + FORMAT(LibraryRandom.RandIntInRange(10000000, 99999999));
            PurchGroup := 'MyPurGroup';
            URL := 'www.aliddr.com';
            Vat := 'VATPosting';
            InvoiceAccount := InvAccount;
            DiscGroup := CopyStr(DiscGroupTxt, 1, 10);
            Group := 'VendGrp';
            Insert(true);
        end;
    end;

    local procedure CheckDefaultDimensionExists(Vendor: Text[10])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", Database::Vendor);
        DefaultDimension.SetRange("No.", Vendor);
        DefaultDimension.SetRange("Dimension Code", 'C5DEPARTMENT');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(DepartmentTxt), DefaultDimension."Dimension Value Code", 'Incorrect value in department dimension.');
        DefaultDimension.SetRange("Dimension Code", 'C5COSTCENTRE');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(CostCenterTxt), DefaultDimension."Dimension Value Code", 'Incorrect value in cost center dimension.');
        DefaultDimension.SetRange("Dimension Code", 'C5PURPOSE');
        Assert.IsTrue(DefaultDimension.FindFirst(), 'Default dimension not found');
        Assert.AreEqual(Uppercase(PurposeTxt), DefaultDimension."Dimension Value Code", 'Incorrect value in purpose dimension.');
    end;

    local procedure CheckVendorExists(C5VendTable: Record "C5 VendTable")
    var
        Vendor: Record Vendor;
    begin
        with Vendor do begin
            SetRange("No.", C5VendTable.Account);
            FindFirst();
            Assert.AreEqual(Name, C5VendTable.Name, 'Name not migrated');
            Assert.AreEqual("Search Name", UpperCase(C5VendTable.SearchName), 'Search name not migrated');
            Assert.AreEqual(Address, C5VendTable.Address1, 'Address 1 not migrated');
            Assert.AreEqual("Address 2", C5VendTable.Address2, 'Address 2 not migrated');
            Assert.AreEqual(City, 'Wien', 'City not migrated');
            Assert.AreEqual("Post Code", 'AT-1100', 'Post code not migrated');
            Assert.AreEqual("Country/Region Code", 'AT', 'Country not migrated');
            Assert.AreEqual(Contact, C5VendTable.Attention, 'Attention not migrated');
            Assert.AreEqual("Phone No.", C5VendTable.Phone, 'Phone not migrated');
            Assert.AreEqual("Telex No.", C5VendTable.Telex, 'Telex not migrated');
            Assert.AreEqual("Our Account No.", C5VendTable.OurAccount, 'OurAccount not migrated');
            Assert.AreEqual("Currency Code", C5VendTable.Currency, 'Currency not migrated');
            Assert.AreEqual("Language Code", C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_), 'Language not mgirated');
            Assert.AreEqual("Payment Terms Code", UpperCase(C5VendTable.Payment), 'Payment not migrated');
            Assert.AreEqual("Purchaser Code", UpperCase(C5VendTable.Purchaser), 'Purchaser not migrated');
            Assert.AreEqual("Shipment Method Code", UpperCase(C5VendTable.Delivery), 'Delivery not migrated');
            Assert.AreEqual("Invoice Disc. Code", UpperCase(C5VendTable.DiscGroup), 'DiscGroup not migrated');
            Assert.AreEqual(Blocked, Blocked::" ", 'Blocked not migrated');
            Assert.AreEqual("Fax No.", C5VendTable.Fax, 'Fax not migrated');
            Assert.AreEqual("VAT Registration No.", UpperCase(C5VendTable.VatNumber), 'Vat number not migrated');
            Assert.AreEqual("Home Page", C5VendTable.URL, 'Url not migrated');
            Assert.AreEqual("E-Mail", C5VendTable.Email, 'Email not migrated');
        end;
    end;

    local procedure CheckVendorPostingIsEmpty(C5VendTable: Record "C5 VendTable")
    var
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
    begin
        with Vendor do begin
            SetRange("No.", C5VendTable.Account);
            FindFirst();
            // check vendor posting group
            Assert.AreEqual('', "Vendor Posting Group", 'Vendor Posting group migrated from VendorGroup');

            Assert.RecordIsEmpty(GenJournalLine);
        end;
    end;

    local procedure CheckVendorPosting(C5VendTable: Record "C5 VendTable")
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        with Vendor do begin
            SetRange("No.", C5VendTable.Account);
            FindFirst();
            // check vendor posting group
            Assert.AreEqual('VENDGRP', "Vendor Posting Group", 'Vendor Posting group was not migrated from VendorGroup');
            VendorPostingGroup.Get("Vendor Posting Group");
            Assert.AreEqual('82020', VendorPostingGroup."Payables Account", 'incorrect payables acc');

            // check general journal line
            GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
            GenJournalLine.SetRange("Account No.", C5VendTable.Account);
            GenJournalLine.FindFirst();
            Assert.AreEqual('VENDMIGR', GenJournalLine."Journal Batch Name", 'Hard coded batch name incorrect');
            Assert.AreEqual(1000, GenJournalLine.Amount, 'Incorrect amount');
            Assert.AreEqual('C5MIGRATE', GenJournalLine."Document No.", 'Incorrect document number');
            Assert.AreEqual(DMY2Date(10, 4, 2014), GenJournalLine."Document Date", 'incorrect doc date');
            Assert.AreEqual(DMY2Date(10, 4, 2014), GenJournalLine."Posting Date", 'incorrect posting date');
            Assert.AreEqual(DMY2Date(12, 5, 2014), GenJournalLine."Due Date", 'incorrect due date');
            Assert.AreNotEqual('', GenJournalLine.Description, 'Discription was empty');
            Assert.AreEqual(VendorPostingGroup."Payables Account", GenJournalLine."Bal. Account No.", 'Balance account was different than expected.');

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

    local procedure CreateC5VendGroup(): Text[10]
    var
        C5VendGroup: Record "C5 VendGroup";
        C5LedTable: Record "C5 LedTable";
    begin
        C5VendGroup.Init();
        C5VendGroup.RecId := 987654;
        C5VendGroup.Group := 'VendGrp';
        C5VendGroup.GroupName := 'Full group name';

        C5LedTable.DeleteAll();
        C5VendGroup.GroupAccount := '82020';
        C5LedTable.RecId := C5VendGroup.RecId;
        C5LedTable.Account := C5VendGroup.GroupAccount;
        C5LedTable.Insert();
        C5HelperFunctions.CreateGLAccount(C5VendGroup.GroupAccount);
        C5VendGroup.Insert(true);
        exit(C5VendGroup.Group);
    end;

    local procedure CreateC5VendTrans()
    var
        C5VendTrans: Record "C5 VendTrans";
    begin
        C5VendTrans.Init();
        C5VendTrans.RecId := 1;
        C5VendTrans.Account := CopyStr(VendNumTxt, 1, 10);
        C5VendTrans.Open := C5VendTrans.Open::Yes;
        C5VendTrans.BudgetCode := C5VendTrans.BudgetCode::Actual;
        C5VendTrans.Voucher := 352533;
        C5VendTrans.InvoiceNumber := 'MyInvoice';
        C5VendTrans.Txt := 'Some text';
        C5VendTrans.Date_ := DMY2Date(10, 4, 2014);
        C5VendTrans.DueDate := DMY2Date(12, 5, 2014);
        C5VendTrans.AmountMST := 1000;
        C5VendTrans.Department := CopyStr(Department2Txt, 1, 10);
        C5VendTrans.Centre := CopyStr(CostCenter2Txt, 1, 10);
        C5VendTrans.Purpose := CopyStr(Purpose2Txt, 1, 10);
        C5VendTrans.Insert();

        C5VendTrans.Init();
        C5VendTrans.RecId := 2;
        C5VendTrans.Account := CopyStr(AltVendNumTxt, 1, 10);
        C5VendTrans.Open := C5VendTrans.Open::Yes;
        C5VendTrans.BudgetCode := C5VendTrans.BudgetCode::Actual;
        C5VendTrans.Voucher := 352533;
        C5VendTrans.InvoiceNumber := 'MyInvoice2';
        C5VendTrans.Txt := 'Some text';
        C5VendTrans.Date_ := DMY2Date(10, 4, 2014);
        C5VendTrans.DueDate := DMY2Date(12, 5, 2014);
        C5VendTrans.AmountMST := 1000;
        C5VendTrans.Department := CopyStr(Department2Txt, 1, 10);
        C5VendTrans.Centre := CopyStr(CostCenter2Txt, 1, 10);
        C5VendTrans.Purpose := CopyStr(Purpose2Txt, 1, 10);
        C5VendTrans.Insert();
    end;
}