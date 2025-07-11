// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

table 18602 "Gate Entry Comment Line"
{
    Caption = 'Gate Entry Comment Line';
    DrillDownPageID = "Gate Entry Comment List";
    LookupPageID = "Gate Entry Comment List";

    fields
    {
        field(1; "Gate Entry Type"; Enum "Gate Entry Type")
        {
            Caption = 'Gate Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(5; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(6; Comment; Text[80])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Gate Entry Type", "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        GateEntryCommentLine: Record "Gate Entry Comment Line";

    procedure SetUpNewLine()
    begin
        GateEntryCommentLine.SetRange("Gate Entry Type", "Gate Entry Type");
        GateEntryCommentLine.SetRange("No.", "No.");
        GateEntryCommentLine.SetRange(Date, WorkDate());
        if not GateEntryCommentLine.FindFirst() then
            Date := WorkDate();
    end;
}
