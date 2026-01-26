namespace Microsoft.Sustainability.Account;
page 6213 "Sustain. Account Categories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Account Categories';
    UsageCategory = Lists;
    SourceTable = "Sustain. Account Category";
    AnalysisModeEnabled = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the category code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the category description.';
                }
                field("Emission Scope"; Rec."Emission Scope")
                {
                    ToolTip = 'Specifies the scope of the emissions that are associated with the sustainability category. Scope 1: Direct emissions from sources that are owned or controlled by the reporting entity. Scope 2: Indirect emissions from the generation of purchased electricity, heat, or steam consumed by the reporting entity. Scope 3: Other indirect emissions, such as the extraction and production of purchased materials and fuels, transport-related activities in vehicles not owned or controlled by the reporting entity, and waste disposal.';
                }
                field(CO2; Rec.CO2)
                {
                    ToolTip = 'Specifies if the category is used to register CO2 emission.';
                }
                field(CH4; Rec.CH4)
                {
                    ToolTip = 'Specifies if the category is used to register CH4 emission.';
                }
                field(N2O; Rec.N2O)
                {
                    ToolTip = 'Specifies if the category is used to register N2O emission.';
                }
                field("Water Intensity"; Rec."Water Intensity")
                {
                    ToolTip = 'Specifies if the category is used to register Water Intensity.';
                }
                field("Discharged Into Water"; Rec."Discharged Into Water")
                {
                    ToolTip = 'Specifies if the category is used to register Discharged Into Water.';
                }
                field("Waste Intensity"; Rec."Waste Intensity")
                {
                    ToolTip = 'Specifies if the category is used to register Waste Intensity.';
                }
                field("Calculation Foundation"; Rec."Calculation Foundation")
                {
                    ToolTip = 'Specifies the calculation foundation for emission calculation.';
                }
                field("Custom Value"; Rec."Custom Value")
                {
                    ToolTip = 'Specifies the custom value for emission calculation.';
                }
                field("Calculate from General Ledger"; Rec."Calculate from General Ledger")
                {
                    ToolTip = 'Specifies if the custom amount is calculated from general ledger.';
                }
                field("G/L Account Filter"; Rec."G/L Account Filter")
                {
                    ToolTip = 'Specifies the G/L account filter to be used in custom amount calculation.';
                }
                field("Global Dimension 1 Filter"; Rec."Global Dimension 1 Filter")
                {
                    ToolTip = 'Specifies the global dimension 1 filter to be used in custom amount calculation.';
                }
                field("Global Dimension 2 Filter"; Rec."Global Dimension 2 Filter")
                {
                    ToolTip = 'Specifies the global dimension 2 filter to be used in custom amount calculation.';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("Category")
            {
                Caption = 'Category';
                Image = Category;
                action(Subcategories)
                {
                    Caption = 'Subcategories';
                    Image = Description;
                    RunObject = Page "Sustain. Account Subcategories";
                    RunPageLink = "Category Code" = field(Code);
                    ToolTip = 'Open the Subcategories page to view and manage the subcategories for the selected category.';
                    Scope = Repeater;
                }
            }
        }
        area(Promoted)
        {
            actionref("Subcategories_Promoted"; Subcategories) { }
        }
    }
}