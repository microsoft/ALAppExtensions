table 4044 "GP Company Migration Settings"
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

        field(2; Replicate; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Hybrid Company".Replicate where(Name = field(Name)));
        }

        field(9; NumberOfSegments; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("GP Segment Name" where("Company Name" = field("Name")));
        }
        field(10; ProcessesAreRunning; Boolean)
        {
            InitValue = false;
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
}