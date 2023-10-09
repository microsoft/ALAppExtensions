// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Security.AccessControl;

permissionset 9011 "Azure AD User - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata User = r,
                  tabledata "User Property" = r;
}