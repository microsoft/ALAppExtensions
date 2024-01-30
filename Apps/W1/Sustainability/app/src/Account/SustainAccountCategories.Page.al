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
                    ToolTip = 'Specifies the description of the record.';
                }
                field("Emission Scope"; Rec."Emission Scope")
                {
                    ToolTip = 'Specifies the type of the scope of the record.';
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
                field("Calculation Foundation"; Rec."Calculation Foundation")
                {
                    ToolTip = 'Specifies the foundation for emission calculation.';
                }
                field("Custom Value"; Rec."Custom Value")
                {
                    ToolTip = 'Specifies the custom foundation for emission calculation.';
                }
                field("Calculate from General Ledger"; Rec."Calculate from General Ledger")
                {
                    ToolTip = 'Specifies if the custom amount should be calculated from general ledger entries.';
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
                    ToolTip = 'View or edit multiple subcategories for a specific category.';
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