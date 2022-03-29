// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
            Caption = 'Page ID';
        }
        field(2; Name; Text[250])
        {
            Caption = 'Name';
        }
        field(3; "Order"; Integer)
        {
            Caption = 'Order';
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Not Completed,Completed,Not Started,Seen,Watched,Read, ';
            OptionMembers = "Not Completed",Completed,"Not Started",Seen,Watched,Read," ";
        }
        field(5; Visible; Boolean)
        {
            Caption = 'Visible';
        }
        field(8; Icon; Media)
        {
            Caption = 'Icon';
        }
        field(9; "Item Type"; Option)
        {
            Caption = 'Item Type';
            InitValue = "Setup and Help";
            OptionCaption = ' ,Group,Setup and Help';
            OptionMembers = " ",Group,"Setup and Help";
        }
        field(12; "Assisted Setup Page ID"; Integer)
        {
            Caption = 'Assisted Setup Page ID';
        }
        field(17; "External Assisted Setup"; Boolean)
        {
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

