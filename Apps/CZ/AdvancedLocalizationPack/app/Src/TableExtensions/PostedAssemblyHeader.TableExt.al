tableextension 31260 "Posted Assembly Header CZA" extends "Posted Assembly Header"
{
    fields
    {
        field(31060; "Gen. Bus. Posting Group CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
    }
}
