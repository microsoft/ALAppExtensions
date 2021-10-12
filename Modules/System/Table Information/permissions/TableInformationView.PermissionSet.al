// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8701 "Table Information - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Table Information - Read";

    Permissions = tabledata "Table Information Cache" = imd,
                  tabledata "Company Size Cache" = imd;
}