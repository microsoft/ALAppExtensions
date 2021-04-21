tableextension 18718 "Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(18716; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}