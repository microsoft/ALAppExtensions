// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9012 "Azure AD Graph - Objects"
{
    Assignable = false;

    IncludedPermissionSets = "Environment Info. - Objects";

    Permissions = Codeunit "Azure AD Graph Impl." = X,
                  Codeunit "Azure AD Graph" = X;
}
