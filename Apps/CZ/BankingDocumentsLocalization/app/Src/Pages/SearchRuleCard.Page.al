page 31241 "Search Rule Card CZB"
{
    Caption = 'Search Rule Card';
    PageType = Card;
    SourceTable = "Search Rule CZB";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the search rule code.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the search rule.';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default search rule.';
                }
            }
            part(Lines; "Search Rule Subform CZB")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Search Rule Code" = field(Code);
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

    actions
    {
        area(Creation)
        {
            action(CreateDefaultLines)
            {
                Caption = 'Create Default Lines';
                Ellipsis = true;
                Image = ExpandDepositLine;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Inserts default search rule lines.';

                trigger OnAction()
                begin
                    Rec.CreateDefaultLinesWithConfirm();
                end;
            }
        }
    }
}
