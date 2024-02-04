namespace Microsoft.Sustainability.Account;
page 6214 "Sustain. Account Subcategories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    Caption = 'Sustainability Account Subcategories';
    SourceTable = "Sustain. Account Subcategory";
    AnalysisModeEnabled = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Category Code"; Rec."Category Code")
                {
                    ToolTip = 'Specifies a parent category code.';
                    Visible = false;
                }
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies a subcategory code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the record.';
                }
                field("Emission Factor CO2"; Rec."Emission Factor CO2")
                {
                    ToolTip = 'Specifies an emission factor for CO2 emission.';
                }
                field("Emission Factor CH4"; Rec."Emission Factor CH4")
                {
                    ToolTip = 'Specifies an emission factor for CH4 emission.';
                }
                field("Emission Factor N2O"; Rec."Emission Factor N2O")
                {
                    ToolTip = 'Specifies an emission factor for N2O emission.';
                }
                field("Import Data"; Rec."Import Data")
                {
                    ToolTip = 'Specifies if a data is imported from external source.';
                }
                field("Import From"; Rec."Import From")
                {
                    ToolTip = 'Specifies a source URL from where the data is imported.';
                }
                field("Renewable Energy"; Rec."Renewable Energy")
                {
                    ToolTip = 'Specifies if a subcategory is a part of renewable energy.';
                }
            }
        }
    }
}