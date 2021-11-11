// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 458 "Azure AD Licensing - Exec"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Licensing - Objects",
                             "Azure AD Plan - View";
}