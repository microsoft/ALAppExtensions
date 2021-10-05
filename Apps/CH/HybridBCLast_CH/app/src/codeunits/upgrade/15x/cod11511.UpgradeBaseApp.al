codeunit 11511 "Upgrade BaseApp"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for CH.
        // Matching file: .\App\Layers\CH\BaseApp\Upgrade\UpgradeBaseApp.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        // Special logic needed here for CH to move the blocked fields
        UpdateItems();
    end;

    local procedure UpdateItems()
    var
        Item: Record Item;
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetItemCategoryOnItemAPIUpgradeTag()) then
            exit;

        with Item do begin
            FilterGroup(-1);
            SetRange("Sale blocked", true);
            SetRange("Purchase blocked", true);
            if FindSet(true, false) then
                repeat
                    Validate("Sales Blocked", "Sale blocked");
                    Validate("Purchasing Blocked", "Purchase blocked");
                    if Modify() then;
                until Next() = 0;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetItemCategoryOnItemAPIUpgradeTag());
    end;
}