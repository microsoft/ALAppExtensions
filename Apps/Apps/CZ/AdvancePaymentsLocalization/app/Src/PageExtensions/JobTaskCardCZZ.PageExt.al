#pragma warning disable AA0247
pageextension 31247 "Job Task Card CZZ" extends "Job Task Card"
{
    actions
    {
        addlast(Processing)
        {
            group("F&unctions CZZ")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action(CreateAdvanceLetterCZZ)
                {
                    Caption = 'Create Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The function creates the advance letter for the project task.';
                    Image = CreateDocument;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        CreateSalesAdvLetterCZZ: Report "Create Sales Adv. Letter CZZ";
                    begin
                        CreateSalesAdvLetterCZZ.SetJobTask(Rec);
                        CreateSalesAdvLetterCZZ.Run();
                    end;
                }
            }
        }
        addafter(Dimensions)
        {
            action(SalesAdvanceLettersCZZ)
            {
                ApplicationArea = Jobs;
                Caption = 'Sales Advance Letters';
                Image = GetSourceDoc;
                ToolTip = 'View the sales advance letters that are related to the selected project task.';

                trigger OnAction()
                var
                    TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
                begin
                    TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(Rec."Job No.", Rec."Job Task No.", TempAdvanceLetterApplicationCZZ);
                    Page.RunModal(Page::"Advance Letter Application CZZ", TempAdvanceLetterApplicationCZZ)
                end;
            }
        }
    }
}
