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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Not used anymore.';
        }
    }
}
