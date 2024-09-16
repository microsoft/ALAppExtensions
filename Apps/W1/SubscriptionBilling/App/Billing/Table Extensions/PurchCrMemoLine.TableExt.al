namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.History;

tableextension 8064 "Purch Cr. Memo Line" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(8051; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Contract";
        }
        field(8052; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Contract Line"."Line No." where("Contract No." = field("Contract No."));
        }
        field(8053; "Recurring Billing from"; Date)
        {
            Caption = 'Recurring Billing from';
            DataClassification = CustomerContent;
        }
        field(8054; "Recurring Billing to"; Date)
        {
            Caption = 'Recurring Billing to';
            DataClassification = CustomerContent;
        }
    }
}