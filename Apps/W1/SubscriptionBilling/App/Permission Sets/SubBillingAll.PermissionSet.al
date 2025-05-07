namespace Microsoft.SubscriptionBilling;

permissionset 8052 "Sub. Billing All"
{
    Assignable = true;
    Caption = 'Subscription Billing All', MaxLength = 30;
    ObsoleteReason = 'Removed as the permission set has been replaced with "Sub. Billing Basic".';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';


    IncludedPermissionSets = "Sub. Billing Objects";

    Permissions =
        tabledata "Billing Line Archive" = R,
        tabledata "Billing Line" = R,
        tabledata "Billing Template" = R,
        tabledata "Cust. Sub. Contract Deferral" = R,
        tabledata "Cust. Sub. Contract Line" = R,
        tabledata "Customer Subscription Contract" = R,
        tabledata "Field Translation" = R,
        tabledata "Generic Import Settings" = R,
        tabledata "Imported Cust. Sub. Contract" = R,
        tabledata "Imported Subscription Header" = R,
        tabledata "Imported Subscription Line" = R,
        tabledata "Item Subscription Package" = R,
        tabledata "Item Templ. Sub. Package" = R,
        tabledata "Overdue Subscription Line" = R,
        tabledata "Planned Subscription Line" = R,
        tabledata "Price Update Template" = R,
        tabledata "Sales Service Commitment Buff." = R,
        tabledata "Sales Sub. Line Archive" = R,
        tabledata "Sales Subscription Line" = R,
        tabledata "Sub. Contr. Analysis Entry" = R,
        tabledata "Sub. Contr. Price Update Line" = R,
        tabledata "Sub. Contract Renewal Line" = R,
        tabledata "Sub. Package Line Template" = R,
        tabledata "Subscription Billing Cue" = R,
        tabledata "Subscription Contract Setup" = R,
        tabledata "Subscription Contract Type" = R,
        tabledata "Subscription Header" = R,
        tabledata "Subscription Line Archive" = R,
        tabledata "Subscription Line" = R,
        tabledata "Subscription Package Line" = R,
        tabledata "Subscription Package" = R,
        tabledata "Usage Data Billing" = R,
        tabledata "Usage Data Blob" = R,
        tabledata "Usage Data Generic Import" = R,
        tabledata "Usage Data Import" = R,
        tabledata "Usage Data Supp. Customer" = R,
        tabledata "Usage Data Supp. Subscription" = R,
        tabledata "Usage Data Supplier Reference" = R,
        tabledata "Usage Data Supplier" = R,
        tabledata "Vend. Sub. Contract Deferral" = R,
        tabledata "Vend. Sub. Contract Line" = R,
        tabledata "Vendor Subscription Contract" = R;
}
