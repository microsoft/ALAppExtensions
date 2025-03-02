namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.History;

tableextension 8060 "Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(8051; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Subscription Contract";
        }
        field(8052; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            DataClassification = CustomerContent;
            TableRelation = "Vend. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
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
        field(8055; "Discount"; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}