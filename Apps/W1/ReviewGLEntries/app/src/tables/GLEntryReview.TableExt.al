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
            CalcFormula = exist("G/L Entry Review Entry" where("G/L Entry No." = field("Entry No.")));
        }
        field(22213; "Reviewed By"; Code[50])
        {
            Caption = 'Reviewed By';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Entry"."Reviewed By" where("G/L Entry No." = field("Entry No.")));
        }
        field(22214; "Reviewed Date"; DateTime)
        {
            Caption = 'Reviewed Date';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Entry".SystemModifiedAt where("G/L Entry No." = field("Entry No.")));
        }
        field(22215; "Reviewed Identifier"; Integer)
        {
            Caption = 'Reviewed Identifier';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Entry Review Entry"."Reviewed Identifier" where("G/L Entry No." = field("Entry No.")));
        }

    }


}