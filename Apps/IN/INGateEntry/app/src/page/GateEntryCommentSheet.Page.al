page 18603 "Gate Entry Comment Sheet"
{
    AutoSplitKey = true;
    Caption = 'Gate Entry Comment Sheet';
    DataCaptionFields = "Gate Entry Type", "No.";
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Gate Entry Comment Line";

    layout
    {
        area(content)
        {
            repeater(List)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which comment is created.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment entered on gate entry.';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the code assigned to the comment.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine();
    end;
}