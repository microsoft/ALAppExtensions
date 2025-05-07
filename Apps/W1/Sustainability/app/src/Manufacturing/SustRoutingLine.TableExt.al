namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Routing;
using Microsoft.Sustainability.Setup;

tableextension 6245 "Sust. Routing Line" extends "Routing Line"
{
    fields
    {
        field(6210; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            DataClassification = CustomerContent;
        }
        field(6211; "CO2e Last Date Modified"; Date)
        {
            Caption = 'CO2e Last Date Modified';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}