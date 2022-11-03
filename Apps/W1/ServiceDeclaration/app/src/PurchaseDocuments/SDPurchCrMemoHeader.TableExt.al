tableextension 5030 "SD Purch. Cr.Memo Header" extends "Purch. Cr. Memo Hdr."
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