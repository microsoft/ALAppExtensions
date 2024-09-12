namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;

permissionsetextension 8051 "Sub. Billing D365 Setup" extends "D365 SETUP"
{
    Permissions =
        tabledata "Service Contract Setup" = RIMD,
        tabledata "Customer Contract" = RIMD,
        tabledata "Contract Type" = RIMD,
        tabledata "Contract Renewal Line" = RIMD,
        tabledata "Overdue Service Commitments" = RIMD,
        tabledata "Planned Service Commitment" = RIMD,
        tabledata "Service Commitment Template" = RIMD,
        tabledata "Service Commitment Package" = RIMD,
        tabledata "Service Comm. Package Line" = RIMD,
        tabledata "Service Object" = RIMD,
        tabledata "Imported Service Object" = RIMD,
        tabledata "Imported Service Commitment" = RIMD,
        tabledata "Imported Customer Contract" = RIMD,
        tabledata "Item Serv. Commitment Package" = RIMD,
        tabledata "Service Commitment" = RIMD,
        tabledata "Billing Template" = RIMD,
        tabledata "Billing Line" = RIMD,
        tabledata "Customer Contract Line" = RIMD,
        tabledata "Vendor Contract" = RIMD,
        tabledata "Billing Line Archive" = RIMD,
        tabledata "Vendor Contract Line" = RIMD,
        tabledata "Customer Contract Deferral" = RIMD,
        tabledata "Sales Service Commitment" = RIMD,
        tabledata "Sales Service Comm. Archive" = RIMD,
        tabledata "Subscription Billing Cue" = RIMD,
        tabledata "Vendor Contract Deferral" = RIMD,
        tabledata "Service Commitment Archive" = RIMD,
        tabledata "Price Update Template" = RIMD,
        tabledata "Contract Price Update Line" = RIMD,
        tabledata "Item Templ. Serv. Comm. Pack." = RIMD,
        tabledata "Field Translation" = RIMD,
        tabledata "Contract Analysis Entry" = RIMD;
}