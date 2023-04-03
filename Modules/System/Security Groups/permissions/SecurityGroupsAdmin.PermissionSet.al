// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9022 "Security Groups - Admin"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Security Groups - Read";

    Permissions = tabledata "Security Group" = imd,
                  tabledata "Access Control" = imd,
                  tabledata User = md;
}
