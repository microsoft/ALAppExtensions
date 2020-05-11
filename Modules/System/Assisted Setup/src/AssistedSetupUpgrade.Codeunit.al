codeunit 1807 "Assisted Setup Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        AssistedSetup: Record "Assisted Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        AssistedSetupUpgradeTag: Codeunit "Assisted Setup Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag()) then
            exit;

        AssistedSetup.DeleteAll();

        UpgradeTag.SetUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag());
    end;
}