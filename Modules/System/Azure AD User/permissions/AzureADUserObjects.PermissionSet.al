// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9071 "Azure AD User - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Graph - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "Azure AD Graph User Impl." = X,
                  Codeunit "Azure AD Graph User" = X;
}
