tableextension 18534 "Charge Purch. Cr. Me. Hdr. Ext" extends "Purch. Cr. Memo Hdr."
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