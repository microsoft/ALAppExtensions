namespace Microsoft.Sustainability.Journal;

page 6216 "Sustainability Jnl. Batches"
{
    Caption = 'Sustainability Journal Batches';
    PageType = List;
    SourceTable = "Sustainability Jnl. Batch";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the journal batch you are creating.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a brief description of the journal batch you are creating.';
                }
                field("No Series"; Rec."No Series")
                {
                    ToolTip = 'Specifies the No. Series to use for the journal batch.';
                }
                field("Emission Scope"; Rec."Emission Scope")
                {
                    ToolTip = 'Specifies the emission scope that is allowed to be used in the journal batch. If none specified, all emission scopes are allowed.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code for the journal batch.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the reason code for the journal batch.';
                }
            }
        }
    }
}