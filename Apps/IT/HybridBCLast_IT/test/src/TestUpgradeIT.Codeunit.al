codeunit 148120 "Test Upgrade IT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        CountryCodeTxt: Label 'IT', Locked = true;

    local procedure Initialize()
    var
        UpgradeTagLibrary: Codeunit "Upgrade Tag Library";
    begin
        UpgradeTagLibrary.DeleteAllUpgradeTags();
    end;

    [Test]
    procedure UpgradeSetsVendorLedgEntries()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
        LibraryRandom: Codeunit "Library - Random";
    begin
        // [SCENARIO] Data migration for IT runs the correct upgrade code for the vendor ledger entries.
        // [GIVEN] Both vendor ledger entry and detailed vendor ledger entries exist.
        Initialize();
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Entry No." := LibraryRandom.RandIntInRange(99000, 100000);
        VendorLedgerEntry."Document No." := '13';
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::"Credit Memo";
        VendorLedgerEntry.Insert();

        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Entry No." := 13371;
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        DetailedVendorLedgEntry.Insert();

        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Entry No." := 13372;
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        DetailedVendorLedgEntry.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The table is appropriately transformed
        DetailedVendorLedgEntry.Get(13371);
        Assert.AreEqual('13', DetailedVendorLedgEntry."Original Document No.", 'Original Document No.');
        Assert.AreEqual(VendorLedgerEntry."Document Type"::"Credit Memo", DetailedVendorLedgEntry."Original Document Type", 'Original Document Type');

        DetailedVendorLedgEntry.Get(13372);
        Assert.AreEqual('13', DetailedVendorLedgEntry."Original Document No.", 'Original Document No.');
        Assert.AreEqual(VendorLedgerEntry."Document Type"::"Credit Memo", DetailedVendorLedgEntry."Original Document Type", 'Original Document Type');
    end;

    [Test]
    procedure UpgradeSetsCustLedgEntries()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1CompanyHandler: Codeunit "W1 Company Handler";
        LibraryRandom: Codeunit "Library - Random";
    begin
        // [SCENARIO] Data migration for IT runs the correct upgrade code for the customer ledger entries.
        // [GIVEN] Both customer ledger entry and detailed customer ledger entries exist.
        Initialize();
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := LibraryRandom.RandIntInRange(99000, 100000);
        CustLedgerEntry."Document No." := '13';
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::"Credit Memo";
        CustLedgerEntry.Insert();

        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Entry No." := 13371;
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        DetailedCustLedgEntry.Insert();

        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Entry No." := 13372;
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        DetailedCustLedgEntry.Insert();

        // [WHEN] The upgrade logic is triggered
        W1CompanyHandler.OnUpgradePerCompanyDataForVersion(HybridReplicationSummary, CountryCodeTxt, 15.0);

        // [THEN] The table is appropriately transformed
        DetailedCustLedgEntry.Get(13371);
        Assert.AreEqual('13', DetailedCustLedgEntry."Original Document No.", 'Original Document No.');
        Assert.AreEqual(CustLedgerEntry."Document Type"::"Credit Memo", DetailedCustLedgEntry."Original Document Type", 'Original Document Type');

        DetailedCustLedgEntry.Get(13372);
        Assert.AreEqual('13', DetailedCustLedgEntry."Original Document No.", 'Original Document No.');
        Assert.AreEqual(CustLedgerEntry."Document Type"::"Credit Memo", DetailedCustLedgEntry."Original Document Type", 'Original Document Type');
    end;

}