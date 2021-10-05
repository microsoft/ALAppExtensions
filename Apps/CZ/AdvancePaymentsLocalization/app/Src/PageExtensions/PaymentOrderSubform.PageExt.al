pageextension 31181 "Payment Order Subform CZZ" extends "Payment Order Subform CZB"
{
    layout
    {
        addafter("Applies-to C/V/E Entry No.")
        {
            field("Purch. Advance Letter No. CZZ"; Rec."Purch. Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                Visible = AdvancePaymentsEnabledCZZ;
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
