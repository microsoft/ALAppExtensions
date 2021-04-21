tableextension 4006 "Hybrid Activites Cue" extends "Activities Cue"
{
    fields
    {
        field(4000; "Replication Success Rate"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = '<Precision,0:0><Standard Format,9>%';
            Description = 'The percentage rate of tables that successfully replicated.';
            DataClassification = SystemMetadata;
        }
    }
}