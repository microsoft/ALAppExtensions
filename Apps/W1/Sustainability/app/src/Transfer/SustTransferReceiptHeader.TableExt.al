namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Ledger;

tableextension 6257 "Sust. Transfer Receipt Header" extends "Transfer Receipt Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Transfer Receipt Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
        field(6211; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Ledger Entry"."CO2e Emission" where("Document No." = field("No."), "Document Type" = filter(Invoice | "GHG Credit")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}