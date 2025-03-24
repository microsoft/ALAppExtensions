#pragma warning disable AA0247
codeunit 4702 "VAT Group Upgrade Tags"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetVATGroupAuthEnumRenameUpgradeTag());
    end;

    internal procedure GetVATGroupAuthEnumRenameUpgradeTag(): Code[250]
    begin
        exit('MS-446087-GetVATGroupAuthEnumRenameUpgradeTag-20221005');
    end;
}
