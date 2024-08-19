namespace Microsoft.Sustainability.Certificate;

page 6239 "Sustainability Certificates"
{
    PageType = List;
    Caption = 'Sustainability Certificates';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Sustainability Certificate";
    CardPageId = "Sust. Certificate Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the No. of Sustainability Certificate';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Name of Sustainability Certificate';
                }
            }
        }
    }
}