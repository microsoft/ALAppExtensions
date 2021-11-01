codeunit 148107 "Test Upgrade BE"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        CountryCodeTxt: Label 'BE', Locked = true;

    local procedure Initialize()
    var
        UpgradeTagLibrary: Codeunit "Upgrade Tag Library";
    begin
        UpgradeTagLibrary.DeleteAllUpgradeTags();
    end;

    [Test]
    procedure UpgradeSetsPurchPayableSetup()
    var
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for BE runs the correct upgrade code for the purch payables setup table.
        // [GIVEN] A purchase payables setup record exists and has an anticipated code upgrade
        Initialize();
        PurchasePayablesSetup.Get();
        PurchasePayablesSetup."Copy Line Descr. to G/L Entry" := false;
        PurchasePayablesSetup.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The table is appropriately transformed
        PurchasePayablesSetup.Get();
        Assert.IsTrue(PurchasePayablesSetup."Copy Line Descr. to G/L Entry", PurchasePayablesSetup.FieldName("Copy Line Descr. to G/L Entry"));
    end;

    [Test]
    procedure UpgradeMovesCurrencyISOCode()
    var
        Currency: Record "Currency";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for BE runs the correct upgrade code for the currency iso code field.
        // [GIVEN] A Currency record exists with the old ISO field populated
        Initialize();
        Currency.FindFirst();
        Currency."ISO Currency Code" := 'NEW';
        Currency.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The data is moved into the new field
        Currency.FindFirst();
        Assert.AreEqual('NEW', Currency."ISO Code", Currency.FieldName("ISO Code"));
        Assert.AreEqual('', Currency."ISO Currency Code", Currency.FieldName("ISO Currency Code"));
    end;

    [Test]
    procedure UpgradeMovesCountryRegionISOCode()
    var
        CountryRegion: Record "Country/Region";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for BE runs the correct upgrade code for the Country/Region iso code field.
        // [GIVEN] A Country/Region record exists with the old ISO field populated
        Initialize();
        CountryRegion.FindFirst();
        CountryRegion."ISO Country/Region Code" := 'NE';
        CountryRegion.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The data is moved into the new field
        CountryRegion.FindFirst();
        Assert.AreEqual('NE', CountryRegion."ISO Code", CountryRegion.FieldName("ISO Code"));
        Assert.AreEqual('', CountryRegion."ISO Country/Region Code", CountryRegion.FieldName("ISO Country/Region Code"));
    end;

}