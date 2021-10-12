pageextension 31059 "Item Card CZZ" extends "Item Card"
{
    actions
    {
        modify("Prepa&yment Percentages")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
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
