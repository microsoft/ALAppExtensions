pageextension 31037 "Purchase Order CZZ" extends "Purchase Order"
{
    layout
    {
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
            part("Purch. Adv. Usage FactBox CZZ"; "Purch. Adv. Usage FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                Provider = PurchLines;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Line No." = field("Line No.");
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
    }

    actions
    {
        modify(PostedPrepaymentInvoices)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(PostedPrepaymentCrMemos)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
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
        modify(Action1220036)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Create Advance Letter")
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
                        CreatePurchAdvLetterCZZ: Report "Create Purch. Adv. Letter CZZ";
                    begin
                        CreatePurchAdvLetterCZZ.SetPurchHeader(Rec);
                        CreatePurchAdvLetterCZZ.Run();
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
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", Rec."No.", Rec."Pay-to Vendor No.", Rec."Posting Date", Rec."Currency Code");
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
                    PurchPostYesNo: Codeunit "Purch.-Post (Yes/No)";
                begin
                    BindSubscription(ShowPreviewHandlerCZZ);
                    PurchPostYesNo.Preview(Rec);
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
