pageextension 31182 "Iss. Payment Order Subform CZZ" extends "Iss. Payment Order Subform CZB"
{
    layout
    {
        addlast(Control1)
        {
            field("Purch. Advance Letter No. CZZ"; Rec."Purch. Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                Visible = not AdvancePaymentsEnabledCZZ;
                ToolTip = 'Specifies no. of purchase advance letter.';
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
