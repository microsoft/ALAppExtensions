#pragma warning disable AA0247
pageextension 31245 "Job Card CZZ" extends "Job Card"
{
    layout
    {
        addlast(factboxes)
        {
            part(AdvanceUsageFactBoxCZZ; "Advance Usage FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action(CreateAdvanceLetterCZZ)
            {
                Caption = 'Create Advance Letter';
                ApplicationArea = Basic, Suite;
                ToolTip = 'The function creates the advance letter for the project.';
                Image = CreateDocument;
                Ellipsis = true;

                trigger OnAction()
                var
                    CreateSalesAdvLetterCZZ: Report "Create Sales Adv. Letter CZZ";
                begin
                    CreateSalesAdvLetterCZZ.SetJob(Rec);
                    CreateSalesAdvLetterCZZ.Run();
                end;
            }
        }
        addafter(SalesInvoicesCreditMemos)
        {
            action(SalesAdvanceLettersCZZ)
            {
                ApplicationArea = Jobs;
                Caption = 'Sales Advance Letters';
                Image = GetSourceDoc;
                ToolTip = 'View the sales advance letters that are related to the selected project.';

                trigger OnAction()
                var
                    TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
                begin
                    TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(Rec."No.", TempAdvanceLetterApplicationCZZ);
                    Page.RunModal(Page::"Advance Letter Application CZZ", TempAdvanceLetterApplicationCZZ)
                end;
            }
        }
        addafter(SalesInvoicesCreditMemos_Promoted)
        {
            actionref(SalesAdvanceLetters_PromotedCZZ; SalesAdvanceLettersCZZ)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            CurrPage.AdvanceUsageFactBoxCZZ.Page.SetDocument(Rec);
    end;
}
