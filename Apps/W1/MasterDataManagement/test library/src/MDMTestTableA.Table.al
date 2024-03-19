table 139757 "MDM Test Table A"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; "Self-Reference Field"; Code[20])
        {
            Caption = 'Self-Reference Field';
            TableRelation = "MDM Test Table A"."Primary Key";
        }
        field(3; "TableB Reference"; Code[20])
        {
            Caption = 'TableB Reference';
            TableRelation = "MDM Test Table B"."Primary Key";
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