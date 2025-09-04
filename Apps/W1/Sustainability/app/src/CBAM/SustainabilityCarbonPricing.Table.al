// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.CBAM;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.Setup;

table 6234 "Sustainability Carbon Pricing"
{
    Caption = 'Carbon Pricing';
    DataClassification = CustomerContent;
    LookupPageId = "Sustainability Carbon Pricing";
    DrillDownPageId = "Sustainability Carbon Pricing";

    fields
    {
        field(1; "Country/Region of Origin"; Code[10])
        {
            Caption = 'Country/Region of Origin';
            TableRelation = "Country/Region".Code;
        }
        field(2; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(StartingDateCannotBeAfterEndingDateErr, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(3; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                Validate("Starting Date");
            end;
        }
        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure".Code;
        }
        field(5; "Rounding Type"; Option)
        {
            Caption = 'Rounding Type';
            OptionCaption = 'Nearest,Up,Down,None';
            OptionMembers = Nearest,Up,Down,None;
        }
        field(6; "Carbon Price"; Decimal)
        {
            Caption = 'Carbon Price';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
        field(7; "Threshold Quantity"; Decimal)
        {
            Caption = 'Threshold Quantity';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
        }
    }
    keys
    {
        key(PK; "Country/Region of Origin", "Starting Date", "Unit of Measure Code", "Threshold Quantity")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        StartingDateCannotBeAfterEndingDateErr: Label '%1 cannot be after %2', Comment = '%1 = Starting Date, %2 = Ending Date';

    internal procedure RoundingDirection(): Text[1]
    begin
        case "Rounding Type" of
            "Rounding Type"::Nearest:
                exit('=');
            "Rounding Type"::Up:
                exit('>');
            "Rounding Type"::Down:
                exit('<');
        end;
    end;
}