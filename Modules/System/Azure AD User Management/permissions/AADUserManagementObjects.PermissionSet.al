// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9010 "AAD User Management - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Graph - Objects",
                             "Client Type Mgt. - Objects",
                             "Confirm Management - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "Azure AD User Management" = X,
                  Codeunit "Azure AD User Mgmt. Impl." = X,
                  Page "Azure AD User Update Wizard" = X,
                  Table "Azure AD User Update Buffer" = X;
}
