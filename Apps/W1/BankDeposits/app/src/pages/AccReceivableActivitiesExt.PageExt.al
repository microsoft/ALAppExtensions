namespace Microsoft.Bank.Deposit;

using Microsoft.Finance.RoleCenters;

pageextension 1706 AccReceivableActivitiesExt extends "Acc. Receivable Activities"
{
    Caption = 'Activities';
    layout
    {
        addlast(content)
        {
            cuegroup(BankDeposits)
            {
                Caption = 'Bank Deposits';
                field("Bank Deposits to Post"; Rec."Bank Deposits to Post")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Deposits to Post';
                    DrillDownPageID = "Bank Deposit List";
                    ToolTip = 'Specifies the bank deposits that will be posted.';
                }
            }
        }
    }
}

