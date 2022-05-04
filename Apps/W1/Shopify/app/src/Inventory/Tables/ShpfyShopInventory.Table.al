/// <summary>
/// Table Shpfy Shop Inventory (ID 30112).
/// </summary>
table 30112 "Shpfy Shop Inventory"
{
    Access = Internal;
    Caption = 'Shopify Shop Inventory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Shpfy Shop";
        }

        field(2; "Product Id"; BigInteger)
        {
            Caption = 'Product Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(3; "Variant Id"; BigInteger)
        {
            Caption = 'Variant Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(4; "Location Id"; BigInteger)
        {
            Caption = 'Location Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(5; "Inventory Item Id"; BigInteger)
        {
            Caption = 'Inventory Item Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(6; "Shopify Stock"; Integer)
        {
            Caption = 'Shopify Stock';
            DataClassification = CustomerContent;
            Description = 'Last imported stock from Shopify.';
            Editable = false;

            trigger OnValidate()
            begin
                "Last Synced On" := CurrentDateTime();
            end;
        }

        field(7; Stock; Integer)
        {
            Caption = 'Last Calculated Stock';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                "Last Calculated On" := CurrentDateTime();
            end;
        }

        field(8; "Last Synced On"; DateTime)
        {
            Caption = 'Last Synced On';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(9; "Last Calculated On"; DateTime)
        {
            Caption = 'Last Calculated On';
            DataClassification = CustomerContent;
        }

        field(10; "Location Name"; Text[250])
        {
            CalcFormula = lookup("Shpfy Shop Location".Name where("Shop Code" = field("Shop Code"), Id = field("Location Id")));
            Caption = 'Location Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Shop Code", "Product Id", "Variant Id", "Location Id")
        {
            Clustered = true;
        }
    }
}