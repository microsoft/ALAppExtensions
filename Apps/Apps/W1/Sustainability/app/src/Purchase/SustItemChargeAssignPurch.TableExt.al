// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Setup;

tableextension 6280 "Sust. Item Charge Assign Purch" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(6210; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            DataClassification = CustomerContent;
        }
        field(6211; "CO2e to Assign"; Decimal)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
            Caption = 'CO2e to Assign';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                Rec."CO2e to Assign" := Rec."Qty. to Assign" * Rec."CO2e per Unit";
            end;
        }
        field(6212; "CO2e to Handle"; Decimal)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
            Caption = 'CO2e to Handle';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                Rec."CO2e to Handle" := Rec."Qty. to Handle" * Rec."CO2e per Unit";
            end;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}