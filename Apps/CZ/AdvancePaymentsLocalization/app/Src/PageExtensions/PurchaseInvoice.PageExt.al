pageextension 31039 "Purchase Invoice CZZ" extends "Purchase Invoice"
{
    layout
    {
#if not CLEAN20
#pragma warning disable AL0432
        modify("Prepayment %")
        {
            Visible = false;
        }
        modify("Compress Prepayment")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
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

                    trigger OnAction()
                    var
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", Rec."No.", Rec."Pay-to Vendor No.", Rec."Posting Date", Rec."Currency Code");
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
