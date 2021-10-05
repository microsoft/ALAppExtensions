// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set is required to turn a feature on or off.
/// </summary>
PermissionSet 2611 "Feature Key - Admin"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Feature Key - View";

    Permissions = tabledata "Feature Key" = m;
}
