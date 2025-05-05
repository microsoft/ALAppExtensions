namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Finance;

codeunit 8122 "Create Sub. Bill. Item Templ."
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertItemTemplateData(SubscriptionItem(), SubscriptionItemLbl, Enum::"Item Service Commitment Type"::"Service Commitment Item", '', CreatePostingGroup.RetailPostingGroup(), CreateVATPostingGroups.Standard());
    end;

    procedure SubscriptionItem(): Code[20]
    begin
        exit(SubscriptionItemTok);
    end;

    var
        SubscriptionItemTok: Label 'SUBSCRIPTION', MaxLength = 20;
        SubscriptionItemLbl: Label 'Subscription Item', MaxLength = 100;
}
