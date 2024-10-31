namespace Microsoft.DataMigration.GP.HistoricalData;

table 40905 "Hist. Payables Document"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Voucher No."; Code[35])
        {
            Caption = 'Voucher No.';
            NotBlank = true;
        }
        field(3; "Vendor No."; Code[35])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
        }
        field(4; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
        }
        field(5; "Document Type"; enum "Hist. Payables Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(6; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(8; "Document Amount"; Decimal)
        {
            Caption = 'Document Amount';
        }
        field(9; "Currency Code"; Code[10])
        {
            Caption = 'Currency';
        }
        field(10; "Current Trx. Amount"; Decimal)
        {
            Caption = 'Current Trx. Amount';
        }
        field(11; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Disc. Taken Amount';
        }
        field(12; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(13; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(14; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(15; "Purchase No."; Code[35])
        {
            Caption = 'Purchase No.';
        }
        field(16; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(17; "Trx. Description"; Text[50])
        {
            Caption = 'Trx. Description';
        }
        field(18; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(19; User; Text[50])
        {
            Caption = 'User';
        }
        field(20; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(21; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(22; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(23; "Total Payments"; Decimal)
        {
            Caption = 'Total Payments';
        }
        field(24; Voided; Boolean)
        {
            Caption = 'Voided';
            InitValue = false;
        }
        field(25; "Invoice Paid Off Date"; Date)
        {
            Caption = 'Invoice Paid Off Date';
        }
        field(26; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(27; "1099 Amount"; Decimal)
        {
            Caption = '1099 Amount';
        }
        field(28; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
        }
        field(29; "Trade Discount Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
        }
        field(30; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(31; "1099 Type"; Text[50])
        {
            Caption = '1099 Type';
        }
        field(32; "1099 Box Number"; Text[50])
        {
            Caption = '1099 Box Number';
        }
        field(33; "PO Number"; Code[35])
        {
            Caption = 'PO Number';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Voucher No.", "Document Type", "Document No.")
        {
            IncludedFields = "Audit Code", "Vendor No.";
        }
        key(Key3; "Vendor No.")
        {
        }
    }
}