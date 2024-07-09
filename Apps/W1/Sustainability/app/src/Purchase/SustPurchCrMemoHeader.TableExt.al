namespace Microsoft.Sustainability.Purchase;

using Microsoft.Sustainability.Setup;
using Microsoft.Purchases.History;

tableextension 6218 "Sust. Purch. Cr. Memo Header" extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Purch. Cr. Memo Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
        field(6211; "Emission C02"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Purch. Cr. Memo Line"."Emission CO2" where("Document No." = field("No.")));
            Caption = 'Emission CO2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Purch. Cr. Memo Line"."Emission CH4" where("Document No." = field("No.")));
            Caption = 'Emission CH4';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6213; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Purch. Cr. Memo Line"."Emission N2O" where("Document No." = field("No.")));
            Caption = 'Emission N2O';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}