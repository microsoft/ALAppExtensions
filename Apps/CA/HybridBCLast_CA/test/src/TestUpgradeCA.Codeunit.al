codeunit 139911 "Test Upgrade CA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'CA', Locked = true;

    [Test]
    procedure TestIrs1099FormBoxesGetUpdated()
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] CA data migration (14x -> 15x) runs the correct upgrade code for the IRS 1099 stuff.
        // [GIVEN] Old 1099 records are present and have not been upgraded yet.
        IRS1099FormBox.DeleteAll();
        IRS1099FormBox.Init();
        IRS1099FormBox.Code := 'DIV-06';
        IRS1099FormBox.Description := 'Unicycle Park Dividends';
        IRS1099FormBox."Minimum Reportable" := 1000;
        IRS1099FormBox.Insert();

        // [WHEN] The upgrade trigger is called
        HybridReplicationSummary.Init();
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The old 1099 records have been upgraded.
        IRS1099FormBox.Get('DIV-07');
        Assert.AreEqual('Unicycle Park Dividends', IRS1099FormBox.Description, IRS1099FormBox.FieldName(Description));

        IRS1099FormBox.Get('DIV-05');
        Assert.AreEqual('Section 199A dividends', IRS1099FormBox.Description, IRS1099FormBox.FieldName(Description));
    end;

    [Test]
    procedure AlreadyUpgraded1099RecordsDontGetChanged()
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] CA data migration (14x -> 15x) skips upgrade code for 1099 records if it has already happened.
        // [GIVEN] 1099 records have already been updated.
        IRS1099FormBox.DeleteAll();
        IRS1099FormBox.Code := 'DIV-07';
        IRS1099FormBox.Description := 'Section 1337 Gains';
        IRS1099FormBox."Minimum Reportable" := 1000;
        IRS1099FormBox.Insert();

        CLEAR(IRS1099FormBox);
        IRS1099FormBox.Code := 'NEC-01';
        IRS1099FormBox.Description := 'Payer made direct sales of $5000 or more of consumer products';
        IRS1099FormBox."Minimum Reportable" := 5000;
        IRS1099FormBox.Insert();

        CLEAR(IRS1099FormBox);
        IRS1099FormBox.Code := 'NEC-04';
        IRS1099FormBox.Description := 'Federal income tax withheld';
        IRS1099FormBox."Minimum Reportable" := 0;
        IRS1099FormBox.Insert();

        // [WHEN] The upgrade trigger is called
        HybridReplicationSummary.Init();
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The 1099 records are unchanged
        Assert.AreEqual(3, IRS1099FormBox.Count(), 'Unexpected count of records.');
        IRS1099FormBox.Get('DIV-07');
        IRS1099FormBox.Get('NEC-01');
        IRS1099FormBox.Get('NEC-04');
    end;

    // [Test]
    procedure SalesDocumentCFDIFieldsGetUpdated()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] CA data migration (14x -> 15x) runs upgrade code for the CFDI fields on sales documents
        // [GIVEN] Customer records exist with a CFDI purpose
        SalesHeader.FindFirst();
        Customer.Get(SalesHeader."Bill-to Customer No.");
        Customer."CFDI Purpose" := 'CHG';
        Customer."CFDI Relation" := 'DEU';
        Customer.Modify();

        // [WHEN] The data migration upgrade trigger is called
        HybridReplicationSummary.Init();
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The Sales Header record is updated
        with SalesHeader do begin
            FindFirst(); // Refresh the record
            Assert.AreEqual('CHG', "CFDI Purpose", FieldName("CFDI Purpose"));
            Assert.AreEqual('DEU', "CFDI Relation", FieldName("CFDI Relation"));
        end;
    end;

    // [Test]
    procedure ServiceDocumentCFDIFieldsGetUpdated()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] CA data migration (14x -> 15x) runs upgrade code for the CFDI fields on service documents
        // [GIVEN] Customer records exist with a CFDI purpose
        Customer.FindFirst();
        Customer."CFDI Purpose" := 'CHG';
        Customer."CFDI Relation" := 'DEU';
        Customer.Modify();

        // [GIVEN] Service header record exists for the customer.
        ServiceHeader.Init();
        ServiceHeader."Bill-to Customer No." := Customer."No.";
        ServiceHeader.Insert();

        // [WHEN] The data migration upgrade trigger is called
        HybridReplicationSummary.Init();
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The Service Header record is updated
        with ServiceHeader do begin
            SetRange("Bill-to Customer No.", Customer."No.");
            FindFirst(); // Refresh the record
            Assert.AreEqual('CHG', "CFDI Purpose", FieldName("CFDI Purpose"));
            Assert.AreEqual('DEU', "CFDI Relation", FieldName("CFDI Relation"));
        end;
    end;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] CA table mapping for 15.0 to 16.0 upgrade
        LibraryHybridBCLast.InitializeMapping(15.0);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with staged tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, true);
        Assert.AreEqual(1, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
    end;

    [Test]
    procedure VerifyMappedTablesUnstaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] CA table mapping for 15.0 to 16.0 upgrade
        LibraryHybridBCLast.InitializeMapping(15.0);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with the correct tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, false);
        Assert.AreEqual(1, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

    [Test]
    procedure DataExchDefTransformsData()
    var
        StgDataExchDef: Record "Stg Data Exch Def CA";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] All Staging Data Exch. Def records where Type = 5 should be set to 10000
        // All Staging Data Exch. Def records where Type = 6 should be set to 5

        // [GIVEN] Some Staging records have been created
        StgDataExchDef.DeleteAll();
        StgDataExchDef.Init();
        StgDataExchDef.Type := 5;
        StgDataExchDef.Code := '1';
        StgDataExchDef.Insert();

        StgDataExchDef.Init();
        StgDataExchDef.Type := 6;
        StgDataExchDef.Code := '2';
        StgDataExchDef.Insert();

        // [WHEN] The data load is triggered
        W1CompanyHandler.OnTransformPerCompanyTableDataForVersion(CountryCodeTxt, 16.0);

        // [THEN] Staging Data Exch. Def records where Type=5 should now be 10000. 
        // Staging Data Exch. Def records where Type=6 should now be 5.
        StgDataExchDef.SetRange(Type, 10000);
        Assert.AreEqual(1, StgDataExchDef.Count(), 'Unexpected quantity of Data Exch. Def records, Type=1000');

        StgDataExchDef.Reset();
        StgDataExchDef.SetRange(Type, 5);
        Assert.AreEqual(1, StgDataExchDef.Count(), 'Unexpected quantity of Data Exch. Def records, Type=6');
    end;

    [Test]
    procedure DataExchDefLoadsData()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        DataExchDef: Record "Data Exch. Def";
        StgDataExchDef: Record "Stg Data Exch Def CA";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        // [SCENARIO] All Data Exch. Def records where Type = 5 should be set to 10000
        // All Data Exch. Def records where Type = 6 should be set to 5
        HybridReplicationSummary.Init();

        // [GIVEN] Some Staging records have been created and transformed
        StgDataExchDef.DeleteAll();
        StgDataExchDef.Init();
        StgDataExchDef.Type := 10000;
        StgDataExchDef.Code := '1';
        StgDataExchDef.Insert();

        StgDataExchDef.Init();
        StgDataExchDef.Type := 5;
        StgDataExchDef.Code := '2';
        StgDataExchDef.Insert();

        // [GIVEN] Primary contents of table have been replicated
        DataExchDef.DeleteAll();
        DataExchDef.Init();
        DataExchDef.Type := 5;
        DataExchDef.Code := '1';
        DataExchDef.Insert();

        DataExchDef.Init();
        DataExchDef.Type := 6;
        DataExchDef.Code := '2';
        DataExchDef.Insert();

        // [WHEN] The data load is triggered
        W1DataLoad.LoadTableData(HybridReplicationSummary, CountryCodeTxt);

        // [THEN] Data Exch. Def records where Type=5 should now be 10000. Data Exch. Def records where Type=6 should now be 5.
        DataExchDef.SetRange(Type, 10000);
        Assert.AreEqual(1, DataExchDef.Count(), 'Unexpected quantity of Data Exch. Def records, Type=1000');

        DataExchDef.Reset();
        DataExchDef.SetRange(Type, 5);
        Assert.AreEqual(1, DataExchDef.Count(), 'Unexpected quantity of Data Exch. Def records, Type=6');

        Assert.AreEqual(0, StgDataExchDef.Count(), 'Staging table should be emptied.');
    end;
}