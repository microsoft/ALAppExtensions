tableextension 18805 "Charge Sales Invoice Line Ext" extends "Sales Invoice Line"
{
    fields
    {
        field(18703; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
        }
        field(18704; "Charge Group Line No."; Integer)
        {
            Caption = 'Charge Group Line No.';
            DataClassification = CustomerContent;
        }
    }
}