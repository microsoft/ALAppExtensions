// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9011 "Azure AD User - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD User - Objects",
                             "Language - Read";

    Permissions = tabledata User = r,
                  tabledata "User Property" = r;
}