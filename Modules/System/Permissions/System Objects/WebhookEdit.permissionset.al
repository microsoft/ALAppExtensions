permissionset 97 "Webhook - Edit"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Webhook - Read";

    Permissions = tabledata "API Webhook Notification" = IMD,
                  tabledata "API Webhook Notification Aggr" = IMD,
                  tabledata "API Webhook Subscription" = IMD,
                  tabledata "Webhook Notification" = IMD,
                  tabledata "Webhook Subscription" = imd;
}
