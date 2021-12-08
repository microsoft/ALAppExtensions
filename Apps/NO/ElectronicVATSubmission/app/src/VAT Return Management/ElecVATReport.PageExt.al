pageextension 10697 "Elec. VAT Report" extends "VAT Report"
{
    layout
    {
        addlast(General)
        {
            field(KID; KID)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number to identify the payment.';
            }
        }
    }
}