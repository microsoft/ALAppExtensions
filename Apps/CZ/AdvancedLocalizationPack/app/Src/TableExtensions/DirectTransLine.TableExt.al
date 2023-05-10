tableextension 31236 "Direct Trans. Line CZA" extends "Direct Trans. Line"
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