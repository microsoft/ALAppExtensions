table 6100 "E-Invoice Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            TableRelation = "E-Document";
            Caption = 'E-Document Entry No';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Unit of Measure Code"; Text[50])
        {
            Caption = 'Unit of Measure Code';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
        }
        field(8; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }
}