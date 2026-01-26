namespace Microsoft.Sustainability.Scorecard;

page 6233 "Sustainability Scorecard"
{
    PageType = Card;
    SourceTable = "Sustainability Scorecard";
    Caption = 'Sustainability Scorecard';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
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
                    ToolTip = 'Specifies the Owner field value. Only users designated as Sustainability Managers in the User Setup page can be selected as the owner.';
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