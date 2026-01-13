// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Service;

using Microsoft.Service.History;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Ledger;

tableextension 6274 "Sust. Service Invoice Header" extends "Service Invoice Header"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Service Invoice Line" where("Sust. Account No." = filter('<>'''''), "Document No." = field("No.")));
        }
#pragma warning disable AA0232
        field(6211; "Total CO2e"; Decimal)
#pragma warning restore AA0232
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Value Entry"."CO2e Amount (Actual)" where("Document No." = field("No.")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}