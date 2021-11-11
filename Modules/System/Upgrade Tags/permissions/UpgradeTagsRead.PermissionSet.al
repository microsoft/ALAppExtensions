// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9992 "Upgrade Tags - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Upgrade Tags - Objects";

    Permissions = tabledata Company = r,
                  tabledata "Upgrade Tags" = r,
                  tabledata "Upgrade Tag Backup" = r,
                  tabledata "Intelligent Cloud" = r;
}
