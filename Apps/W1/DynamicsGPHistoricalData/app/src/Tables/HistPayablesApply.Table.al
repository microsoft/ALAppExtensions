namespace Microsoft.DataMigration.GP.HistoricalData;

table 40913 "Hist. Payables Apply"
{
    Caption = 'Hist. Payables Apply';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Vendor No."; Code[35])
        {
            Caption = 'Vendor No.';
        }
        field(3; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
        }
        field(4; "Document Type"; enum "Hist. Payables Doc. Type")
        {
            Caption = 'Document Type';
        }
        field(5; "Apply To Voucher No."; Code[35])
        {
            Caption = 'Apply To Voucher No.';
        }
        field(6; "Apply To Document No."; Code[35])
        {
            Caption = 'Apply To Document No.';
        }
        field(7; "Apply To Document Type"; enum "Hist. Payables Doc. Type")
        {
            Caption = 'Apply To Document Type';
        }
        field(8; "Apply To Document Date"; Date)
        {
            Caption = 'Apply To Document Date';
        }
        field(9; "Voucher No."; Code[35])
        {
            Caption = 'Voucher No.';
        }
        field(10; "Document Amount"; Decimal)
        {
            Caption = 'Document Amount';
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(12; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Disc. Taken Amount';
        }
        field(13; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
        }
        field(14; "Orig. Applied Amount"; Decimal)
        {
            Caption = 'Orig. Applied Amount';
        }
        field(15; "Orig. Discount Taken Amount"; Decimal)
        {
            Caption = 'Orig. Discount Taken Amount';
        }
        field(16; "Orig. Discount Available Taken"; Decimal)
        {
            Caption = 'Orig. Discount Available Taken';
        }
        field(17; "Orig. Write Off Amount"; Decimal)
        {
            Caption = 'Orig. Write Off Amount';
        }
        field(18; "Apply To Post Date"; Date)
        {
            Caption = 'Apply To Post Date';
        }
        field(19; "Apply From Document No."; Code[35])
        {
            Caption = 'Apply From Document No.';
        }
        field(20; "Apply From GL Posting Date"; Date)
        {
            Caption = 'Apply From GL Posting Date';
        }
        field(21; "Apply From Currency Code"; Code[10])
        {
            Caption = 'Apply From Currency ID';
        }
        field(22; "Apply From Apply Amount"; Decimal)
        {
            Caption = 'Apply From Apply Amount';
        }
        field(23; "Apply From Disc. Taken Amount"; Decimal)
        {
            Caption = 'Apply From Discount Taken Amount';
        }
        field(24; "Apply From Disc. Avail. Taken"; Decimal)
        {
            Caption = 'Apply From Discount Available Taken';
        }
        field(25; "Apply From Write Off Amount"; Decimal)
        {
            Caption = 'Apply From Write Off Amount';
        }
        field(26; "Actual Apply To Amount"; Decimal)
        {
            Caption = 'Actual Apply To Amount';
        }
        field(27; "Actual Discount Taken Amount"; Decimal)
        {
            Caption = 'Actual Discount Taken Amount';
        }
        field(28; "Actual Disc. Available Taken"; Decimal)
        {
            Caption = 'Actual Discount Available Taken';
        }
        field(29; "Actual Write Off Amount"; Decimal)
        {
            Caption = 'Actual Write Off Amount';
        }
        field(30; "Apply From Exchange Rate"; Decimal)
        {
            Caption = 'Apply From Exchange Rate';
        }
        field(31; "Apply From Denom. Exch. Rate"; Decimal)
        {
            Caption = 'Apply From Denomination Exchange Rate';
        }
        field(32; "PPS Amount Deducted"; Decimal)
        {
            Caption = 'PPS Amount Deducted';
        }
        field(33; "GST Discount Amount"; Decimal)
        {
            Caption = 'GST Discount Amount';
        }
        field(34; "1099 Amount"; Decimal)
        {
            Caption = '1099 Amount';
        }
        field(35; "Credit 1099 Amount"; Decimal)
        {
            Caption = 'Credit 1099 Amount';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Document Type", "Voucher No.")
        {
        }
        key(Key3; "Vendor No.")
        {
        }
    }
}