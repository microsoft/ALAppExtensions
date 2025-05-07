#pragma warning disable AA0247
page 14100 "CD Location Setup"
{
    Caption = 'CD Location Setup';
    PageType = List;
    SourceTable = "CD Location Setup";

    layout
    {
        area(content)
        {
            repeater(Control1210000)
            {
                ShowCaption = false;
                field("Item Tracking Code"; Rec."Item Tracking Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how serial or lot numbers assigned to the item are tracked in the supply chain.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the warehouse or other place where the involved items are handled or stored.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description associated with this line.';
                }
                field("CD Info. Must Exist"; Rec."CD Info. Must Exist")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that information about customs declarations must exist.';
                }
                field("CD Sales Check on Release"; Rec."CD Sales Check on Release")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that a sales document cannot be released if the customs declaration is missing.';
                }
                field("CD Purchase Check on Release"; Rec."CD Purchase Check on Release")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that a purchase document cannot be released if the customs declaration is missing.';
                }
                field("Allow Temporary CD Number"; "Allow Temporary CD Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that a purchase document can use temporary custom declaration number.';
                }
            }
        }
    }

    actions
    {
    }
}

