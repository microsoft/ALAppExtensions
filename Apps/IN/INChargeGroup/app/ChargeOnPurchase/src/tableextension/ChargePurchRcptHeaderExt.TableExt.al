tableextension 18539 "Charge Purch. Rcpt. Hdr. Ext." extends "Purch. Rcpt. Header"
{
    fields
    {
        field(18675; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
        }
    }
}