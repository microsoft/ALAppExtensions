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
        Assert.AreEqual(2, SourceTableMapping.Count(), 'Unexpected number of mapped, staged tables.');
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
        Assert.AreEqual(2, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

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

    [Test]
    procedure VATPostingSetupLoadsData()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        VATPostingSetup: Record "VAT Posting Setup";
        StgVATPostingSetup: Record "Stg VAT Posting Setup";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        // [SCENARIO] The VAT Posting Setup staging table is correctly loaded into the real table.
        HybridReplicationSummary.Init();

        // [GIVEN] A staging record has been created and transformed
        with StgVATPostingSetup do begin
            DeleteAll();
            Init();
            StgVATPostingSetup."VAT Bus. Posting Group" := '13';
            StgVATPostingSetup."VAT Prod. Posting Group" := '37';
            StgVATPostingSetup."Corrections for Bad Receivable" := "Corrections for Bad Receivable"::"Insolvency Proceedings (p.44)";
            StgVATPostingSetup.Insert();
        end;

        // [GIVEN] Primary contents of table have been replicated
        VATPostingSetup.Init();
        VATPostingSetup."VAT Bus. Posting Group" := '13';
        VATPostingSetup."VAT Prod. Posting Group" := '37';
        VATPostingSetup.Insert();

        // [WHEN] The data load is triggered
        W1DataLoad.LoadTableData(HybridReplicationSummary, CountryCodeTxt);

        // [THEN] The real table contains the new record
        with VATPostingSetup do begin
            Get('13', '37');
            Assert.AreEqual("Corrections for Bad Receivable", "Corrections for Bad Receivable"::"Insolvency Proceedings (p.44)", 'Field not loaded');
        end;

        Assert.AreEqual(0, StgVATPostingSetup.Count(), 'Staging table should be emptied.');
    end;

    [Test]
    procedure VerifySalesAndRecSetupUpgraded()
    var
        SalesAndRecSetup: Record "Sales & Receivables Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] "Copy Line Descr. To G/L Entry" field on Sales & Receivables Setup get set
        // [GIVEN] Sales & Receivables Setup record exists
        SalesAndRecSetup.DeleteAll();
        SalesAndRecSetup.Init();
        SalesAndRecSetup."Primary Key" := '1';
        SalesAndRecSetup."G/L Entry as Doc. Lines (Acc.)" := true;
        SalesAndRecSetup.Insert();

        // [WHEN] The upgrade trigger is called
        HybridReplicationSummary.Init();
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 16.0);

        // [THEN] The corresponding name fields are populated in the "Sales & Receivables Setup" record
        SalesAndRecSetup.Get('1');
        Assert.AreEqual(true, SalesAndRecSetup."Copy Line Descr. To G/L Entry", SalesAndRecSetup.FieldName("Copy Line Descr. To G/L Entry"));
    end;
}