// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

table 1808 "Aggregated Assisted Setup"
{
    Access = Internal;
    Caption = 'Aggregated Assisted Setup';
    ObsoleteState = Removed;
    ObsoleteReason = 'Data available in Assisted Setup already- extensions also register in the same table.';
    ObsoleteTag = '19.0';
    ReplicateData = false;

    fields
    {
        field(1; "Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Page ID';
        }
        field(2; Name; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Name';
        }
        field(3; "Order"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Order';
        }
        field(4; Status; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Status';
            OptionCaption = 'Not Completed,Completed,Not Started,Seen,Watched,Read, ';
            OptionMembers = "Not Completed",Completed,"Not Started",Seen,Watched,Read," ";
        }
        field(5; Visible; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Visible';
        }
        field(8; Icon; Media)
        {
            DataClassification = SystemMetadata;
            Caption = 'Icon';
        }
        field(9; "Item Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Item Type';
            InitValue = "Setup and Help";
            OptionCaption = ' ,Group,Setup and Help';
            OptionMembers = " ",Group,"Setup and Help";
        }
        field(12; "Assisted Setup Page ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Assisted Setup Page ID';
        }
        field(17; "External Assisted Setup"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'External Assisted Setup';
        }
        field(18; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Page ID")
        {
            Clustered = true;
        }
        key(Key2; "External Assisted Setup")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Name, Status, Icon)
        {
        }
    }
}

