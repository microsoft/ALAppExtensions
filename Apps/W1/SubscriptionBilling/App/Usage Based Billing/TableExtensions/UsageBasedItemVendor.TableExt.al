namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

tableextension 8009 "Usage Based Item Vendor" extends "Item Vendor"
{
    fields
    {
        field(8000; "Supplier Ref. Entry No."; Integer)
        {
            Caption = 'Usage Data Supplier Ref. Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Usage Data Supplier Reference" where(Type = const(Product));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Rec."Item No." = '' then
                    exit;
                Item.Get(Rec."Item No.");
                if Item."Service Commitment Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
                    Error(NotServiceCommitmentItemErr);
            end;
        }
    }
    var
        NotServiceCommitmentItemErr: Label 'Usage Data Supplier Ref. Entry No. can only be entered for Service Commitment Items (see "Service Commitment Option in the Item).';
}
