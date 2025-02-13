namespace Microsoft.SubscriptionBilling;

permissionsetextension 8005 "Usage Based User" extends "Sub. Billing User"
{
    Permissions = tabledata "Usage Data Subscription" = IMD,
                  tabledata "Usage Data Supplier" = IM,
                  tabledata "Usage Data Supplier Reference" = IMD,
                  tabledata "Usage Data Customer" = IMD,
                  tabledata "Usage Data Import" = IMD,
                  tabledata "Usage Data Blob" = IMD,
                  tabledata "Usage Data Billing" = IMD,
                  tabledata "Generic Import Settings" = IM,
                  tabledata "Usage Data Generic Import" = IMD;
}
