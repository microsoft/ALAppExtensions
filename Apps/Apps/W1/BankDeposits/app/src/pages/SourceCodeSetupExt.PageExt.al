namespace Microsoft.Bank.Deposit;

using Microsoft.Foundation.AuditCodes;

pageextension 1701 SourceCodeSetupExt extends "Source Code Setup"
{
    Caption = 'Source Code Setup';

    layout
    {
        addafter("Payment Reconciliation Journal")
        {
            field("Bank Deposit"; Rec."Bank Deposit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code linked to entries that are posted from a bank deposit.';
            }
        }
    }
}