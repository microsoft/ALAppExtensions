page 132526 "Edit In Excel Json"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Edit In Excel Test Table";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}