codeunit 139796 "Test Upgrade CZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'CZ', Locked = true;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] CZ extension maps tables that need to be staged
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with staged tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, true);
        Assert.AreEqual(0, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
    end;

    [Test]
    procedure VerifyMappedTablesUnstaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO] CZ extension maps tables that have moved to W1
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with the moved tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, false);
        Assert.AreEqual(0, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;
#if not CLEAN21
    [Test]
    procedure VATPostingSetupTransformsCorrectFields()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] The VAT Posting Setup staging table is correctly transformed.
        HybridReplicationSummary.Init();

        // [GIVEN] A staging record has been created
        with StgVATPostingSetup do begin
            DeleteAll();
            Init();
            StgVATPostingSetup."VAT Bus. Posting Group" := '13';
            StgVATPostingSetup."VAT Prod. Posting Group" := '37';
            StgVATPostingSetup."Insolvency Proceedings (p.44)" := true;
            StgVATPostingSetup.Insert();
        end;

        // [WHEN] The transformation is triggered
        W1CompanyHandler.OnTransformPerCompanyTableDataForVersion(CountryCodeTxt, 15.0);

        // [THEN] The appropriate field transformations have ocurred
        with StgVATPostingSetup do begin
            Get('13', '37');
            Assert.AreEqual("Corrections for Bad Receivable", "Corrections for Bad Receivable"::"Insolvency Proceedings (p.44)", 'Field not updated');
        end;
    end;
#endif
}