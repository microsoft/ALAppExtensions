pageextension 1700 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    Caption = 'Sales & Receivables Setup';

    layout
    {
        addafter(Dimensions)
        {
            group("Bank Deposits")
            {
                field("Bank Deposit Nos."; "Bank Deposit Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to bank deposits.';
                }
                field("Post Bank Deposits as Lump Sum"; "Post Bank Deposits as Lump Sum")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if bank deposits should be posted as a single bank account ledger entry with the total amount. You can change this setting on the bank deposit card.';
                }
            }
        }
    }
}