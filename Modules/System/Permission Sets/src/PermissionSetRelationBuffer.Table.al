// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Buffer table for permission set relations.
/// </summary>
table 9861 "Permission Set Relation Buffer"
{
    Access = Internal;
    Caption = 'Permission Set Relation Buffer';
    TableType = Temporary;

    fields
    {
        field(1; "App ID"; Guid)
        {
            Caption = 'App ID';
            TableRelation = if ("Related Scope" = CONST(System)) "Tenant Permission Set"."App ID" else
            "Tenant Permission Set"."App ID";
        }
        field(2; "Role ID"; Code[30])
        {
            Caption = 'Role ID';
            TableRelation = if ("Related Scope" = CONST(System)) "Metadata Permission Set"."Role ID" else
            "Tenant Permission Set"."Role ID";
        }
        field(3; "Related App ID"; Guid)
        {
            Caption = 'Related App ID';
            TableRelation = if ("Related Scope" = CONST(System))
            "Metadata Permission Set"."App ID" WHERE("Role ID" = FIELD("Related Role ID"))
            else
            "Tenant Permission Set"."App ID" WHERE("Role ID" = FIELD("Related Role ID"));
        }
        field(4; "Related Role ID"; Code[30])
        {
            Caption = 'Related Role ID';
            TableRelation = if ("Related Scope" = CONST(System)) "Metadata Permission Set"."Role ID" else
            "Tenant Permission Set"."Role ID";
        }
        field(5; "Related Role ID As Text"; Text[100])
        {
            Caption = 'Role ID';
        }
        field(6; "Related Scope"; Option)
        {
            Caption = 'Related Scope';
            OptionMembers = System,Tenant;
            OptionCaption = 'System,Tenant';
        }
        field(7; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Include,Exclude;
            OptionCaption = 'Include,Exclude';
            InitValue = Include;
        }
        field(8; Indent; Integer)
        {
            Caption = 'Indentation';
        }
        field(9; Position; Integer)
        {
            Caption = 'Position';
        }
        field(10; Status; Option)
        {
            OptionMembers = Included,PartiallyIncluded,Excluded;
            OptionCaption = 'Full,Partial,Excluded';
            Caption = 'Position';
        }
        field(11; Editable; Boolean)
        {
            Caption = 'Position';
            InitValue = true;
        }
        field(12; "Inclusion Status"; Text[50])
        {
            Caption = 'Included';
        }
    }

    keys
    {
        key(Key1; "App ID", "Role ID", "Related App ID", "Related Role ID", Position)
        {
            Clustered = true;
        }

        key(Key2; Type, "Related Role ID")
        {
        }
    }

    fieldgroups
    {
    }
}

