page 4706 "VAT Group Sub. Lines Subform"
{
    PageType = ListPart;
    Caption = 'VAT Group Submission Lines';
    SourceTable = "VAT Group Submission Line";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the row number of the VAT return from the group member that submitted it.';
                }
                field("Box No."; Rec."Box No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the box number of the VAT return.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the VAT group submission line.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT amount for the specified box number.';
                }
            }
        }
    }

}