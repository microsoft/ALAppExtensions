// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Security.AccessControl;

permissionset 9024 "Azure AD User - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Azure AD User - Read";

    Permissions = tabledata User = m;
}