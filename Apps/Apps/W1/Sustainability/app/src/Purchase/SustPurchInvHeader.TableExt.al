namespace Microsoft.Sustainability.Purchase;

using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Ledger;
using Microsoft.Purchases.History;

tableextension 6217 "Sust. Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Purch. Inv. Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
#pragma warning disable AA0232
        field(6211; "Emission C02"; Decimal)
#pragma warning restore AA0232
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Document No." = field("No."), "Document Type" = filter(Invoice | "GHG Credit")));
            Caption = 'Emission CO2';
            CaptionClass = '102,6,1';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Document No." = field("No."), "Document Type" = filter(Invoice | "GHG Credit")));
            Caption = 'Emission CH4';
            CaptionClass = '102,6,2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6213; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Document No." = field("No."), "Document Type" = filter(Invoice | "GHG Credit")));
            Caption = 'Emission N2O';
            CaptionClass = '102,6,3';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6214; "Energy Consumption"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."Energy Consumption" where("Document No." = field("No."), "Document Type" = filter(Invoice | "GHG Credit")));
            Caption = 'Energy Consumption';
            CaptionClass = '102,13,4';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}