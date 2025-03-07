namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 8070 "General Posting Setup" extends "General Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field(CustomerContractAccount; Rec."Cust. Sub. Contract Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account to which Customer Subscription Contract revenue is posted.';

            }
            field(CustContrDeferralAccount; Rec."Cust. Sub. Contr. Def Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account to which Customer Subscription Contract revenue is accrued.';
            }
            field(VendorContractAccount; Rec."Vend. Sub. Contract Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account to which Vendor Subscription Contract costs are posted.';
            }
            field(VendContrDeferralAccount; Rec."Vend. Sub. Contr. Def. Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account to which Vendor Subscription Contract costs are accrued.';
            }
        }
    }
}
