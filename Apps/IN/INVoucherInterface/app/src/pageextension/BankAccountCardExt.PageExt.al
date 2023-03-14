pageextension 18950 "Bank Account Card Ext" extends "Bank Account Card"
{
    layout
    {
        addafter("Balance Last Statement")
        {
            field("Stale Cheque Stipulated Period"; Rec."Stale Cheque Stipulated Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Stale Cheque Stipulated Period';
                ToolTip = 'Specifies after how long the cheque can be marked stale for this bank account.';
            }
            field("UPI ID"; Rec."UPI ID")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'UPI ID';
                ToolTip = 'Specifies UPI ID for this bank account.';
            }
        }
    }
}