tableextension 5015 "Serv. Decl. Item Ledg. Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
        }
    }
}