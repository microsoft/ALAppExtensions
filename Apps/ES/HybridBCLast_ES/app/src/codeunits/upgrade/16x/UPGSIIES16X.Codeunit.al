#if not CLEAN20
codeunit 11736 "UPG SII ES 16X"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 16.0 then
            exit;

        PopulatedNewFields();
    end;

    local procedure PopulatedNewFields()
    var
        SIISetup: Record "SII Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpdateSIICertificateTag()) then
            exit;

        // This code is based on app upgrade logic for ES.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UPGSII.Codeunit.al
        // Based on commit: 2c1c901e
        if SIISetup.Get() then
            SIISetup.SetDefaults();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpdateSIICertificateTag());
    end;
}
#endif