namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

tableextension 8002 Vendor extends Vendor
{
    fields
    {
        field(8010; "Vendor Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Vendor Contracts';
            CalcFormula = count("Vendor Contract" where("Buy-from Vendor No." = field("No."), Active = filter(true)));
            Editable = false;
        }
    }
}