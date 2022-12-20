tableextension 5032 "Serv. Decl. Serv. Inv. Header" extends "Service Invoice Header"
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
