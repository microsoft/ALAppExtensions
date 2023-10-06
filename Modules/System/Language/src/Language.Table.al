// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Globalization;

/// <summary>
/// Table that contains the available application languages.
/// </summary>
table 8 Language
{
    Access = Public;
    LookupPageID = Languages;
    InherentEntitlements = RX;
    InherentPermissions = RX;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Windows Language ID"; Integer)
        {
            DataClassification = SystemMetadata;
            BlankZero = true;
            TableRelation = "Windows Language";

            trigger OnValidate()
            begin
                CalcFields("Windows Language Name");
            end;
        }
        field(7; "Windows Language Name"; Text[80])
        {
            CalcFormula = lookup("Windows Language".Name where("Language ID" = field("Windows Language ID")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Windows Language ID")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Name)
        {
        }
    }
}

