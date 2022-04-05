/// <summary>
/// Table Shpfy Order Line (ID 30119).
/// </summary>
table 30119 "Shpfy Order Line"
{
    Access = Internal;
    Caption = 'Shopify Order Line';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Shopify Order Id"; BigInteger)
        {
            Caption = 'Shopify Order Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line Id"; BigInteger)
        {
            Caption = 'Line Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Shopify Product Id"; BigInteger)
        {
            Caption = 'Shopify Product Id';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(6; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Shopify Variant Id"; BigInteger)
        {
            Caption = 'Shopify Variant Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Variant Description"; Text[50])
        {
            Caption = 'Variant Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Fulfillment Service"; Text[100])
        {
            Caption = 'Fulfillment Service';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; Taxable; Boolean)
        {
            Caption = 'Taxable';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Gift Card"; Boolean)
        {
            Caption = 'Gift Card';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Product Exists"; Boolean)
        {
            Caption = 'Product Exists';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(15; "Fulfillable Quantity"; Decimal)
        {
            Caption = 'Fulfillable Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(16; Tip; Boolean)
        {
            Caption = 'Tip';
            DataClassification = SystemMetadata;
            Editable = true;
        }
        field(17; "Location Id"; BigInteger)
        {
            Caption = 'Location Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1000; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            TableRelation = Item;

            trigger OnValidate();
            begin
                if "Item No." <> xRec."Item No." then begin
                    ErrorIfSalesOrderExists();
                    Validate("Variant Code", '');
                    Validate("Unit of Measure Code", '');
                end;
            end;
        }
        field(1001; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));

            trigger OnValidate();
            begin
                if "Variant Code" <> xRec."Variant Code" then
                    ErrorIfSalesOrderExists();
            end;
        }
        field(1002; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate();
            begin
                if "Unit of Measure Code" <> xRec."Unit of Measure Code" then
                    ErrorIfSalesOrderExists();
            end;
        }
    }

    keys
    {
        key(Key1; "Shopify Order Id", "Line Id")
        {
            Clustered = true;
        }
        key(Idx001; "Shopify Order Id", "Gift Card", Tip)
        {
            SumIndexFields = Quantity;
        }
    }

    /// <summary> 
    /// Error If Sales Order Exists.
    /// </summary>
    local procedure ErrorIfSalesOrderExists();
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
    begin
        ShopifyOrderHeader.Get("Shopify Order Id");
        ShopifyOrderHeader.TestField("Sales Order No.", '');
    end;
}

