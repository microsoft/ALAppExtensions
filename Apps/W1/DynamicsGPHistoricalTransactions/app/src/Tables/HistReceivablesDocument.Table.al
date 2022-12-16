table 40904 "Hist. Receivables Document"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[35])
        {
            Caption = 'Customer No.';
            NotBlank = true;
        }
        field(2; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(3; "Document Type"; enum "Hist. Receivables Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(4; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(5; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(6; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(7; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(8; "Trx. Description"; Text[50])
        {
            Caption = 'Trx. Description';
        }
        field(9; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(10; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(11; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(12; User; Text[50])
        {
            Caption = 'User';
        }
        field(13; "Currency Code"; Code[10])
        {
            Caption = 'Currency';
        }
        field(14; "Orig. Trx. Amount"; Decimal)
        {
            Caption = 'Orig. Trx. Amount';
        }
        field(15; "Current Trx. Amount"; Decimal)
        {
            Caption = 'Current Trx. Amount';
        }
        field(16; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(17; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
        }
        field(18; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(19; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(20; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(21; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Disc. Taken Amount';
        }
        field(22; "Customer Purchase No."; Code[35])
        {
            Caption = 'Customer Purchase No.';
        }
        field(23; "Salesperson No."; Code[35])
        {
            Caption = 'Salesperson No.';
        }
        field(24; "Sales Territory"; Text[50])
        {
            Caption = 'Sales Territory';
        }
        field(25; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(26; "Cash Amount"; Decimal)
        {
            Caption = 'Cash Amount';
        }
        field(27; "Commission Dollar Amount"; Decimal)
        {
            Caption = 'Commission Dollar Amount';
        }
        field(28; "Invoice Paid Off Date"; Date)
        {
            Caption = 'Invoice Paid Off Date';
        }
        field(29; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(30; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Document Type", "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Audit Code")
        {
        }
        key(Key3; "Customer No.")
        {
        }
    }
}