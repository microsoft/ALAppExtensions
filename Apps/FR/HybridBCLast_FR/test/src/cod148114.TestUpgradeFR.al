codeunit 148114 "Test Upgrade FR"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        CountryCodeTxt: Label 'FR', Locked = true;

    [Test]
    procedure UpgradeSetsDetailedCustomerLedgerEntries()
    var
        Customer: Record Customer;
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for FR correctly updates customer ledger entries.
        // [GIVEN] The base records exist and have an anticipated code upgrade
        Customer.FindFirst();
        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Entry No." := 1337;
        DetailedCustLedgEntry."Customer No." := Customer."No.";
        DetailedCustLedgEntry."Entry Type" := DetailedCustLedgEntry."Entry Type"::"Unrealized Gain";
        DetailedCustLedgEntry.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The tables are appropriately transformed
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        DetailedCustLedgEntry.Get(1337);
        Assert.AreEqual(DetailedCustLedgEntry."Curr. Adjmt. G/L Account No.", CustomerPostingGroup."Receivables Account", 'Field not updated.');
    end;

    [Test]
    procedure UpgradeSetsDetailedVendorLedgerEntries()
    var
        Vendor: Record Vendor;
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
    begin
        // [SCENARIO] Data migration for FR correctly updates vendor ledger entries.
        // [GIVEN] The base records exist and have an anticipated code upgrade
        Vendor.FindFirst();
        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Entry No." := 1337;
        DetailedVendorLedgEntry."Vendor No." := Vendor."No.";
        DetailedVendorLedgEntry."Entry Type" := DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain";
        DetailedVendorLedgEntry.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The tables are appropriately transformed
        VendorPostingGroup.Get(Vendor."Vendor Posting Group");
        DetailedVendorLedgEntry.Get(1337);
        Assert.AreEqual(DetailedVendorLedgEntry."Curr. Adjmt. G/L Account No.", VendorPostingGroup."Payables Account", 'Field not updated.');
    end;
}