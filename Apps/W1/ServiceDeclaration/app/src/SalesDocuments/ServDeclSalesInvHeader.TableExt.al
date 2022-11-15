tableextension 5027 "Serv. Decl. Sales Inv. Header" extends "Sales Invoice Header"
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