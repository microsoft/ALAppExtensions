tableextension 4852 "AutoAcc G/L Account" extends "G/L Account"
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
