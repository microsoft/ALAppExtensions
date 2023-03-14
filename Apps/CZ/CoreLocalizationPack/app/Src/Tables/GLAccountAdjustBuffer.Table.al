table 31118 "G/L Account Adjust. Buffer CZL"
{
    Caption = 'G/L Account Adjustment Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(10; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
        }
        field(11; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
    }

    keys
    {
        key(Key1; "Document No.")
        {
            Clustered = true;
        }
    }
}
