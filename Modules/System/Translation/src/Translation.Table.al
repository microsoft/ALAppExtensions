// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Globalization;

table 3712 Translation
{
    Caption = 'Translation';
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Language ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Language ID';
            TableRelation = Language."Windows Language ID";
        }
        field(2; "System ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'System ID';
            Editable = false;
        }
        field(3; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            Editable = false;
        }
        field(4; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field ID';
            Editable = false;
        }
        field(5; Value; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(6; "Language Name"; Text[50])
        {
            CalcFormula = lookup(Language.Name where("Windows Language ID" = field("Language ID")));
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

