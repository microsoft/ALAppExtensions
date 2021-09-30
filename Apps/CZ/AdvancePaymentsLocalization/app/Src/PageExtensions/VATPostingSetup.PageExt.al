pageextension 31025 "VAT Posting Setup CZZ" extends "VAT POsting Setup"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("Sales Advance VAT Account")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Sales Advance Offset VAT Acc.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Sales Ded. VAT Base Adj. Acc.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Purch. Advance VAT Account")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Purch. Advance Offset VAT Acc.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Purch. Ded. VAT Base Adj. Acc.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addafter("Sales VAT Account")
        {
            field("Sales Adv. Letter Account CZZ"; Rec."Sales Adv. Letter Account CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies sales advance letter account.';
                Visible = AdvancePaymentsEnabledCZZ;
            }
            field("Sales Adv. Letter VAT Acc. CZZ"; Rec."Sales Adv. Letter VAT Acc. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies sales advance letter VAT account.';
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
        addafter("Purchase VAT Account")
        {
            field("Purch. Adv. Letter Account CZZ"; Rec."Purch. Adv. Letter Account CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies purchase advance letter account.';
                Visible = AdvancePaymentsEnabledCZZ;
            }
            field("Purch. Adv.Letter VAT Acc. CZZ"; Rec."Purch. Adv.Letter VAT Acc. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies purchase advance letter VAT account.';
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
