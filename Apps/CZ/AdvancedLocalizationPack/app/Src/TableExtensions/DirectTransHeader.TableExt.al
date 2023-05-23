tableextension 31235 "Direct Trans. Header CZA" extends "Direct Trans. Header"
{
    fields
    {
        field(31200; "Gen. Bus. Posting Group CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
    }
}