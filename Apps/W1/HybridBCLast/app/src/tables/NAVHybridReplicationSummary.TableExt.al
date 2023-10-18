namespace Microsoft.DataMigration.BC;

using Microsoft.DataMigration;

tableextension 4001 "NAV Hybrid Replication Summary" extends "Hybrid Replication Summary"
{
    fields
    {
        field(38; "Synced Version"; BigInteger)
        {
            Description = 'The SQL version that was replicated.';
            DataClassification = SystemMetadata;
        }
        field(39; "Upgrade Started DateTime"; DateTime)
        {
            Description = 'The SQL version that was replicated.';
            DataClassification = SystemMetadata;
        }
    }
}