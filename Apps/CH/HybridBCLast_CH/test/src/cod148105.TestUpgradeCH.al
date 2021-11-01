codeunit 148105 "Test Upgrade CH"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridBCLast: Codeunit "Library - Hybrid BC Last";
        CountryCodeTxt: Label 'CH', Locked = true;

    local procedure Initialize()
    var
        UpgradeTagLibrary: Codeunit "Upgrade Tag Library";
    begin
        UpgradeTagLibrary.DeleteAllUpgradeTags();
    end;

    [Test]
    procedure VerifyMappedTablesStaged()
    var
        SourceTableMapping: Record "Source Table Mapping";
    begin
        // [SCENARIO 287703] Swiss extension maps tables that need to be staged
        Initialize();
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
        // [SCENARIO 287703] Swiss extension maps tables that have moved to W1
        Initialize();
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
        Initialize();
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
        Initialize();
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

    [Test]
    procedure CurrencyIsoCodeMovesToNewField()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        Currency: Record Currency;
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] When migration upgrade logic is run, the ISO Currency Code field is moved to the new W1 field.
        Initialize();
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [GIVEN] A currency record exists with the old field populated.
        Currency.Init();
        Currency.Code := '1337';
        Currency."ISO Currency Code" := 'CHF';
        Currency.Insert();

        // [WHEN] The upgrade logic is triggered.
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The ISO Currency Code value is moved to the new ISO Code field in W1.
        Currency.Get('1337');
        Assert.AreEqual('CHF', Currency."ISO Code", Currency.FieldName("ISO Code"));
    end;

    [Test]
    procedure ItemBlockedMovesToNewFields()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        Item: Record Item;
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] When migration upgrade logic is run, the old blocked fields are moved to the W1 fields.
        Initialize();
        LibraryHybridBCLast.InitializeMapping(14.5);

        // [GIVEN] An item record exists with the old blocked fields populated.
        Item.Init();
        Item."No." := '1337';
        Item."Sale Blocked" := true;
        Item."Purchase Blocked" := true;
        Item.Insert();

        // [WHEN] The upgrade logic is triggered.
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The new block fields get set based on the old values.
        Item.Get('1337');
        Assert.IsTrue(Item."Sales Blocked", Item.FieldName("Sales Blocked"));
        Assert.IsTrue(Item."Purchasing Blocked", Item.FieldName("Purchasing Blocked"));
    end;
}