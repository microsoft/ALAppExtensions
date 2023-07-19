// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 132549 "Page Sum Admin Test"
{
    Assignable = true;

    IncludedPermissionSets = "Page Summary - Admin";

    // Include Test Tables
    Permissions = tabledata "Page Provider Summary Test" = RIMD,
                  tabledata "Page Provider Summary Test2" = RIMD;
}