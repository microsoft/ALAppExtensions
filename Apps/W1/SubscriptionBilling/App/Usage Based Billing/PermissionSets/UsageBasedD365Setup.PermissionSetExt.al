namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;

permissionsetextension 8004 "Usage Based D365 Setup" extends "D365 SETUP"
{
    Permissions = tabledata "Usage Data Subscription" = RIMD,
                  tabledata "Usage Data Supplier" = RIMD,
                  tabledata "Usage Data Supplier Reference" = RIMD,
                  tabledata "Usage Data Customer" = RIMD,
                  tabledata "Usage Data Import" = RIMD,
                  tabledata "Usage Data Blob" = RIMD,
                  tabledata "Usage Data Billing" = RIMD,
                  tabledata "Generic Import Settings" = RIMD,
                  tabledata "Usage Data Generic Import" = RIMD;
}
