namespace Microsoft.DataMigration.GP.HistoricalData;

table 40915 "Hist. Invt. Trx. SerialLot"
{
    Caption = 'Hist. Invt. Trx. SerialLot';
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
        field(3; "Serial/Lot Number"; Text[50])
        {
            Caption = 'Serial/Lot Number';
        }
        field(4; "Serial/Lot Qty."; Decimal)
        {
            Caption = 'Serial/Lot Qty.';
        }
        field(5; "Document No."; Code[35])
        {
            Caption = 'Document No.';
        }
        field(6; "Document Type"; enum "Hist. Inventory Doc. Type")
        {
            Caption = 'Document Type';
        }
        field(7; "Line Sequence Number"; Decimal)
        {
            Caption = 'Line Sequence Number';
        }
        field(8; "Serial/Lot Seq. Number"; Integer)
        {
            Caption = 'Serial/Lot Seq. Number';
        }
        field(9; "From Bin"; Text[50])
        {
            Caption = 'From Bin';
        }
        field(10; "To Bin"; Text[50])
        {
            Caption = 'To Bin';
        }
        field(11; "Manufacture Date"; Date)
        {
            Caption = 'Manufacture Date';
        }
        field(12; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(13; "Audit Code"; Code[35])
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
        key(Key2; "Document Type", "Document No.", "Line Sequence Number")
        {
            IncludedFields = "Item No.", "Serial/Lot Seq. Number", "Audit Code";
        }
        key(Key3; "Serial/Lot Number")
        {
            IncludedFields = "Item No.", "Serial/Lot Seq. Number", "Audit Code";
        }
    }
}