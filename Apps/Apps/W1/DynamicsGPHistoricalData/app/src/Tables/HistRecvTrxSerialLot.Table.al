namespace Microsoft.DataMigration.GP.HistoricalData;

table 40916 "Hist. Recv. Trx. SerialLot"
{
    Caption = 'Hist. Recv. Trx. SerialLot';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(3; "Qty. Type"; enum "Hist. Inventory Qty. Type")
        {
            Caption = 'Qty. Type';
        }
        field(4; "Serial/Lot Number"; Text[50])
        {
            Caption = 'Serial/Lot Number';
        }
        field(5; "Serial/Lot Qty."; Decimal)
        {
            Caption = 'Serial/Lot Qty.';
        }
        field(6; "Date Received"; Date)
        {
            Caption = 'Date Received';
        }
        field(7; "Date Sequence No."; Decimal)
        {
            Caption = 'Date Sequence No.';
        }
        field(8; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(9; "No."; Code[35])
        {
            Caption = 'No.';
        }
        field(10; "Sales Trx. Type"; enum "Hist. Sales Trx. Type")
        {
            Caption = 'Sales Trx. Type';
        }
        field(11; "Line Item Sequence"; Decimal)
        {
            Caption = 'Line Item Sequence';
        }
        field(12; "Component Sequence"; Decimal)
        {
            Caption = 'Component Sequence';
        }
        field(13; "Serial/Lot Seq. Number"; Integer)
        {
            Caption = 'Serial/Lot Seq. No.';
        }
        field(14; "Override Serial/Lot"; Boolean)
        {
            Caption = 'Override Serial/Lot';
        }
        field(15; Bin; Text[50])
        {
            Caption = 'Bin';
        }
        field(16; "Manufacture Date"; Date)
        {
            Caption = 'Manufacture Date';
        }
        field(17; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(18; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Sales Trx. Type", "No.", "Line Item Sequence")
        {
            IncludedFields = "Item No.", "Qty. Type", "Component Sequence", "Serial/Lot Seq. Number", "Audit Code";
        }
        key(Key3; "Serial/Lot Number")
        {
            IncludedFields = "Item No.", "Qty. Type", "Component Sequence", "Serial/Lot Seq. Number", "Audit Code";
        }
    }
}