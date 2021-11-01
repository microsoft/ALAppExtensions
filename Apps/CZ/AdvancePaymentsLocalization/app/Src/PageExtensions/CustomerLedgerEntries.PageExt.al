pageextension 31021 "Customer Ledger Entries CZZ" extends "Customer Ledger Entries"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepayment Type")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Open For Advance Letter")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addlast(Control1)
        {
            field("Advance Letter No. CZZ"; Rec."Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter no.';
                Editable = false;
                Visible = AdvancePaymentsEnabledCZZ;
            }
            field("Adv. Letter Template Code CZZ"; Rec."Adv. Letter Template Code CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter template';
                Editable = false;
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
    }

    actions
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("Link Advances")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("U&nlink Advances")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addlast(processing)
        {
            group(AdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';

                action(LinkAdvanceLetterCZZ)
                {
                    Caption = 'Link Advance Letter';
                    ToolTip = 'Link advance letter.';
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    Image = Link;
                    Enabled = (Rec."Document Type" = Rec."Document Type"::Payment) and (Rec."Advance Letter No. CZZ" = '');
                    Visible = AdvancePaymentsEnabledCZZ;

                    trigger OnAction()
                    var
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.LinkAdvancePayment(Rec);
                    end;
                }
                action(UnlinkAdvanceLetterCZZ)
                {
                    Caption = 'Unlink Advance Letter';
                    ToolTip = 'Unlink advance letter.';
                    ApplicationArea = Basic, Suite;
                    Image = UnApply;
                    Enabled = (Rec."Document Type" = Rec."Document Type"::" ") and (Rec."Advance Letter No. CZZ" <> '');
                    Visible = AdvancePaymentsEnabledCZZ;

                    trigger OnAction()
                    var
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.UnlinkAdvancePayment(Rec);
                    end;
                }
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
