namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

tableextension 8008 "Usage Based Item Reference" extends "Item Reference"
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
                if Item."Subscription Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
                    Error(NotServiceCommitmentItemErr);
            end;
        }
    }
    var
        NotServiceCommitmentItemErr: Label 'Usage Data Supplier Ref. Entry No. can only be entered for Subscription Items (see "Subscription Option in the Item).';

    internal procedure FindForVendorAndSupplierReference(VendorNo: Code[20]; SupplierReferenceEntryNo: Integer): Boolean
    begin
        Rec.SetRange("Reference Type", Enum::"Item Reference Type"::Vendor);
        Rec.SetRange("Reference Type No.", VendorNo);
        Rec.SetRange("Supplier Ref. Entry No.", SupplierReferenceEntryNo);
        exit(Rec.FindFirst());
    end;
}
