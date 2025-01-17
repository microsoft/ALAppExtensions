namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

tableextension 8001 "Contracts Customer" extends Customer
{
    fields
    {
        field(8010; "Customer Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Customer Contracts';
            CalcFormula = count("Customer Contract" where("Sell-to Customer No." = field("No."), Active = filter(true)));
            Editable = false;
        }
        field(8011; "Service Objects"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Service Objects';
            CalcFormula = count("Service Object" where("End-User Customer No." = field("No.")));
            Editable = false;
        }
    }
}