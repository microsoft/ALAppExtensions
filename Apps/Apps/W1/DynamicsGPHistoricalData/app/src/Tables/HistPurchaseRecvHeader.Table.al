namespace Microsoft.DataMigration.GP.HistoricalData;

table 40908 "Hist. Purchase Recv. Header"
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
        field(3; "Document Type"; enum "Hist. Purchase Recv. Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(4; "Vendor Document No."; Code[35])
        {
            Caption = 'Vendor Document No.';
        }
        field(5; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';
        }
        field(6; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(7; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(8; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(9; "Vendor No."; Code[35])
        {
            Caption = 'Vendor No.';
        }
        field(10; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
        }
        field(11; "Subtotal"; Decimal)
        {
            Caption = 'Subtotal';
        }
        field(12; "Trade Discount Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
        }
        field(13; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(14; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(15; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(16; "1099 Amount"; Decimal)
        {
            Caption = '1099 Amount';
        }
        field(17; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(18; "Discount Percent Amount"; Decimal)
        {
            Caption = 'Discount Percent Amount';
        }
        field(19; "Discount Dollar Amount"; Decimal)
        {
            Caption = 'Discount Dollar Amount';
        }
        field(20; "Discount Available Amount"; Decimal)
        {
            Caption = 'Discount Available Amount';
        }
        field(21; "Discount Date"; Date)
        {
            Caption = 'Discount Date';
        }
        field(22; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(23; "Reference"; Text[50])
        {
            Caption = 'Reference';
        }
        field(24; "Void"; Boolean)
        {
            Caption = 'Void';
        }
        field(25; "User"; Text[50])
        {
            Caption = 'User';
        }
        field(26; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(27; "Voucher No."; Code[35])
        {
            Caption = 'Voucher No.';
        }
        field(28; "Currency Code"; Code[35])
        {
            Caption = 'Currency Code';
        }
        field(29; "Invoice Receipt Date"; Date)
        {
            Caption = 'Invoice Receipt Date';
        }
        field(30; "Prepayment Amount"; Decimal)
        {
            Caption = 'Prepayment Amount';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Receipt No.")
        {
            IncludedFields = "Audit Code", "Vendor No.";
        }
    }
}