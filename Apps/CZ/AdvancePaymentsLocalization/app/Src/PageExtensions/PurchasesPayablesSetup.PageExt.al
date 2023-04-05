pageextension 31108 "Purchases & Payables Setup CZZ" extends "Purchases & Payables Setup"
{
    actions
    {
        addlast(navigation)
        {
            action(AdvanceLetterTemplatesCZZ)
            {
                Caption = 'Advance Letter Templates';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show advance letter templates.';
                Image = Setup;
                RunObject = Page "Advance Letter Templates CZZ";
                RunPageView = where("Sales/Purchase" = const(Purchase));
            }
        }
        addlast(Category_Process)
        {
            actionref(AdvanceLetterTemplatesCZZ_Promoted; AdvanceLetterTemplatesCZZ)
            {
            }
        }
    }
}
