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
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for BE runs the correct upgrade code for the purch payables setup table.
        // [GIVEN] A purchase payables setup record exists and has an anticipated code upgrade
        Initialize();
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Copy Line Descr. to G/L Entry" := false;
        PurchasesPayablesSetup.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The table is appropriately transformed
        PurchasesPayablesSetup.Get();
        Assert.IsTrue(PurchasesPayablesSetup."Copy Line Descr. to G/L Entry", PurchasesPayablesSetup.FieldName("Copy Line Descr. to G/L Entry"));
    end;
}