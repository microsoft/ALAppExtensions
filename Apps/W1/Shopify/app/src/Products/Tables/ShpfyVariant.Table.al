namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Table Shpfy Variant (ID 30129).
/// </summary>
table 30129 "Shpfy Variant"
{
    Caption = 'Shopify Variant';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; "Product Id"; BigInteger)
        {
            Caption = 'ProductId';
            DataClassification = CustomerContent;
        }
        field(3; "Created At"; DateTime)
        {
            Caption = 'CreatedAt';
            DataClassification = CustomerContent;
        }
        field(4; "Updated At"; DateTime)
        {
            Caption = 'Updated At';
            DataClassification = CustomerContent;
        }
        field(5; "Available For Sales"; Boolean)
        {
            Caption = 'Available For Sales';
            DataClassification = CustomerContent;
        }
        field(6; Barcode; Text[50])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
        field(7; "Compare at Price"; Decimal)
        {
            Caption = 'Compare at Price';
            DataClassification = CustomerContent;
        }
        field(8; "Display Name"; Text[250])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
        }
        field(9; "Inventory Policy"; Enum "Shpfy Inventory Policy")
        {
            Caption = 'Inventory Policy';
            DataClassification = CustomerContent;
        }
        field(10; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(11; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(12; SKU; Text[50])
        {
            Caption = 'SKU';
            DataClassification = CustomerContent;
        }
        field(13; "Tax Code"; Code[20])
        {
            Caption = 'Tax Code';
            DataClassification = CustomerContent;
        }
        field(14; Taxable; Boolean)
        {
            Caption = 'Taxable';
            DataClassification = CustomerContent;
        }
        field(15; Title; Text[100])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(16; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        field(17; "Option 1 Name"; Text[50])
        {
            Caption = 'Option 1 Name';
            DataClassification = CustomerContent;
        }
        field(18; "Option 1 Value"; Text[50])
        {
            Caption = 'Option 1 Value';
            DataClassification = CustomerContent;
        }
        field(19; "Option 2 Name"; Text[50])
        {
            Caption = 'Option 2 Name';
            DataClassification = CustomerContent;
        }
        field(20; "Option 2 Value"; Text[50])
        {
            Caption = 'Option 2 Value';
            DataClassification = CustomerContent;
        }
        field(21; "Option 3 Name"; Text[50])
        {
            Caption = 'Option 3 Name';
            DataClassification = CustomerContent;
        }
        field(22; "Option 3 Value"; Text[50])
        {
            Caption = 'Option 3 Value';
            DataClassification = CustomerContent;
        }
        field(23; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(24; "Image Id"; BigInteger)
        {
            Caption = 'Image Id';
            DataClassification = CustomerContent;
        }
        field(100; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Shop";
        }

        field(101; "Item SystemId"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Item SystemId';
        }
        field(102; "Item Variant SystemId"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Item Variant SystemId';
        }
        field(103; "Last Updated by BC"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Updated by BC';
        }
        field(104; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."No." where(SystemId = field("Item SystemId")));
        }
        field(105; "Variant Code"; Code[10])
        {
            Caption = 'Variant No.';
            FieldClass = FlowField;
            CalcFormula = lookup("Item Variant".Code where(SystemId = field("Item Variant SystemId")));
        }
        field(106; "UoM Option Id"; Integer)
        {
            Caption = 'UoM Option Id';
            DataClassification = SystemMetadata;
        }
        field(107; "Mapped By Item"; Boolean)
        {
            Caption = 'Mapped By Item';
            DataClassification = SystemMetadata;
        }
        field(108; "Image Hash"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        InventoryItem: Record "Shpfy Inventory Item";
        Metafield: Record "Shpfy Metafield";
    begin
        InventoryItem.SetRange("Variant Id", Id);
        if not InventoryItem.IsEmpty then
            InventoryItem.DeleteAll();

        Metafield.SetRange("Parent Table No.", Database::"Shpfy Variant");
        Metafield.SetRange("Owner Id", Id);
        if not Metafield.IsEmpty then
            Metafield.DeleteAll();
    end;
}
