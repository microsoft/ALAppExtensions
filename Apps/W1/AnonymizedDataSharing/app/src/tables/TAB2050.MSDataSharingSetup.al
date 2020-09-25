table 2050 "MS - Data Sharing Setup"
{
    DataPerCompany = false;
    ReplicateData = false;
    fields
    {
        field(1; "Company Id"; Guid)
        {
        }
        field(2; Enabled; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Company Id")
        {
            Clustered = true;
        }
    }
}