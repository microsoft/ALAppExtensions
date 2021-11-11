// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 239 "Azure AD Licensing - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Graph - Objects";

    Permissions = Codeunit "Azure AD Licensing Impl." = X,
                  Codeunit "Azure AD Licensing" = X;
}
