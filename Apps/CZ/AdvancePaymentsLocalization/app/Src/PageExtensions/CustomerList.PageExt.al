pageextension 31058 "Customer List CZZ" extends "Customer List"
{
    actions
    {
        modify("Prepa&yment Percentages")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
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
                PromotedCategory = Category5;
                Visible = AdvancePaymentsEnabledCZZ;

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

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}
