namespace Microsoft.SubscriptionBilling;

using System.Upgrade;

codeunit 8032 "Upgrade Subscription Billling"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
        UpdateClosedFlagForServiceCommitments();
    end;

    local procedure UpdateClosedFlagForServiceCommitments()
    var
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
        ServiceCommitment: Record "Service Commitment";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetClosedFlagUpgradeTag()) then
            exit;

        CustomerContractLine.SetLoadFields(Closed);
        CustomerContractLine.SetRange(Closed, true);
        if CustomerContractLine.FindSet() then
            repeat
                if ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.") then begin
                    ServiceCommitment.Closed := CustomerContractLine.Closed;
                    ServiceCommitment.Modify(false);
                end;
            until CustomerContractLine.Next() = 0;

        VendorContractLine.SetLoadFields(Closed);
        VendorContractLine.SetRange(Closed, true);
        if VendorContractLine.FindSet() then
            repeat
                if ServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.") then begin
                    ServiceCommitment.Closed := VendorContractLine.Closed;
                    ServiceCommitment.Modify(false);
                end;
            until VendorContractLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetClosedFlagUpgradeTag());
    end;

    internal procedure GetClosedFlagUpgradeTag(): Code[250]
    begin
        exit('MS-XXXXXX-ClosedFlagUpgradeTag-20241110');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetClosedFlagUpgradeTag());
    end;
}
