// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1488 "Edit in Excel - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Tenant - Objects",
                             "Environment Info. - Objects";

    Permissions = Codeunit "Edit in Excel Impl." = X,
                  Codeunit "Edit in Excel" = X,
                  Page "Excel Centralized Depl. Wizard" = X,
                  Table "Edit in Excel Settings" = X;
}
