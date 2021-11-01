page 18811 "TCS Nature Of Collections"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TCS Nature of Collection";
    Caption = 'TCS Nature of Collections';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Nature of Collection on which TCS is applied.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the TCS Nature of Collection.';
                }
                field("TCS On Recpt. Of Pmt."; Rec."TCS On Recpt. Of Pmt.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select this field to calculate TCS on payment receipt only. By selecting this field, TCS will not be calculated on Sales Invoice and Sales Credit Memo.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("TCS Rates")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TCS Rates';
                Promoted = false;
                Image = EditList;
                RunObject = page "Tax Rates";
                RunPageLink = "Tax Type" = const('TCS');
                RunPageMode = Edit;
                ToolTip = 'Specifies the TCS rates for each NOC and assessee type in the TCS rates window.';
            }
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
                    TCSNatureofCollectionLbl: Label 'Code eq %1', Comment = '%1 = TCS Nature of Collection';
                begin
                    EditinExcel.EditPageInExcel('TCS Nature of Collection', CurrPage.ObjectId(false), StrSubstNo(TCSNatureofCollectionLbl, Rec.Code));
                end;
            }
            action(ClearFilter)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Clear Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Clear the filer applied on the Page';

                trigger OnAction()
                begin
                    Rec.Reset();
                end;
            }
        }
    }
}