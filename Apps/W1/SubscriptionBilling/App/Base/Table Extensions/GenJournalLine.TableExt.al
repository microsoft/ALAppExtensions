namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 8070 "Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(8051; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            DataClassification = CustomerContent;
        }
    }
}
