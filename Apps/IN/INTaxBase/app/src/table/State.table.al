table 18547 "State"
{
    Caption = 'State';
    DataClassification = EndUserIdentifiableInformation;
    DrillDownPageId = States;
    LookupPageId = States;
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Description; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "State Code for eTDS/TCS"; Code[2])
        {
            DataClassification = EndUserIdentifiableInformation;
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