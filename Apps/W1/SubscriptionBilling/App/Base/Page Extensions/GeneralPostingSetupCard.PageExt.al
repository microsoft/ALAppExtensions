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
                Caption = 'Subscription Billing', locked = true;
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
}
