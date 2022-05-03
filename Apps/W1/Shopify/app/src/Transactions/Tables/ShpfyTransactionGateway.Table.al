/// <summary>
/// Table Shpfy Transaction Gateway (ID 30135).
/// </summary>
table 30135 "Shpfy Transaction Gateway"
{
    Access = Internal;
    Caption = 'Shopify Transaction Gateway';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Shpfy Transaction Gateways";
    LookupPageId = "Shpfy Transaction Gateways";

    fields
    {
        field(1; Name; Text[30])
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
