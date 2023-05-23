tableextension 4863 "AutoAcc Sales Line" extends "Sales Line"
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
