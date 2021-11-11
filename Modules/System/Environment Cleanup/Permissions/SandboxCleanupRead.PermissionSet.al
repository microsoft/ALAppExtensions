#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1884 "Sandbox Cleanup - Read"
{
    ObsoleteReason = 'Replaced by Environment Cleanup module.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
    Assignable = false;

    IncludedPermissionSets = "Sandbox Cleanup - Objects";

    Permissions = tabledata Company = r;
}
#endif