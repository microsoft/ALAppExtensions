namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

tableextension 8055 "Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(8051; "Recurring Billing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Recurring Billing';
        }
        field(8052; "Sub. Contract Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Subscription Contract Detail Overview';
            DataClassification = CustomerContent;
        }
    }
}