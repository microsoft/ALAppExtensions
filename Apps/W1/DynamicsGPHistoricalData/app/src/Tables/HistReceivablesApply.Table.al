namespace Microsoft.DataMigration.GP.HistoricalData;

table 40914 "Hist. Receivables Apply"
{
    Caption = 'Hist. Receivables Apply';
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
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(4; "Corporate Customer No."; Code[35])
        {
            Caption = 'Corporate Customer No.';
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(6; "GL Posting Date"; Date)
        {
            Caption = 'GL Posting Date';
        }
        field(7; "Apply To Document No."; Code[35])
        {
            Caption = 'Apply To Document No.';
        }
        field(8; "Apply To Document Type"; enum "Hist. Receivables Doc. Type")
        {
            Caption = 'Apply To Document Type';
        }
        field(9; "Apply To Document Date"; Date)
        {
            Caption = 'Apply To Document Date';
        }
        field(10; "Apply To GL Posting Date"; Date)
        {
            Caption = 'Apply To GL Posting Date';
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(12; "Apply To Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply To Amount';
        }
        field(13; "Discount Taken Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Discount Taken Amount';
        }
        field(14; "Discount Available Taken"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Discount Available Taken';
        }
        field(15; "Write Off Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Write Off Amount';
        }
        field(16; "Orig. Apply To Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Apply To Amount';
        }
        field(17; "Orig. Disc. Taken Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Discount Taken Amount';
        }
        field(18; "Orig. Disc. Available Taken"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Discount Available Taken';
        }
        field(19; "Orig. Write Off Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Write Off Amount';
        }
        field(20; "Apply To Exchange Rate"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Apply To Exchange Rate';
        }
        field(21; "Apply To Denom. Exch. Rate"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Apply To Denom. Exchange Rate';
        }
        field(22; "Apply From Document No."; Code[35])
        {
            Caption = 'Apply From Document No.';
        }
        field(23; "Apply From Document Type"; enum "Hist. Receivables Doc. Type")
        {
            Caption = 'Apply From Document Type';
        }
        field(24; "Apply From Document Date"; Date)
        {
            Caption = 'Apply From Document Date';
        }
        field(25; "Apply From GL Posting Date"; Date)
        {
            Caption = 'Apply From GL Posting Date';
        }
        field(26; "Apply From Currency Code"; Code[10])
        {
            Caption = 'Apply From Currency Code';
        }
        field(27; "Apply From Apply Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply From Apply Amount';
        }
        field(28; "Apply From Disc. Taken Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply From Discount Taken Amount';
        }
        field(29; "Apply From Disc. Avail. Taken"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply From Discount Avail. Taken';
        }
        field(30; "Apply From Write Off Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply From Write Off Amount';
        }
        field(31; "Actual Apply To Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Actual Apply To Amount';
        }
        field(32; "Actual Disc. Taken Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Actual Discount Taken Amount';
        }
        field(33; "Actual Disc. Avail. Taken"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Actual Discount Avail. Taken';
        }
        field(34; "Actual Write Off Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Actual Write Off Amount';
        }
        field(35; "Apply From Exchange Rate"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Apply From Exchange Rate';
        }
        field(36; "Apply From Denom. Exch. Rate"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Apply From Denom. Exch. Rate';
        }
        field(37; "Apply From Round Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Apply From Round Amount';
        }
        field(38; "Apply To Round Amount"; Decimal)
        {
            Caption = 'Apply To Round Amount';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(39; "Apply To Round Discount"; Decimal)
        {
            Caption = 'Apply To Round Discount';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(40; "Orig. Apply From Round Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Apply From Round Amount';
        }
        field(41; "Orig. Apply To Round Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Apply To Round Amount';
        }
        field(42; "Orig. Apply To Round Discount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Originating Apply To Round Discount';
        }
        field(43; "GST Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'GST Discount Amount';
        }
        field(44; "PPS Amount Deducted"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'PPS Amount Deducted';
        }
        field(45; "Realized Gain-Loss Amount"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Realized Gain-Loss Amount';
        }
        field(46; "Settled Gain CreditCurrTrx"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Gain CreditCurrTrx';
        }
        field(47; "Settled Loss CreditCurrTrx"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Loss CreditCurrTrx';
        }
        field(48; "Settled Gain DebitCurrTrx"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Gain DebitCurrTrx';
        }
        field(49; "Settled Loss DebitCurrTrx"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Loss DebitCurrTrx';
        }
        field(50; "Settled Gain DebitDiscAvail"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Gain DebitDiscAvail';
        }
        field(51; "Settled Loss DebitDiscAvail"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Settled Loss DebitDiscAvail';
        }
        field(52; "Audit Code"; Code[35])
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
        key(Key2; "Customer No.", "Apply To Document No.", "Apply To Document Type")
        {
        }
        key(Key3; "Customer No.")
        {
        }
    }
}