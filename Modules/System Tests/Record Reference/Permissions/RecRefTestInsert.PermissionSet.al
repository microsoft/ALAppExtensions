// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permissionset should only grant INDIRECT permissions
/// </summary>
permissionset 138707 "RecRefTest-Insert"
{
    Assignable = false;
    Access = Internal;
    IncludedPermissionSets = "RecRefTest-Object";

    Permissions = tabledata "Record Reference Test" = i;
}