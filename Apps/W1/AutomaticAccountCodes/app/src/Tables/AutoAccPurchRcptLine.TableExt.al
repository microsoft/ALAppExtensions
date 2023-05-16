tableextension 4859 "AutoAcc Purch. Rcpt. Line" extends "Purch. Rcpt. Line"
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
