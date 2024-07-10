table 139758 "MDM Test Table B"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(3; "TableA Reference"; Code[20])
        {
            Caption = 'TableA Reference';
            TableRelation = "MDM Test Table A"."Primary Key";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}