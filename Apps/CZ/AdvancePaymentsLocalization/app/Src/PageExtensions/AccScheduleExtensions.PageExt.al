pageextension 31216 "Acc. Schedule Extensions CZZ" extends "Acc. Schedule Extensions CZL"
{
    layout
    {
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
        UpdateControls();
    end;

    var
        [InDataSet]
        AdvancePaymentsVisibleCZZ: Boolean;

    local procedure UpdateControls()
    begin
        AdvancePaymentsVisibleCZZ := LedgEntryType in [LedgEntryType::"Customer Entry", LedgEntryType::"Vendor Entry"];
    end;
}
