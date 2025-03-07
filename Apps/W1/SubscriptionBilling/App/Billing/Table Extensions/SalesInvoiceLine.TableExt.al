namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

tableextension 8056 "Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(8051; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer Subscription Contract";
        }
        field(8052; "Subscription Contract Line No."; Integer)
        {
            Caption = 'Subscription Contract Line No.';
            DataClassification = CustomerContent;
            TableRelation = "Cust. Sub. Contract Line"."Line No." where("Subscription Contract No." = field("Subscription Contract No."));
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
        field(8058; "Discount"; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}