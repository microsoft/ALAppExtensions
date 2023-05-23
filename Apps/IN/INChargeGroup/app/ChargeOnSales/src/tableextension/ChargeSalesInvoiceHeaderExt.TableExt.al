tableextension 18804 "Charge Sales Inv. Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(18698; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
        }
    }
}