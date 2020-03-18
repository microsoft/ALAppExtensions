tableextension 27034 "DIOT Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(27030; "DIOT Type of Operation"; Option)
        {
            Caption = 'DIOT Type of Operation';
            OptionMembers = " ","Prof. Services","Lease and Rent",Others;
            OptionCaption = ' ,Prof. Services,Lease and Rent,Others';
        }
    }
}