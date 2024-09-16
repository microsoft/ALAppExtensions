namespace Microsoft.SubscriptionBilling;

permissionset 8053 "Sub. Billing User"
{
    Assignable = true;
    Caption = 'Subscription Billing User', MaxLength = 30;

    Permissions =
        tabledata "Customer Contract" = IMD,
        tabledata "Contract Renewal Line" = IMD,
        tabledata "Overdue Service Commitments" = IMD,
        tabledata "Planned Service Commitment" = IMD,
        tabledata "Service Object" = IMD,
        tabledata "Item Serv. Commitment Package" = IMD,
        tabledata "Service Commitment" = IMD,
        tabledata "Billing Template" = IMD,
        tabledata "Billing Line" = IMD,
        tabledata "Customer Contract Line" = IMD,
        tabledata "Vendor Contract" = IMD,
        tabledata "Billing Line Archive" = IMD,
        tabledata "Vendor Contract Line" = IMD,
        tabledata "Customer Contract Deferral" = IMD,
        tabledata "Sales Service Commitment" = IMD,
        tabledata "Sales Service Comm. Archive" = IMD,
        tabledata "Vendor Contract Deferral" = IMD,
        tabledata "Service Commitment Archive" = IMD,
        tabledata "Price Update Template" = IMD,
        tabledata "Contract Price Update Line" = IMD,
        tabledata "Field Translation" = IMD,
        tabledata "Contract Analysis Entry" = IMD;
}
