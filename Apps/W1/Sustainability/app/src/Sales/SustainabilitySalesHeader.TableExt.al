namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.Document;
using Microsoft.Sustainability.Setup;

tableextension 6234 "Sustainability Sales Header" extends "Sales Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Sales Line" where("Document Type" = field("Document Type"),
                                                   "Document No." = field("No."),
                                                   "Sust. Account No." = filter('<>''''')));
        }
        field(6211; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sales Line"."Total CO2e" where("Document Type" = field("Document Type"),
                                                              "Document No." = field("No.")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "Posted Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sales Line"."Posted Total CO2e" where("Document Type" = field("Document Type"),
                                                                     "Document No." = field("No.")));
            Caption = 'Posted Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}