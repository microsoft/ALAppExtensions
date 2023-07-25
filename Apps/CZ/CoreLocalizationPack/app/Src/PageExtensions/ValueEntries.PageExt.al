#if not CLEAN22
pageextension 31109 "Value Entries CZL" extends "Value Entries"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        addafter("Job Ledger Entry No.")
        {
            field("Incl. in Intrastat Amount CZL"; Rec."Incl. in Intrastat Amount CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Incl. in Intrastat Amount (Obsolete)';
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Incl. in Intrastat S.Value CZL"; Rec."Incl. in Intrastat S.Value CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Incl. in Intrastat Stat. Value (Obsolete)';
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat statistical value.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
}
#endif