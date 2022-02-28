#if not CLEAN20
codeunit 10711 "UPG SII ES"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for ES.
        // Matching file: .\App\Layers\ES\BaseApp\Upgrade\UPGSII.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpdateEmployeeNewNames();
    end;

    local procedure UpdateEmployeeNewNames()
    var
        Employee: Record "Employee";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpdateEmployeeNewNamesTag()) then
            exit;

        if Employee.FindSet() then
            repeat
                Employee.UpdateNamesFromOldFields();
#pragma warning disable AA0214                
                Employee.Modify();
#pragma warning restore AA0214                
            until Employee.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpdateEmployeeNewNamesTag());
    end;
}
#endif