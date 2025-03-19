namespace Microsoft.SubscriptionBilling;

permissionset 8054 "Sub. Billing Basic"
{
    Assignable = true;
    Caption = 'Subscription Billing Basic', MaxLength = 30;

    IncludedPermissionSets = "Sub. Billing Objects";

    Permissions =
        tabledata "Subscription Contract Setup" = R,
        tabledata "Customer Subscription Contract" = R,
        tabledata "Subscription Contract Type" = R,
        tabledata "Sub. Contract Renewal Line" = R,
        tabledata "Overdue Subscription Line" = R,
        tabledata "Planned Subscription Line" = R,
        tabledata "Sub. Package Line Template" = R,
        tabledata "Subscription Package" = R,
        tabledata "Subscription Package Line" = R,
        tabledata "Subscription Header" = R,
        tabledata "Imported Subscription Header" = R,
        tabledata "Imported Subscription Line" = R,
        tabledata "Imported Cust. Sub. Contract" = R,
        tabledata "Item Subscription Package" = R,
        tabledata "Subscription Line" = R,
        tabledata "Billing Template" = R,
        tabledata "Billing Line" = R,
        tabledata "Cust. Sub. Contract Line" = R,
        tabledata "Vendor Subscription Contract" = R,
        tabledata "Billing Line Archive" = R,
        tabledata "Vend. Sub. Contract Line" = R,
        tabledata "Cust. Sub. Contract Deferral" = R,
        tabledata "Sales Subscription Line" = R,
        tabledata "Sales Sub. Line Archive" = R,
        tabledata "Subscription Billing Cue" = R,
        tabledata "Vend. Sub. Contract Deferral" = R,
        tabledata "Subscription Line Archive" = R,
        tabledata "Price Update Template" = R,
        tabledata "Sub. Contr. Price Update Line" = R,
        tabledata "Item Templ. Sub. Package" = R,
        tabledata "Field Translation" = R,
        tabledata "Sub. Contr. Analysis Entry" = R,
        tabledata "Sales Service Commitment Buff." = R,
        tabledata "Generic Import Settings" = R,
        tabledata "Usage Data Billing" = R,
        tabledata "Usage Data Billing Metadata" = R,
        tabledata "Usage Data Blob" = R,
        tabledata "Usage Data Supp. Customer" = R,
        tabledata "Usage Data Generic Import" = R,
        tabledata "Usage Data Import" = R,
        tabledata "Usage Data Supp. Subscription" = R,
        tabledata "Usage Data Supplier" = R,
        tabledata "Usage Data Supplier Reference" = R;
}
