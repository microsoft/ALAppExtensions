pageextension 31027 "Sales Invoice CZZ" extends "Sales Invoice"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Prepayment Type")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        modify("Compress Prepayment")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        addlast(factboxes)
        {
            part("Sales Adv. Usage FactBox CZZ"; "Sales Adv. Usage FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                Provider = SalesLines;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Line No." = field("Line No.");
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
    }
    actions
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Assignment Ad&vance Letters")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Assigned Adv. Letters - detail")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(Action1220032)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Create Ad&vance Letter")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Link Advance Letter")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Cancel All Adv. Payment Relations")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Adjust VAT by Adv. Payment Deduction")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addbefore("P&osting")
        {
            group(AdvanceLetterGrCZZ)
            {
                Caption = 'Advance Letter';
                Image = Prepayment;

                action(LinkAdvanceLetterCZZ)
                {
                    Caption = 'Link Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The function allows to link advance letters.';
                    Image = LinkWithExisting;
                    Ellipsis = true;
                    Visible = AdvancePaymentsEnabledCZZ;

                    trigger OnAction()
                    var
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", Rec."No.", Rec."Bill-to Customer No.", Rec."Posting Date", Rec."Currency Code");
                    end;
                }
            }
        }
        addafter(Preview)
        {
            action(AdvanceVATStatisticsCZZ)
            {
                Caption = 'Advance VAT Statistics';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Shows summarized VAT Entries, include advance VAT Entries, based on posting preview.';
                Image = VATEntries;
                Visible = AdvancePaymentsEnabledCZZ;

                trigger OnAction()
                var
                    ShowPreviewHandlerCZZ: Codeunit "Show Preview Handler CZZ";
                    SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
                begin
                    BindSubscription(ShowPreviewHandlerCZZ);
                    SalesPostYesNo.Preview(Rec);
                end;
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
