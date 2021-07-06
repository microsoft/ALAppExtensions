// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set is required in order to view the status of a feature Key and get the status of the data upgrade
/// </summary>
PermissionSet 2612 "Feature Key - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Feature Key - Read",
                             "System Initialization - Exec";

    Permissions = tabledata "Feature Data Update Status" = imd;
}
