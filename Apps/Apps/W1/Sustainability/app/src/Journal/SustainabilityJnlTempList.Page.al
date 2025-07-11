namespace Microsoft.Sustainability.Journal;

page 6218 "Sustainability Jnl. Temp. List"
{
    Caption = 'Sustainability Journal Template List';
    Editable = false;
    PageType = List;
    SourceTable = "Sustainability Jnl. Template";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;
    Description = 'Used when more than one Template is available. Selection is required when open the Sustainability Journal.';

    layout
    {
        area(Content)
        {
            repeater(repeater)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the sustainability journal template.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the sustainability journal template.';
                }
                field(Recurring; Rec.Recurring)
                {
                    ToolTip = 'Specifies whether the sustainability journal template is recurring.';
                }
            }
        }
    }
}