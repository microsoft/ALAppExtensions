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
                Caption = 'Subscription Billing';
                field(ContractDeferralsRelease; Rec."Sub. Contr. Deferrals Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which source code is used in the G/L when posting the release of contract deferrals.';
                }
            }
        }
    }
}