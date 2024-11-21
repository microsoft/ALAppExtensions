namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 8070 "General Posting Setup" extends "General Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field(CustomerContractAccount; Rec."Customer Contract Account")
            {
                ApplicationArea = All;
                Caption = 'Customer Contract Account';
                ToolTip = 'Specifies the G/L account to which customer contract revenue (Subscription Billing) is posted.';

            }
            field(CustContrDeferralAccount; Rec."Cust. Contr. Deferral Account")
            {
                ApplicationArea = All;
                Caption = 'Customer Contract Deferral Account';
                ToolTip = 'Specifies the G/L account to which customer contract revenue (Subscription Billing) is accrued.';
            }
            field(VendorContractAccount; Rec."Vendor Contract Account")
            {
                ApplicationArea = All;
                Caption = 'Vendor Contract Account';
                ToolTip = 'Specifies the G/L account to which vendor contract costs (Subscription Billing) are posted.';
            }
            field(VendContrDeferralAccount; Rec."Vend. Contr. Deferral Account")
            {
                ApplicationArea = All;
                Caption = 'Vendor Contract Deferral Account';
                ToolTip = 'Specifies the G/L account to which vendor contract costs (Subscription Billing) are accrued.';
            }
        }
    }
}
