tableextension 31270 "Source Code Setup CZC" extends "Source Code Setup"
{
    fields
    {
        field(31270; "Compensation CZC"; Code[10])
        {
            Caption = 'Compensation';
            TableRelation = "Source Code";
            DataClassification = CustomerContent;
        }
    }
}
