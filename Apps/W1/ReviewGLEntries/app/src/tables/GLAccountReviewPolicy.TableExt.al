tableextension 22210 "G/L Account Review Policy" extends "G/L Account"
{
    fields
    {
        // Add changes to table fields here
        field(22200; "Review Policy"; enum "Review Policy Type")
        {
            DataClassification = SystemMetadata;
        }
    }
}