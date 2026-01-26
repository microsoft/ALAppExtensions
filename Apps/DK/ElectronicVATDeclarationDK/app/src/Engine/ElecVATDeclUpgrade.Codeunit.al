namespace Microsoft.Finance.VAT.Reporting;

using System.Upgrade;

codeunit 13669 "Elec. VAT Decl. Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    begin
        UpgradeUseAKVSetup();
    end;

    local procedure UpgradeUseAKVSetup()
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetElecVATDeclAKVSetupUpgradeTag()) then
            exit;

        if not ElecVATDeclSetup.Get() then
            exit;

        ElecVATDeclSetup."Use Azure Key Vault" := true;
        ElecVATDeclSetup.Modify();

        UpgradeTag.SetUpgradeTag(GetElecVATDeclAKVSetupUpgradeTag());
    end;


    procedure GetElecVATDeclAKVSetupUpgradeTag(): Code[250];
    begin
        exit('MS-537717-ElecVATDeclSetupWithAKVVariableTag-20250609');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetElecVATDeclAKVSetupUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetElecVATDeclAKVSetupUpgradeTag());
    end; 
}