// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Reflection;

table 6123 "E-Doc. Mapping Log"
{
    DataClassification = CustomerContent;
    Caption = 'E-Document Mapping Log';
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(2; "E-Doc Log Entry No."; Integer)
        {
            Caption = 'E-Doc Log Entry No.';
            TableRelation = "E-Document Log";
        }
        field(3; "E-Doc Entry No."; Integer)
        {
            Caption = 'E-Document Entry No';
            TableRelation = "E-Document";
        }
        field(4; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(5; "Table ID Caption"; Text[250])
        {
            Caption = 'Table Caption';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(7; "Field ID Caption"; Text[250])
        {
            Caption = 'Field Caption';
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"), "No." = field("Field ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Find Value"; Text[250])
        {
            Caption = 'Find Value';
        }
        field(9; "Replace Value"; Text[250])
        {
            Caption = 'Replace Value';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "E-Doc Log Entry No.", "E-Doc Entry No.")
        {
        }
    }
    internal procedure InitFromMapping(EDocumentMapping: Record "E-Doc. Mapping")
    begin
        Rec.Init();
        Rec."Entry No." := 0;
        Rec.Validate("Table ID", EDocumentMapping."Table ID");
        Rec.Validate("Field ID", EDocumentMapping."Field ID");
        Rec.Validate("Find Value", EDocumentMapping."Find Value");
        Rec.Validate("Replace Value", EDocumentMapping."Replace Value");
    end;
}
