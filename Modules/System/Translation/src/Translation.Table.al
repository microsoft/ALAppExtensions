// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 3712 Translation
{
    Caption = 'Translation';
    Access = Internal;

    fields
    {
        field(1; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            TableRelation = Language."Windows Language ID";
        }
        field(2; "System ID"; Guid)
        {
            Caption = 'System ID';
            Editable = false;
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(4; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            Editable = false;
        }
        field(5; Value; Text[2048])
        {
            Caption = 'Value';
        }
        field(6; "Language Name"; Text[50])
        {
            CalcFormula = Lookup (Language.Name WHERE("Windows Language ID" = FIELD("Language ID")));
            Caption = 'Language Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Language ID", "System ID", "Field ID")
        {
            Clustered = true;
        }
        key(Key2; "Table ID", "Field ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Language ID");
    end;

    trigger OnModify()
    begin
        TestField("Language ID");
    end;
}

