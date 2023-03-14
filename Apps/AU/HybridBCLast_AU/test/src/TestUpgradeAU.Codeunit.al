codeunit 139910 "Test Upgrade AU"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        CountryCodeTxt: Label 'AU', Locked = true;

    [Test]
    procedure UpgradeSetsCopyLineDescrToGLEntry()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for AU runs the correct upgrade code for the setup tables.
        // [GIVEN] The setup records exist and have an anticipated code upgrade
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Copy Line Descr. to G/L Entry" := false;
        PurchasesPayablesSetup.Modify();

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Copy Line Descr. to G/L Entry" := false;
        SalesReceivablesSetup.Modify();

        ServiceMgtSetup.Get();
        ServiceMgtSetup."Copy Line Descr. to G/L Entry" := false;
        ServiceMgtSetup.Modify();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The tables are appropriately transformed
        PurchasesPayablesSetup.Get();
        Assert.IsTrue(PurchasesPayablesSetup."Copy Line Descr. to G/L Entry", PurchasesPayablesSetup.FieldName("Copy Line Descr. to G/L Entry"));
        SalesReceivablesSetup.Get();
        Assert.IsTrue(SalesReceivablesSetup."Copy Line Descr. to G/L Entry", SalesReceivablesSetup.FieldName("Copy Line Descr. to G/L Entry"));
        ServiceMgtSetup.Get();
        Assert.IsTrue(ServiceMgtSetup."Copy Line Descr. to G/L Entry", ServiceMgtSetup.FieldName("Copy Line Descr. to G/L Entry"));
    end;
}