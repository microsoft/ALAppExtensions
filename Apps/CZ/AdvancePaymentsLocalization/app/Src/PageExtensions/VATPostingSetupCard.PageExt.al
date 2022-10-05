pageextension 31026 "VAT Posting Setup Card CZZ" extends "VAT Posting Setup Card"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(Advances)
        {
            Visible = false;
        }
        modify("Sales Advance VAT Account")
        {
            Visible = false;
        }
        modify("Sales Advance Offset VAT Acc.")
        {
            Visible = false;
        }
        modify("Sales Ded. VAT Base Adj. Acc.")
        {
            Visible = false;
        }
        modify("Purch. Advance VAT Account")
        {
            Visible = false;
        }
        modify("Purch. Advance Offset VAT Acc.")
        {
            Visible = false;
        }
        modify("Purch. Ded. VAT Base Adj. Acc.")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        addbefore(VATCtrlReportCZL)
        {
            group(AdvancePaymentsCZZ)
            {
                Caption = 'Advance Payments';
                field("Sales Adv. Letter Account CZZ"; Rec."Sales Adv. Letter Account CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales advance letter account.';
                }
                field("Sales Adv. Letter VAT Acc. CZZ"; Rec."Sales Adv. Letter VAT Acc. CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales advance letter VAT account.';
                }
                field("Purch. Adv. Letter Account CZZ"; Rec."Purch. Adv. Letter Account CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies purchase advance letter account.';
                }
                field("Purch. Adv.Letter VAT Acc. CZZ"; Rec."Purch. Adv.Letter VAT Acc. CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies purchase advance letter VAT account.';
                }
            }
        }
    }
}
