// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 135038 "Video Read"
{
    Assignable = true;

    IncludedPermissionSets = "Video - Read";

    // Add Test Tables
    Permissions = tabledata "My Video Source" = RIMD;
}
