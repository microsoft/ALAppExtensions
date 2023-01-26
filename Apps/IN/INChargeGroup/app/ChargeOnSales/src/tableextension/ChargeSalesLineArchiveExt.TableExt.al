tableextension 18806 "Charge Sales Line Archive Ext" extends "Sales Line Archive"
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