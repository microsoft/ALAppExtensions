namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Catalog (ID 30400).
/// </summary>
table 30400 "Shpfy Market Catalog Relation"
{
    Caption = 'Shopify Catalog';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Market Id"; BigInteger)
        {
            Caption = 'Market Id';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the unique identifier for the market in Shopify.';
        }
        field(2; "Catalog Id"; BigInteger)
        {
            Caption = 'Catalog Id';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the unique identifier for the market catalog in Shopify.';
        }
        field(3; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
            ToolTip = 'Specifies the Shopify shop code.';
        }
        field(4; "Market Name"; Text[500])
        {
            Caption = 'Market Name';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the name of the market.';
        }
        field(5; "Catalog Title"; Text[500])
        {
            Caption = 'Catalog Title';
            Editable = false;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the title of the market catalog.';
        }
    }
    keys
    {
        key(PK; "Market Id", "Catalog Id")
        {
            Clustered = true;
        }
    }
}
