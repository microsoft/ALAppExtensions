namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Ledger;

tableextension 22211 "G/L Entry Review" extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(22212; Reviewed; Boolean)
        {
            Caption = 'Reviewed';
            FieldClass = FlowField;
            CalcFormula = exist("G/L Entry Review Log" where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies whether the G/L entry has been reviewed.';
        }
        field(22213; "Reviewed By"; Code[50])
        {
            Caption = 'Reviewed By';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Log"."Reviewed By" where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies the user who reviewed the G/L entry.';
        }
        field(22214; "Reviewed Date"; DateTime)
        {
            Caption = 'Reviewed Date';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Log".SystemModifiedAt where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies the date and time when the G/L entry was reviewed.';
        }
        field(22215; "Reviewed Identifier"; Integer)
        {
            Caption = 'Reviewed Identifier';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Log"."Reviewed Identifier" where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies the identifier for the review of the G/L entry.';
        }
        field(22217; "Reviewed Amount"; Decimal)
        {
            Caption = 'Reviewed Amount';
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry Review Log"."Reviewed Amount" where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies the amount that was reviewed for the G/L entry.';
        }
        field(22218; "Amount to Review"; Decimal)
        {
            Caption = 'Amount to Review';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the amount that will be reviewed.';
        }
    }
}