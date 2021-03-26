// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
table 149002 "BCPT Log Entry"
{
    DataClassification = SystemMetadata;
    DrillDownPageId = "BCPT Log Entries";
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "BCPT Code"; Code[10])
        {
            Caption = 'BCPT Code';
            NotBlank = true;
            TableRelation = "BCPT Header";
        }
        field(3; "BCPT Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Start Time"; DateTime)
        {
            Caption = 'Start Time';
        }
        field(5; "End Time"; DateTime)
        {
            Caption = 'End Time';
        }
        field(6; "Message"; text[250])
        {
            Caption = 'Message';
        }
        field(7; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
        }
        field(8; "Codeunit Name"; Text[250])
        {
            Caption = 'Codeunit Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = CONST(Codeunit), "Object ID" = field("Codeunit ID")));
        }
        field(9; "Duration (ms)"; integer)
        {
            Caption = 'Duration (ms)';
        }
        field(10; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Success,Error;
        }
        field(11; Operation; Text[100])
        {
            Caption = 'Operation';
        }
        field(12; "No. of SQL Statements"; Integer)
        {
            Caption = 'No. of SQL Statements';
        }
        field(13; Version; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Version';
        }
        field(14; "Session No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Session No.';
        }
        field(15; Tag; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Tag';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "BCPT Code", Version, "BCPT Line No.", Operation, "Duration (ms)", "No. of SQL Statements")
        {
            // Instead of a SIFT index. This will make both inserts and calculations faster - and non-blocking
        }
    }

    trigger OnInsert()
    begin
        if "End Time" = 0DT then
            "End Time" := CurrentDateTime;
        if "Start Time" = 0DT then
            "Start Time" := "End Time" - "Duration (ms)";
        if "Duration (ms)" = 0 then
            "Duration (ms)" := "End Time" - "Start Time";
        "Session No." := SessionId();
    end;
}