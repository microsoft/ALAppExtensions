// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2300 "Tenant License State - Read"
{
    Assignable = false;

    IncludedPermissionSets = "Tenant License State - Objects",
                             "Telemetry - Exec";

    Permissions = tabledata "Tenant License State" = r;
}