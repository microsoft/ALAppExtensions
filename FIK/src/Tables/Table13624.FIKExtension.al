table 13624 FIKExtension
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Using per company table instead, table 13625 FIKUplift';
    ReplicateData = false;

    fields
    {
        field(1; Code; Code[10])
        {
        }
        field(2; IsUpgraded; Boolean)
        {
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