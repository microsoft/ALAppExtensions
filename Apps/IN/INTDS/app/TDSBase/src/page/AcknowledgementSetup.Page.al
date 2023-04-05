page 18685 "Acknowledgement Setup"
{
    PageType = List;
    SourceTable = "Acknowledgement Setup";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Financial Year"; Rec."Financial Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Financial Year';
                }
                field(Quarter; Rec.Quarter)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quarter this Financial Year period belongs to.';
                }
                field("Acknowledgment No."; Rec."Acknowledgment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Acknowledgment No.';
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code';
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
                ToolTip = 'Send the data in the sub page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    EditinExcel: Codeunit "Edit in Excel";
                begin
                    EditinExcel.EditPageInExcel('Acknowledgement Setup', Page::"Acknowledgement Setup");
                end;
            }
        }
    }
}