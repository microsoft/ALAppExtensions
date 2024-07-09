namespace Microsoft.Sustainability.Scorecard;

page 6232 "Sustainability Scorecards"
{
    Caption = 'Sustainability Scorecards';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "Sustainability Scorecard";
    CardPageId = "Sustainability Scorecard";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field(Owner; Rec.Owner)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Owner';
                    ToolTip = 'Specifies the value of the Owner field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Goals")
            {
                ApplicationArea = Basic, Suite;
                Image = MakeAgreement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executes the Goals action.';
                Caption = 'Goals';

                trigger OnAction()
                var
                    SustainabilityGoal: Record "Sustainability Goal";
                begin
                    SustainabilityGoal.RunSustainabilityGoalsFromScorecard(Rec);
                end;
            }
        }
    }
}