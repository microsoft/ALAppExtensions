page 10675 "SAF-T Standard Accounts"
{
    PageType = List;
    SourceTable = "SAF-T Mapping";
    SourceTableView = where ("Mapping Type" = filter ("Two Digit Standard Account" | "Four Digit Standard Account"));
    Caption = 'SAF-T Standard Accounts';

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the standard account code that is used for mapping.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the standard account category that is used for mapping.';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
}
