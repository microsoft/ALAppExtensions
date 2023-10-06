// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System.Reflection;

table 1992 "Checklist Item Role"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Checklist Item Role';
    Permissions = tabledata "All Profile" = r;

    fields
    {
        field(1; Code; Code[300])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            TableRelation = "Checklist Item".Code;
        }
        field(2; "Role ID"; Code[30])
        {
            Caption = 'Role ID';
            DataClassification = SystemMetadata;
            TableRelation = "All Profile"."Profile ID";

            trigger OnValidate()
            var
                AllProfile: Record "All Profile";
            begin
                if "Role ID" = '' then
                    Error(InvalidRoleErr);

                AllProfile.SetRange("Profile ID", "Role ID");
                if AllProfile.IsEmpty() then
                    Error(InvalidRoleErr);
            end;
        }
    }

    keys
    {
        key(Key1; Code, "Role ID")
        {
            Clustered = true;
        }
    }

    var
        InvalidRoleErr: Label 'Please provide a valid role';
}