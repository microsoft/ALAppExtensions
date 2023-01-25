tableextension 18911 "Charge Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(18703; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";
        }
        field(18704; "Charge Group Line No."; Integer)
        {
            Caption = 'Charge Group Line No.';
            DataClassification = CustomerContent;
        }
    }
}