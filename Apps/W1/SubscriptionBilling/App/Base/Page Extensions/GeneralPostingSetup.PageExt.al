namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 8070 "General Posting Setup" extends "General Posting Setup"
{
    layout
    {
        addafter("Purch. FA Disc. Account")
        {
            field(CustomerContractAccount; Rec."Customer Contract Account")
            {
                ApplicationArea = All;
                Caption = 'Customer Contract Account';
                ToolTip = 'Specifies the G/L account to which the revenues from customer contracts are posted.';

            }
            field(CustContrDeferralAccount; Rec."Cust. Contr. Deferral Account")
            {
                ApplicationArea = All;
                Caption = 'Customer Contract Deferral Account';
                ToolTip = 'Specifies the G/L account to which the revenue from customer contracts is accrued.';
            }
            field(VendorContractAccount; Rec."Vendor Contract Account")
            {
                ApplicationArea = All;
                Caption = 'Vendor Contract Account';
                ToolTip = 'Specifies the G/L account to which the revenues from vendor contracts are posted.';
            }
            field(VendContrDeferralAccount; Rec."Vend. Contr. Deferral Account")
            {
                ApplicationArea = All;
                Caption = 'Vendor Contract Deferral Account';
                ToolTip = 'Specifies the G/L account to which the revenue from vendor contracts is accrued.';
            }
        }
    }
}
