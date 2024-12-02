namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.History;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

tableextension 6236 "Sust. Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Sales Cr.Memo Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
        field(6211; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."CO2e Emission" where("Document No." = field("No."), "Document Type" = filter("Credit Memo" | "GHG Credit")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}