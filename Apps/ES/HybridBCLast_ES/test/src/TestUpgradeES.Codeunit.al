codeunit 148111 "Test Upgrade ES"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'ES', Locked = true;
        TestCertTxt: Label 'MIIFMQIBAzCCBPcGCSqGSIb3DQEHAaCCBOgEggTkMIIE4DCCAv8GCSqGSIb3DQEHBqCCAvAwggLsAgEAMIIC5QYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQInoKB6qoKZIQCAggAgIICuF9ZKEqoyo2dKPmAYqXL+Cf35+SDMgXxhRc89HKDXQ4va5umT+wBsy51FRxRahSiKksHmqRSLfZwTKEcQvSaOTyJdT0pL4uV5WNajrneiqw8JbdJYK57YLqol+92doBECbPMxQwZUuC2oZo3cyWJJBi3ehIqEOeSfYVBcDDCQrGy+ggmKfcYeDwjS9XDCnBO9xgl462J2w02tm/KW1rC1926xyVvmzspTdL0QFSc6t810oZ/f9L4/F04mRdvlbuR7RU09jHFSzLm5D2ybtXJd/B9YhwwGNQkfp/dPxq17Z7b4usEjXJWO7TwJtduOGXadznQJIVihWZBYBsqVI3mABh5FVZWrwdPGhfVOaeDhvAiqpKLA2+aewFuT7unaKSsjoOGHFvHF4RiiTCR/ag+2sHQPqpSUQJdlQjmiZ1F8tbpzuhJdBLY/i5Iqs13sk3zPrwP1oqwv9Xp3gd6hjktHNWyTrI/0LZct9REvJznOeLnKct0EhWuDuY4L24ZRjrMgBqNCgkm4hcUfhiOAlbYaMMVFWbUzA+6dEgwcltIp1gSZbhj8aB8MP/1fT8VjyhJsSE4p6wsqsgTpd27zsenJcLgyu7COjSstmkQ3qeIwNS/x9zuEinxzA7t3II1kROJz0nTqtQi4IgcBjb/2DiD2QwCLD4NvbbR7hWjDrUTOgtmgxrhn3qfsemDe2bQw3/ZJkKZrJO9fJzkhwXQWv7aj+4Nf1wxYIOcxKp30lB3zcKrTlBkNsmZDnVNEU7UwN8qAWkMyvWdyZaBW1TgbVer1D+YSGxXMqPesm7IJ+HBYJBUuC6xyXmOJ8QScNcIWHUDFUpb2Hg2Vw64y7nyPgxdb3C9zquM2TPAKUKEQylOGwTtzgd+73wVvoqLZbo0DXe9ZXrT/GRlac1mFP0lbF1GoAYOGgSbJoWF8jCCAdkGCSqGSIb3DQEHAaCCAcoEggHGMIIBwjCCAb4GCyqGSIb3DQEMCgECoIIBhjCCAYIwHAYKKoZIhvcNAQwBAzAOBAhJN3StWPRixwICCAAEggFg42+YWXJTaw52YnkoBFZMN5zWdMa6HlsJHV4FYbaCKE8NKTuxKibLWU/f0qgOJwo9fxy503Xz22wnEL7xRU2B9JblrlGrHlix0mswt/QU4rjhfzpYIv6kfOIHE8zKacQYdy2zDUXax54gX+Dj8m2dE22l+gCRZHqkYymV1nMdWJsqFRAiV2EsSwGLLZovYqp0/fVUxry7bYUCnu+yj9wkYr53LZ9O4EFUePDoJXMvGasPeB7876xDnVWdzQA6jZne0syZ8tH6q7/0wckPn0SvFfhphYqHFKlCc0FDCk/Nsxjod0A1PZz8HMueHJO1Jo3oODYMktI+HVCAC9UUqcmrW4jBBczEzKtCPyDgZkiP6xYU5AHUcBomHO94KHE5X5mZdgXblTRM1zc0uJS2CrBx4jc59s28S/bWABKduqNcczEnBuLyUsYKxX5/WkTmqSPdaJkU2xrfA/PcOTUodzYJVTElMCMGCSqGSIb3DQEJFTEWBBTxYMwv+lUDqlEPcjZoIfCnM5GzbzAxMCEwCQYFKw4DAhoFAAQU+06w2rleuz30pmANAqG7IHZX8q0ECF8gd+t0FeE8AgIIAA==';

    local procedure Initialize()
    var
        UpgradeTagLibrary: Codeunit "Upgrade Tag Library";
    begin
        UpgradeTagLibrary.DeleteAllUpgradeTags();
    end;

    [Test]
    procedure VerifyEmployeeTableUpgraded()
    var
        Employee: Record Employee;
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Employee name fields get transformed during the upgrade process
        // [GIVEN] Employee records exist
        Initialize();
        Employee.Init();
        Employee."No." := 'Test';
        Employee."First Name" := 'First';
        Employee."Middle Name" := 'Middle';
        Employee."Last Name" := 'Last';
        Employee.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The corresponding name fields are populated in the Employee record
        Employee.Get('Test');
        Assert.AreEqual('First', Employee.Name, Employee.FieldName(Name));
        Assert.AreEqual('Middle', Employee."Second Family Name", Employee.FieldName("Second Family Name"));
        Assert.AreEqual('Last', Employee."First Family Name", Employee.FieldName("First Family Name"));
    end;

    [Test]
    procedure VerifyNoTaxableVATEntriesUpdated()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] No taxable VAT Entries get modified during the upgrade process
        // [GIVEN] A 'No Taxable Type' VAT Posting Setup record exists
        Initialize();
        VATPostingSetup.Init();
        VATPostingSetup."VAT Bus. Posting Group" := 'BUS';
        VATPostingSetup."VAT Prod. Posting Group" := 'PROD';
        VATPostingSetup."No Taxable Type" := VATPostingSetup."No Taxable Type"::"Non Taxable Due To Localization Rules";
        VATPostingSetup.Insert();

        // [GIVEN] A corresponding VAT Entry record exists
        VATEntry.Init();
        VATEntry."Entry No." := 1337;
        VATEntry."VAT Bus. Posting Group" := 'BUS';
        VATEntry."VAT Prod. Posting Group" := 'PROD';
        VATEntry."No Taxable Type" := VATEntry."No Taxable Type"::" "; // Should get updated during upgrade
        VATEntry.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The 'No Taxable Type' is update on the VAT Entry to reflect that of the Posting Setup record
        VATEntry.Get(1337);
        Assert.AreEqual(VATEntry."No Taxable Type", VATEntry."No Taxable Type"::"Non Taxable Due To Localization Rules", 'Not updated');
    end;

    [Test]
    procedure VerifySIISetupTableUpgraded()
    var
        SIISetup: Record "SII Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] SII Setup fields get transformed during the upgrade process
        // [GIVEN] SII Setup records exist
        Initialize();
        SIISetup.Init();
        SIISetup."Primary Key" := '1';
        SIISetup.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 16.0);

        // [THEN] The corresponding name fields are populated in the SII Setup record
        SIISetup.Get('1');
        Assert.IsFalse(SIISetup."SuministroInformacion Schema" = '', 'SuministroInformacion Schema should not be empty.');
        Assert.IsFalse(SIISetup."SuministroLR Schema" = '', 'SuministroLR Schema should not be empty.');
    end;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] ES table mapping for 15.0 to 16.0 upgrade
        Initialize();
        LibraryHybridBCLast.InitializeMapping(15.0);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with staged tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, true);
        Assert.AreEqual(2, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
    end;

    [Test]
    procedure VerifyMappedTablesUnstaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] ES table mapping for 15.0 to 16.0 upgrade
        Initialize();
        LibraryHybridBCLast.InitializeMapping(15.0);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with the correct tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, false);
        Assert.AreEqual(2, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

#pragma warning disable AL0432
    [Test]
    procedure SIISetupLoadsData()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        SIISetup: Record "SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        StgSIISetup: Record "Stg SII Setup";
        W1DataLoad: Codeunit "W1 Data Load";
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
    begin
        // [SCENARIO] The certificate from the SII Setup staging table is correctly loaded
        // into the Isolated Certificate table. The "Certificate Code" field on the SII Setup
        // is set correctly.
        Initialize();
        HybridReplicationSummary.Init();

        // [GIVEN] A staging record has been created and transformed
        StgSIISetup.DeleteAll();
        StgSIISetup.Init();
        StgSIISetup."Primary Key" := '1';
        StgSIISetup.Certificate.CreateOutStream(OutStream);
        Base64Convert.FromBase64(TestCertTxt, OutStream);
        StgSIISetup.Password := 'test1234';
        StgSIISetup.Insert();

        // [GIVEN] Primary contents of table have been replicated
        SIISetup.DeleteAll();
        SIISetup.Init();
        SIISetup."Primary Key" := '1';
        SIISetup.Insert();

        // [WHEN] The data load is triggered
        W1DataLoad.LoadTableData(HybridReplicationSummary, CountryCodeTxt);

        // [THEN] An Isolated Certificate should have been created and the "Certificate Code" should be set.
        with SIISetup do begin
            Get('1');
            IsolatedCertificate.Get("Certificate Code");
            Assert.AreEqual(IsolatedCertificate.Code, "Certificate Code", 'Certificate Code should be set.');
        end;

        Assert.AreEqual(0, StgSIISetup.Count(), 'Staging table should be emptied.');
    end;
#pragma warning restore AL0432
}