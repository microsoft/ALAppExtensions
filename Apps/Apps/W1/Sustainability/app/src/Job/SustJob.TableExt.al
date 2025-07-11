// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Job;

using Microsoft.Projects.Project.Job;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

tableextension 6257 "Sust. Job" extends Job
{
    fields
    {
        field(6210; "Resource (Total CO2e)"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Value Entry"."CO2e Amount (Actual)" where("Job No." = field("No."), Type = const(Resource)));
            Caption = 'Resource (Total CO2e)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6211; "Item (Total CO2e)"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Value Entry"."CO2e Amount (Actual)" where("Job No." = field("No."), Type = const(Item)));
            Caption = 'Item (Total CO2e)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6212; "G/L Account (Total CO2e)"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Value Entry"."CO2e Amount (Actual)" where("Job No." = field("No."), Type = const("G/L Account")));
            Caption = 'G/L Account (Total CO2e)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6213; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("Sustainability Value Entry"."CO2e Amount (Actual)" where("Job No." = field("No.")));
            Caption = 'Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}