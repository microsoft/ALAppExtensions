tableextension 18537 "Charge Purch. Inv. Header Ext." extends "Purch. Inv. Header"
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