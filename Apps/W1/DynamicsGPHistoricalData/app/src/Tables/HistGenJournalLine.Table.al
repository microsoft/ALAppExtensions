namespace Microsoft.DataMigration.GP.HistoricalData;

table 40901 "Hist. Gen. Journal Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Journal Entry No."; Code[35])
        {
            Caption = 'Journal Entry No.';
            NotBlank = true;
        }
        field(3; "Source Type"; enum "Hist. Source Type")
        {
            Caption = 'Source Type';
            NotBlank = true;
        }
        field(4; "Account No."; Code[130])
        {
            Caption = 'Account No.';
            NotBlank = true;
            TableRelation = "Hist. G/L Account"."No.";
        }
        field(5; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            NotBlank = true;
        }
        field(6; Closed; Boolean)
        {
            Caption = 'Closed';
            NotBlank = true;
        }
        field(7; "Audit Code"; Text[35])
        {
            Caption = 'Audit Code';
            NotBlank = true;
        }
        field(8; Year; Integer)
        {
            Caption = 'Year';
            NotBlank = true;
        }
        field(9; "Date"; Date)
        {
            Caption = 'Date';
            NotBlank = true;
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            NotBlank = true;
        }
        field(11; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(12; "Orig. Debit Amount"; Decimal)
        {
            Caption = 'Originating Debit Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(13; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(14; "Orig. Credit Amount"; Decimal)
        {
            Caption = 'Originating Credit Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
        }
        field(15; "Document Type"; Text[35])
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(16; "Orig. Document No."; Text[35])
        {
            Caption = 'Originating Document No.';
        }
        field(17; "Orig. Trx. Source No."; Text[35])
        {
            Caption = 'Originating Trx. Source No.';
        }
        field(18; "Source No."; Text[35])
        {
            Caption = 'Source No.';
        }
        field(19; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
        }
        field(20; "Reference Desc."; Text[50])
        {
            Caption = 'Reference Desc.';
        }
        field(21; "Description"; Text[50])
        {
            Caption = 'Description';
        }
        field(22; "User"; Text[50])
        {
            Caption = 'User';
        }
        field(23; Custom1; Text[50])
        {
            Caption = 'Custom 1';
        }
        field(24; Custom2; Text[50])
        {
            Caption = 'Custom 2';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "Account No.", "Year", Closed)
        {
            IncludedFields = "Source Type", "Journal Entry No.", "Audit Code";
        }
        key(Key3; "Orig. Trx. Source No.")
        {
        }
    }
}