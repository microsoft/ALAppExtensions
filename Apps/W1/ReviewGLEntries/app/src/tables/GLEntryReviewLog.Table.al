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
            ToolTip = 'Specifies the line number of the G/L entry review log.';
        }
        field(2; "G/L Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the G/L entry number that is being reviewed.';
        }
        field(3; "Reviewed Identifier"; Integer)
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the identifier for the review of the G/L entry.';
        }
        field(4; "Reviewed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who reviewed the G/L entry.';
        }
        field(5; "Reviewed Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the amount that was reviewed for the G/L entry.';
        }
        field(6; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the G/L account number associated with the G/L entry.';
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