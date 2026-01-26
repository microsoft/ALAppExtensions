namespace Microsoft.Sustainability.Certificate;

page 6242 "Sust. Certificate Areas"
{
    PageType = List;
    Caption = 'Sust. Certificate Areas';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sust. Certificate Area";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. of Sust. Certificate Area';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of Sust. Certificate Area';
                }
            }
        }
    }
}