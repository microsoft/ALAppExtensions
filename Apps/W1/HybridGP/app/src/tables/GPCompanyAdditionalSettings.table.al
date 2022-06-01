table 40105 "GP Company Additional Settings"
{
    ReplicateData = false;
    DataPerCompany = false;
    Extensible = false;

    fields
    {
        field(1; Name; Text[30])
        {
            TableRelation = "Hybrid Company".Name;
            DataClassification = OrganizationIdentifiableInformation;
        }

        field(10; "Migrate Inactive Checkbooks"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(11; "Vendor EFT Bank Acc. Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}