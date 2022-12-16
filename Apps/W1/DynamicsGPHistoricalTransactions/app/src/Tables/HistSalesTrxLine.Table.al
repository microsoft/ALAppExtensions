table 40903 "Hist. Sales Trx. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Trx. Type"; enum "Hist. Sales Trx. Type")
        {
            Caption = 'Sales Type';
            NotBlank = true;
        }
        field(2; "Sales Header No."; Code[35])
        {
            Caption = 'Sales Header No.';
            NotBlank = true;
            TableRelation = "Hist. Sales Trx. Header"."No.";
        }
        field(3; "Line Item Sequence No."; Integer)
        {
            Caption = 'Line Item Sequence No.';
            NotBlank = true;
            InitValue = 0;
        }
        field(4; "Component Sequence"; Integer)
        {
            Caption = 'Component Sequence';
            NotBlank = true;
            InitValue = 0;
        }
        field(5; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(6; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
        }
        field(7; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(8; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            BlankZero = true;
        }
        field(9; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            BlankZero = true;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            BlankZero = true;
        }
        field(11; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
            BlankZero = true;
        }
        field(12; "Ext. Price"; Decimal)
        {
            Caption = 'Ext. Price';
            BlankZero = true;
        }
        field(13; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            BlankZero = true;
        }
        field(14; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(15; "Ship-to Name"; Text[65])
        {
            Caption = 'Ship-to Name';
        }
    }

    keys
    {
        key(Key1; "Sales Trx. Type", "Sales Header No.", "Line Item Sequence No.", "Component Sequence")
        {
            Clustered = true;
        }
        key(Key2; "Sales Header No.")
        {
        }
    }
}