namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 8085 "General Posting Setup Card" extends "General Posting Setup Card"
{
    layout
    {
        addafter(Usage)
        {
            group(SubcriptionBilling)
            {
                Caption = 'Subcription Billing', locked = true;
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
}
