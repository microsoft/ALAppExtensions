page 31117 "VAT Statement Comments CZL"
{
    Caption = 'VAT Statement Comments';
    DataCaptionFields = "VAT Statement Template Name", "VAT Statement Name";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "VAT Statement Comment Line CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("VAT Statement Name"; Rec."VAT Statement Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of VAT statement.';
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of VAT statement comment.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment for VAT statement.';
                }
            }
        }
    }
}
