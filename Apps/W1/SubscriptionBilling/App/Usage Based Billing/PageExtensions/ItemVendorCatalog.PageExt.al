namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Catalog;

pageextension 8005 "Item Vendor Catalog" extends "Item Vendor Catalog"
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
