#pragma warning disable AA0247
codeunit 4711 "Install VAT Group"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        VATGroupUpgradeTags: Codeunit "VAT Group Upgrade Tags";
    begin
        if not UpgradeTag.HasUpgradeTag(VATGroupUpgradeTags.GetVATGroupAuthEnumRenameUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(VATGroupUpgradeTags.GetVATGroupAuthEnumRenameUpgradeTag());
    end;
}
