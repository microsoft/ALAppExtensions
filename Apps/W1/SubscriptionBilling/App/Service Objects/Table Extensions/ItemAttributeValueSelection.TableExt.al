namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Attribute;

tableextension 8006 "Item Attribute Value Selection" extends "Item Attribute Value Selection"
{
    fields
    {
        field(8000; Primary; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary';
        }
    }
}