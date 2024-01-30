#if not CLEAN24
namespace Microsoft.Bank.Deposit;

using Microsoft.Finance.RoleCenters;

pageextension 1706 AccReceivableActivitiesExt extends "Acc. Receivable Activities"
{
    Caption = 'Activities';
    ObsoleteReason = 'Removed, bank deposits is not part of the account receivables activities.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
    layout
    {
        addlast(content)
        {
            cuegroup(BankDeposits)
            {
                Caption = 'Bank Deposits';
                ObsoleteReason = 'Removed, bank deposits is not part of the account receivables activities.';
                ObsoleteState = Pending;
                ObsoleteTag = '24.0';
                Visible = false;
                field("Bank Deposits to Post"; Rec."Bank Deposits to Post")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Deposits to Post';
                    DrillDownPageID = "Bank Deposit List";
                    ToolTip = 'Specifies the bank deposits that will be posted.';
                    Visible = false;
                    ObsoleteReason = 'Removed, bank deposits is not part of the account receivables activities.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';
                }
            }
        }
    }
}

#endif