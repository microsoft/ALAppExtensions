namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Routing;

pageextension 6245 "Sust. Routing Lines" extends "Routing Lines"
{
    layout
    {
        addafter("Unit Cost per")
        {
            field("CO2e per Unit"; Rec."CO2e per Unit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the CO2e per Unit field.';
            }
        }
    }
}