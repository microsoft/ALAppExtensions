tableextension 27032 "DIOT Gen. Journal Line" extends "Gen. Journal Line"
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