table 31117 "Bank Acc. Adjust. Buffer CZL"
{
    Caption = 'Bank Account Adjustment Buffer';
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
        field(20; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(25; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(30; Valid; Boolean)
        {
            Caption = 'Valid';
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
