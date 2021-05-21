table 18686 "Act Applicable"
{
    Caption = 'Act Applicable';
    LookupPageId = "Act Applicable";
    DrillDownPageId = "Act Applicable";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}