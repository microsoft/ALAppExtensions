page 132525 "Edit in Excel List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Edit in Excel Settings";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                }
                field("Use Centralized deployments"; Rec."Use Centralized deployments")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}