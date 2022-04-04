#if not CLEAN20
codeunit 4057 "Upg Mig User Callouts"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '20.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnUpgradeNonCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradeNonCompanyUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        PopulateUserCallouts();
    end;

    local procedure PopulateUserCallouts()
    var
        User: Record User;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UserSettings: Codeunit "User Settings";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUserCalloutsUpgradeTag()) then
            exit;

        if User.FindSet() then
            repeat
                UserSettings.DisableTeachingTips(User."User Security ID");
            until (User.Next() = 0);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUserCalloutsUpgradeTag());
    end;
}
#endif