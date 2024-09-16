namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;

permissionsetextension 8003 "Usage Based D365 Basic" extends "D365 BASIC"
{
    Permissions = tabledata "Usage Data Subscription" = R,
                  tabledata "Usage Data Supplier" = R,
                  tabledata "Usage Data Supplier Reference" = R,
                  tabledata "Usage Data Customer" = R,
                  tabledata "Usage Data Import" = R,
                  tabledata "Usage Data Blob" = R,
                  tabledata "Usage Data Billing" = R,
                  tabledata "Generic Import Settings" = R,
                  tabledata "Usage Data Generic Import" = R;
}
