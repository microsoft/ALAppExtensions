// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.User;

using System.Security.AccessControl;

permissionset 152 "User Permissions - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "User Permissions - Objects";

    Permissions = tabledata "Access Control" = r,
                  tabledata User = r;
}