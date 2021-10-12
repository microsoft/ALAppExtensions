// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 132508 "Record Link View"
{
    Assignable = true;
    IncludedPermissionSets = "Record Link Management - View";

    // Include Test Tables
    Permissions = tabledata "Record Link Record Test" = RIMD;
}