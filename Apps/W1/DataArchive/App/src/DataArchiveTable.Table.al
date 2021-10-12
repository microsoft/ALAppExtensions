// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This table contains archived data from the specified table.
/// </summary>
table 601 "Data Archive Table"
{
    Access = Public;
    Extensible = true;
    Caption = 'Data Archive';
    DataClassification = CustomerContent;
    LookupPageId = "Data Archive Table List";
    DrillDownPageId = "Data Archive Table List";
    Permissions = tabledata "Data Archive" = rimd,
                  tabledata "Data Archive Table" = rimd,
                  tabledata "Data Archive Media Field" = rimd;

    fields
    {
        field(1; "Data Archive Entry No."; Integer)
        {
            Caption = 'Data Archive Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Data Archive";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Entry No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(4; "Table Name"; Text[80])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(Id = field("Table No.")));
        }
        field(5; "Table Fields (json)"; Media)
        {
            Caption = 'Table Fields (json)';
            DataClassification = SystemMetadata;
        }
        field(6; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = SystemMetadata;
        }
        field(7; "Description"; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "Table Data (json)"; Media)
        {
            Caption = 'Table Data (json)';
            DataClassification = CustomerContent;
        }
        field(9; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Data Archive Entry No.", "Table No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "Created On")
        {
        }
    }

    procedure HasReadPermission(): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
    begin
        if not TableMetadata.Get(Rec."Table No.") then
            exit(true);
        RecRef.Open(Rec."Table No.");
        exit(RecRef.ReadPermission());
    end;
}
