page 18141 "E-Commerce Merchant Id"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "e-Commerce Merchant";
    Caption = 'e-Commerce Merchant';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer number for which merchant id has to be recorded.';
                }
                field("Merchant Id"; Rec."Merchant Id")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the merchant id provided to customers by their payment processor.';
                }
                field("Company GST Reg. No."; Rec."Company GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s GST Reg. number issued by authorized body.';
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
                begin
                    EditinExcel.EditPageInExcel(
                        'e-Commerce Merchant Id',
                        CurrPage.ObjectId(false),
                        StrSubstNo(CustomerNumLbl, Rec."Customer No."));
                end;
            }
        }
    }
    var
        CustomerNumLbl: Label 'Code %1', Comment = '%1 = Customer No.';
}