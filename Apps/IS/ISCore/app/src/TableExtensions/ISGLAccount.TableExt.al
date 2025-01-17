tableextension 14602 "IS G/L Account" extends "G/L Account"
{
    fields
    {
        field(14602; "IRS No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'IRS Number';
            TableRelation = "IS IRS Numbers";
        }
    }
}
