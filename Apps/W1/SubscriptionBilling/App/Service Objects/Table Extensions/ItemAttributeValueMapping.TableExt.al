namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Attribute;

tableextension 8007 "Item Attribute Value Mapping" extends "Item Attribute Value Mapping"
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