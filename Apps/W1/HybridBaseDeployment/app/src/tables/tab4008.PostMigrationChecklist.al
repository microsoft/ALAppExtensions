table 4008 "Post Migration Checklist"
{
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; "Company Name"; Text[250])
        {
            Description = 'The name of a company';
            DataClassification = SystemMetadata;
        }
        field(2; Help; Boolean)
        {
            Description = 'Help has been read';
            DataClassification = SystemMetadata;
        }
        field(3; "Users Setup"; Boolean)
        {
            Description = 'Users are setup';
            DataClassification = SystemMetadata;
        }
        field(4; "Disable Intelligent Cloud"; Boolean)
        {
            Description = 'Disable the Intelligent Cloud';
            DataClassification = SystemMetadata;
        }
        field(5; "D365 Sales"; Boolean)
        {
            Description = 'Connection to Dynamics 365 Sales is set up';
            DataClassification = SystemMetadata;
        }
        field(6; "Define User Mappings"; Boolean)
        {
            Description = 'Deine user mappings';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Company Name")
        {
            Clustered = true;
        }
    }
    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}