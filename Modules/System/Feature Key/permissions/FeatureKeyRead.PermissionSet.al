// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 2610 "Feature Key - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Feature Key - Objects",
                             "System Initialization - Exec";

    Permissions = tabledata "Active Session" = r,
                  tabledata Company = r,
                  tabledata "Feature Data Update Status" = R,
                  tabledata "Feature Key" = r,
                  tabledata "Session Event" = r,
                  tabledata "Scheduled Task" = r;
}
