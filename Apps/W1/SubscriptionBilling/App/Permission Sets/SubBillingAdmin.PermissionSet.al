namespace Microsoft.SubscriptionBilling;

permissionset 8051 "Sub. Billing Admin"
{
    Assignable = true;
    Caption = 'Subscription Billing Admin', MaxLength = 30;

    IncludedPermissionSets = "Sub. Billing User";

    Permissions =
        tabledata "Subscription Contract Setup" = IMD,
        tabledata "Subscription Contract Type" = IMD,
        tabledata "Sub. Package Line Template" = IMD,
        tabledata "Subscription Package" = IMD,
        tabledata "Subscription Package Line" = IMD,
        tabledata "Item Templ. Sub. Package" = IMD,
        tabledata "Generic Import Settings" = IMD;
}