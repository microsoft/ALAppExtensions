tableextension 4860 "AutoAcc Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
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
