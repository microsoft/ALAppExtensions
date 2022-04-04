codeunit 10805 "Upgrade Dtld. CV FR"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for FR.
        // Matching file: .\App\Layers\FR\BaseApp\Upgrade\UPGFR.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpgradeDetailedCVLedgerEntries();
    end;

    local procedure UpgradeDetailedCVLedgerEntries()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpgradeDetailedCVLedgerEntriesTag()) then
            exit;

        Codeunit.Run(Codeunit::"Update Dtld. CV Ledger Entries");
        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpgradeDetailedCVLedgerEntriesTag());
    end;
}

