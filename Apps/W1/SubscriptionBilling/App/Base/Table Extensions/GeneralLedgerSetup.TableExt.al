namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;

tableextension 8051 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(8051; "Dimension Code Cust. Contr."; Code[20])
        {
            ObsoleteReason = 'Moved to Subscription Contract Setup.';
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            DataClassification = CustomerContent;
            Caption = 'Dimension Code for Customer Subscription Contract';
            TableRelation = Dimension;
        }
    }

}
