/// <summary>
/// Table Shpfy Synchronization Info (ID 30103).
/// </summary>
table 30103 "Shpfy Synchronization Info"
{
    Access = Internal;
    Caption = 'Shopify Synchronization Info';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop".Code;
        }
        field(2; "Synchronization Type"; Enum "Shpfy Synchronization Type")
        {
            Caption = 'Synchronization Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Last Sync Time"; DateTime)
        {
            Caption = 'Last Sync Time';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Shop Code", "Synchronization Type")
        {
            Clustered = true;
        }
    }

}
