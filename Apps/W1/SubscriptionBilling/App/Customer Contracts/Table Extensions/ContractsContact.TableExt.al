namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

tableextension 8000 "Contracts Contact" extends Contact
{
    fields
    {
        field(8000; "Cust. Subscription Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Customer Subscription Contracts';
            CalcFormula = count("Customer Subscription Contract" where("Sell-to Contact No." = field("Company No."), Active = filter(true)));
            Editable = false;
        }
        field(8001; "Subscription Headers"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Subscriptions';
            CalcFormula = count("Subscription Header" where("End-User Contact No." = field("Company No.")));
            Editable = false;
        }
    }
}