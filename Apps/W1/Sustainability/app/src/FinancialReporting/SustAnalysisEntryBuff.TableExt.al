namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Sustainability.Setup;

tableextension 6222 "Sust. Analysis Entry Buff." extends "Upd Analysis View Entry Buffer"
{
    fields
    {
        field(6210; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
        }
        field(6211; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
        }
        field(6212; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
        }
    }
    var
        SustainabilitySetup: Record "Sustainability Setup";
}