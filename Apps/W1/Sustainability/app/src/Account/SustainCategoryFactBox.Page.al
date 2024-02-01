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
                ToolTip = 'Specifies the type of the scope of the record.';
            }
            field("Calculation Foundation"; Rec."Calculation Foundation")
            {
                ToolTip = 'Specifies the foundation for emission calculation.';
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