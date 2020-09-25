pageextension 11512 "Swiss QR-Bill Company Info." extends "Company Information"
{
    layout
    {
        addafter(IBAN)
        {
            field("Swiss QR-Bill IBAN"; "Swiss QR-Bill IBAN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the QR-IBAN value of your primary bank account.';
            }
        }
    }
}
