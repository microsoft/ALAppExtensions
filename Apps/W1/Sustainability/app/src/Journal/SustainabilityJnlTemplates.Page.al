namespace Microsoft.Sustainability.Journal;

page 6217 "Sustainability Jnl. Templates"
{
    Caption = 'Sustainability Journal Templates';
    PageType = List;
    SourceTable = "Sustainability Jnl. Template";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Name"; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the Sustainability Journal Template.';
                }
                field("Description"; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Sustainability Journal Template.';
                }
                field(Recurring; Rec.Recurring)
                {
                    ToolTip = 'Specifies whether the Sustainability Journal Template is recurring.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(Batch)
            {
                action(Batches)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Batches';
                    Image = Description;
                    RunObject = Page "Sustainability Jnl. Batches";
                    RunPageLink = "Journal Template Name" = field(Name);
                    ToolTip = 'View or edit multiple journals for a specific template. You can use batches when you need multiple journals of a certain type.';
                    Scope = Repeater;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Batch_Promoted; Batches)
                {
                }
            }
        }
    }
}