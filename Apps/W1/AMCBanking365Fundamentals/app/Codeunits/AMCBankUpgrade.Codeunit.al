codeunit 20119 "AMC Bank Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeAMCConsent();
    end;


    local procedure UpgradeAMCConsent()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAMCConsentUpgradeTag()) then
            exit;

        if AMCBankingSetup.Get() then begin
            AMCBankingSetup."AMC Enabled" := true;
            if AMCBankingSetup.Modify() then;
        end;

        UpgradeTag.SetUpgradeTag(GetAMCConsentUpgradeTag());
    end;



    internal procedure GetAMCConsentUpgradeTag(): Code[250]
    begin
        exit('MS-407087-AMCConsent-20210812');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetAMCConsentUpgradeTag());
    end;
}