#if not CLEAN22
tableextension 30200 "Shpfy Feature Data Update" extends "Feature Data Update Status"
{
    fields
    {
        field(30200; "Shpfy Templates Migrate"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Migrate Shopify templates';
        }
    }
}
#endif