table 4034 "Stg Report Selections"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '23.0';
    ReplicateData = false;

    fields
    {
        field(1; Usage; Enum "Report Selection Usage")
        {
            DataClassification = CustomerContent;
        }
        field(2; Sequence; Code[10])
        {
            DataClassification = CustomerContent;
            Numeric = true;
        }
    }

    keys
    {
        key(Key1; Usage, Sequence)
        {
            Clustered = true;
        }
    }
}