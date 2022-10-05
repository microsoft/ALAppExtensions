pageextension 31037 "Purchase Order CZZ" extends "Purchase Order"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = false;
        }
        modify("Compress Prepayment")
        {
            Visible = false;
        }
        modify("Prepmt. Payment Terms Code")
        {
            Visible = false;
        }
        modify("Prepayment Due Date")
        {
            Visible = false;
        }
        modify("Prepmt. Payment Discount %")
        {
            Visible = false;
        }
        modify("Prepmt. Pmt. Discount Date")
        {
            Visible = false;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Prepayment Type")
        {
            Visible = false;
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
            }
        }
    }

    actions
    {
        modify(PostedPrepaymentInvoices)
        {
            Visible = false;
        }
        modify(PostedPrepaymentCrMemos)
        {
            Visible = false;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = false;
        }
        modify("Assignment Ad&vance Letters")
        {
            Visible = false;
        }
        modify("Assigned Adv. Letters - detail")
        {
            Visible = false;
        }
        modify(Action1220036)
        {
            Visible = false;
        }
        modify("Create Advance Letter")
        {
            Visible = false;
        }
        modify("Link Advance Letter")
        {
            Visible = false;
        }
        modify("Cancel All Adv. Payment Relations")
        {
            Visible = false;
        }
        modify("Adjust VAT by Adv. Payment Deduction")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        modify("Prepa&yment")
        {
            Visible = false;
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
}
