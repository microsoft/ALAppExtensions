namespace Microsoft.SubscriptionBilling;

permissionset 8051 "Sub. Billing Admin"
{
    Assignable = true;
    Caption = 'Subscription Billing Admin', MaxLength = 30;

    IncludedPermissionSets = "Sub. Billing User";

    Permissions =
        tabledata "Service Contract Setup" = IMD,
        tabledata "Contract Type" = IMD,
        tabledata "Service Commitment Template" = IMD,
        tabledata "Service Commitment Package" = IMD,
        tabledata "Service Comm. Package Line" = IMD,
        tabledata "Item Templ. Serv. Comm. Pack." = IMD,
        tabledata "Generic Import Settings" = IMD;
}