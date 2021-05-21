table 4040 "GP Segment Name"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Company Name"; Text[50])
        {
            Description = 'Name of the Company that the segment belongs to.';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(2; "Segment Number"; Integer)
        {
            Description = 'Number for the segment.';
            DataClassification = SystemMetadata;
        }
        field(3; "Segment Name"; Text[30])
        {
            Description = 'Name of the segment.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Segment Name", "Company Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Segment Name", "Segment Number")
        {
            Caption = 'Values to display in a dropdown list.';
        }
    }
}