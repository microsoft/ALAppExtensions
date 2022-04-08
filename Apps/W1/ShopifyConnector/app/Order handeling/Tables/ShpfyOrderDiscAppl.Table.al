/// <summary>
/// Table Shpfy Order Disc.Appl. (ID 30117).
/// </summary>
table 30117 "Shpfy Order Disc.Appl."
{
    Access = Internal;
    Caption = 'Shopify Order Discount Application';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; Type; Text[50])
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(4; "Code"; Text[50])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(5; "Allocation Method"; Enum "Shpfy Allocation Method")
        {
            Caption = 'Allocation Method';
            DataClassification = SystemMetadata;
        }
        field(6; "Target Selection"; Enum "Shpfy Target Selection")
        {
            Caption = 'Target Selection';
            DataClassification = SystemMetadata;
        }
        field(7; "Target Type"; Enum "Shpfy Target Type")
        {
            Caption = 'Target Type';
            DataClassification = SystemMetadata;
        }
        field(8; "Value Type"; Enum "Shpfy Value Type")
        {
            Caption = 'Value Type';
            DataClassification = SystemMetadata;
        }
        field(9; Value; Decimal)
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Order Id", "Line No.")
        {
            Clustered = true;
        }
    }

}
