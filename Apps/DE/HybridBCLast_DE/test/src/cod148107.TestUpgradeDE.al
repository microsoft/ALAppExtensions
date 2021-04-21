codeunit 148107 "Test Upgrade DE"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'DE', Locked = true;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO 287703] German extension maps tables that need to be staged
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with staged tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, true);
        Assert.AreEqual(0, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

    [Test]
    procedure VerifyMappedTablesUnstaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO 287703] German extension maps tables that have moved to W1
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [WHEN] The extension is installed
        // [THEN] The Source Table Mapping table is populated with the moved tables
        SourceTableMapping.SetRange("Country Code", CountryCodeTxt);
        SourceTableMapping.SetRange(Staged, false);
        Assert.AreEqual(14, SourceTableMapping.Count(), 'Unexpected number of mapped, unstaged tables.');
    end;

    [Test]
    procedure SourceCodeSetupTransformsCorrectFields()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        SourceCodeSetup: Record "Source Code Setup";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO 287703] Source Code Setup table is correctly upgraded
        LibraryHybridBCLast.InitializeMapping(14.5);
        HybridReplicationSummary.Init();

        // [GIVEN] A Source Code Setup record has been created
        with SourceCodeSetup do begin
            DeleteAll();
            "Phys. Invt. Order" := 'PIO';
            Insert();
        end;

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The appropriate field transformations have ocurred
        with SourceCodeSetup do begin
            Get();
            Assert.AreEqual('PIO', "Phys. Invt. Orders", FieldName("Phys. Invt. Orders"));
        end;
    end;

    [Test]
    procedure InventorySetupTransformsCorrectFields()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        InventorySetup: Record "Inventory Setup";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO xxxxxx] Inventory Setup table is correctly upgraded
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [GIVEN] An Inventory Setup record has been created
        HybridReplicationSummary.Init();
        with InventorySetup do begin
            DeleteAll();
            Init();
            "Phys. Inv. Order Nos." := 'PION';
            "Posted Phys. Inv. Order Nos." := 'PPION';
            Insert();
        end;

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The appropriate field transformations have ocurred
        with InventorySetup do begin
            Get();
            Assert.AreEqual('PION', "Phys. Invt. Order Nos.", FieldName("Phys. Invt. Order Nos."));
            Assert.AreEqual('PPION', "Posted Phys. Invt. Order Nos.", FieldName("Posted Phys. Invt. Order Nos."));
        end;
    end;
}