// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9864 "Permission Sets - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Permission Sets - Read";

    Permissions = tabledata "Permission Lookup Buffer" = IMD;
}