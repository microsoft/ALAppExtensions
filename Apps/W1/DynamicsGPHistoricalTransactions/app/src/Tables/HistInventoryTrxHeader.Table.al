table 40906 "Hist. Inventory Trx. Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
            NotBlank = true;
        }
        field(2; "Document Type"; enum "Hist. Inventory Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(3; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(5; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(6; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(7; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(8; "Source Reference No."; Code[35])
        {
            Caption = 'Source Reference No.';
        }
        field(9; "Source Indicator"; Text[65])
        {
            Caption = 'Source Indicator';
        }
    }

    keys
    {
        key(Key1; "Audit Code", "Document Type", "Document No.")
        {
            Clustered = true;
        }
    }
}