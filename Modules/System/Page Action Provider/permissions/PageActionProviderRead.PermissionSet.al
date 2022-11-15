// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2916 "Page Action Provider - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Page Action Provider - Obj.";

    Permissions = tabledata "Page Action" = r,
                  tabledata "All Profile" = r,
                  tabledata "User Personalization" = r,
                  tabledata "Page Data Personalization" = R; // DotNet NavPageActionALFunctions requires this
}