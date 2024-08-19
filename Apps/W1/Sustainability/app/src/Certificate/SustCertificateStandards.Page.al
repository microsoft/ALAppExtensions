namespace Microsoft.Sustainability.Certificate;

page 6241 "Sust. Certificate Standards"
{
    PageType = List;
    Caption = 'Sust. Certificate Standards';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sust. Certificate Standard";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. of Sust. Certificate Standard';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of Sust. Certificate Standard';
                }
            }
        }
    }
}