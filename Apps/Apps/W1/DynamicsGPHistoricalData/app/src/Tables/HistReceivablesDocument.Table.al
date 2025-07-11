namespace Microsoft.DataMigration.GP.HistoricalData;

table 40904 "Hist. Receivables Document"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[35])
        {
            Caption = 'Customer No.';
            NotBlank = true;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(4; "Document Type"; enum "Hist. Receivables Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(5; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(6; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(7; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(8; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(9; "Trx. Description"; Text[50])
        {
            Caption = 'Trx. Description';
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(11; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(12; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(13; User; Text[50])
        {
            Caption = 'User';
        }
        field(14; "Currency Code"; Code[10])
        {
            Caption = 'Currency';
        }
        field(15; "Orig. Trx. Amount"; Decimal)
        {
            Caption = 'Orig. Trx. Amount';
        }
        field(16; "Current Trx. Amount"; Decimal)
        {
            Caption = 'Current Trx. Amount';
        }
        field(17; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(18; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
        }
        field(19; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(20; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(21; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(22; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Disc. Taken Amount';
        }
        field(23; "Customer Purchase No."; Code[35])
        {
            Caption = 'Customer Purchase No.';
        }
        field(24; "Salesperson No."; Code[35])
        {
            Caption = 'Salesperson No.';
        }
        field(25; "Sales Territory"; Text[50])
        {
            Caption = 'Sales Territory';
        }
        field(26; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(27; "Cash Amount"; Decimal)
        {
            Caption = 'Cash Amount';
        }
        field(28; "Commission Dollar Amount"; Decimal)
        {
            Caption = 'Commission Dollar Amount';
        }
        field(29; "Invoice Paid Off Date"; Date)
        {
            Caption = 'Invoice Paid Off Date';
        }
        field(30; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(31; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
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
            IncludedFields = "Customer No.", "Audit Code";
        }
        key(Key3; "Customer No.")
        {
        }
    }
}