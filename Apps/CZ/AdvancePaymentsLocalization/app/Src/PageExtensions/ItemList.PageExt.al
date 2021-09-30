pageextension 31060 "Item List CZZ" extends "Item List"
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
