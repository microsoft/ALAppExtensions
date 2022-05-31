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
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    procedure GetMigrateInactiveCheckbooks(): Boolean
    var
        MigrateInactiveCheckbooks: Boolean;
    begin
        MigrateInactiveCheckbooks := true;
        if Rec.Get(CompanyName()) then
            MigrateInactiveCheckbooks := Rec."Migrate Inactive Checkbooks";

        exit(MigrateInactiveCheckbooks);
    end;
}