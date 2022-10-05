pageextension 31052 "Customer Card CZZ" extends "Customer Card"
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
        modify("Prepa&yment Percentages")
        {
            Visible = false;
        }
        addlast(creation)
        {
            action(NewSalesAdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';
                ToolTip = 'Create sales advance letter.';
                ApplicationArea = Basic, Suite;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                begin
                    AdvanceLetterTemplateCZZ.SetRange("Sales/Purchase", AdvanceLetterTemplateCZZ."Sales/Purchase"::Sales);
                    if Page.RunModal(0, AdvanceLetterTemplateCZZ) <> Action::LookupOK then
                        Error('');

                    AdvanceLetterTemplateCZZ.TestField("Advance Letter Document Nos.");
                    SalesAdvLetterHeaderCZZ.Init();
                    SalesAdvLetterHeaderCZZ."Advance Letter Code" := AdvanceLetterTemplateCZZ.Code;
                    SalesAdvLetterHeaderCZZ."No. Series" := AdvanceLetterTemplateCZZ."Advance Letter Document Nos.";
                    SalesAdvLetterHeaderCZZ.Insert(true);
                    SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", Rec."No.");
                    SalesAdvLetterHeaderCZZ.Modify(true);

                    Page.Run(Page::"Sales Advance Letter CZZ", SalesAdvLetterHeaderCZZ);
                end;
            }
        }
    }
}
