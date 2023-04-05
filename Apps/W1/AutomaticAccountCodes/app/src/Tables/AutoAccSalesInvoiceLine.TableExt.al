tableextension 4862 "AutoAcc Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            TableRelation = "Automatic Account Header";
        }
    }
}
