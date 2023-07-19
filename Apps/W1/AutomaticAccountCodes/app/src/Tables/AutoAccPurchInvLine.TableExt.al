tableextension 4858 "AutoAcc Purch. Inv. Line" extends "Purch. Inv. Line"
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
