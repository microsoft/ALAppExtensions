namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Catalog;

pageextension 8004 "Vendor Item Catalog" extends "Vendor Item Catalog"
{
    layout
    {
        addlast(Control1)
        {
            field(SupplierRefEntryNo; Rec."Supplier Ref. Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sequential number of the associated product reference for processing usage-based billing.';
            }
        }
    }
}