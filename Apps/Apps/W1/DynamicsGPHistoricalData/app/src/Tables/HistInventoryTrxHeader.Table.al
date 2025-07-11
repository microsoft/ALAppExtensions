namespace Microsoft.DataMigration.GP.HistoricalData;

table 40906 "Hist. Inventory Trx. Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
            NotBlank = true;
        }
        field(3; "Document Type"; enum "Hist. Inventory Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(4; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(6; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(7; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(8; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(9; "Source Reference No."; Code[35])
        {
            Caption = 'Source Reference No.';
        }
        field(10; "Source Indicator"; Text[65])
        {
            Caption = 'Source Indicator';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.")
        {
            IncludedFields = "Audit Code";
        }
    }
}