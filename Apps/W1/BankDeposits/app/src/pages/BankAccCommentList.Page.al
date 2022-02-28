page 1698 "Bank Acc. Comment List"
{
    Caption = 'Bank Account Comment List';
    DataCaptionFields = "No.";
    Editable = false;
    PageType = List;
    SourceTable = "Bank Acc. Comment Line";
    Permissions = tabledata "Bank Acc. Comment Line" = rimd;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the number of the account, bank account, customer, vendor or item to which the comment applies.';
                }
                field(Date; Date)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the date the comment was created.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the comment itself.';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies a code for the comment.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

