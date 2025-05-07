namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

tableextension 8001 "Contracts Customer" extends Customer
{
    fields
    {
        field(8010; "Cust. Subscription Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Customer Subscription Contracts';
            CalcFormula = count("Customer Subscription Contract" where("Sell-to Customer No." = field("No."), Active = filter(true)));
            Editable = false;
        }
        field(8011; "Subscription Headers"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Subscriptions';
            CalcFormula = count("Subscription Header" where("End-User Customer No." = field("No.")));
            Editable = false;
        }
    }
}