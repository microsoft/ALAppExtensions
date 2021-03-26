table 18809 "T.C.A.N. No."
{
    Caption = 'T.C.A.N. No.';
    DataCaptionFields = Code, Description;
    LookupPageId = "T.C.A.N. Nos.";
    DrillDownPageId = "T.C.A.N. Nos.";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
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