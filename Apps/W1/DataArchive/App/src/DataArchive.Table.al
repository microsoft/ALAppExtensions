// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This table holds the individual archive headers.
/// Data from each table is stored in "Data Archive Table"
/// </summary>
table 600 "Data Archive"
{
    Access = Public;
    Extensible = true;
    Caption = 'Data Archive';
    DataClassification = CustomerContent;
    LookupPageId = "Data Archive List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(6; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "No. of Tables"; Integer)
        {
            Caption = 'No. of Tables';
            FieldClass = FlowField;
            CalcFormula = count("Data Archive Table" where("Data Archive Entry No." = field("Entry No.")));
        }
        field(8; "No. of Records"; Integer)
        {
            Caption = 'No. of Records';
            FieldClass = FlowField;
            CalcFormula = sum("Data Archive Table"."No. of Records" where("Data Archive Entry No." = field("Entry No.")));
        }
        field(9; "Created by User"; Text[50])
        {
            Caption = 'Created by User';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field(SystemCreatedBy)));
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DataArchiveTable: Record "Data Archive Table";
    begin
        DataArchiveTable.Setrange("Data Archive Entry No.", Rec."Entry No.");
        DataArchiveTable.DeleteAll();
    end;
}
