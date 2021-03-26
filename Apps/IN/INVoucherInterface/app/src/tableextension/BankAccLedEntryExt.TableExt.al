tableextension 18932 "Bank Acc Led Entry Ext" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(18929; "Cheque No."; Code[10])
        {
            Caption = 'Cheque No.';
        }
        field(18930; "Cheque Date"; Date)
        {
            Caption = 'Cheque Date';
        }
    }
}