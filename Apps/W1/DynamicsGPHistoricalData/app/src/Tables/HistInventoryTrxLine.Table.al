namespace Microsoft.DataMigration.GP.HistoricalData;

table 40907 "Hist. Inventory Trx. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
            NotBlank = true;
        }
        field(3; "Document Type"; enum "Hist. Inventory Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(4; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(5; "Line Item Sequence"; Integer)
        {
            Caption = 'Line Item Sequence';
            NotBlank = true;
        }
        field(6; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(7; "Source Description"; Text[50])
        {
            Caption = 'Source Description';
        }
        field(8; "Customer No."; Code[35])
        {
            Caption = 'Customer No.';
        }
        field(9; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(10; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(11; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(12; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(13; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
        }
        field(14; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(15; "Transfer To Location Code"; Code[35])
        {
            Caption = 'Transfer To Location Code';
        }
        field(16; "Reason Code"; Code[40])
        {
            Caption = 'Reason Code';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.")
        {
        }
    }
}