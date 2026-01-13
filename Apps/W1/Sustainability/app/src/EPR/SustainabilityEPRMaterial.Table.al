// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.Setup;

table 6235 "Sustainability EPR Material"
{
    DataClassification = CustomerContent;
    Caption = 'EPR Material';
    LookupPageId = "Sustainability EPR Materials";
    DrillDownPageId = "Sustainability EPR Materials";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure".Code;
        }
        field(4; "EPR Fee Rate"; Decimal)
        {
            Caption = 'EPR Fee Rate';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(5; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}