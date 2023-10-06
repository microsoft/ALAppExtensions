// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Utilities;

table 10683 "SAF-T Export Line"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Export Line';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            TableRelation = "SAF-T Export Header";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Task ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Task ID';
        }
        field(4; Progress; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Progress';
            ExtendedDatatype = Ratio;
        }
        field(5; Status; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            OptionMembers = "Not Started","In Progress",Failed,Completed;
            OptionCaption = 'Not Started,In Progress,Failed,Completed';
        }
        field(6; "Master Data"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Master Data';
        }
        field(7; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(8; "No. Of Retries"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No. Of Retries';
            InitValue = 3;
        }
        field(10; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';
        }
        field(11; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Date';
        }
        field(20; "SAF-T File"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T File';
        }
        field(30; "Server Instance ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Server Instance ID';
        }
        field(31; "Session ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Session ID';
        }
        field(32; "Created Date/Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date/Time';
        }
    }

    keys
    {
        key(PK; ID, "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", RecordId());
        ActivityLog.DeleteAll();
    end;
}
