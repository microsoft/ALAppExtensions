namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Ledger;

tableextension 8067 "G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(8000; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = if ("Source Type" = const(Customer)) "Customer Subscription Contract" else
            if ("Source Type" = const(Vendor)) "Vendor Subscription Contract";
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
