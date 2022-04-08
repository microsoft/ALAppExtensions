/// <summary>
/// Table Shpfy Credit Card Company (ID 30132).
/// </summary>
table 30132 "Shpfy Credit Card Company"
{
    Access = Internal;
    Caption = 'Shopify Credit Card Company';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Shpfy Credit Card Companies";
    LookupPageId = "Shpfy Credit Card Companies";

    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }
}
