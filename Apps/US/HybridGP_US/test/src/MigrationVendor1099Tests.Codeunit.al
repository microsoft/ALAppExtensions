codeunit 139684 "Migration Vendor 1099 Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;
    Permissions = tableData "Detailed Vendor Ledg. Entry" = rimd,
                  tabledata "Vendor Ledger Entry" = rimd;

    var
        Assert: Codeunit Assert;
        TestVendorNoLbl: Label 'TESTVENDOR01', Locked = true;
        PayablesAccountNoLbl: Label '2100', Locked = true;
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        IRSFormFeatureKeyIdTok: Label 'IRSForm', Locked = true;

    [Test]
    procedure TestMappingsCreated()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        SupportedTaxYear: Record "Supported Tax Year";
        GP1099BoxMapping: Record "GP 1099 Box Mapping";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
    begin
        Initialize();

        // Enable Migrate Vendor 1099 setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", true);
        GPCompanyAdditionalSettings.Validate("1099 Tax Year", 2022);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] GP migration has completed and the Vendor 1099 migration has started
        GPCloudMigrationUS.RunPostMigration();

        // [THEN] The supported tax year of 2022 will be present
        SupportedTaxYear.SetRange("Tax Year", 2022);
        Assert.RecordCount(SupportedTaxYear, 1);

        // [THEN] Mappings will be present for the supported tax year
        GP1099BoxMapping.SetRange("Tax Year", 2022);
        GP1099BoxMapping.SetRange("GP 1099 Type", 2);
        GP1099BoxMapping.SetRange("GP 1099 Box No.", 1);
        Assert.IsTrue(GP1099BoxMapping.FindFirst(), 'No GP 1099 Box mapping record found for DIV-01-A.');
        Assert.AreEqual('DIV-01-A', GP1099BoxMapping."BC IRS 1099 Code", 'Incorrect box code mapping.');

        GP1099BoxMapping.SetRange("Tax Year", 2022);
        GP1099BoxMapping.SetRange("GP 1099 Type", 3);
        GP1099BoxMapping.SetRange("GP 1099 Box No.", 3);
        Assert.IsTrue(GP1099BoxMapping.FindFirst(), 'No GP 1099 Box mapping record found for INT-03.');
        Assert.AreEqual('INT-03', GP1099BoxMapping."BC IRS 1099 Code", 'Incorrect box code mapping.');

        GP1099BoxMapping.SetRange("Tax Year", 2022);
        GP1099BoxMapping.SetRange("GP 1099 Type", 4);
        GP1099BoxMapping.SetRange("GP 1099 Box No.", 2);
        Assert.IsTrue(GP1099BoxMapping.FindFirst(), 'No GP 1099 Box mapping record found for MISC-02.');
        Assert.AreEqual('MISC-02', GP1099BoxMapping."BC IRS 1099 Code", 'Incorrect box code mapping.');

        GP1099BoxMapping.SetRange("Tax Year", 2022);
        GP1099BoxMapping.SetRange("GP 1099 Type", 5);
        GP1099BoxMapping.SetRange("GP 1099 Box No.", 1);
        Assert.IsTrue(GP1099BoxMapping.FindFirst(), 'No GP 1099 Box mapping record found for NEC-01.');
        Assert.AreEqual('NEC-01', GP1099BoxMapping."BC IRS 1099 Code", 'Incorrect box code mapping.');
    end;

    [Test]
    procedure TestGetSupportedYear()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
    begin
        Initialize();

        // Enable Migrate Vendor 1099 setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", true);
        GPCompanyAdditionalSettings.Validate("1099 Tax Year", 2022);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] GP migration has completed and the Vendor 1099 migration has started
        GPCloudMigrationUS.RunPostMigration();

        // [WHEN] The 2022 1099 mapping is created when installed
        // [THEN] The GetSupportedTaxYear procedure will return correct results
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2022), 'Supported tax year is incorrect.');
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2023), 'Supported tax year is incorrect.');
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2024), 'Supported tax year is incorrect.');
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2025), 'Supported tax year is incorrect.');
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2026), 'Supported tax year is incorrect.');
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetSupportedTaxYear(2027), 'Supported tax year is incorrect.');
        Assert.AreEqual(0, GPVendor1099MappingHelpers.GetSupportedTaxYear(2020), 'Supported tax year is incorrect.');
        Assert.AreEqual(0, GPVendor1099MappingHelpers.GetSupportedTaxYear(2010), 'Supported tax year is incorrect.');
        Assert.AreEqual(0, GPVendor1099MappingHelpers.GetSupportedTaxYear(2005), 'Supported tax year is incorrect.');
        Assert.AreEqual(0, GPVendor1099MappingHelpers.GetSupportedTaxYear(1997), 'Supported tax year is incorrect.');
    end;

    [Test]
    procedure TestGetIRS1099BoxCode()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
    begin
        Initialize();

        // Enable Migrate Vendor 1099 setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", true);
        GPCompanyAdditionalSettings.Validate("1099 Tax Year", 2022);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] GP migration has completed and the Vendor 1099 migration has started
        GPCloudMigrationUS.RunPostMigration();

        // [THEN] The GetIRS1099BoxCode procedure will return correct results
        // Unsupported tax year
        Assert.AreEqual('', GPVendor1099MappingHelpers.GetIRS1099BoxCode(1997, 2, 1), 'Incorrect 1099 Box Code returned.');

        // Tax year 2022

        // DIV
        Assert.AreEqual('DIV-01-A', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 1), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-01-B', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 2), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-A', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 3), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-B', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 4), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-C', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 5), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-D', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 6), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-E', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 17), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-02-F', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 18), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-03', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 7), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-04', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 8), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-05', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 9), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-06', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 10), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-07', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 11), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-09', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 12), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-10', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 13), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-12', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 14), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('DIV-13', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 2, 15), 'Incorrect 1099 Box Code returned.');

        // INT
        Assert.AreEqual('INT-01', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 1), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-02', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 2), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-03', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 3), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-04', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 4), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-05', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 5), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-06', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 6), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-08', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 7), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-09', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 8), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-10', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 9), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-11', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 10), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-12', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 11), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('INT-13', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 3, 12), 'Incorrect 1099 Box Code returned.');

        // MISC
        Assert.AreEqual('MISC-01', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 1), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-02', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 2), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-03', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 3), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-04', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 4), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-05', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 5), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-06', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 6), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-08', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 7), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-09', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 8), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-10', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 9), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-11', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 15), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-12', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 10), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-14', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 11), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-15', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 12), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('MISC-16', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 4, 13), 'Incorrect 1099 Box Code returned.');

        // NEC
        Assert.AreEqual('NEC-01', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 5, 1), 'Incorrect 1099 Box Code returned.');
        Assert.AreEqual('NEC-04', GPVendor1099MappingHelpers.GetIRS1099BoxCode(2022, 5, 2), 'Incorrect 1099 Box Code returned.');
    end;

    [Test]
    procedure TestVendor1099Migration()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GP1099MigrationLog: Record "GP 1099 Migration Log";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
        DocumentNo: Code[20];
    begin
        Initialize();

        // [GIVEN] The Intelligent Cloud migration is completed
        CreateVendorData();

        // Enable Migrate Vendor 1099 setting
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", true);
        GPCompanyAdditionalSettings.Validate("1099 Tax Year", 2022);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] The main migration is finished and the Vendor 1099 migration is started
        GPCloudMigrationUS.RunPostMigration();

        // [THEN] The Vendor record will have correct 1099 data
        Assert.IsTrue(Vendor.Get(TestVendorNoLbl), 'Vendor not found.');
        IRS1099VendorFormBoxSetup.Get('2022', Vendor."No.");
        Assert.AreEqual('NEC-01', IRS1099VendorFormBoxSetup."Form Box No.", 'Incorrect IRS 1099 Code.');
        Assert.AreEqual('123456789', Vendor."Federal ID No.", 'Incorrect Federal ID No.');
        Assert.AreEqual(Vendor."Tax Identification Type"::"Legal Entity", Vendor."Tax Identification Type", 'Incorrect Tax Identification Type.');

        // [THEN] The Vendor will have Vendor Ledger Entries applied correctly
        VendorLedgerEntry.SetRange("Vendor No.", TestVendorNoLbl);
        Assert.IsTrue(VendorLedgerEntry.Count() > 0, 'No VLE created!');

        VendorLedgerEntry.FindFirst();

        // NEC-01, total is $120
        VendorLedgerEntry.SetRange("Vendor No.", TestVendorNoLbl);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("IRS 1099 Reporting Period", Format(GPCompanyAdditionalSettings."1099 Tax Year"));
        VendorLedgerEntry.SetRange(Description, 'NEC-01');
        Assert.IsTrue(VendorLedgerEntry.FindFirst(), 'NEC-01 Invoice Vendor ledger entry not found.');

        DocumentNo := VendorLedgerEntry."Document No.";
        Assert.AreEqual('NEC-01', VendorLedgerEntry.Description, 'Invoice Vendor ledger entry description is incorrect.');
        Assert.AreEqual('NEC-01', VendorLedgerEntry."IRS 1099 Form Box No.", 'Invoice Vendor ledger entry IRS 1099 Code is incorrect.');
        Assert.AreEqual(-120, VendorLedgerEntry."IRS 1099 Reporting Amount", 'Invoice Vendor ledger entry IRS 1099 Amount is incorrect.');
        Assert.AreEqual(0, VendorLedgerEntry."Remaining Amount", 'Invoice Vendor ledger entry Remaining Amount should be zero.');

        VendorLedgerEntry.SetRange("Vendor No.", TestVendorNoLbl);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange(Description, 'NEC-01');
        Assert.IsTrue(VendorLedgerEntry.FindFirst(), 'NEC-01 Payment Vendor ledger entry not found.');
        Assert.AreEqual('NEC-01', VendorLedgerEntry.Description, 'Payment Vendor ledger entry description is incorrect.');
        Assert.AreEqual('NEC-01', VendorLedgerEntry."IRS 1099 Form Box No.", 'Payment Vendor ledger entry IRS 1099 Code is incorrect.');

        DetailedVendorLedgEntry.SetRange("Vendor No.", TestVendorNoLbl);
        DetailedVendorLedgEntry.SetRange("Initial Document Type", DetailedVendorLedgEntry."Initial Document Type"::Payment);
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(DetailedVendorLedgEntry.FindFirst(), 'Applied Payment Detailed Vendor ledger entry for NEC-01 not found.');
        Assert.AreEqual(120, DetailedVendorLedgEntry."Credit Amount", 'Applied Payment Detailed Vendor ledger entry Credit Amount is incorrect.');

        // NEC-04, $200
        VendorLedgerEntry.SetRange("Vendor No.", TestVendorNoLbl);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange(Description, 'NEC-04');
        Assert.IsTrue(VendorLedgerEntry.FindFirst(), 'NEC-04 Vendor ledger entry not found.');
        DocumentNo := VendorLedgerEntry."Document No.";

        DetailedVendorLedgEntry.SetRange("Vendor No.", TestVendorNoLbl);
        DetailedVendorLedgEntry.SetRange("Initial Document Type", DetailedVendorLedgEntry."Initial Document Type"::Payment);
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(DetailedVendorLedgEntry.FindFirst(), 'Applied Payment Detailed Vendor ledger entry for NEC-02 not found.');
        Assert.AreEqual(200, DetailedVendorLedgEntry."Credit Amount", 'Applied Payment Detailed Vendor ledger entry Credit Amount is incorrect.');

        // Invalid box number (5, 200)
        GP1099MigrationLog.SetRange("Vendor No.", TestVendorNoLbl);
        GP1099MigrationLog.SetRange("GP 1099 Type", 5);
        GP1099MigrationLog.SetRange("GP 1099 Box No.", 200);
        Assert.IsTrue(GP1099MigrationLog.FindFirst(), 'Log entry missing for skipped invalid mapping (5, 200)');
        Assert.AreEqual('', GP1099MigrationLog."BC IRS 1099 Code", 'Log entry for missing mapping should have an empty mapped IRS 1099 Box Code');
    end;

    [Test]
    procedure TestDefaultYear()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        GPCloudMigrationUS: Codeunit "GP Cloud Migration US";
        CurrentYear: Integer;
    begin
        CurrentYear := System.Date2DMY(Today(), 3);

        Initialize();

        // [GIVEN] The Intelligent Cloud migration is completed
        CreateVendorData();

        GPCompanyAdditionalSettings.Get();
        Assert.AreEqual(CurrentYear, GPCompanyAdditionalSettings."1099 Tax Year", 'Incorrect configured default tax year');

        // Enable Migrate Vendor 1099 setting, and the 1099 Tax Year is not set
        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Vendor 1099", true);
        GPCompanyAdditionalSettings.Modify();

        // [WHEN] The main migration is finished and the Vendor 1099 migration is started
        GPCloudMigrationUS.RunPostMigration();

        // [THEN] The 1099 Tax Year will be configured for the current year
        Assert.AreEqual(2022, GPVendor1099MappingHelpers.GetMinimumSupportedTaxYear(), 'Incorrect minimum supported tax year');
        Assert.AreEqual(CurrentYear, GPCompanyAdditionalSettings.Get1099TaxYear(), 'Incorrect configured tax year');
    end;

    local procedure Initialize()
    var
        Vendor: Record Vendor;
        GPPM00200: Record "GP PM00200";
        GPPM00204: Record "GP PM00204";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GPPostingAccounts: Record "GP Posting Accounts";
        GLAccount: Record "G/L Account";
        GP1099MigrationLog: Record "GP 1099 Migration Log";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        ManuallyEnabledIRSFormFeatureIfRequired();

        Vendor.SetRange("No.", TestVendorNoLbl);
        if not Vendor.IsEmpty() then
            Vendor.DeleteAll();

        if not GPPM00200.IsEmpty() then
            GPPM00200.DeleteAll();

        if not GPPM00204.IsEmpty() then
            GPPM00204.DeleteAll();

        if not GPPostingAccounts.IsEmpty() then
            GPPostingAccounts.DeleteAll();

        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", TestVendorNoLbl);
        if not GenJournalLine.IsEmpty() then
            GenJournalLine.DeleteAll();

        DetailedVendorLedgEntry.SetRange("Vendor No.", TestVendorNoLbl);
        if not DetailedVendorLedgEntry.IsEmpty() then
            DetailedVendorLedgEntry.DeleteAll();

        VendorLedgerEntry.SetRange("Vendor No.", TestVendorNoLbl);
        if not VendorLedgerEntry.IsEmpty() then
            VendorLedgerEntry.DeleteAll();

        if GLAccount.Get(PayablesAccountNoLbl) then
            GLAccount.Delete();

        if not GP1099MigrationLog.IsEmpty() then
            GP1099MigrationLog.DeleteAll();

        if not GPCompanyMigrationSettings.IsEmpty() then
            GPCompanyMigrationSettings.DeleteAll();

        if not GPCompanyAdditionalSettings.IsEmpty() then
            GPCompanyAdditionalSettings.DeleteAll();

        if not IRS1099VendorFormBoxSetup.IsEmpty() then
            IRS1099VendorFormBoxSetup.DeleteAll();

        CreateConfigurationSettings();
    end;

    local procedure CreateConfigurationSettings()
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        CompanyNameText: Text[30];
    begin
        Clear(GPCompanyMigrationSettings);
        GPCompanyMigrationSettings.Insert(true);

        Clear(GPCompanyAdditionalSettings);
        GPCompanyAdditionalSettings.Insert(true);

#pragma warning disable AA0139
        CompanyNameText := CompanyName();
#pragma warning restore AA0139

        Clear(GPCompanyMigrationSettings);
        if not GPCompanyMigrationSettings.Get(CompanyNameText) then begin
            GPCompanyMigrationSettings.Name := CompanyNameText;
            GPCompanyMigrationSettings.Insert(true);
        end;

        Clear(GPCompanyAdditionalSettings);
        if not GPCompanyAdditionalSettings.Get(CompanyNameText) then begin
            GPCompanyAdditionalSettings.Name := CompanyNameText;
            GPCompanyAdditionalSettings.Insert(true);
        end;
    end;

    local procedure CreateVendorData()
    var
        Vendor: Record Vendor;
        GPPM00200: Record "GP PM00200";
        GPPM00204: Record "GP PM00204";
        GPPostingAccounts: Record "GP Posting Accounts";
        GLAccount: Record "G/L Account";
    begin
        Initialize();

        Clear(GPPostingAccounts);
        GPPostingAccounts.PayablesAccount := PayablesAccountNoLbl;
        GPPostingAccounts.Insert();

        GLAccount."No." := PayablesAccountNoLbl;
        GLAccount.Name := 'Payables';
        GLAccount."Account Type" := "G/L Account Type"::Posting;
        GLAccount.Insert();

        CreatePostingGroupsIfNeeded();

        GPPM00200.VENDORID := TestVendorNoLbl;
        GPPM00200.VENDNAME := 'Test Vendor 01';
        GPPM00200.TEN99TYPE := 5;
        GPPM00200.TEN99BOXNUMBER := 1;
        GPPM00200.TXIDNMBR := '123456789';
        GPPM00200.VNDCLSID := 'GP';
        GPPM00200.Insert();

        Vendor."No." := TestVendorNoLbl;
        Vendor.Name := 'Test Vendor 01';
        Vendor."Vendor Posting Group" := 'GP';
        Vendor.Insert();

        // NEC-01, $100
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 100;
        GPPM00204.YEAR1 := 2022;
        GPPM00204.PERIODID := 3;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 1;
        GPPM00204.Insert();

        // NEC-01, $20
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 20;
        GPPM00204.YEAR1 := 2022;
        GPPM00204.PERIODID := 4;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 1;
        GPPM00204.Insert();

        // NEC-04, $200
        Clear(GPPM00204);
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 200;
        GPPM00204.YEAR1 := 2022;
        GPPM00204.PERIODID := 4;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 2;
        GPPM00204.Insert();

        // Invalid box number (5, 200)
        Clear(GPPM00204);
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 200000;
        GPPM00204.YEAR1 := 2022;
        GPPM00204.PERIODID := 4;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 200;
        GPPM00204.Insert();

        // Previous year
        Clear(GPPM00204);
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 200000;
        GPPM00204.YEAR1 := 2021;
        GPPM00204.PERIODID := 1;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 1;
        GPPM00204.Insert();

        // Previous unsupported year
        Clear(GPPM00204);
        GPPM00204.VENDORID := TestVendorNoLbl;
        GPPM00204.TEN99AMNT := 200000;
        GPPM00204.YEAR1 := 1997;
        GPPM00204.PERIODID := 4;
        GPPM00204.TEN99TYPE := 5;
        GPPM00204.TEN99BOXNUMBER := 1;
        GPPM00204.Insert();
    end;

    local procedure CreatePostingGroupsIfNeeded()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if not GenProductPostingGroup.Get(PostingGroupCodeTxt) then begin
            GenProductPostingGroup.Code := PostingGroupCodeTxt;
            GenProductPostingGroup.Description := 'Migrated from GP';
            GenProductPostingGroup."Auto Insert Default" := true;
            GenProductPostingGroup.Insert();

            GeneralPostingSetup."Gen. Prod. Posting Group" := PostingGroupCodeTxt;
            GeneralPostingSetup."Purch. Account" := PayablesAccountNoLbl;
            GeneralPostingSetup.Insert();
        end;

        if VendorPostingGroup.Get(PostingGroupCodeTxt) then
            VendorPostingGroup.Delete();

        if not VendorPostingGroup.Get(PostingGroupCodeTxt) then begin
            VendorPostingGroup.Validate("Code", PostingGroupCodeTxt);
            VendorPostingGroup."Payables Account" := PayablesAccountNoLbl;
            VendorPostingGroup.Insert(true);
        end;
    end;

    local procedure ManuallyEnabledIRSFormFeatureIfRequired()
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
#if CLEAN25
        exit;
#endif
        if FeatureKey.Get(IRSFormFeatureKeyIdTok) then
            if FeatureKey.Enabled <> FeatureKey.Enabled::"All Users" then begin
                FeatureKey.Enabled := FeatureKey.Enabled::"All Users";
                FeatureKey.Modify();
            end;

        if FeatureDataUpdateStatus.Get(IRSFormFeatureKeyIdTok, CompanyName()) then
            if FeatureDataUpdateStatus."Feature Status" <> FeatureDataUpdateStatus."Feature Status"::Enabled then begin
                FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Enabled;
                FeatureDataUpdateStatus.Modify();
            end;
    end;
}