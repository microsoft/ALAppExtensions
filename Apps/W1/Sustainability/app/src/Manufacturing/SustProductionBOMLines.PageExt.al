namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.ProductionBOM;

pageextension 6243 "Sust. Production BOM Lines" extends "Production BOM Lines"
{
    layout
    {
        addafter("Routing Link Code")
        {
            field("CO2e per Unit"; Rec."CO2e per Unit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the CO2e per Unit field.';
            }
        }
    }
}