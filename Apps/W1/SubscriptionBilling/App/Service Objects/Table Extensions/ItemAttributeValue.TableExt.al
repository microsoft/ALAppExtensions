namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Attribute;

tableextension 8005 "Item Attribute Value" extends "Item Attribute Value"
{
    fields
    {
        field(8000; Primary; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary';
            Editable = false;
        }
    }
}