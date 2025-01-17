namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

tableextension 8000 "Contracts Contact" extends Contact
{
    fields
    {
        field(8000; "Customer Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Customer Contracts';
            CalcFormula = count("Customer Contract" where("Sell-to Contact No." = field("Company No."), Active = filter(true)));
            Editable = false;
        }
        field(8001; "Service Objects"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Service Objects';
            CalcFormula = count("Service Object" where("End-User Contact No." = field("Company No.")));
            Editable = false;
        }
    }
}