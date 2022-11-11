pageextension 31053 "Vendor Card CZZ" extends "Vendor Card"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = false;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Advances (LCY)")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
    }

    actions
    {
        modify("Prepa&yment Percentages")
        {
            Visible = false;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Advance Letters")
        {
            Visible = false;
        }
        modify("Ad&vance Invoices")
        {
            Visible = false;
        }
        modify("Advance Credit &Memos")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        addlast(creation)
        {
            action(NewPurchAdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';
                ToolTip = 'Create purchase advance letter.';
                ApplicationArea = Basic, Suite;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Category6;

                trigger OnAction()
                var
                    AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
                    PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                begin
                    AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Purchase);
                    if Page.RunModal(0, AdvanceLetterTemplateCZZ) <> Action::LookupOK then
                        Error('');

                    AdvanceLetterTemplateCZZ.TestField("Advance Letter Document Nos.");
                    PurchAdvLetterHeaderCZZ.Init();
                    PurchAdvLetterHeaderCZZ."Advance Letter Code" := AdvanceLetterTemplateCZZ.Code;
                    PurchAdvLetterHeaderCZZ."No. Series" := AdvanceLetterTemplateCZZ."Advance Letter Document Nos.";
                    PurchAdvLetterHeaderCZZ.Insert(true);
                    PurchAdvLetterHeaderCZZ.Validate("Pay-to Vendor No.", Rec."No.");
                    PurchAdvLetterHeaderCZZ.Modify(true);

                    Page.Run(Page::"Purch. Advance Letter CZZ", PurchAdvLetterHeaderCZZ);
                end;
            }
        }
    }
}
