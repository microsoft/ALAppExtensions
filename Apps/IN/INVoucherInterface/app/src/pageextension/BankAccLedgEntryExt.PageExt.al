pageextension 18938 "Bank Acc Ledg Entry Ext" extends "Bank Account Ledger Entries"
{
    layout
    {
        addafter(Description)
        {
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the cheque number on the bank account ledger entry.';
            }
            field("Cheque Date"; "Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the cheque date on the bank account ledger entry.';
            }
        }
    }
}