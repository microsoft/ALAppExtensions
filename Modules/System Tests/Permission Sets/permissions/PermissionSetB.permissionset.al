// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 132437 "Permission Set B"
{
    Assignable = true;
    IncludedPermissionSets = "Permission Set A";
    Permissions = tabledata "Tenant Permission" = RIMD;
}