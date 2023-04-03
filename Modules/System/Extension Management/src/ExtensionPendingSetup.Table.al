// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>This table is used to store information about extensions that was installed but did not run the setup.</summary>
table 2509 "Extension Pending Setup"
{
    Caption = 'Extension Pending Setup';
    Extensible = false;
    ReplicateData = false;
    InherentEntitlements = rX;
    InherentPermissions = rX;

    fields
    {
        field(1; "User Id"; Guid)
        {
            Caption = 'User Id';
            DataClassification = SystemMetadata;
        }
        field(2; "App Id"; Guid)
        {
            Caption = 'App Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "User Id")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}