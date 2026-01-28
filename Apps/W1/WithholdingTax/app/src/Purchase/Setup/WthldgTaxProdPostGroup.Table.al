// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using System.Telemetry;

table 6785 "Wthldg. Tax Prod. Post. Group"
{
    Caption = 'Withholding Tax Prod. Post. Group';
    LookupPageID = "Wthldg. Tax Prod. Post. Group";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    trigger OnInsert()
    begin
        FeatureTelemetry.LogUptake('0000QX7', SetupWHTTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SetupWHTTok: Label 'Set Up Withholding Tax', Locked = true;
}