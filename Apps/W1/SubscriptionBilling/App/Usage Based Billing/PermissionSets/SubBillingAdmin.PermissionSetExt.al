namespace Microsoft.SubscriptionBilling;

permissionsetextension 8002 "Sub. Billing Admin" extends "Sub. Billing Admin"
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
