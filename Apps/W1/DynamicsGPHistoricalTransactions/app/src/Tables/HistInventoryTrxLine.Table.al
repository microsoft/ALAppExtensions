table 40907 "Hist. Inventory Trx. Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
            NotBlank = true;
        }
        field(2; "Document Type"; enum "Hist. Inventory Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(3; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(4; "Line Item Sequence"; Integer)
        {
            Caption = 'Line Item Sequence';
            NotBlank = true;
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(6; "Source Description"; Text[50])
        {
            Caption = 'Source Description';
        }
        field(7; "Customer No."; Code[35])
        {
            Caption = 'Customer No.';
        }
        field(8; "Item No."; Code[35])
        {
            Caption = 'Item No.';
        }
        field(9; "Unit of Measure"; Code[35])
        {
            Caption = 'Unit of Measure';
        }
        field(10; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(11; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(12; "Ext. Cost"; Decimal)
        {
            Caption = 'Ext. Cost';
        }
        field(13; "Location Code"; Code[35])
        {
            Caption = 'Location Code';
        }
        field(14; "Transfer To Location Code"; Code[35])
        {
            Caption = 'Transfer To Location Code';
        }
        field(15; "Reason Code"; Code[40])
        {
            Caption = 'Reason Code';
        }
    }

    keys
    {
        key(Key1; "Audit Code", "Document Type", "Document No.", "Line Item Sequence")
        {
            Clustered = true;
        }
    }
}