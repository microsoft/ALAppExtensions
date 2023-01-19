tableextension 18800 "Charge Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
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