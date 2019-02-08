pageextension 13618 PaymentJournal extends "Payment Journal"
{
    layout
    {
        addafter("Creditor No.")
        {
            field("Giro Acc. No."; GiroAccNo)
            {
                ToolTip = 'Specifies the vendor''s giro account.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}