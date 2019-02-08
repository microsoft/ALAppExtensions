tableextension 13640 "OIOUBL-Payment Terms" extends "Payment Terms"
{
    fields
    {
        field(13630; "OIOUBL-Code"; Option)
        {
            Caption = 'Code';
            OptionMembers = " ",Contract,Specific;
        }
    }
    keys
    {
    }
}