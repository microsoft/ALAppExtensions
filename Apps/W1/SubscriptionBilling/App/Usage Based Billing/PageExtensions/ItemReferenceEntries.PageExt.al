namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Catalog;

pageextension 8006 "Item Reference Entries" extends "Item Reference Entries"
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
