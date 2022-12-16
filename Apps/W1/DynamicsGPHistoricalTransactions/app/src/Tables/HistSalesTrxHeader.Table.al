table 40902 "Hist. Sales Trx. Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[35])
        {
            NotBlank = true;
        }
        field(2; "Sales Trx. Type"; enum "Hist. Sales Trx. Type")
        {
            Caption = 'Sales Type';
            NotBlank = true;
        }
        field(3; "Sales Trx. Status"; enum "Hist. Sales Trx. Status")
        {
            NotBlank = true;
        }
        field(4; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            NotBlank = true;
        }
        field(5; "Sub Total"; Decimal)
        {
            Caption = 'Sub Total';
        }
        field(6; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            BlankZero = true;
        }
        field(7; "Trade Disc. Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
            BlankZero = true;
        }
        field(8; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
            BlankZero = true;
        }
        field(9; "Misc. Amount"; Decimal)
        {
            Caption = 'Miscellaneous Amount';
            BlankZero = true;
        }
        field(10; "Payment Recv. Amount"; Decimal)
        {
            Caption = 'Payment Received Amount';
            BlankZero = true;
        }
        field(11; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Discount Taken Amount';
            BlankZero = true;
        }
        field(12; "Total"; Decimal)
        {
            Caption = 'Total';
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
            NotBlank = true;
        }
        field(14; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(15; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(16; "Customer No."; Text[35])
        {
            Caption = 'Customer No.';
        }
        field(17; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(18; "Ship-to Code"; Code[35])
        {
            Caption = 'Ship-to Code';
        }
        field(19; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }
        field(20; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
        }
        field(21; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(22; "Ship-to City"; Text[50])
        {
            Caption = 'Ship-to City';
        }
        field(23; "Ship-to State"; Text[50])
        {
            Caption = 'Ship-to State';
        }
        field(24; "Ship-to Zipcode"; Text[20])
        {
            Caption = 'Ship-to Zipcode';
        }
        field(25; "Ship-to Country"; Text[50])
        {
            Caption = 'Ship-to Country';
        }
        field(26; "Contact Person Name"; Text[100])
        {
            Caption = 'Contact Person Name';
        }
        field(27; "Salesperson No."; Code[35])
        {
            Caption = 'Salesperson No.';
        }
        field(28; "Sales Territory"; Text[50])
        {
            Caption = 'Sales Territory';
        }
        field(29; "Customer Purchase No."; Code[35])
        {
            Caption = 'Customer Purchase No.';
        }
        field(30; "Original No."; Code[35])
        {
            Caption = 'Original No.';
        }
        field(31; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(32; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
    }

    keys
    {
        key(Key1; "No.", "Sales Trx. Type")
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