tableextension 11779 "Source Code Setup CZP" extends "Source Code Setup"
{
    fields
    {
        field(11740; "Cash Desk CZP"; Code[10])
        {
            Caption = 'Cash Desk';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
    }
}
