// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 153 "User Permissions - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "User Permissions - Read";

    Permissions = tabledata "Access Control" = d;
}