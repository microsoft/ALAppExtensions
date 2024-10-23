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
                    ToolTip = 'Specifies the parent category code.';
                    Visible = false;
                }
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the subcategory code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the record.';
                }
                field("Emission Factor CO2"; Rec."Emission Factor CO2")
                {
                    ToolTip = 'Specifies the emission factor for CO2 emission.';
                }
                field("Emission Factor CH4"; Rec."Emission Factor CH4")
                {
                    ToolTip = 'Specifies the emission factor for CH4 emission.';
                }
                field("Emission Factor N2O"; Rec."Emission Factor N2O")
                {
                    ToolTip = 'Specifies the emission factor for N2O emission.';
                }
                field("Water Intensity Factor"; Rec."Water Intensity Factor")
                {
                    ToolTip = 'Specifies the intensity factor for Water.';
                }
                field("Discharged Into Water Factor"; Rec."Discharged Into Water Factor")
                {
                    ToolTip = 'Specifies the intensity factor for Discharged Into Water.';
                }
                field("Waste Intensity Factor"; Rec."Waste Intensity Factor")
                {
                    ToolTip = 'Specifies the intensity factor for Waste.';
                }
                field("Import Data"; Rec."Import Data")
                {
                    ToolTip = 'Specifies if the data is imported from external source.';
                }
                field("Import From"; Rec."Import From")
                {
                    ToolTip = 'Specifies the source of the imported data.';
                }
                field("Renewable Energy"; Rec."Renewable Energy")
                {
                    ToolTip = 'Specifies if the subcategory is a part of renewable energy.';
                }
            }
        }
    }
}