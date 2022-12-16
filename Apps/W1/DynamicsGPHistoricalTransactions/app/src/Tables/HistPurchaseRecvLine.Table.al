table 40909 "Hist. Purchase Recv. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[35])
        {
            Caption = 'Receipt No.';
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            NotBlank = true;
        }
        field(3; "PO Number"; Code[35])
        {
            Caption = 'PO Number';
        }
        field(4; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(5; "Item Desc."; Text[100])
        {
            Caption = 'Item Desc.';
        }
        field(6; "Vendor Item No."; Text[50])
        {
            Caption = 'Vendor Item No.';
        }
        field(7; "Vendor Item Desc."; Text[100])
        {
            Caption = 'Vendor Item Desc.';
        }
        field(8; "Base UofM Qty."; Decimal)
        {
            Caption = 'Base UofM Qty.';
        }
        field(9; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(10; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(11; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(12; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
        }
        field(13; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(14; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(15; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(16; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(17; "Orig. Unit Cost"; Decimal)
        {
            Caption = 'Orig. Unit Cost';
        }
        field(18; "Orig. Ext. Cost"; Decimal)
        {
            Caption = 'Orig. Ext. Cost';
        }
        field(19; "Orig. Disc. Taken Amount"; Decimal)
        {
            Caption = 'Orig. Disc. Taken Amount';
        }
        field(20; "Orig. Trade Disc. Amount"; Decimal)
        {
            Caption = 'Orig. Trade Disc. Amount';
        }
        field(21; "Orig. Freight Amount"; Decimal)
        {
            Caption = 'Orig. Freight Amount';
        }
        field(22; "Orig. Misc. Amount"; Decimal)
        {
            Caption = 'Orig. Misc. Amount';
        }
        field(23; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
        }
        field(24; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
        }
    }

    keys
    {
        key(Key1; "Receipt No.", "Line No.")
        {
            Clustered = true;
        }
    }
}