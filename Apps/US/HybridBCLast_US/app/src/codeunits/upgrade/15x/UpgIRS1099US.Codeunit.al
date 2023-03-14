codeunit 10034 "Upg. IRS 1099 US"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for NA.
        // Matching file: .\App\Layers\NA\BaseApp\Upgrade\UPGIRS1099FormBoxes.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        RunIRS1099DIV2018Changes();
    end;

    local procedure RunIRS1099DIV2018Changes()
    var
        UpgradeIRS1099FormBoxes: Codeunit "Upgrade IRS 1099 Form Boxes";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.Get1099DIV2018UpgradeTag()) then
            exit;

        UpgradeIRS1099FormBoxes.Run();
        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.Get1099DIV2018UpgradeTag());
    end;
}

