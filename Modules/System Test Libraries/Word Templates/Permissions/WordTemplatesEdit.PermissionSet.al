// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 130443 "Word Templates Edit"
{
    Assignable = true;

    IncludedPermissionSets = "Word Templates - Edit";

    // Include Test Tables
    Permissions = tabledata "Word Templates Test Table" = RIMD,
                  tabledata "Word Templates Test Table 2" = RIMD,
                  tabledata "Word Templates Test Table 3" = RIMD,
                  tabledata "Word Templates Test Table 4" = RIMD,
                  tabledata "Word Templates Test Table 5" = RIMD;
}