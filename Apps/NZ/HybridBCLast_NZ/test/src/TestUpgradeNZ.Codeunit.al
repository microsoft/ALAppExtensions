codeunit 139913 "Test Upgrade NZ"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        CountryCodeTxt: Label 'NZ', Locked = true;

    [Test]
    procedure UpgradeSetsCopyLineDescrToGLEntry()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for NZ runs the correct upgrade code for the setup tables.
        // [GIVEN] The setup records exist and have an anticipated code upgrade
        PurchSetup.Get();
        PurchSetup."Copy Line Descr. to G/L Entry" := false;
        PurchSetup.Modify();

        SalesSetup.Get();
        SalesSetup."Copy Line Descr. to G/L Entry" := false;
        SalesSetup.Modify();

        ServiceMgtSetup.Get();
        ServiceMgtSetup."Copy Line Descr. to G/L Entry" := false;
        ServiceMgtSetup.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The tables are appropriately transformed
        PurchSetup.Get();
        Assert.IsTrue(PurchSetup."Copy Line Descr. to G/L Entry", PurchSetup.FieldName("Copy Line Descr. to G/L Entry"));
        SalesSetup.Get();
        Assert.IsTrue(SalesSetup."Copy Line Descr. to G/L Entry", SalesSetup.FieldName("Copy Line Descr. to G/L Entry"));
        ServiceMgtSetup.Get();
        Assert.IsTrue(ServiceMgtSetup."Copy Line Descr. to G/L Entry", ServiceMgtSetup.FieldName("Copy Line Descr. to G/L Entry"));
    end;
}