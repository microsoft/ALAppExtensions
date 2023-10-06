namespace Microsoft.Bank.Deposit;

using System.Upgrade;

codeunit 1712 "Upg. Tag Def. Bank Deposits"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetNADepositsUpgradeTag());
    end;

    internal procedure GetNADepositsUpgradeTag(): Code[250]
    begin
        exit('478423-NADepositsUpgrade-20230718');
    end;

}