namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Sustainability.Setup;

tableextension 6243 "Sust. Production BOM Line" extends "Production BOM Line"
{
    fields
    {
        field(6210; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."CO2e per Unit" <> 0 then
                    Rec.TestField(Type, Rec.Type::Item);
            end;
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