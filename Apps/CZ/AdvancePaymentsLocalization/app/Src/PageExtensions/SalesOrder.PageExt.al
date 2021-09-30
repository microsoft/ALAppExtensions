pageextension 31023 "Sales Order CZZ" extends "Sales Order"
{
    layout
    {
        modify(Control1900201301)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepayment %")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Compress Prepayment")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt. Payment Terms Code")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepayment Due Date")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt. Payment Discount %")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt. Pmt. Discount Date")
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
        addlast(General)
        {
            field("Unpaid Advance Letter CZZ"; Rec."Unpaid Advance Letter CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if unpaid advance letter exists for this order.';
                Visible = false;
            }
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
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(PagePostedSalesPrepaymentInvoices)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(PagePostedSalesPrepaymentCrMemos)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Assignment Ad&vance Letters")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Assigned Adv. Letters - detail")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(Action1220019)
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
        modify("Prepa&yment")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        addbefore("P&osting")
        {
            group(AdvanceLetterGrCZZ)
            {
                Caption = 'Advance Letter';
                Image = Prepayment;

                action(CreateAdvanceLetterCZZ)
                {
                    Caption = 'Create Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The function create advance letter.';
                    Image = CreateDocument;
                    Ellipsis = true;
                    Visible = AdvancePaymentsEnabledCZZ;

                    trigger OnAction()
                    var
                        CreateSalesAdvLetterCZZ: Report "Create Sales Adv. Letter CZZ";
                    begin
                        CreateSalesAdvLetterCZZ.SetSalesHeader(Rec);
                        CreateSalesAdvLetterCZZ.Run();
                    end;
                }
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
                        SalesAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", Rec."No.", Rec."Bill-to Customer No.", Rec."Posting Date", Rec."Currency Code");
                    end;
                }
            }
        }
        addafter(PreviewPosting)
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
