tableextension 5036 "SD Serv. Cr.Memo Header" extends "Service Cr.Memo Header"
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
