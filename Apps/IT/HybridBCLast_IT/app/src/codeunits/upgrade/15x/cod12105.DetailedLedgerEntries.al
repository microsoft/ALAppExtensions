codeunit 12105 "Detailed Ledger Entries IT"
{
    Permissions = TableData "Detailed Cust. Ledg. Entry" = rm,
                  TableData "Detailed Vendor Ledg. Entry" = rm;
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for IT.
        // Matching file: .\App\Layers\IT\BaseApp\Upgrade\upgledgerentriesit.codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpgradeDetailedVendorLedgerEntries();
        UpgradeDetailedCustomerLedgerEntries();
    end;

    procedure UpgradeDetailedVendorLedgerEntries();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        if VendorLedgerEntry.FindSet() then
            repeat
                DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
                DetailedVendorLedgEntry.ModifyAll("Original Document No.", VendorLedgerEntry."Document No.");
                DetailedVendorLedgEntry.ModifyAll("Original Document Type", VendorLedgerEntry."Document Type");
            until VendorLedgerEntry.Next() = 0;
    end;

    procedure UpgradeDetailedCustomerLedgerEntries();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        if CustLedgerEntry.FindSet() then
            repeat
                DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
                DetailedCustLedgEntry.ModifyAll("Original Document No.", CustLedgerEntry."Document No.");
                DetailedCustLedgEntry.ModifyAll("Original Document Type", CustLedgerEntry."Document Type");
            until CustLedgerEntry.Next() = 0;
    end;
}

