namespace Microsoft.Sustainability.Emission;

page 6245 "Emission Fees"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Emission Fee";
    Caption = 'Emission Fees';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Emission Type"; Rec."Emission Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies gas emission type.';
                }
                field("Scope Type"; Rec."Scope Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Scope Type field.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Ending Date field.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Country/Region Code field.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                }
                field("Carbon Fee"; Rec."Carbon Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies internal carbon fee that a company charges itself for each unit of CO2 equivalent that it emits.';
                }
                field("Carbon Equivalent Factor"; Rec."Carbon Equivalent Factor")
                {
                    Editable = not (Rec."Emission Type" = Rec."Emission Type"::CO2);
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the coefficient that converts the impact of various greenhouse gases into the equivalent amount of carbon dioxide based on their global warming potential.';
                }
            }
        }
    }
}