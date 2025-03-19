namespace Microsoft.SubscriptionBilling;

permissionset 8053 "Sub. Billing User"
{
    Assignable = true;
    Caption = 'Subscription Billing User', MaxLength = 30;

    IncludedPermissionSets = "Sub. Billing Basic";

    Permissions =
        tabledata "Customer Subscription Contract" = IMD,
        tabledata "Sub. Contract Renewal Line" = IMD,
        tabledata "Overdue Subscription Line" = IMD,
        tabledata "Planned Subscription Line" = IMD,
        tabledata "Subscription Header" = IMD,
        tabledata "Imported Subscription Header" = IMD,
        tabledata "Imported Subscription Line" = IMD,
        tabledata "Imported Cust. Sub. Contract" = IMD,
        tabledata "Item Subscription Package" = IMD,
        tabledata "Subscription Line" = IMD,
        tabledata "Billing Template" = IMD,
        tabledata "Billing Line" = IMD,
        tabledata "Cust. Sub. Contract Line" = IMD,
        tabledata "Vendor Subscription Contract" = IMD,
        tabledata "Billing Line Archive" = IMD,
        tabledata "Vend. Sub. Contract Line" = IMD,
        tabledata "Cust. Sub. Contract Deferral" = IMD,
        tabledata "Sales Subscription Line" = IMD,
        tabledata "Sales Sub. Line Archive" = IMD,
        tabledata "Subscription Billing Cue" = IMD,
        tabledata "Vend. Sub. Contract Deferral" = IMD,
        tabledata "Subscription Line Archive" = IMD,
        tabledata "Price Update Template" = IMD,
        tabledata "Sub. Contr. Price Update Line" = IMD,
        tabledata "Field Translation" = IMD,
        tabledata "Sub. Contr. Analysis Entry" = IMD,
        tabledata "Sales Service Commitment Buff." = IMD,
        tabledata "Usage Data Billing" = IMD,
        tabledata "Usage Data Blob" = IMD,
        tabledata "Usage Data Supp. Customer" = IMD,
        tabledata "Usage Data Generic Import" = IMD,
        tabledata "Usage Data Import" = IMD,
        tabledata "Usage Data Supp. Subscription" = IMD,
        tabledata "Usage Data Supplier" = IMD,
        tabledata "Usage Data Supplier Reference" = IMD,
        tabledata "Usage Data Billing Metadata" = IMD;
}
