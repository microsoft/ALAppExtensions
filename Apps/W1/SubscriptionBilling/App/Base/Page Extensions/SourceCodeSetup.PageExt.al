namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.AuditCodes;

pageextension 8086 "Source Code Setup" extends "Source Code Setup"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group(SubcriptionBilling)
            {
                Caption = 'Subcription Billing';
                field(ContractDeferralsRelease; Rec."Contract Deferrals Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which source code is used in the G/L when posting the release of contract deferrals (Subscription Billing).';
                }
            }
        }
    }
}