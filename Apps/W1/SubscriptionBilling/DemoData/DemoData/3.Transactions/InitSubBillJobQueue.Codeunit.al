namespace Microsoft.SubscriptionBilling;

codeunit 8121 "Init Sub. Bill. Job Queue"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SubBillingModuleSetup: Record "Sub. Billing Module Setup";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        SubBillingModuleSetup.Get();
        if not SubBillingModuleSetup."Create entries in Job Queue" then
            exit;

        ContosoSubscriptionBilling.InitUpdateServicesDatesJobQueueEntry();
    end;
}