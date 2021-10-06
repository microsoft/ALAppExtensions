page 18544 "Concessional Codes"
{
    Caption = 'Concessional Codes';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Concessional Code";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the concessional code required for eTDS returns';
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the concessional code description';
                    ApplicationArea = Basic, Suite;
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
                    ConcessionalCodeLbl: Label 'Code eq %1', Comment = '%1= Concessional Code';
                begin
                    EditinExcel.EditPageInExcel(
                        'Concessional Codes',
                        CurrPage.ObjectId(false),
                        StrSubstNo(ConcessionalCodeLbl, Rec.Code));
                end;
            }
        }
    }
}