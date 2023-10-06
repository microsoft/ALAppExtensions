
namespace Microsoft.Bank.Deposit;

using Microsoft.Finance.RoleCenters;

pageextension 1707 BookkeeperActivitiesExt extends "Bookkeeper Activities"
{
    Caption = 'Activities';
    layout
    {
        addafter("Non-Applied Payments")
        {
            field("Bank Deposits to Post"; Rec."Bank Deposits to Post")
            {
                ApplicationArea = Basic, Suite;
                DrillDownPageID = "Bank Deposit List";
                ToolTip = 'Specifies bank deposits that are ready to be posted.';
            }
        }
    }
}

