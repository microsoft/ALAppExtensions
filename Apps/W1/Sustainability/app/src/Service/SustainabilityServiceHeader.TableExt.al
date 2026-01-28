// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Service;

using Microsoft.Service.Document;
using Microsoft.Sustainability.Setup;

tableextension 6270 "Sustainability Service Header" extends "Service Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Service Line" where("Document Type" = field("Document Type"),
                                                   "Document No." = field("No."),
                                                   "Sust. Account No." = filter('<>''''')));
        }
        field(6211; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Service Line"."Total CO2e" where("Document Type" = field("Document Type"),
                                                              "Document No." = field("No.")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "Posted Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Service Line"."Posted Total CO2e" where("Document Type" = field("Document Type"),
                                                                     "Document No." = field("No.")));
            Caption = 'Posted Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}