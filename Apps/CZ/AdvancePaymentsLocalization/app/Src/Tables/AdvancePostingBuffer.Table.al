table 31013 "Advance Posting Buffer CZZ"
{
    Caption = 'Advance Posting Buffer';
    ReplicateData = false;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(8; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(12; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
        }
        field(14; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
        }
        field(25; "Amount (ACY)"; Decimal)
        {
            Caption = 'Amount (ACY)';
        }
        field(26; "VAT Amount (ACY)"; Decimal)
        {
            Caption = 'VAT Amount (ACY)';
        }
        field(29; "VAT Base Amount (ACY)"; Decimal)
        {
            Caption = 'VAT Base Amount (ACY)';
        }
        field(32; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 1 : 1;
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
            Clustered = true;
        }
    }
}
