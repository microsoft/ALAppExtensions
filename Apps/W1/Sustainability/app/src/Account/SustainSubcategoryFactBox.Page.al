page 6223 "Sustain. Subcategory FactBox"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Subcategory Details';
    PageType = CardPart;
    Editable = false;
    SourceTable = "Sustain. Account Subcategory";

    layout
    {
        area(Content)
        {
            field(Code; Rec.Code)
            {
                Caption = 'Subcategory';
                ToolTip = 'Specifies a subcategory code.';
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
            field("Renewable Energy"; Rec."Renewable Energy")
            {
                ToolTip = 'Specifies if a subcategory is a part of renewable energy.';
            }
        }
    }
}