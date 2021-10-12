// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Table that contains the available application languages.
/// </summary>
table 8 Language
{
    Access = Public;
    LookupPageID = Languages;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
        }
        field(6; "Windows Language ID"; Integer)
        {
            BlankZero = true;
            TableRelation = "Windows Language";

            trigger OnValidate()
            begin
                CalcFields("Windows Language Name");
            end;
        }
        field(7; "Windows Language Name"; Text[80])
        {
            CalcFormula = Lookup("Windows Language".Name WHERE("Language ID" = FIELD("Windows Language ID")));
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
    }

    fieldgroups
    {
        fieldgroup(Brick; Name)
        {
        }
    }
}

