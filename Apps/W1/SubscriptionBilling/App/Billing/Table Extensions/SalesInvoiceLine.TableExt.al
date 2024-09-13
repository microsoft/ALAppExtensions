namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

tableextension 8056 "Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(8051; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer Contract";
        }
        field(8052; "Contract Line No."; Integer)
        {
            Caption = 'Contract Line No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer Contract Line"."Line No." where("Contract No." = field("Contract No."));
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