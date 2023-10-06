namespace Microsoft.DataMigration.GP.HistoricalData;

table 40902 "Hist. Sales Trx. Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "No."; Code[35])
        {
            NotBlank = true;
        }
        field(3; "Sales Trx. Type"; enum "Hist. Sales Trx. Type")
        {
            Caption = 'Sales Type';
            NotBlank = true;
        }
        field(4; "Sales Trx. Status"; enum "Hist. Sales Trx. Status")
        {
            NotBlank = true;
        }
        field(5; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            NotBlank = true;
        }
        field(6; "Sub Total"; Decimal)
        {
            Caption = 'Sub Total';
        }
        field(7; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
            BlankZero = true;
        }
        field(8; "Trade Disc. Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
            BlankZero = true;
        }
        field(9; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
            BlankZero = true;
        }
        field(10; "Misc. Amount"; Decimal)
        {
            Caption = 'Miscellaneous Amount';
            BlankZero = true;
        }
        field(11; "Payment Recv. Amount"; Decimal)
        {
            Caption = 'Payment Received Amount';
            BlankZero = true;
        }
        field(12; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Discount Taken Amount';
            BlankZero = true;
        }
        field(13; "Total"; Decimal)
        {
            Caption = 'Total';
        }
        field(14; "Document Date"; Date)
        {
            Caption = 'Document Date';
            NotBlank = true;
        }
        field(15; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(16; "Actual Ship Date"; Date)
        {
            Caption = 'Actual Ship Date';
        }
        field(17; "Customer No."; Text[35])
        {
            Caption = 'Customer No.';
        }
        field(18; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(19; "Ship-to Code"; Code[35])
        {
            Caption = 'Ship-to Code';
        }
        field(20; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }
        field(21; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
        }
        field(22; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(23; "Ship-to City"; Text[50])
        {
            Caption = 'Ship-to City';
        }
        field(24; "Ship-to State"; Text[50])
        {
            Caption = 'Ship-to State';
        }
        field(25; "Ship-to Zipcode"; Text[20])
        {
            Caption = 'Ship-to Zipcode';
        }
        field(26; "Ship-to Country"; Text[50])
        {
            Caption = 'Ship-to Country';
        }
        field(27; "Contact Person Name"; Text[100])
        {
            Caption = 'Contact Person Name';
        }
        field(28; "Salesperson No."; Code[35])
        {
            Caption = 'Salesperson No.';
        }
        field(29; "Sales Territory"; Text[50])
        {
            Caption = 'Sales Territory';
        }
        field(30; "Customer Purchase No."; Code[35])
        {
            Caption = 'Customer Purchase No.';
        }
        field(31; "Original No."; Code[35])
        {
            Caption = 'Original No.';
        }
        field(32; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(33; "Audit Code"; Code[35])
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
        key(Key2; "Sales Trx. Type", "No.")
        {
            IncludedFields = "Customer No.", "Audit Code";
        }
    }
}