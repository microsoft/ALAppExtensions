tableextension 27036 "DIOT VAT Entry" extends "VAT Entry"
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