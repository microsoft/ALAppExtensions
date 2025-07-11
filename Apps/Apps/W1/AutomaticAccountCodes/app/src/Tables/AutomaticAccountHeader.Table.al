// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Telemetry;

table 4850 "Automatic Account Header"
{
    Caption = 'Automatic Account Header';
    DrillDownPageID = "Automatic Account List";
    LookupPageID = "Automatic Account List";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; Balance; Decimal)
        {
            CalcFormula = Sum("Automatic Account Line"."Allocation %" WHERE("Automatic Acc. No." = FIELD("No.")));
            Caption = 'Balance';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        AutoAccountLine.SetRange("Automatic Acc. No.", "No.");
        AutoAccountLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0001P9F', AccTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    var
        AutoAccountLine: Record "Automatic Account Line";
        AccTok: Label 'W1 Automatic Account', Locked = true;
}

