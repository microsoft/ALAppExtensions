// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1432 "Satisfaction Survey - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Satisfaction Survey - Objects",
                             "Upgrade Tags - Read";

    Permissions = tabledata "Add-in" = r,
                  tabledata "Net Promoter Score" = r,
                  tabledata "Net Promoter Score Setup" = r,
                  tabledata "User Property" = r;
}
