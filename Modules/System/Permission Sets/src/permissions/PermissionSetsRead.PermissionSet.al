// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9863 "Permission Sets - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Permission Sets - Objects";

    Permissions = tabledata "Permission Lookup Buffer" = R;
}