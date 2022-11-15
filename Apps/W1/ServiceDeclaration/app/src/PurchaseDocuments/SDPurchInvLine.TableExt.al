tableextension 5024 "SD Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";
            Editable = false;
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
            Editable = false;
        }
    }
}