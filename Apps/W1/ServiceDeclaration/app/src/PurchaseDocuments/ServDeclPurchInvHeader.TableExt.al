tableextension 5029 "Serv. Decl. Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(5010; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
            Editable = false;
        }
    }
}