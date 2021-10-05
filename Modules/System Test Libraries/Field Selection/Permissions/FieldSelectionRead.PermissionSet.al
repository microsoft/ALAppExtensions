// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 135036 "Field Selection Read"
{
    Assignable = true;

    IncludedPermissionSets = "Field Selection - Read";

    // Include Test Tables
    Permissions = tabledata "Test Table A" = RIMD,
                  tabledata "Test Table B" = RIMD;
}