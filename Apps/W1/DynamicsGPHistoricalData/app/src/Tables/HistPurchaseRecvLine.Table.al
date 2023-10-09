namespace Microsoft.DataMigration.GP.HistoricalData;

table 40909 "Hist. Purchase Recv. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Receipt No."; Code[35])
        {
            Caption = 'Receipt No.';
            NotBlank = true;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            NotBlank = true;
        }
        field(4; "PO Number"; Code[35])
        {
            Caption = 'PO Number';
        }
        field(5; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(6; "Item Desc."; Text[100])
        {
            Caption = 'Item Desc.';
        }
        field(7; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
        }
        field(8; "Vendor Item Desc."; Text[100])
        {
            Caption = 'Vendor Item Desc.';
        }
        field(9; "Base UofM Qty."; Decimal)
        {
            Caption = 'Base UofM Qty.';
        }
        field(10; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(11; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(12; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(13; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
        }
        field(14; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(15; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(16; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(17; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(18; "Orig. Unit Cost"; Decimal)
        {
            Caption = 'Orig. Unit Cost';
        }
        field(19; "Orig. Ext. Cost"; Decimal)
        {
            Caption = 'Orig. Ext. Cost';
        }
        field(20; "Orig. Disc. Taken Amount"; Decimal)
        {
            Caption = 'Orig. Disc. Taken Amount';
        }
        field(21; "Orig. Trade Disc. Amount"; Decimal)
        {
            Caption = 'Orig. Trade Disc. Amount';
        }
        field(22; "Orig. Freight Amount"; Decimal)
        {
            Caption = 'Orig. Freight Amount';
        }
        field(23; "Orig. Misc. Amount"; Decimal)
        {
            Caption = 'Orig. Misc. Amount';
        }
        field(24; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
        }
        field(25; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(key2; "Receipt No.")
        {
            IncludedFields = "Line No.";
        }
    }
}