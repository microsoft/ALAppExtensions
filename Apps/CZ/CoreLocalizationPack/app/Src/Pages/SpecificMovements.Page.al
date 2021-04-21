page 31038 "Specific Movements CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Specific Movements';
    PageType = List;
    SourceTable = "Specific Movement CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a specific movement code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for specific movement.';
                }
                field("Description EN"; Rec."Description EN")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the english description for specific movement.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}