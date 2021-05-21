page 31118 "VAT Stmt. Comment Sheet CZL"
{
    AutoSplitKey = true;
    Caption = 'VAT Statement Comment Sheet';
    DataCaptionFields = "VAT Statement Template Name", "VAT Statement Name";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "VAT Statement Comment Line CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date the comment was created.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment for VAT statement.';
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Date := WorkDate();
    end;
}
