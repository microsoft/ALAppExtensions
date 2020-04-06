// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1807 "Assisted Setup Log"
{
    Access = Internal;
    Caption = 'Assisted Setup Log';
    ReplicateData = false;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(3; "Entery No."; Integer)
        {
            Caption = 'Entery No.';
            TableRelation = "Assisted Setup"."Page ID";
        }
        field(10; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
        }
        field(11; "Invoked Action"; Option)
        {
            Caption = 'Invoked Action';
            OptionCaption = ' ,Video,Help,Tour,Assisted Setup';
            OptionMembers = " ",Video,Help,Tour,"Assisted Setup";
            ObsoleteState = Pending;
            ObsoleteReason = 'Only videos opened are logged.';
            ObsoleteTag = '16.0';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

