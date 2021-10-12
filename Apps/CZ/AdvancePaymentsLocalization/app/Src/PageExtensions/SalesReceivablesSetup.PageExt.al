pageextension 31107 "Sales & Receivables Setup CZZ" extends "Sales & Receivables Setup"
{
    PromotedActionCategories = 'New,Process,Report,Customer Groups,Payments,Advance';

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
                Promoted = true;
                PromotedCategory = Category6;
                RunObject = Page "Advance Letter Templates CZZ";
                RunPageView = where("Sales/Purchase" = const(Sales));
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
    }

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}
