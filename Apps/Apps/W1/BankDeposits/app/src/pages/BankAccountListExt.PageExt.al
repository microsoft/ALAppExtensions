namespace Microsoft.Bank.Deposit;

using Microsoft.Bank.BankAccount;

pageextension 1703 BankAccountListExt extends "Bank Account List"
{
    Caption = 'Bank Accounts';

    actions
    {
        addafter(Statements)
        {
            action("Bank Deposits")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Posted Bank Deposits';
                Image = DepositSlip;
                RunObject = Page "Posted Bank Deposit List";
                RunPageLink = "Bank Account No." = field("No.");
                RunPageView = sorting("Bank Account No.");
                ToolTip = 'View the list of posted bank deposits for the bank account.';
            }
        }
    }
}