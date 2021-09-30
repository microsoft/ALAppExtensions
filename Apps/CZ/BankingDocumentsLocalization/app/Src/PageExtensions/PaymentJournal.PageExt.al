pageextension 31288 "Payment Journal CZB" extends "Payment Journal"
{
    layout
    {
        addlast(Control1)
        {
            field("Search Rule Code CZB"; Rec."Search Rule Code CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the search rule code.';
            }
            field("Search Rule Line No. CZB"; Rec."Search Rule Line No. CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the line no. of search rule.';
                AssistEdit = true;

                trigger OnAssistEdit()
                var
                    SearchRuleLineCZB: Record "Search Rule Line CZB";
                begin
                    if Rec."Search Rule Line No. CZB" = 0 then
                        exit;
                    SearchRuleLineCZB.Get(Rec."Search Rule Code CZB", Rec."Search Rule Line No. CZB");
                    SearchRuleLineCZB.SetRecFilter();
                    Page.RunModal(Page::"Search Rule Line Card CZB", SearchRuleLineCZB);
                end;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action(MatchBySearchRuleCZB)
            {
                Caption = 'Match by Search Rule';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Matches payment journal line using search rule code.';
                Image = ViewRegisteredOrder;

                trigger OnAction()
                var
                    MatchBankPaymentCZB: Codeunit "Match Bank Payment CZB";
                begin
                    MatchBankPaymentCZB.Run(Rec);
                    Rec.Modify(true);
                end;
            }
        }
    }
}
