namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

tableextension 30200 "Shpfy Feature Data Update" extends "Feature Data Update Status"
{
    fields
    {
        field(30200; "Shpfy Templates Migrate"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Migrate Shopify templates';
#if not CLEAN22
#pragma warning disable AS0072
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#pragma warning restore AS0072
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Not used anymore.';
        }
    }
}
