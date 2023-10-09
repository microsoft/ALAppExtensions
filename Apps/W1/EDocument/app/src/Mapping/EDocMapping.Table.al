// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.IO;
using System.Reflection;

table 6118 "E-Doc. Mapping"
{
    Access = Public;
    Extensible = false;
    Caption = 'E-Document Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'EDocument Format';
            NotBlank = true;
            TableRelation = "E-Document Service";
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(4; "Table ID Caption"; Text[250])
        {
            Caption = 'Table Caption';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(6; "Field ID Caption"; Text[250])
        {
            Caption = 'Field Caption';
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"), "No." = field("Field ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Transformation Rule"; Code[20])
        {
            Caption = 'Transformation Rule';
            TableRelation = "Transformation Rule";
        }
        field(8; "Find Value"; Text[250])
        {
            Caption = 'Find Value';
        }
        field(9; "Replace Value"; Text[250])
        {
            Caption = 'Replace Value';
        }
        field(10; Indent; Integer)
        {
            Caption = 'Indent';
        }
        field(11; Used; Boolean)
        {
            Caption = 'Used';
        }
        field(12; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(13; "For Import"; Boolean)
        {
            Caption = 'Is for Import';
        }
    }

    keys
    {
        key(Key1; Code, "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Line No.")
        {
        }
        key(Key3; Used, Code, "For Import")
        {
        }
    }
}
