codeunit 11109 "Move Order Nos AT"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for DACH.
        // Matching file: .\App\Layers\DACH\BaseApp\Upgrade\UPGLocalFunctionality.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if TargetVersion <> 15.0 then
            exit;

        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetPhysInvntOrdersUpgradeTag()) then
            exit;

        LoadInventorySetup();
        LoadSourceCodeSetup();

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetPhysInvntOrdersUpgradeTag());
    end;

    local procedure LoadInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Phys. Invt. Order Nos." := InventorySetup."Phys. Inv. Order Nos.";
            InventorySetup."Posted Phys. Invt. Order Nos." := InventorySetup."Posted Phys. Inv. Order Nos.";
            InventorySetup.Modify();
        end;
    end;

    local procedure LoadSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Phys. Invt. Orders" := SourceCodeSetup."Phys. Invt. Order";
            SourceCodeSetup.Modify();
        end;
    end;
}