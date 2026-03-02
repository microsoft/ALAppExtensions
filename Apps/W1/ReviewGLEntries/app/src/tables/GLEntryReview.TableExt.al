namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Account;
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
            CalcFormula = lookup("G/L Entry Review Log".SystemCreatedAt where("G/L Entry No." = field("Entry No.")));
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
            AutoFormatType = 1;
            AutoFormatExpression = '';
            Caption = 'Reviewed Amount';
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry Review Log"."Reviewed Amount" where("G/L Entry No." = field("Entry No.")));
            ToolTip = 'Specifies the amount that was reviewed for the G/L entry.';
        }
        field(22218; "Amount to Review"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            Caption = 'Amount to Review';
            BlankZero = true;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the amount that you want to review for the entry. Leaving this field blank or setting it to zero indicates that the entire amount is to be reviewed.';
        }
        field(22219; "Review Policy"; Enum "Review Policy Type")
        {
            Caption = 'Review Policy';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account"."Review Policy" where("No." = field("G/L Account No.")));
            ToolTip = 'Specifies the review policy for the G/L Account.';
        }

    }
}