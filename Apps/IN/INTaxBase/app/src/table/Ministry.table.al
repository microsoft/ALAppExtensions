table 18546 "Ministry"
{
    DataClassification = EndUserIdentifiableInformation;
    Caption = 'Ministry';
    DrillDownPageId = Ministries;
    LookupPageId = Ministries;
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[3])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Name; Text[150])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Other Ministry"; Boolean)
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