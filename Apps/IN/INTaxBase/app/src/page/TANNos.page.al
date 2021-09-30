page 18548 "T.A.N. Nos."
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TAN Nos.";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TAN Nos depending on the number of branch locations from where the company files its returns';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for identification of TAN Nos.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                    TANNoLbl: Label 'Code eq %1', Comment = '%1= T.A.N. No.';
                begin
                    EditinExcel.EditPageInExcel(
                        'TAN Nos',
                        CurrPage.ObjectId(false),
                        StrSubstNo(TANNoLbl, Rec.Code));
                end;
            }
        }
    }
}