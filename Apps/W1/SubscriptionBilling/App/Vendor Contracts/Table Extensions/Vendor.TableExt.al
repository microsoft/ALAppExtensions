namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

tableextension 8002 Vendor extends Vendor
{
    fields
    {
        field(8010; "Vendor Contracts"; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Vendor Subscription Contracts';
            CalcFormula = count("Vendor Subscription Contract" where("Buy-from Vendor No." = field("No."), Active = filter(true)));
            Editable = false;
        }
    }
}