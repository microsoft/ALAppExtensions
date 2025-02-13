table 6100 "E-Invoice Line"
{
    Access = Internal;
    Caption = 'E-Invoice Line';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No';
            TableRelation = "E-Document";
            ToolTip = 'Specifies the E-Document number that the line is related to.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number in the E-Document of the item or resource being purchased.';
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies what is being purchased.';
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Describes what is being purchased.';
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours.';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity of what you''re buying. The number is based on the unit chosen in the Unit of Measure Code field.';
        }
        field(7; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            ToolTip = 'Specifies the price of one unit of what you are buying.';
        }
        field(8; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
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