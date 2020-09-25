pageextension 11513 "Swiss QR-Bill Payment Method" extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {
            field("Swiss QR-Bill Layout"; "Swiss QR-Bill Layout")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the QR-Bill Layout code.';
                Caption = 'QR-Bill Layout';
            }
        }
    }
}