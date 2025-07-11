namespace Microsoft.DataMigration.GP.HistoricalData;

table 40903 "Hist. Sales Trx. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Sales Trx. Type"; enum "Hist. Sales Trx. Type")
        {
            Caption = 'Sales Type';
            NotBlank = true;
        }
        field(3; "Sales Header No."; Code[35])
        {
            Caption = 'Sales Header No.';
            NotBlank = true;
            TableRelation = "Hist. Sales Trx. Header"."No.";
        }
        field(4; "Line Item Sequence No."; Integer)
        {
            Caption = 'Line Item Sequence No.';
            NotBlank = true;
            InitValue = 0;
        }
        field(5; "Component Sequence"; Integer)
        {
            Caption = 'Component Sequence';
            NotBlank = true;
            InitValue = 0;
        }
        field(6; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(7; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
        }
        field(8; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(9; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            BlankZero = true;
        }
        field(10; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            BlankZero = true;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            BlankZero = true;
        }
        field(12; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
            BlankZero = true;
        }
        field(13; "Ext. Price"; Decimal)
        {
            Caption = 'Ext. Price';
            BlankZero = true;
        }
        field(14; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            BlankZero = true;
        }
        field(15; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(16; "Ship-to Name"; Text[65])
        {
            Caption = 'Ship-to Name';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Sales Trx. Type", "Sales Header No.")
        {
        }
    }
}