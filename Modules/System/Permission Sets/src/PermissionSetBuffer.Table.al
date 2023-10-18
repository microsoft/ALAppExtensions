// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Buffer table for a permission set.
/// </summary>
table 9862 "PermissionSet Buffer"
{
    Access = Internal;
    Caption = 'Permission Set Buffer';
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; Scope; Option)
        {
            Caption = 'Scope';
            DataClassification = SystemMetadata;
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
        field(2; "App ID"; Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Role ID"; Code[30])
        {
            Caption = 'Role ID';
            DataClassification = SystemMetadata;
        }
        field(4; Name; Text[30])
        {
            Caption = 'Name';
            CalcFormula = lookup("Aggregate Permission Set".Name where("Role ID" = field("Role ID")));
            FieldClass = FlowField;
        }
        field(5; "App Name"; Text[250])
        {
            Caption = 'App Name';
            DataClassification = SystemMetadata;
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'User-Defined,Extension,System';
            OptionMembers = "User-Defined",Extension,System;
        }
    }

    keys
    {
        key(Key1; Scope, "App ID", "Role ID")
        {
            Clustered = true;
        }

        key(Key2; Scope, "Role ID")
        {
        }
    }
}

