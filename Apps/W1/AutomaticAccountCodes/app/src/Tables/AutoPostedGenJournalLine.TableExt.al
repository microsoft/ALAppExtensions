tableextension 4855 "Auto Posted Gen. Journal Line" extends "Posted Gen. Journal Line"
{
    fields
    {
        field(4851; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            TableRelation = "Automatic Account Header";
        }

    }
}
