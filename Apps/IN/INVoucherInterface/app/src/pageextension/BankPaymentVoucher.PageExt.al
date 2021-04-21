pageextension 18941 "Bank Payment Voucher" extends "Bank Payment Voucher"
{
    layout
    {
        addafter("Location Code")
        {
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
            field("Cheque Date"; "Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
        }
        addbefore(Narration)
        {
            group("Cheque_No.")
            {
                ShowCaption = false;
                field("Cheque No.2"; "Cheque No.")
                {
                    Caption = 'Cheque No.';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cheque number of the journal entry.';
                }
            }
        }
    }
}