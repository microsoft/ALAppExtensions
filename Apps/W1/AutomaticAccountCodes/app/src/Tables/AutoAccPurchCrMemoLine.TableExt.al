tableextension 4857 "AutoAcc Purch. Cr. Memo Line" extends "Purch. Cr. Memo Line"
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
