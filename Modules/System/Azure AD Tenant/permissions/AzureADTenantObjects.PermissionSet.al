// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 433 "Azure AD Tenant - Objects"
{
    Assignable = false;

    IncludedPermissionSets = "Azure AD Graph - Objects";

    Permissions = Codeunit "Azure AD Tenant Impl." = X,
                  Codeunit "Azure AD Tenant" = X;
}
