table 40908 "Hist. Purchase Recv. Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Receipt No."; Code[35])
        {
            Caption = 'Receipt No.';
            NotBlank = true;
        }
        field(2; "Document Type"; enum "Hist. Purchase Recv. Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(3; "Vendor Document No."; Code[35])
        {
            Caption = 'Vendor Document No.';
        }
        field(4; "Receipt Date"; Date)
        {
            Caption = 'Receipt Date';
        }
        field(5; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(6; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(7; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(8; "Vendor No."; Code[35])
        {
            Caption = 'Vendor No.';
        }
        field(9; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
        }
        field(10; "Subtotal"; Decimal)
        {
            Caption = 'Subtotal';
        }
        field(11; "Trade Discount Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
        }
        field(12; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(13; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(14; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(15; "1099 Amount"; Decimal)
        {
            Caption = '1099 Amount';
        }
        field(16; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(17; "Discount Percent Amount"; Decimal)
        {
            Caption = 'Discount Percent Amount';
        }
        field(18; "Discount Dollar Amount"; Decimal)
        {
            Caption = 'Discount Dollar Amount';
        }
        field(19; "Discount Available Amount"; Decimal)
        {
            Caption = 'Discount Available Amount';
        }
        field(20; "Discount Date"; Date)
        {
            Caption = 'Discount Date';
        }
        field(21; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(22; "Reference"; Text[50])
        {
            Caption = 'Reference';
        }
        field(23; "Void"; Boolean)
        {
            Caption = 'Void';
        }
        field(24; "User"; Text[50])
        {
            Caption = 'User';
        }
        field(25; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(26; "Voucher No."; Code[35])
        {
            Caption = 'Voucher No.';
        }
        field(27; "Currency Code"; Code[35])
        {
            Caption = 'Currency Code';
        }
        field(28; "Invoice Receipt Date"; Date)
        {
            Caption = 'Invoice Receipt Date';
        }
        field(29; "Prepayment Amount"; Decimal)
        {
            Caption = 'Prepayment Amount';
        }
    }

    keys
    {
        key(Key1; "Receipt No.")
        {
            Clustered = true;
        }
        key(Key2; "Audit Code")
        {
        }
        key(Key3; "Vendor No.")
        {
        }
    }
}