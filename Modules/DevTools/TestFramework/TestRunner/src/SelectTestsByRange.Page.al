page 130452 "Select Tests By Range"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Selection Filter"; SelectionFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Selection Filter';
                }
            }
        }
    }

    actions
    {
    }

    var
        SelectionFilter: Text;

    procedure GetRange(): Text
    begin
        exit(SelectionFilter);
    end;
}

