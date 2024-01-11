page 40133 "GP Migration Log"
{
    ApplicationArea = All;
    Caption = 'GP Migration Log';
    PageType = List;
    SourceTable = "GP Migration Log";
    UsageCategory = Administration;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field.';
                }
                field("Migration Area"; Rec."Migration Area")
                {
                    ToolTip = 'Specifies the value of the Migration Area field.';
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the value of the Context field.';
                }
                field("Log Text"; Rec."Log Text")
                {
                    ToolTip = 'Specifies the value of the Log Text field.';
                }
            }
        }
    }
}