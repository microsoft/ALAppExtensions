// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 459 "Record Link Management - View"
{
    Assignable = false;
    IncludedPermissionSets = "Record Link Management - Read";

    Permissions = tabledata "Record Link" = imd;
}