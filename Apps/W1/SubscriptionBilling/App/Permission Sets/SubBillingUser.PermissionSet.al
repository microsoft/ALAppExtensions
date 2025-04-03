namespace Microsoft.SubscriptionBilling;

permissionset 8053 "Sub. Billing User"
{
    Assignable = true;
    Caption = 'Subscription Billing User', MaxLength = 30;

    IncludedPermissionSets = "Sub. Billing Basic";

    Permissions =
        tabledata "Billing Line Archive" = IMD,
        tabledata "Billing Line" = IMD,
        tabledata "Billing Template" = IMD,
        tabledata "Cust. Sub. Contract Deferral" = IMD,
        tabledata "Cust. Sub. Contract Line" = IMD,
        tabledata "Customer Subscription Contract" = IMD,
        tabledata "Field Translation" = IMD,
        tabledata "Imported Cust. Sub. Contract" = IMD,
        tabledata "Imported Subscription Header" = IMD,
        tabledata "Imported Subscription Line" = IMD,
        tabledata "Item Subscription Package" = IMD,
        tabledata "Overdue Subscription Line" = IMD,
        tabledata "Planned Subscription Line" = IMD,
        tabledata "Price Update Template" = IMD,
        tabledata "Sales Service Commitment Buff." = IMD,
        tabledata "Sales Sub. Line Archive" = IMD,
        tabledata "Sales Subscription Line" = IMD,
        tabledata "Sub. Contr. Analysis Entry" = IMD,
        tabledata "Sub. Contr. Price Update Line" = IMD,
        tabledata "Sub. Contract Renewal Line" = IMD,
        tabledata "Subscription Billing Cue" = IMD,
        tabledata "Subscription Header" = IMD,
        tabledata "Subscription Line Archive" = IMD,
        tabledata "Subscription Line" = IMD,
        tabledata "Usage Data Billing Metadata" = IMD,
        tabledata "Usage Data Billing" = IMD,
        tabledata "Usage Data Blob" = IMD,
        tabledata "Usage Data Generic Import" = IMD,
        tabledata "Usage Data Import" = IMD,
        tabledata "Usage Data Supp. Customer" = IMD,
        tabledata "Usage Data Supp. Subscription" = IMD,
        tabledata "Usage Data Supplier Reference" = IMD,
        tabledata "Usage Data Supplier" = IMD,
        tabledata "Vend. Sub. Contract Deferral" = IMD,
        tabledata "Vend. Sub. Contract Line" = IMD,
        tabledata "Vendor Subscription Contract" = IMD;
}
