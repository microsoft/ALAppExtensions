// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1887 "Environment Cleanup - Read"
{
    Assignable = false;

    IncludedPermissionSets = "Environment Cleanup - Objects";

    Permissions = tabledata Company = r;
}