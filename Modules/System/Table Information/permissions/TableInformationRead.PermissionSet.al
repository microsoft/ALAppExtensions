// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8700 "Table Information - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Table Information - Objects";

    Permissions = tabledata "Table Information" = r,
                  tabledata "Table Information Cache" = r,
                  tabledata "Company Size Cache" = r;
}