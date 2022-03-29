codeunit 4051 "Upg Mig Named Forward Links"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
        // Matching file: .\App\Layers\W1\BaseApp\Upgrade\UpgLoadNamedForwardLinks.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        LoadForwardLinks();
    end;

    procedure LoadForwardLinks()
    var
        NamedForwardLink: Record "Named Forward Link";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        IF UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetLoadNamedForwardLinksUpgradeTag()) THEN
            exit;

        NamedForwardLink.Load();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetLoadNamedForwardLinksUpgradeTag());
    end;
}
