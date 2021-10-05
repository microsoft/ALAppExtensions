// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9993 "Upgrade Tags - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Upgrade Tags - Read";

    Permissions = tabledata "Upgrade Tags" = imd,
                  tabledata "Upgrade Tag Backup" = imd;
}
