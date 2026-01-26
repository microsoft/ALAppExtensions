// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Service;

using Microsoft.Service.Document;
using Microsoft.Sustainability.Setup;

tableextension 6277 "Sust. Service Item Line" extends "Service Item Line"
{
    fields
    {
        field(6210; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Service Line"."Total CO2e" where("Document Type" = field("Document Type"),
                                                                "Document No." = field("Document No."),
                                                                "Service Item Line No." = field("Line No.")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}