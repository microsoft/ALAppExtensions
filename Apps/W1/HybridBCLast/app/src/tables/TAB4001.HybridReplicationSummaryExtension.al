tableextension 4001 "NAV Hybrid Replication Summary" extends "Hybrid Replication Summary"
{
    fields
    {
        field(38; "Synced Version"; BigInteger)
        {
            Description = 'The SQL version that was replicated.';
            DataClassification = SystemMetadata;
        }
    }
}