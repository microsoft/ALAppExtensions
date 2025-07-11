#pragma warning disable AA0247
page 40133 "GP Migration Warnings"
{
    ApplicationArea = All;
    Caption = 'GP Migration Warnings';
    PageType = List;
    SourceTable = "GP Migration Warnings";
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
                field("Warning Text"; Rec."Warning Text")
                {
                    ToolTip = 'Specifies the value of the Warning Text field.';
                }
            }
        }
    }
}
