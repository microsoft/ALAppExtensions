table 4095 "GP Item"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; No; Code[75])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(3; SearchDescription; Code[50])
        {
            Caption = 'Search Description';
            DataClassification = CustomerContent;
        }
        field(4; ShortName; Text[50])
        {
            Caption = 'Short Name';
            DataClassification = CustomerContent;
        }
        field(5; BaseUnitOfMeasure; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(6; ItemType; Integer)
        {
            Caption = 'Item Type';
            DataClassification = CustomerContent;
        }
        field(7; CostingMethod; Text[50])
        {
            Caption = 'Costing Method';
            DataClassification = CustomerContent;
        }
        field(8; CurrentCost; Decimal)
        {
            Caption = 'Current Cost';
            DataClassification = CustomerContent;
        }
        field(9; StandardCost; Decimal)
        {
            Caption = 'Standard Cost';
            DataClassification = CustomerContent;
        }
        field(10; UnitListPrice; Decimal)
        {
            Caption = 'Unit List Price';
            DataClassification = CustomerContent;
        }
        field(11; ShipWeight; Decimal)
        {
            Caption = 'Shipping Weight';
            DataClassification = CustomerContent;
        }
        field(12; InActive; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(13; QuantityOnHand; Decimal)
        {
            Caption = 'Quantity on Hand';
            DataClassification = CustomerContent;
        }
        field(14; SalesUnitOfMeasure; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(15; PurchUnitOfMeasure; Code[10])
        {
            Caption = 'Purchase Unit of Measure';
            DataClassification = CustomerContent;
        }
        field(16; ItemTrackingCode; Code[10])
        {
            Caption = 'Item Tracking Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}