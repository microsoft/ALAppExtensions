namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;

tableextension 8051 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(8051; "Dimension Code Cust. Contr."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension Code for Customer Contract';
            TableRelation = Dimension;
        }
    }

}