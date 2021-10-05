page 18546 "Ministries"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Ministry;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Ministry.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the Ministry.';
                }
                field("Other Ministry"; Rec."Other Ministry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the ministry is classified as other Ministry.';
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
                    MinistryCodeLbl: Label 'Code eq %1', Comment = '%1= Ministry Code';
                begin
                    EditinExcel.EditPageInExcel(
                        'Ministries',
                        CurrPage.ObjectId(false),
                        StrSubstNo(MinistryCodeLbl, Rec.Code));
                end;
            }
        }
    }
}