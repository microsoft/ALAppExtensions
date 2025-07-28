namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6223 "Sust. Analysis View Entry" extends "Analysis View Entry"
{
    fields
    {
        modify("Account No.")
        {
            TableRelation = if ("Account Source" = const("Sust. Account")) "Sustainability Account";
        }
        field(6210; "Emission CO2"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            CaptionClass = '102,6,1';
        }
        field(6211; "Emission CH4"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            CaptionClass = '102,6,2';
        }
        field(6212; "Emission N2O"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            CaptionClass = '102,6,3';
        }
        field(6213; "CO2e Emission"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'CO2e Emission';
            DecimalPlaces = 2 : 5;
            ToolTip = 'Specifies the value of the CO2e Emission field.';
        }
        field(6214; "Carbon Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Fee';
            DecimalPlaces = 2 : 5;
            ToolTip = 'Specifies the value of the Carbon Fee field.';
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}