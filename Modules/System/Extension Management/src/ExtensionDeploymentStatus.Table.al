// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>This temporary table is used to mirror the "NAV App Tenant Operation" system table and present details about the extension deployment status.///</summary>
table 2508 "Extension Deployment Status"
{
    Caption = 'Extension Deployment Status';
    TableType = Temporary;
    Extensible = false;

    fields
    {
        field(1; "Operation ID"; Guid)
        {
            Caption = 'Operation ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Started On"; DateTime)
        {
            Caption = 'Started On';
            DataClassification = SystemMetadata;
        }
        field(3; "Operation Type"; Option)
        {
            Caption = 'Operation Type';
            OptionCaption = 'DeployTarget,DeployPackage';
            OptionMembers = DeployTarget,DeployPackage;
            DataClassification = SystemMetadata;
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Unknown,InProgress,Failed,Completed,NotFound';
            OptionMembers = Unknown,InProgress,Failed,Completed,NotFound;
            DataClassification = SystemMetadata;
        }
        field(5; Details; BLOB)
        {
            Caption = 'Details';
            DataClassification = SystemMetadata;
        }
        field(9; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Operation ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}