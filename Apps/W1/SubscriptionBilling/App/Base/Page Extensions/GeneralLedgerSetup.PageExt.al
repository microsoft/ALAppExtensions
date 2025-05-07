#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 8053 "General Ledger Setup" extends "General Ledger Setup"
{
    ObsoleteReason = 'Moved to Subscription Contract Setup.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    layout
    {
        addlast(Control1900309501)
        {
            field("Dimension Code Cust. Contr."; Rec."Dimension Code Cust. Contr.")
            {
                ObsoleteReason = 'Moved to Subscription Contract Setup.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the Dimension Code that is used for Customer Subscription Contracts.';
            }
        }
    }
}
#endif