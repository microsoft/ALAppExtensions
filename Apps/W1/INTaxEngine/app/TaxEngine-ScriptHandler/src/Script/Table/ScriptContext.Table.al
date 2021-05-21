table 20200 "Script Context"
{
    Caption = 'Script Context';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(2; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}