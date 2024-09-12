namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Ledger;

tableextension 8067 "G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(8000; "Sub. Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = if ("Source Type" = const(Customer)) "Customer Contract" else
            if ("Source Type" = const(Vendor)) "Vendor Contract";
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
