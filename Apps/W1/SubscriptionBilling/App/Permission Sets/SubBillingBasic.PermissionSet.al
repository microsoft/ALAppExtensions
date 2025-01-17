namespace Microsoft.SubscriptionBilling;

permissionset 8054 "Sub. Billing Basic"
{
    Assignable = true;
    Caption = 'Subscription Billing Basic', MaxLength = 30;

    Permissions =
        tabledata "Service Contract Setup" = R,
        tabledata "Customer Contract" = R,
        tabledata "Contract Type" = R,
        tabledata "Contract Renewal Line" = R,
        tabledata "Overdue Service Commitments" = R,
        tabledata "Planned Service Commitment" = R,
        tabledata "Service Commitment Template" = R,
        tabledata "Service Commitment Package" = R,
        tabledata "Service Comm. Package Line" = R,
        tabledata "Service Object" = R,
        tabledata "Item Serv. Commitment Package" = R,
        tabledata "Service Commitment" = R,
        tabledata "Billing Template" = R,
        tabledata "Billing Line" = R,
        tabledata "Customer Contract Line" = R,
        tabledata "Vendor Contract" = R,
        tabledata "Billing Line Archive" = R,
        tabledata "Vendor Contract Line" = R,
        tabledata "Customer Contract Deferral" = R,
        tabledata "Sales Service Commitment" = R,
        tabledata "Sales Service Comm. Archive" = R,
        tabledata "Subscription Billing Cue" = R,
        tabledata "Vendor Contract Deferral" = R,
        tabledata "Service Commitment Archive" = R,
        tabledata "Price Update Template" = R,
        tabledata "Contract Price Update Line" = R,
        tabledata "Item Templ. Serv. Comm. Pack." = R,
        tabledata "Field Translation" = R,
        tabledata "Contract Analysis Entry" = R;
}
