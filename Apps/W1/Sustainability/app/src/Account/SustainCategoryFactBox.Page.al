namespace Microsoft.Sustainability.Account;

page 6222 "Sustain. Category FactBox"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Category Details';
    PageType = CardPart;
    Editable = false;
    SourceTable = "Sustain. Account Category";

    layout
    {
        area(Content)
        {
            field(Code; Rec.Code)
            {
                Caption = 'Category';
                ToolTip = 'Specifies the category code.';
            }
            field("Emission Scope"; Rec."Emission Scope")
            {
                ToolTip = 'Specifies the scope of the emissions that are associated with the sustainability category. Scope 1: Direct emissions from sources that are owned or controlled by the reporting entity. Scope 2: Indirect emissions from the generation of purchased electricity, heat, or steam consumed by the reporting entity. Scope 3: Other indirect emissions, such as the extraction and production of purchased materials and fuels, transport-related activities in vehicles not owned or controlled by the reporting entity, and waste disposal.';
            }
            field("Calculation Foundation"; Rec."Calculation Foundation")
            {
                ToolTip = 'Specifies the calculation foundation for the sustainability category.';
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
        }
    }
}