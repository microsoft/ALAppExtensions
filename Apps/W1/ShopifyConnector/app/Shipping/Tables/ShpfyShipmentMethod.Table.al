/// <summary>
/// Table Shpfy Shipment Method (ID 30131).
/// </summary>
table 30131 "Shpfy Shipment Method"
{
    Access = Internal;
    Caption = 'Shopify Shipment Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
    }

    keys
    {
        key(PK; "Shop Code", Name)
        {
            Clustered = true;
        }
    }
}