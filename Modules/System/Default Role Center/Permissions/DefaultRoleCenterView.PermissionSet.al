// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9172 "Default Role Center - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Default Role Center - Read";

    Permissions = tabledata "All Profile" = m;
}