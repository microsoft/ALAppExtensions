pageextension 31109 "Value Entries CZL" extends "Value Entries"
{
    layout
    {
        addafter("Job Ledger Entry No.")
        {
            field("Incl. in Intrastat Amount CZL"; Rec."Incl. in Intrastat Amount CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
            }
            field("Incl. in Intrastat S.Value CZL"; Rec."Incl. in Intrastat S.Value CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat statistical value.';
            }
        }
    }
}