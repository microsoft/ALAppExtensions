namespace Microsoft.Finance.GeneralLedger.Review;

table 22218 "G/L Entry Review Log"
{
    Caption = 'G/L Entry Review Log';
    DrillDownPageId = "Reviewed G/L Entries";

    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "G/L Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Reviewed Identifier"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Reviewed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Reviewed Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(LineNo; "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Line No." := 0;
    end;
}