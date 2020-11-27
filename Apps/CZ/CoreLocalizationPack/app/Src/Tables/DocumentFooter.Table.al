table 31119 "Document Footer CZL"
{
    Caption = 'Document Footer';
    DrillDownPageID = "Document Footers CZL";
    LookupPageId = "Document Footers CZL";

    fields
    {
        field(1; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
            DataClassification = CustomerContent;
        }
        field(10; "Footer Text"; Text[1000])
        {
            Caption = 'Footer Text';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Language Code")
        {
            Clustered = true;
        }
    }
}
