table 4034 "Stg Report Selections"
{
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