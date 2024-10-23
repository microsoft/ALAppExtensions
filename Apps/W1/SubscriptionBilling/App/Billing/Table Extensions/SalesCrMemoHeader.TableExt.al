namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

tableextension 8057 "Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(8051; "Recurring Billing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Recurring Billing';
        }
        field(8052; "Contract Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Contract Detail Overview';
            DataClassification = CustomerContent;
        }
    }
}