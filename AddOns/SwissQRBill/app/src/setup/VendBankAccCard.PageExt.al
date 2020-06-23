pageextension 11514 "Swiss QR-Bill Vend.BankAccCard" extends "Vendor Bank Account Card"
{
    layout
    {
        modify(IBAN)
        {
            Caption = 'IBAN/QR-IBAN';
            ToolTip = 'Specifies the IBAN or QR-IBAN account of the vendor.';
        }
    }
}