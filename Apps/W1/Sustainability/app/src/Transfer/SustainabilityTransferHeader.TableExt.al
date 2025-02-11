namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Setup;

tableextension 6249 "Sustainability Transfer Header" extends "Transfer Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Transfer Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
        field(6211; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Transfer Line"."Total CO2e" where("Document No." = field("No."), "Derived From Line No." = const(0)));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "Posted Shipped Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Transfer Line"."Posted Shipped Total CO2e" where("Document No." = field("No."), "Derived From Line No." = const(0)));
            Caption = 'Posted Shipped Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}