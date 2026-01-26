#pragma warning disable AA0247
page 14101 "CD Number Formats"
{
    ApplicationArea = Basic, Suite;
    AutoSplitKey = true;
    Caption = 'CD Number Formats';
    PageType = List;
    SourceTable = "CD Number Format";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1210000)
            {
                ShowCaption = false;
                field(Format; Rec.Format)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies customer declaration number format.';
                }
            }
        }
    }

    actions
    {
    }
}

