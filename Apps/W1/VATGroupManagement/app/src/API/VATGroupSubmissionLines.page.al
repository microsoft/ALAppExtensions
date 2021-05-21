page 4700 "VAT Group Submission Lines"
{
    PageType = ListPart;
    SourceTable = "VAT Group Submission Line";
    DelayedInsert = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = ID;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.ID)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Caption = 'id', Locked = true;
                    ToolTip = 'Specifies the record identifier.';
                }
                field(vatGroupSubmissionNo; Rec."VAT Group Submission No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'vatGroupSubmissionNo', Locked = true;
                    ToolTip = 'Specifies the identifier for the VAT return from the group member that submitted it.';
                }
                field(lineNo; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'lineNo', Locked = true;
                    ToolTip = 'Specifies the number of the line on the VAT return from the group member that submitted it.';
                }
                field(rowNo; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'rowNo', Locked = true;
                    ToolTip = 'Specifies the row number of the VAT return from the group member that submitted it.';
                }
                field(description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'description', Locked = true;
                    ToolTip = 'Specifies a description for the VAT group submission line.';
                }
                field(boxNo; Rec."Box No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'boxNo', Locked = true;
                    ToolTip = 'Specifies the box number of the VAT return.';
                }
                field(amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'amount', Locked = true;
                    ToolTip = 'Specifies the VAT amount for the specified box number.';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.HasFilter() then
            Rec.Validate("VAT Group Submission ID", Rec.GetFilter("VAT Group Submission ID"));

        Rec.Insert(true);
        exit(false);
    end;
}