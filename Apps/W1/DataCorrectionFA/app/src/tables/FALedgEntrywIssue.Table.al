table 6090 "FA Ledg. Entry w. Issue"
{
    Caption = 'FA Ledger Entry';
    DrillDownPageID = "FA Ledger Entries";
    LookupPageID = "FA Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "G/L Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'G/L Entry No.';
            TableRelation = "G/L Entry";
        }
        field(3; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            TableRelation = "Fixed Asset";
        }
        field(4; "FA Posting Date"; Date)
        {
            Caption = 'FA Posting Date';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
        }
        field(7; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "FA Posting Type"; Enum "FA Ledger Entry FA Posting Type")
        {
            Caption = 'FA Posting Type';
        }
        field(14; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(6090; Corrected; Boolean)
        {
            Caption = 'Corrected';
        }

    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Corrected)
        {

        }
        key(Key3; Corrected, "FA No.")
        {

        }
    }
}
