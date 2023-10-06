// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Environment;
using System.Security.AccessControl;

permissionset 9016 "Azure AD Plan - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Plan - Objects",
                             "Azure AD User - View";

    Permissions = tabledata Company = r,
                  tabledata User = r,
                  tabledata "Access Control" = r;
}
