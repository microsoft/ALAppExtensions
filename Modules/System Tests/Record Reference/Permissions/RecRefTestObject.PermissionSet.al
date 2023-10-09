// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Reflection;

using System.Utilities;

/// <summary>
/// This permissionset should only grant INDIRECT permissions to the test table
/// </summary>
permissionset 138710 "RecRefTest-Object"
{
    Assignable = false;
    Access = Internal;
    IncludedPermissionSets = "Record Link Management - View";

    Permissions = table "Record Reference Test" = X;
}