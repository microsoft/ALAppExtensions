// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Reflection;

/// <summary>
/// This permissionset should only grant INDIRECT permissions
/// </summary>
permissionset 138706 "RecRefTest-Read"
{
    Assignable = true;
    Access = Internal;
    IncludedPermissionSets = "RecRefTest-Object";

    Permissions = tabledata "Record Reference Test" = r;
}