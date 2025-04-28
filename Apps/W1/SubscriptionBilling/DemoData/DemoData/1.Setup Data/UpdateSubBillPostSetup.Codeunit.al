namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Common;

codeunit 8107 "Update Sub. Bill. Post. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralPostingSetup();
    end;

    local procedure UpdateGeneralPostingSetup()
    var
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillGLAccount: Codeunit "Create Sub. Bill. GL Account";
    begin
        ContosoSubscriptionBilling.SetOverwriteData(true);
        ContosoSubscriptionBilling.UpdateGeneralPostingSetupWithSubBillingGLAccounts(CommonPostingGroup.Domestic(), CommonPostingGroup.Retail(), CreateSubBillGLAccount.CustomerContractsRevenue(), CreateSubBillGLAccount.CustomerContractsDeferrals(), CreateSubBillGLAccount.VendorContractsCost(), CreateSubBillGLAccount.VendorContractsDeferrals());
        ContosoSubscriptionBilling.SetOverwriteData(false);
    end;
}