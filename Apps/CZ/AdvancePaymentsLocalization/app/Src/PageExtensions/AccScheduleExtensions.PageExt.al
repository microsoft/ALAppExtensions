pageextension 31216 "Acc. Schedule Extensions CZZ" extends "Acc. Schedule Extensions CZL"
{
    layout
    {
#if not CLEAN20
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addafter("Entry Type")
        {
            field("Advance Payments CZZ"; Rec."Advance Payments CZZ")
            {
                ApplicationArea = Prepayments;
                ToolTip = 'Specifies whether line of sales journal is advance payment.';
                Visible = AdvancePaymentsVisibleCZZ;
            }
        }
    }

    trigger OnOpenPage()
    begin
#if not CLEAN20
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
#endif
        UpdateControls();
    end;

    var
#if not CLEAN20
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        [InDataSet]
        AdvancePaymentsEnabledCZZ: Boolean;
#endif
        [InDataSet]
        AdvancePaymentsVisibleCZZ: Boolean;

    local procedure UpdateControls()
    begin
#if not CLEAN20
        AdvancePaymentsVisibleCZZ := false;
        if not AdvancePaymentsEnabledCZZ then
            exit;
#endif
        AdvancePaymentsVisibleCZZ := LedgEntryType in [LedgEntryType::"Customer Entry", LedgEntryType::"Vendor Entry"];
    end;
}